#!/usr/bin/env node

/**
 * Rollback Handler for FlowForge v2.0 Migration
 * Issue #244 - Safe rollback with data integrity
 * 
 * Provides complete rollback capabilities with verification
 */

const fs = require('fs').promises;
const fsSync = require('fs');
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');
const crypto = require('crypto');

const { logger } = require('../utils/logger.js');
const execAsync = promisify(exec);

class RollbackHandler {
  constructor(projectRoot) {
    this.projectRoot = projectRoot || process.cwd();
    this.flowforgeDir = path.join(this.projectRoot, '.flowforge');
    this.backupsDir = path.join(this.flowforgeDir, 'backups');
    this.rollbackLog = [];
  }

  /**
   * Find available backups
   */
  async findBackups() {
    try {
      const backups = [];
      const entries = await fs.readdir(this.backupsDir);
      
      for (const entry of entries) {
        if (entry.startsWith('migration-')) {
          const backupPath = path.join(this.backupsDir, entry);
          const stat = await fs.stat(backupPath);
          
          if (stat.isDirectory()) {
            // Read rollback info
            const infoPath = path.join(backupPath, 'rollback-info.json');
            
            try {
              const info = await fs.readFile(infoPath, 'utf-8');
              const metadata = JSON.parse(info);
              
              backups.push({
                id: entry,
                path: backupPath,
                timestamp: metadata.backup_time,
                expires: metadata.expires_at,
                version: metadata.migration_version,
                files: metadata.files_backed_up || [],
                checksum: metadata.checksum,
                size: await this.getBackupSize(backupPath)
              });
            } catch (e) {
              logger.warn(`Invalid backup metadata for ${entry}`);
            }
          }
        }
      }
      
      // Sort by timestamp (newest first)
      backups.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
      
      return backups;
    } catch (error) {
      if (error.code === 'ENOENT') {
        return [];
      }
      throw error;
    }
  }

  /**
   * Get backup size
   */
  async getBackupSize(backupPath) {
    try {
      const { stdout } = await execAsync(`du -sh "${backupPath}" | cut -f1`);
      return stdout.trim();
    } catch {
      return 'unknown';
    }
  }

  /**
   * Verify backup integrity
   */
  async verifyBackup(backupPath) {
    logger.info('🔍 Verifying backup integrity...');
    
    const verification = {
      valid: true,
      errors: [],
      warnings: []
    };
    
    // Check rollback info exists
    const infoPath = path.join(backupPath, 'rollback-info.json');
    if (!(await this.fileExists(infoPath))) {
      verification.valid = false;
      verification.errors.push('Missing rollback-info.json');
      return verification;
    }
    
    // Read metadata
    const info = JSON.parse(await fs.readFile(infoPath, 'utf-8'));
    
    // Check expiration
    if (new Date(info.expires_at) < new Date()) {
      verification.warnings.push('Backup has expired but can still be used');
    }
    
    // Verify checksums if available
    if (info.checksums) {
      for (const [file, expectedChecksum] of Object.entries(info.checksums)) {
        const filePath = path.join(backupPath, path.basename(file));
        
        if (await this.fileExists(filePath)) {
          const actualChecksum = await this.calculateFileChecksum(filePath);
          
          if (actualChecksum !== expectedChecksum) {
            verification.valid = false;
            verification.errors.push(`Checksum mismatch for ${file}`);
          }
        }
      }
    }
    
    // Check critical files exist
    const criticalFiles = ['SESSIONS.md', 'TASKS.md'];
    for (const file of criticalFiles) {
      const filePath = path.join(backupPath, file);
      
      if (!(await this.fileExists(filePath))) {
        verification.warnings.push(`Missing ${file} in backup`);
      }
    }
    
    // Check tar archive if exists
    const tarPath = path.join(backupPath, 'flowforge-pre-migration.tar.gz');
    if (await this.fileExists(tarPath)) {
      try {
        await execAsync(`tar -tzf "${tarPath}" > /dev/null 2>&1`);
      } catch {
        verification.valid = false;
        verification.errors.push('Corrupted tar archive');
      }
    }
    
    if (verification.valid) {
      logger.info('✅ Backup verification passed');
    } else {
      logger.info('❌ Backup verification failed');
      logger.info('Errors:', { context: verification.errors });
    }
    
    return verification;
  }

