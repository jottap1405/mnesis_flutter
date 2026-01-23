#!/usr/bin/env node

/**
 * User Extraction and Isolation for FlowForge v2.0 Migration
 * Issue #244 - Creates user-specific directories and data
 * 
 * Integrates with user-isolated-storage.js for proper isolation
 */

const fs = require('fs').promises;
const fsSync = require('fs');
const path = require('path');
const UserIsolatedStorage = require('../../src/core/user-isolated-storage');

const { logger } = require('../utils/logger.js');
class UserExtractor {
  constructor(projectRoot) {
    this.projectRoot = projectRoot || process.cwd();
    this.flowforgeDir = path.join(this.projectRoot, '.flowforge');
    this.storage = new UserIsolatedStorage();
  }

  /**
   * Create user directories with proper permissions
   */
  async createUserDirectory(username) {
    const userDir = path.join(this.flowforgeDir, 'user', username);
    
    try {
      await fs.mkdir(userDir, { recursive: true, mode: 0o700 });
      
      // Initialize user's time tracking file
      const timeTrackingPath = path.join(userDir, 'time-tracking.json');
      const initialData = {
        user: username,
        private: true,
        sessions: [],
        total_minutes: 0,
        last_updated: new Date().toISOString(),
        migrated_from: 'v1.x',
        created_at: new Date().toISOString()
      };
      
      await fs.writeFile(
        timeTrackingPath,
        JSON.stringify(initialData, null, 2)
      );
      
      // Set proper permissions
      await fs.chmod(timeTrackingPath, 0o600);
      
      logger.info(`Created directory for user: ${username}`);
      return userDir;
    } catch (error) {
      logger.error(`Failed to create directory for ${username}:`, { context: error });
      throw error;
    }
  }

  /**
   * Extract and isolate user data from sessions
   */
  async extractUserData(sessions) {
    const userMap = new Map();
    
    // Group sessions by user
    for (const session of sessions) {
      if (!userMap.has(session.user)) {
        userMap.set(session.user, {
          username: session.user,
          sessions: [],
          totalMinutes: 0,
          taskIds: new Set(),
          dateRange: {
            start: session.date,
            end: session.date
          }
        });
      }
      
      const userData = userMap.get(session.user);
      userData.sessions.push(session);
      userData.totalMinutes += session.duration;
      userData.taskIds.add(session.taskId);
      
      // Update date range
      if (session.date < userData.dateRange.start) {
        userData.dateRange.start = session.date;
      }
      if (session.date > userData.dateRange.end) {
        userData.dateRange.end = session.date;
      }
    }
    
    return userMap;
  }

