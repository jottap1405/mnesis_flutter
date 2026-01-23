#!/usr/bin/env node

/**
 * Migration Validator for FlowForge v2.0
 * Issue #244 - Ensures 100% billing accuracy
 * 
 * Critical requirement: Zero tolerance for time loss
 */

const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

const { logger } = require('../utils/logger.js');
class MigrationValidator {
  constructor(projectRoot) {
    this.projectRoot = projectRoot || process.cwd();
    this.flowforgeDir = path.join(this.projectRoot, '.flowforge');
    this.errors = [];
    this.warnings = [];
    this.validationResults = {
      passed: false,
      checks: {},
      summary: {}
    };
  }

  /**
   * Calculate checksum for data integrity
   */
  calculateChecksum(data) {
    return crypto
      .createHash('sha256')
      .update(JSON.stringify(data))
      .digest('hex');
  }

  /**
   * Validate billing accuracy - CRITICAL
   * Must be 100% accurate, zero tolerance for discrepancies
   */
  async validateBillingAccuracy(originalData, migratedData) {
    logger.info('🔍 Validating billing accuracy (100% required)...');
    
    const validation = {
      originalTotal: originalData.totalMinutes || 0,
      migratedTotal: 0,
      userTotals: {},
      taskTotals: {},
      discrepancies: []
    };
    
    // Calculate migrated totals from user directories
    try {
      const userDirs = await fs.readdir(path.join(this.flowforgeDir, 'user'));
      
      for (const username of userDirs) {
        const timeTrackingPath = path.join(
          this.flowforgeDir,
          'user',
          username,
          'time-tracking.json'
        );
        
        const data = await fs.readFile(timeTrackingPath, 'utf-8');
        const timeTracking = JSON.parse(data);
        
        validation.userTotals[username] = timeTracking.total_minutes;
        validation.migratedTotal += timeTracking.total_minutes;
        
        // Validate individual sessions sum
        let sessionSum = 0;
        for (const session of timeTracking.sessions) {
          sessionSum += session.duration;
          
          // Track task totals
          if (!validation.taskTotals[session.taskId]) {
            validation.taskTotals[session.taskId] = 0;
          }
          validation.taskTotals[session.taskId] += session.duration;
        }
        
        // Check session sum matches total
        if (sessionSum !== timeTracking.total_minutes) {
          validation.discrepancies.push({
            type: 'session_sum_mismatch',
            user: username,
            expected: timeTracking.total_minutes,
            actual: sessionSum,
            difference: timeTracking.total_minutes - sessionSum
          });
        }
      }
    } catch (error) {
      this.errors.push(`Failed to validate user data: ${error.message}`);
      return false;
    }
    
    // Compare totals - CRITICAL CHECK
    const totalMatch = validation.originalTotal === validation.migratedTotal;
    
    if (!totalMatch) {
      validation.discrepancies.push({
        type: 'total_time_mismatch',
        severity: 'CRITICAL',
        original: validation.originalTotal,
        migrated: validation.migratedTotal,
        difference: validation.originalTotal - validation.migratedTotal,
        percentage: ((Math.abs(validation.originalTotal - validation.migratedTotal) / validation.originalTotal) * 100).toFixed(2)
      });
      
      this.errors.push(
        `CRITICAL: Total time mismatch - Original: ${validation.originalTotal} min, Migrated: ${validation.migratedTotal} min`
      );
    }
    
    // Compare user totals
    if (originalData.byUser) {
      for (const [user, originalMinutes] of Object.entries(originalData.byUser)) {
        const migratedMinutes = validation.userTotals[user] || 0;
        
        if (originalMinutes !== migratedMinutes) {
          validation.discrepancies.push({
            type: 'user_time_mismatch',
            user,
            original: originalMinutes,
            migrated: migratedMinutes,
            difference: originalMinutes - migratedMinutes
          });
        }
      }
    }
    
    // Compare task totals
    if (originalData.byTask) {
      for (const [taskId, originalMinutes] of Object.entries(originalData.byTask)) {
        const migratedMinutes = validation.taskTotals[taskId] || 0;
        
        if (originalMinutes !== migratedMinutes) {
          validation.discrepancies.push({
            type: 'task_time_mismatch',
            taskId,
            original: originalMinutes,
            migrated: migratedMinutes,
            difference: originalMinutes - migratedMinutes
          });
        }
      }
    }
    
    // Set validation result
    validation.passed = validation.discrepancies.length === 0;
    validation.accuracy = totalMatch ? 100 : 
      (100 - Math.abs(validation.originalTotal - validation.migratedTotal) / validation.originalTotal * 100).toFixed(2);
    
    this.validationResults.checks.billing = validation;
    
    if (validation.passed) {
      logger.info('✅ Billing validation PASSED - 100% accuracy confirmed');
    } else {
      logger.info(`❌ Billing validation FAILED - ${validation.accuracy}% accuracy`);
      logger.info('Discrepancies found:', { context: validation.discrepancies });
    }
    
    return validation.passed;
  }