  /**
   * Perform rollback
   */
  async performRollback(backupId, options = {}) {
    logger.info(`\n🔄 Starting rollback from backup: ${backupId}`);
    
    const backupPath = path.join(this.backupsDir, backupId);
    
    // Verify backup first
    const verification = await this.verifyBackup(backupPath);
    
    if (!verification.valid && !options.force) {
      throw new Error('Backup verification failed. Use --force to override.');
    }
    
    if (verification.warnings.length > 0) {
      logger.info('⚠️  Warnings:', { context: verification.warnings });
    }
    
    // Create rollback checkpoint
    await this.createRollbackCheckpoint();
    
    try {
      // Step 1: Restore MD files
      await this.restoreMDFiles(backupPath);
      
      // Step 2: Restore .flowforge directory if backed up
      await this.restoreFlowforgeDirectory(backupPath);
      
      // Step 3: Clean up migration artifacts
      await this.cleanupMigrationArtifacts();
      
      // Step 4: Verify rollback
      await this.verifyRollback(backupPath);
      
      // Log success
      this.rollbackLog.push({
        action: 'rollback_complete',
        timestamp: new Date().toISOString(),
        backupId
      });
      
      await this.saveRollbackLog();
      
      logger.info('✅ Rollback completed successfully!');
      
      return {
        success: true,
        log: this.rollbackLog
      };
      
    } catch (error) {
      logger.error('❌ Rollback failed:', { context: error.message });
      
      // Attempt to restore from checkpoint
      if (!options.noCheckpoint) {
        logger.info('Attempting to restore from rollback checkpoint...');
        await this.restoreFromCheckpoint();
      }
      
      throw error;
    }
  }

  /**
   * Create rollback checkpoint
   */
  async createRollbackCheckpoint() {
    const checkpointDir = path.join(this.flowforgeDir, '.rollback-checkpoint');
    
    logger.info('📸 Creating rollback checkpoint...');
    
    // Remove old checkpoint
    await fs.rm(checkpointDir, { recursive: true, force: true });
    
    // Create new checkpoint
    await fs.mkdir(checkpointDir, { recursive: true });
    
    // Copy current state
    if (await this.directoryExists(path.join(this.flowforgeDir, 'user'))) {
      await execAsync(`cp -r "${this.flowforgeDir}/user" "${checkpointDir}/"`);
    }
    
    if (await this.fileExists(path.join(this.flowforgeDir, 'tasks.json'))) {
      await fs.copyFile(
        path.join(this.flowforgeDir, 'tasks.json'),
        path.join(checkpointDir, 'tasks.json')
      );
    }
    
    this.rollbackLog.push({
      action: 'checkpoint_created',
      timestamp: new Date().toISOString(),
      path: checkpointDir
    });
  }

  /**
   * Restore MD files from backup
   */
  async restoreMDFiles(backupPath) {
    logger.info('📄 Restoring MD files...');
    
    const mdFiles = [
      'SESSIONS.md',
      'TASKS.md',
      'SCHEDULE.md'
    ];
    
    for (const file of mdFiles) {
      const backupFile = path.join(backupPath, file);
      
      if (await this.fileExists(backupFile)) {
        // Determine target path
        let targetPath = path.join(this.projectRoot, file);
        
        // Special case for SESSIONS.md
        if (file === 'SESSIONS.md') {
          // Check if it should go to documentation/development/
          const docPath = path.join(this.projectRoot, 'documentation/development');
          if (await this.directoryExists(docPath)) {
            targetPath = path.join(docPath, file);
          }
        }
        
        // Copy file
        await fs.copyFile(backupFile, targetPath);
        logger.info(`  ✓ Restored ${file}`);
        
        this.rollbackLog.push({
          action: 'file_restored',
          file,
          from: backupFile,
          to: targetPath
        });
      }
    }
    
    // Restore NEXT_SESSION.md if exists
    const nextSessionBackup = path.join(backupPath, 'NEXT_SESSION.md');
    if (await this.fileExists(nextSessionBackup)) {
      const targetPath = path.join(
        this.projectRoot,
        'documentation/development/NEXT_SESSION.md'
      );
      
      await fs.mkdir(path.dirname(targetPath), { recursive: true });
      await fs.copyFile(nextSessionBackup, targetPath);
      logger.info('  ✓ Restored NEXT_SESSION.md');
    }
  }