  /**
   * Save user-specific data with privacy protection
   */
  async saveUserData(username, userData) {
    const userDir = path.join(this.flowforgeDir, 'user', username);
    
    // Ensure directory exists
    await this.createUserDirectory(username);
    
    // Load existing time tracking data
    const timeTrackingPath = path.join(userDir, 'time-tracking.json');
    let timeTracking = {};
    
    try {
      const existing = await fs.readFile(timeTrackingPath, 'utf-8');
      timeTracking = JSON.parse(existing);
    } catch (e) {
      // File doesn't exist or is invalid
    }
    
    // Merge with new data
    timeTracking = {
      ...timeTracking,
      user: username,
      private: true,
      sessions: [...(timeTracking.sessions || []), ...userData.sessions],
      total_minutes: (timeTracking.total_minutes || 0) + userData.totalMinutes,
      task_count: userData.taskIds.size,
      date_range: userData.dateRange,
      last_updated: new Date().toISOString(),
      session_count: userData.sessions.length
    };
    
    // Save updated data
    await fs.writeFile(
      timeTrackingPath,
      JSON.stringify(timeTracking, null, 2)
    );
    
    // Create sessions index for this user
    const sessionsDir = path.join(userDir, 'sessions');
    await fs.mkdir(sessionsDir, { recursive: true });
    
    // Save individual session files
    for (const session of userData.sessions) {
      const sessionPath = path.join(sessionsDir, `${session.id}.json`);
      await fs.writeFile(
        sessionPath,
        JSON.stringify(session, null, 2)
      );
    }
    
    // Create billing summary for user
    const billingPath = path.join(userDir, 'billing-summary.json');
    const billingSummary = {
      user: username,
      total_minutes: userData.totalMinutes,
      total_hours: parseFloat((userData.totalMinutes / 60).toFixed(2)),
      sessions: userData.sessions.length,
      tasks_worked: Array.from(userData.taskIds),
      average_session_minutes: Math.round(userData.totalMinutes / userData.sessions.length),
      date_range: userData.dateRange,
      generated_at: new Date().toISOString()
    };
    
    await fs.writeFile(
      billingPath,
      JSON.stringify(billingSummary, null, 2)
    );
    
    logger.info(`Saved data for user ${username}: ${userData.sessions.length} sessions, { context: ${userData.totalMinutes} minutes` });
  }

  /**
   * Apply privacy protection to user data
   */
  async applyPrivacyProtection(username, options = {}) {
    const userDir = path.join(this.flowforgeDir, 'user', username);
    
    // Add .gitignore to prevent accidental commits
    const gitignorePath = path.join(userDir, '.gitignore');
    const gitignoreContent = `# User-specific data - DO NOT COMMIT
*
!.gitignore
`;
    
    await fs.writeFile(gitignorePath, gitignoreContent);
    
    // Create privacy manifest
    const privacyPath = path.join(userDir, 'privacy.json');
    const privacyManifest = {
      user: username,
      privacy_level: options.privacyLevel || 'private',
      encrypted: options.encrypt || false,
      anonymized: options.anonymize || false,
      restricted_access: true,
      created_at: new Date().toISOString()
    };
    
    await fs.writeFile(
      privacyPath,
      JSON.stringify(privacyManifest, null, 2)
    );
    
    // Set restrictive permissions on all files
    const files = await fs.readdir(userDir);
    for (const file of files) {
      const filePath = path.join(userDir, file);
      const stat = await fs.stat(filePath);
      
      if (stat.isFile()) {
        await fs.chmod(filePath, 0o600);
      } else if (stat.isDirectory()) {
        await fs.chmod(filePath, 0o700);
      }
    }
    
    logger.info(`Applied privacy protection for user: ${username}`);
  }

  /**
   * Validate user data integrity
   */
  async validateUserData(username, expectedMinutes) {
    const userDir = path.join(this.flowforgeDir, 'user', username);
    const timeTrackingPath = path.join(userDir, 'time-tracking.json');
    
    try {
      const data = await fs.readFile(timeTrackingPath, 'utf-8');
      const timeTracking = JSON.parse(data);
      
      // Validate total minutes match
      if (timeTracking.total_minutes !== expectedMinutes) {
        throw new Error(
          `Time mismatch for ${username}: expected ${expectedMinutes}, got ${timeTracking.total_minutes}`
        );
      }
      
      // Validate sessions integrity
      let calculatedMinutes = 0;
      for (const session of timeTracking.sessions) {
        calculatedMinutes += session.duration;
      }
      
      if (calculatedMinutes !== timeTracking.total_minutes) {
        throw new Error(
          `Session sum mismatch for ${username}: sum=${calculatedMinutes}, total=${timeTracking.total_minutes}`
        );
      }
      
      logger.info(`✓ Validated data for ${username}: ${timeTracking.total_minutes} minutes`);
      return true;
    } catch (error) {
      logger.error(`✗ Validation failed for ${username}:`, { context: error.message });
      return false;
    }
  }

  /**
   * Generate user migration report
   */
  async generateUserReport() {
    const userDirs = await fs.readdir(path.join(this.flowforgeDir, 'user'));
    const report = {
      users: [],
      total_users: 0,
      total_minutes: 0,
      total_sessions: 0,
      generated_at: new Date().toISOString()
    };
    
    for (const username of userDirs) {
      const userDir = path.join(this.flowforgeDir, 'user', username);
      const timeTrackingPath = path.join(userDir, 'time-tracking.json');
      
      try {
        const data = await fs.readFile(timeTrackingPath, 'utf-8');
        const timeTracking = JSON.parse(data);
        
        report.users.push({
          username,
          minutes: timeTracking.total_minutes,
          sessions: timeTracking.session_count || timeTracking.sessions.length,
          tasks: timeTracking.task_count || 0,
          date_range: timeTracking.date_range
        });
        
        report.total_minutes += timeTracking.total_minutes;
        report.total_sessions += timeTracking.session_count || timeTracking.sessions.length;
      } catch (e) {
        logger.warn(`Could not read data for ${username}`);
      }
    }
    
    report.total_users = report.users.length;
    report.average_minutes_per_user = Math.round(report.total_minutes / report.total_users);
    
    return report;
  }
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0];
  const projectRoot = args[1] || process.cwd();
  
  const extractor = new UserExtractor(projectRoot);
  
  (async () => {
    try {
      switch (command) {
        case 'create':
          const username = args[1];
          if (!username) {
            logger.error('Username required');
            process.exit(1);
          }
          await extractor.createUserDirectory(username);
          break;
          
        case 'report':
          const report = await extractor.generateUserReport();
          logger.info(JSON.stringify(report, { data: [null, 2] }));
          break;
          
        default:
          logger.info('Usage: user-extractor.js <command> [options]');
          logger.info('Commands:');
          logger.info('  create <username> - Create user directory');
          logger.info('  report           - Generate user report');
          process.exit(1);
      }
    } catch (error) {
      logger.error('Error:', { context: error.message });
      process.exit(1);
    }
  })();
}

module.exports = UserExtractor;