  /**
   * Validate session integrity
   */
  async validateSessions(originalSessions) {
    logger.info('🔍 Validating session integrity...');
    
    const validation = {
      originalCount: originalSessions.length,
      migratedCount: 0,
      missingIds: [],
      duplicateIds: [],
      corruptedSessions: []
    };
    
    const sessionIds = new Set();
    const sessionsDir = path.join(this.flowforgeDir, 'sessions');
    
    try {
      // Check global sessions directory
      if (await this.directoryExists(sessionsDir)) {
        const files = await fs.readdir(sessionsDir);
        
        for (const file of files) {
          if (file.endsWith('.json')) {
            validation.migratedCount++;
            
            try {
              const sessionData = await fs.readFile(
                path.join(sessionsDir, file),
                'utf-8'
              );
              const session = JSON.parse(sessionData);
              
              // Check for duplicates
              if (sessionIds.has(session.id)) {
                validation.duplicateIds.push(session.id);
              }
              sessionIds.add(session.id);
              
              // Validate session structure
              if (!this.validateSessionStructure(session)) {
                validation.corruptedSessions.push(session.id);
              }
            } catch (e) {
              validation.corruptedSessions.push(file);
            }
          }
        }
      }
      
      // Also check user-specific sessions
      const userDirs = await fs.readdir(path.join(this.flowforgeDir, 'user'));
      
      for (const username of userDirs) {
        const userSessionsDir = path.join(this.flowforgeDir, 'user', username, 'sessions');
        
        if (await this.directoryExists(userSessionsDir)) {
          const files = await fs.readdir(userSessionsDir);
          validation.migratedCount += files.filter(f => f.endsWith('.json')).length;
        }
      }
    } catch (error) {
      this.errors.push(`Failed to validate sessions: ${error.message}`);
      return false;
    }
    
    // Check for missing sessions
    for (const originalSession of originalSessions) {
      if (!sessionIds.has(originalSession.id)) {
        validation.missingIds.push(originalSession.id);
      }
    }
    
    validation.passed = 
      validation.originalCount === validation.migratedCount &&
      validation.missingIds.length === 0 &&
      validation.duplicateIds.length === 0 &&
      validation.corruptedSessions.length === 0;
    
    this.validationResults.checks.sessions = validation;
    
    if (validation.passed) {
      logger.info(`✅ Session validation PASSED - ${validation.migratedCount} sessions`);
    } else {
      logger.info(`❌ Session validation FAILED`);
      if (validation.missingIds.length > 0) {
        logger.info('Missing sessions:', { context: validation.missingIds });
      }
      if (validation.duplicateIds.length > 0) {
        logger.info('Duplicate sessions:', { context: validation.duplicateIds });
      }
    }
    
    return validation.passed;
  }

  /**
   * Validate session structure
   */
  validateSessionStructure(session) {
    const requiredFields = ['id', 'taskId', 'user', 'duration', 'timestamp'];
    
    for (const field of requiredFields) {
      if (!(field in session)) {
        return false;
      }
    }
    
    // Validate data types
    if (typeof session.duration !== 'number' || session.duration < 0) {
      return false;
    }
    
    if (typeof session.taskId !== 'number' || session.taskId < 0) {
      return false;
    }
    
    return true;
  }

  /**
   * Validate user data isolation
   */
  async validateUserIsolation(users) {
    logger.info('🔍 Validating user data isolation...');
    
    const validation = {
      expectedUsers: users.length,
      foundUsers: 0,
      missingUsers: [],
      privacyViolations: [],
      permissionErrors: []
    };
    
    for (const username of users) {
      const userDir = path.join(this.flowforgeDir, 'user', username);
      
      // Check directory exists
      if (!(await this.directoryExists(userDir))) {
        validation.missingUsers.push(username);
        continue;
      }
      
      validation.foundUsers++;
      
      // Check permissions (should be 700)
      try {
        const stat = await fs.stat(userDir);
        const mode = (stat.mode & parseInt('777', 8)).toString(8);
        
        if (mode !== '700') {
          validation.permissionErrors.push({
            user: username,
            expected: '700',
            actual: mode
          });
        }
      } catch (e) {
        validation.permissionErrors.push({
          user: username,
          error: e.message
        });
      }
      
      // Check privacy files exist
      const privacyFile = path.join(userDir, 'privacy.json');
      const gitignoreFile = path.join(userDir, '.gitignore');
      
      if (!(await this.fileExists(privacyFile))) {
        validation.privacyViolations.push({
          user: username,
          missing: 'privacy.json'
        });
      }
      
      if (!(await this.fileExists(gitignoreFile))) {
        validation.privacyViolations.push({
          user: username,
          missing: '.gitignore'
        });
      }
    }
    
    validation.passed = 
      validation.expectedUsers === validation.foundUsers &&
      validation.privacyViolations.length === 0 &&
      validation.permissionErrors.length === 0;
    
    this.validationResults.checks.userIsolation = validation;
    
    if (validation.passed) {
      logger.info(`✅ User isolation PASSED - ${validation.foundUsers} users`);
    } else {
      logger.info(`❌ User isolation FAILED`);
      if (validation.missingUsers.length > 0) {
        logger.info('Missing users:', { context: validation.missingUsers });
      }
    }
    
    return validation.passed;
  }