  /**
   * Restore .flowforge directory from backup
   */
  async restoreFlowforgeDirectory(backupPath) {
    const tarPath = path.join(backupPath, 'flowforge-pre-migration.tar.gz');
    
    if (await this.fileExists(tarPath)) {
      logger.info('📦 Restoring .flowforge directory from archive...');
      
      // Remove current .flowforge directory
      await fs.rm(this.flowforgeDir, { recursive: true, force: true });
      
      // Extract backup
      await execAsync(
        `tar -xzf "${tarPath}" -C "${this.projectRoot}"`
      );
      
      logger.info('  ✓ Restored .flowforge directory');
      
      this.rollbackLog.push({
        action: 'directory_restored',
        from: tarPath,
        to: this.flowforgeDir
      });
    } else {
      logger.info('⚠️  No .flowforge backup found, { context: keeping current' });
    }
  }

  /**
   * Clean up migration artifacts
   */
  async cleanupMigrationArtifacts() {
    logger.info('🧹 Cleaning up migration artifacts...');
    
    const artifacts = [
      path.join(this.flowforgeDir, '.migration-checkpoint'),
      path.join(this.flowforgeDir, '.migration-lock'),
      path.join(this.flowforgeDir, 'migration.log'),
      path.join(this.flowforgeDir, 'migration-audit-*.md')
    ];
    
    for (const artifact of artifacts) {
      if (artifact.includes('*')) {
        // Handle glob patterns
        const dir = path.dirname(artifact);
        const pattern = path.basename(artifact);
        
        if (await this.directoryExists(dir)) {
          const files = await fs.readdir(dir);
          
          for (const file of files) {
            if (file.match(pattern.replace('*', '.*'))) {
              await fs.rm(path.join(dir, file), { force: true });
              logger.info(`  ✓ Removed ${file}`);
            }
          }
        }
      } else {
        await fs.rm(artifact, { recursive: true, force: true });
        
        if (await this.fileExists(artifact)) {
          logger.info(`  ✓ Removed ${path.basename(artifact)}`);
        }
      }
    }
  }

  /**
   * Verify rollback success
   */
  async verifyRollback(backupPath) {
    logger.info('🔍 Verifying rollback...');
    
    const checks = {
      mdFilesRestored: true,
      jsonFilesRemoved: true,
      userDirsRemoved: true
    };
    
    // Check MD files exist
    const mdFiles = ['SESSIONS.md', 'TASKS.md'];
    for (const file of mdFiles) {
      const possiblePaths = [
        path.join(this.projectRoot, file),
        path.join(this.projectRoot, 'documentation/development', file)
      ];
      
      let found = false;
      for (const p of possiblePaths) {
        if (await this.fileExists(p)) {
          found = true;
          break;
        }
      }
      
      if (!found) {
        checks.mdFilesRestored = false;
        logger.info(`  ✗ ${file} not restored`);
      }
    }
    
    // Check migration JSON files removed
    const userDir = path.join(this.flowforgeDir, 'user');
    if (await this.directoryExists(userDir)) {
      const users = await fs.readdir(userDir);
      if (users.length > 0) {
        checks.userDirsRemoved = false;
        logger.info(`  ⚠️  User directories still exist`);
      }
    }
    
    if (Object.values(checks).every(v => v)) {
      logger.info('✅ Rollback verification passed');
    } else {
      logger.info('⚠️  Rollback verification has warnings');
    }
    
    return checks;
  }

  /**
   * Restore from checkpoint if rollback fails
   */
  async restoreFromCheckpoint() {
    const checkpointDir = path.join(this.flowforgeDir, '.rollback-checkpoint');
    
    if (await this.directoryExists(checkpointDir)) {
      logger.info('🔄 Restoring from checkpoint...');
      
      // Restore user directories
      const userCheckpoint = path.join(checkpointDir, 'user');
      if (await this.directoryExists(userCheckpoint)) {
        await execAsync(`cp -r "${userCheckpoint}" "${this.flowforgeDir}/"`);
      }
      
      // Restore tasks.json
      const tasksCheckpoint = path.join(checkpointDir, 'tasks.json');
      if (await this.fileExists(tasksCheckpoint)) {
        await fs.copyFile(
          tasksCheckpoint,
          path.join(this.flowforgeDir, 'tasks.json')
        );
      }
      
      logger.info('✅ Restored from checkpoint');
    }
  }

  /**
   * Save rollback log
   */
  async saveRollbackLog() {
    const logPath = path.join(this.flowforgeDir, 'rollback.log');
    
    await fs.writeFile(
      logPath,
      JSON.stringify(this.rollbackLog, null, 2)
    );
  }

  /**
   * Calculate file checksum
   */
  async calculateFileChecksum(filePath) {
    const content = await fs.readFile(filePath);
    return crypto
      .createHash('sha256')
      .update(content)
      .digest('hex');
  }

  /**
   * Helper: Check if file exists
   */
  async fileExists(filePath) {
    try {
      await fs.access(filePath);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Helper: Check if directory exists
   */
  async directoryExists(dirPath) {
    try {
      const stat = await fs.stat(dirPath);
      return stat.isDirectory();
    } catch {
      return false;
    }
  }
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0];
  const projectRoot = process.cwd();
  
  const handler = new RollbackHandler(projectRoot);
  
  (async () => {
    try {
      switch (command) {
        case 'list':
          const backups = await handler.findBackups();
          
          if (backups.length === 0) {
            logger.info('No backups found');
          } else {
            logger.info('Available backups:');
            logger.info('');
            
            for (const backup of backups) {
              logger.info(`ID: ${backup.id}`);
              logger.info(`  Created: ${backup.timestamp}`);
              logger.info(`  Expires: ${backup.expires}`);
              logger.info(`  Size: ${backup.size}`);
              logger.info(`  Version: ${backup.version}`);
              logger.info('');
            }
          }
          break;
          
        case 'rollback':
          const backupId = args[1];
          
          if (!backupId) {
            // Use most recent backup
            const backups = await handler.findBackups();
            
            if (backups.length === 0) {
              logger.error('No backups available');
              process.exit(1);
            }
            
            await handler.performRollback(backups[0].id);
          } else {
            await handler.performRollback(backupId);
          }
          break;
          
        case 'verify':
          const verifyId = args[1];
          
          if (!verifyId) {
            logger.error('Backup ID required');
            process.exit(1);
          }
          
          const backupPath = path.join(handler.backupsDir, verifyId);
          const result = await handler.verifyBackup(backupPath);
          
          logger.info(JSON.stringify(result, { data: [null, 2] }));
          break;
          
        default:
          logger.info('Usage: rollback.js <command> [options]');
          logger.info('Commands:');
          logger.info('  list              - List available backups');
          logger.info('  rollback [id]     - Perform rollback');
          logger.info('  verify <id>       - Verify backup integrity');
          process.exit(1);
      }
    } catch (error) {
      logger.error('Error:', { context: error.message });
      process.exit(1);
    }
  })();
}

module.exports = RollbackHandler;