  /**
   * Validate milestones integration
   */
  async validateMilestones(originalMilestones) {
    logger.info('🔍 Validating milestones integration...');
    
    const validation = {
      originalCount: originalMilestones.length,
      migratedCount: 0,
      missingMilestones: [],
      taskMismatches: []
    };
    
    try {
      const tasksFile = path.join(this.flowforgeDir, 'tasks.json');
      
      if (await this.fileExists(tasksFile)) {
        const tasksData = await fs.readFile(tasksFile, 'utf-8');
        const tasks = JSON.parse(tasksData);
        
        if (tasks.milestones) {
          validation.migratedCount = tasks.milestones.length;
          
          // Compare milestones
          for (const original of originalMilestones) {
            const migrated = tasks.milestones.find(m => m.title === original.title);
            
            if (!migrated) {
              validation.missingMilestones.push(original.title);
            } else {
              // Check task lists match
              const originalTasks = new Set(original.tasks);
              const migratedTasks = new Set(migrated.tasks);
              
              if (originalTasks.size !== migratedTasks.size ||
                  ![...originalTasks].every(t => migratedTasks.has(t))) {
                validation.taskMismatches.push({
                  milestone: original.title,
                  original: original.tasks,
                  migrated: migrated.tasks
                });
              }
            }
          }
        }
      }
    } catch (error) {
      this.errors.push(`Failed to validate milestones: ${error.message}`);
      return false;
    }
    
    validation.passed = 
      validation.originalCount === validation.migratedCount &&
      validation.missingMilestones.length === 0 &&
      validation.taskMismatches.length === 0;
    
    this.validationResults.checks.milestones = validation;
    
    if (validation.passed) {
      logger.info(`✅ Milestones validation PASSED - ${validation.migratedCount} milestones`);
    } else {
      logger.info(`❌ Milestones validation FAILED`);
    }
    
    return validation.passed;
  }

  /**
   * Run comprehensive validation
   */
  async runFullValidation(originalData) {
    logger.info('');
    logger.info('🔍 Running comprehensive migration validation...');
    logger.info('═' * 50);
    
    const checks = [
      () => this.validateBillingAccuracy(originalData.billing, originalData),
      () => this.validateSessions(originalData.sessions || []),
      () => this.validateUserIsolation(originalData.users || []),
      () => this.validateMilestones(originalData.milestones || [])
    ];
    
    let allPassed = true;
    
    for (const check of checks) {
      const passed = await check();
      allPassed = allPassed && passed;
    }
    
    // Generate summary
    this.validationResults.passed = allPassed;
    this.validationResults.summary = {
      totalChecks: checks.length,
      passedChecks: Object.values(this.validationResults.checks)
        .filter(c => c.passed).length,
      errors: this.errors.length,
      warnings: this.warnings.length,
      timestamp: new Date().toISOString()
    };
    
    logger.info('');
    logger.info('═' * 50);
    
    if (allPassed) {
      logger.info('✅ VALIDATION SUCCESSFUL - 100% accuracy confirmed');
      logger.info('All migration checks passed!');
    } else {
      logger.info('❌ VALIDATION FAILED');
      logger.info(`Passed ${this.validationResults.summary.passedChecks}/${this.validationResults.summary.totalChecks} checks`);
      
      if (this.errors.length > 0) {
        logger.info('');
        logger.info('Errors:');
        this.errors.forEach(e => logger.info(`  - ${e}`));
      }
    }
    
    return this.validationResults;
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
   * Generate validation report
   */
  generateReport() {
    return {
      ...this.validationResults,
      errors: this.errors,
      warnings: this.warnings,
      reportGenerated: new Date().toISOString()
    };
  }
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const projectRoot = args[0] || process.cwd();
  
  const validator = new MigrationValidator(projectRoot);
  
  (async () => {
    try {
      // For CLI testing, create mock original data
      const originalData = {
        billing: {
          totalMinutes: 420,
          byUser: { cruzalex: 240, johndoe: 180 },
          byTask: { 142: 210, 231: 90, 239: 120 }
        },
        sessions: [],
        users: ['cruzalex', 'johndoe'],
        milestones: []
      };
      
      const results = await validator.runFullValidation(originalData);
      
      // Output JSON report
      logger.info('');
      logger.info('Full validation report:');
      logger.info(JSON.stringify(results, { data: [null, 2] }));
      
      process.exit(results.passed ? 0 : 1);
    } catch (error) {
      logger.error('Validation error:', { context: error.message });
      process.exit(1);
    }
  })();
}

module.exports = MigrationValidator;