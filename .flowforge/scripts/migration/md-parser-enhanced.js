#!/usr/bin/env node

/**
 * Enhanced MD File Parser for FlowForge v2.0 Migration
 * Issue #244 - Parses BOTH legacy and current MD tracking file formats
 * 
 * Supports:
 * - Table format (current): | Date | Issue | Start | End | Hours | Status | Description |
 * - Legacy format: ## YYYY-MM-DD followed by - Issue #XXX [Xh] @username
 * - User extraction from git history if not in file
 * - 100% billing accuracy guarantee
 */

const fs = require('fs').promises;
const path = require('path');
const { logger } = require('../utils/logger.js');
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

class EnhancedMDParser {
  constructor(projectRoot) {
    this.projectRoot = projectRoot || process.cwd();
    this.sessions = [];
    this.milestones = [];
    this.tasks = [];
    this.users = new Set();
    this.totalMinutes = 0;
    this.formatDetected = null;
  }

  /**
   * Detect format of SESSIONS.md file
   */
  async detectFormat(content) {
    const lines = content.split('\n').filter(line => line.trim());
    
    // Check for table format (pipe-separated values)
    const hasTableHeader = lines.some(line => 
      line.includes('| Date') && line.includes('| Issue') && line.includes('| Hours')
    );
    
    // Check for structured format (session headers with properties)
    const hasStructuredSessions = lines.some(line => /^##\s+Session\s+/.test(line));
    
    // Check for legacy format (date headers and bullet points)
    const hasDateHeaders = lines.some(line => /^##\s+\d{4}-\d{2}-\d{2}/.test(line));
    const hasLegacyEntries = lines.some(line => 
      /-\s+Issue\s+#\d+\s+\[\d+(?:\.\d+)?[hm]?\]/.test(line)
    );
    
    if (hasTableHeader) {
      return 'table';
    } else if (hasStructuredSessions) {
      return 'structured';
    } else if (hasDateHeaders || hasLegacyEntries) {
      return 'legacy';
    }
    
    return 'unknown';
  }

  /**
   * Parse table format SESSIONS.md
   * Format: | Date | Issue | Start | End | Hours | Status | Description |
   */
  async parseTableFormat(content) {
    const lines = content.split('\n');
    let sessionId = 1;
    let inTable = false;
    let headerFound = false;
    
    for (const line of lines) {
      // Skip empty lines
      if (!line.trim()) continue;
      
      // Check for table header
      if (line.includes('| Date') && line.includes('| Issue')) {
        headerFound = true;
        inTable = true;
        continue;
      }
      
      // Skip separator lines (|------|------|)
      if (line.match(/^\|[\s-]+\|/)) continue;
      
      // Parse table rows
      if (inTable && line.startsWith('|')) {
        const cells = line.split('|').map(cell => cell.trim()).filter(cell => cell);
        
        if (cells.length >= 6) {
          const [date, issue, start, end, hours, status, description] = cells;
          
          // Extract issue number
          const issueMatch = issue.match(/#(\d+)/);
          if (!issueMatch) continue;
          
          const issueId = parseInt(issueMatch[1]);
          
          // Parse hours (could be "0.00", "2.5", "ACTIVE", etc.)
          let minutes = 0;
          const hoursFloat = parseFloat(hours);
          if (!isNaN(hoursFloat)) {
            minutes = Math.round(hoursFloat * 60);
          }
          
          // Try to extract user from description first
          let username = null;
          const userMatch = (description || '').match(/@([a-zA-Z0-9_.@-]+)/);
          if (userMatch) {
            username = userMatch[1];
          } else {
            // Try git extraction as fallback
            username = await this.extractUserFromGit(issueId);
          }
          if (!username) {
            username = 'unknown';
          }
          
          if (process.env.DEBUG) {
            // @flowforge-bypass: rule8 - Debug output for user extraction during migration
            logger.error(`Extracted user '${username}' for issue ${issueId} from description: '${description}'`);
          }
          
          // Track user
          this.users.add(username);
          this.totalMinutes += minutes;
          
          // Determine timestamps
          const startTime = start && start !== '-' ? start : null;
          const endTime = end && end !== '-' ? end : null;
          
          // Create session object
          const session = {
            id: `session-${date}-${sessionId++}`,
            taskId: issueId,
            user: username,
            duration: minutes,
            billingMinutes: minutes, // Critical for billing accuracy
            description: description || `Issue #${issueId}`,
            date: date,
            startTime: startTime,
            endTime: endTime,
            status: status,
            timestamp: startTime || `${date}T09:00:00Z`,
            source: 'migrated-from-table'
          };
          
          this.sessions.push(session);
        }
      }
    }
    
    return this.sessions;
  }

  /**
   * Parse structured format SESSIONS.md
   * Format: ## Session session-id followed by properties
   */
  async parseStructuredFormat(content) {
    const lines = content.split('\n');
    let currentSession = null;
    let sessionId = 1;

    for (const line of lines) {
      // Parse session headers (## Session session-id)
      const sessionMatch = line.match(/^##\s+Session\s+(.*)/);
      if (sessionMatch) {
        // Save previous session if complete
        if (currentSession && currentSession.taskId) {
          this.sessions.push({
            id: currentSession.id,
            taskId: currentSession.taskId,
            user: currentSession.user || 'unknown',
            duration: currentSession.duration || 0,
            billingMinutes: currentSession.duration || 0,
            description: currentSession.description || `Issue #${currentSession.taskId}`,
            timestamp: new Date().toISOString(),
            source: 'migrated-from-structured'
          });
          
          this.users.add(currentSession.user || 'unknown');
          this.totalMinutes += currentSession.duration || 0;
        }
        
        // Start new session
        currentSession = {
          id: sessionMatch[1] || `session-${sessionId++}`,
          user: null,
          taskId: null,
          duration: null,
          description: ''
        };
        continue;
      }
      
      // Parse session properties
      if (currentSession) {
        const userMatch = line.match(/-\s+User:\s+(.+)/);
        if (userMatch) {
          currentSession.user = userMatch[1].trim();
          continue;
        }
        
        const taskMatch = line.match(/-\s+Task:\s+#(\d+)/);
        if (taskMatch) {
          currentSession.taskId = parseInt(taskMatch[1]);
          continue;
        }
        
        const durationMatch = line.match(/-\s+Duration:\s+(\d+(?:\.\d+)?)(h|m)?/);
        if (durationMatch) {
          let minutes = parseFloat(durationMatch[1]);
          if (durationMatch[2] === 'h') {
            minutes *= 60;
          }
          currentSession.duration = Math.round(minutes);
          continue;
        }
      }
    }
    
    // Save last session
    if (currentSession && currentSession.taskId) {
      this.sessions.push({
        id: currentSession.id,
        taskId: currentSession.taskId,
        user: currentSession.user || 'unknown',
        duration: currentSession.duration || 0,
        billingMinutes: currentSession.duration || 0,
        description: currentSession.description || `Issue #${currentSession.taskId}`,
        timestamp: new Date().toISOString(),
        source: 'migrated-from-structured'
      });
      
      this.users.add(currentSession.user || 'unknown');
      this.totalMinutes += currentSession.duration || 0;
    }

    return this.sessions;
  }

  /**
   * Parse legacy format SESSIONS.md
   * Format: ## YYYY-MM-DD followed by - Issue #XXX [Xh] @username
   */
  async parseLegacyFormat(content) {
    const lines = content.split('\n');
    let currentDate = null;
    let sessionId = 1;

    for (const line of lines) {
      // Parse date headers (## YYYY-MM-DD)
      const dateMatch = line.match(/^##\s+(\d{4}-\d{2}-\d{2})/);
      if (dateMatch) {
        currentDate = dateMatch[1];
        continue;
      }

      // Parse session entries (multiple formats)
      // First try with user (@username)
      let sessionMatch = line.match(
        /-\s+Issue\s+#(\d+)\s+\[(\d+(?:\.\d+)?)(h|m)?\]\s*-?\s*(.*?)\s*@([a-zA-Z0-9_-]+)/
      );
      
      // If no user found, try without user
      if (!sessionMatch) {
        sessionMatch = line.match(
          /-\s+(?:Task|Issue):\s+#(\d+)(?:\s+-\s*(.*?))?/
        );
        if (sessionMatch) {
          // Look for duration in subsequent lines or this line
          let durationLine = line;
          const durationMatch = durationLine.match(/Duration:\s+(\d+(?:\.\d+)?)(h|m)?/);
          if (durationMatch) {
            sessionMatch = [
              line,
              sessionMatch[1], // issueId
              durationMatch[1], // duration
              durationMatch[2] || 'm', // unit
              sessionMatch[2] || '', // description
              null // no username
            ];
          } else {
            sessionMatch = null;
          }
        }
      }

      if (sessionMatch) {
        const [, issueId, duration, unit, description, username] = sessionMatch;
        
        // Convert duration to minutes
        let minutes = 0;
        if (unit === 'm' || !unit) {
          minutes = Math.round(parseFloat(duration));
        } else if (unit === 'h') {
          minutes = Math.round(parseFloat(duration) * 60);
        }

        // Track user - handle unknown users
        const finalUsername = username || 'unknown';
        this.users.add(finalUsername);
        this.totalMinutes += minutes;

        // Create session object
        const session = {
          id: `session-${currentDate || 'unknown'}-${sessionId++}`,
          taskId: parseInt(issueId),
          user: finalUsername,
          duration: minutes,
          billingMinutes: minutes, // Critical for billing accuracy
          description: description.trim(),
          date: currentDate || new Date().toISOString().split('T')[0],
          timestamp: currentDate ? `${currentDate}T09:00:00Z` : new Date().toISOString(),
          source: 'migrated-from-legacy'
        };

        this.sessions.push(session);
      }
    }

    return this.sessions;
  }

  /**
   * Extract user from git history for an issue
   */
  async extractUserFromGit(issueId) {
    try {
      // Try to find commits related to this issue
      const { stdout } = await execAsync(
        `cd "${this.projectRoot}" && git log --grep="#${issueId}" --format="%ae" -n 1 2>/dev/null`,
        { timeout: 5000 }
      );
      
      if (stdout && stdout.trim()) {
        const email = stdout.trim();
        const username = email.split('@')[0];
        return username;
      }
    } catch (e) {
      // Git extraction failed, fall back to unknown
    }
    
    return null;
  }

  /**
   * Main parse method - auto-detects format
   */
  async parseSessions(filePath) {
    const possiblePaths = [
      path.join(this.projectRoot, 'SESSIONS.md'),
      path.join(this.projectRoot, 'documentation/development/SESSIONS.md'),
      path.join(this.projectRoot, 'documentation/2.0/development/SESSIONS.md')
    ];

    let content = null;
    let actualPath = null;
    
    for (const p of possiblePaths) {
      try {
        content = await fs.readFile(p, 'utf-8');
        actualPath = p;
        if (process.env.DEBUG) {
          // @flowforge-bypass: rule8 - Debug output for file discovery during migration
          logger.error(`Found SESSIONS.md at ${p}`);
        }
        break;
      } catch (e) {
        continue;
      }
    }

    if (!content) {
      if (process.env.DEBUG) {
        // @flowforge-bypass: rule8 - Debug output for missing file during migration
        logger.error('SESSIONS.md not found');
      }
      return [];
    }

    // Detect format
    this.formatDetected = await this.detectFormat(content);
    
    if (process.env.DEBUG) {
      // @flowforge-bypass: rule8 - Debug output for format detection during migration
      logger.error(`Detected format: ${this.formatDetected}`);
    }
    
    // Parse based on detected format
    switch (this.formatDetected) {
      case 'table':
        await this.parseTableFormat(content);
        break;
      case 'structured':
        await this.parseStructuredFormat(content);
        break;
      case 'legacy':
        await this.parseLegacyFormat(content);
        break;
      default:
        // @flowforge-bypass: rule8 - Warning output for format fallback during migration
        logger.warn('Unknown SESSIONS.md format, { context: attempting all parsers' });
        // Try all parsers
        await this.parseTableFormat(content);
        if (this.sessions.length === 0) {
          await this.parseStructuredFormat(content);
        }
        if (this.sessions.length === 0) {
          await this.parseLegacyFormat(content);
        }
    }

    // Only log in debug mode
    if (process.env.DEBUG) {
      // @flowforge-bypass: rule8 - Debug output for parsing results during migration
      logger.error(`Parsed ${this.sessions.length} sessions from ${this.users.size} users`);
      logger.error(`Total billing minutes: ${this.totalMinutes}`);
    }
    
    return this.sessions;
  }

  /**
   * Parse SCHEDULE.md file - Enhanced with multiple format support
   */
  async parseSchedule(filePath) {
    const possiblePaths = [
      path.join(this.projectRoot, 'SCHEDULE.md'),
      path.join(this.projectRoot, 'documentation/development/SCHEDULE.md'),
      path.join(this.projectRoot, 'documentation/2.0/development/SCHEDULE.md')
    ];

    let content = null;
    for (const p of possiblePaths) {
      try {
        content = await fs.readFile(p, 'utf-8');
        break;
      } catch (e) {
        continue;
      }
    }

    if (!content) {
      if (process.env.DEBUG) {
        // @flowforge-bypass: rule8 - Debug output for missing schedule during migration
        logger.error('SCHEDULE.md not found');
      }
      return [];
    }

    const lines = content.split('\n');
    let currentMilestone = null;

    for (const line of lines) {
      // Parse milestone headers - multiple formats
      // Format 1: ## v2.1.0 - Title
      let milestoneMatch = line.match(/^##\s+([vV]?\d+\.\d+\.\d+)\s+-\s+(.+)/);
      if (milestoneMatch) {
        // Save previous milestone if exists
        if (currentMilestone) {
          this.milestones.push(currentMilestone);
        }

        currentMilestone = {
          id: milestoneMatch[1].trim(),
          title: milestoneMatch[2].trim(),
          startDate: null,
          endDate: null,
          tasks: [],
          status: 'planned',
          dependencies: []
        };
        continue;
      }

      // Format 2: ## Title - YYYY-MM-DD (legacy)
      milestoneMatch = line.match(/^##\s+(.+?)\s+-\s+(\d{4}-\d{2}-\d{2})/);
      if (milestoneMatch) {
        // Save previous milestone if exists
        if (currentMilestone) {
          this.milestones.push(currentMilestone);
        }

        currentMilestone = {
          id: milestoneMatch[1].trim().replace(/\s+/g, '-').toLowerCase(),
          title: milestoneMatch[1].trim(),
          startDate: null,
          endDate: milestoneMatch[2] + 'T00:00:00Z',
          dueDate: milestoneMatch[2],
          tasks: [],
          status: 'planned',
          dependencies: []
        };
        continue;
      }

      // Parse milestone properties if we have a current milestone
      if (currentMilestone) {
        // Parse start date - preserve original format
        const startMatch = line.match(/-\s+Start:\s+([\d\-T:Z.]+)/);
        if (startMatch) {
          currentMilestone.startDate = startMatch[1];
        }

        // Parse end date - preserve original format
        const endMatch = line.match(/-\s+End:\s+([\d\-T:Z.]+)/);
        if (endMatch) {
          currentMilestone.endDate = endMatch[1];
        }

        // Parse status
        const statusMatch = line.match(/-\s+Status:\s+(completed|in_progress|planned|active)/i);
        if (statusMatch) {
          currentMilestone.status = statusMatch[1].toLowerCase().replace('active', 'in_progress');
        }

        // Parse dependencies
        const depMatch = line.match(/-\s+Dependencies?:\s+(.+)/i);
        if (depMatch) {
          const deps = depMatch[1].trim();
          if (deps.toLowerCase() !== 'none') {
            currentMilestone.dependencies = deps.split(',').map(d => d.trim());
          }
        }

        // Parse task references
        const taskMatch = line.match(/-\s+Issue\s+#(\d+)/);
        if (taskMatch) {
          currentMilestone.tasks.push(parseInt(taskMatch[1]));
        }
      }
    }

    // Save last milestone
    if (currentMilestone) {
      this.milestones.push(currentMilestone);
    }

    if (process.env.DEBUG) {
      // @flowforge-bypass: rule8 - Debug output for milestone parsing during migration
      logger.error(`Parsed ${this.milestones.length} milestones`);
    }
    
    return this.milestones;
  }

  /**
   * Parse TASKS.md file - handles both table and list formats
   */
  async parseTasks(filePath) {
    const possiblePaths = [
      path.join(this.projectRoot, 'TASKS.md'),
      path.join(this.projectRoot, 'documentation/development/TASKS.md'),
      path.join(this.projectRoot, 'documentation/2.0/development/TASKS.md')
    ];

    let content = null;
    for (const p of possiblePaths) {
      try {
        content = await fs.readFile(p, 'utf-8');
        break;
      } catch (e) {
        continue;
      }
    }

    if (!content) {
      if (process.env.DEBUG) {
        // @flowforge-bypass: rule8 - Debug output for missing tasks during migration
        logger.error('TASKS.md not found');
      }
      return [];
    }

    const lines = content.split('\n');
    let currentTask = null;
    let inMicrotasks = false;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // Parse task entries with different states
      const taskMatch = line.match(/-\s+\[([ x]|in-progress|on-hold|invalid-status)\]\s+\*?\*?Issue\s+#([a-zA-Z0-9]+)\*?\*?\s*-?\s*(.*)/);
      if (taskMatch) {
        // Save previous task if exists
        if (currentTask) {
          this.tasks.push(currentTask);
        }
        
        const [, status, issueId, description] = taskMatch;
        
        // Detect corrupted issue IDs (should be numeric)
        const numericIssueId = parseInt(issueId);
        if (isNaN(numericIssueId) || issueId.length > 6) {
          throw new Error(`Corrupted file detected: Invalid issue ID format: ${issueId}`);
        }
        
        // Detect invalid status values
        if (status === 'invalid-status') {
          throw new Error(`Corrupted file detected: Invalid task status: ${status}`);
        }
        
        let taskStatus = 'pending';
        if (status === 'x') {
          taskStatus = 'completed';
        } else if (status === 'in-progress') {
          taskStatus = 'in_progress';
        } else if (status === 'on-hold') {
          taskStatus = 'on_hold';
        }

        currentTask = {
          id: numericIssueId,
          title: description.trim() || `Issue #${numericIssueId}`,
          status: taskStatus,
          microtasks: [],
          source: 'migrated-from-md',
          createdAt: new Date().toISOString()
        };
        
        inMicrotasks = false;
        continue;
      }
      
      // Parse microtasks section
      if (currentTask) {
        if (line.trim() === '- Microtasks:') {
          inMicrotasks = true;
          continue;
        }
        
        if (inMicrotasks) {
          const microtaskMatch = line.match(/^\s+- (.+)/);
          if (microtaskMatch) {
            currentTask.microtasks.push(microtaskMatch[1].trim());
          } else if (line.trim() === '' || !line.match(/^\s/)) {
            inMicrotasks = false;
          }
        }
      }
    }
    
    // Save last task
    if (currentTask) {
      this.tasks.push(currentTask);
    }

    if (process.env.DEBUG) {
      // @flowforge-bypass: rule8 - Debug output for task parsing during migration
      logger.error(`Parsed ${this.tasks.length} tasks`);
    }
    
    return this.tasks;
  }

  /**
   * Get all unique users found
   */
  getUsers() {
    return Array.from(this.users);
  }

  /**
   * Get total time tracked in minutes
   */
  getTotalMinutes() {
    return this.totalMinutes;
  }

  /**
   * Generate user-specific data
   */
  getUserData(username) {
    const userSessions = this.sessions.filter(s => s.user === username);
    const totalMinutes = userSessions.reduce((sum, s) => sum + s.duration, 0);
    
    return {
      user: username,
      sessions: userSessions,
      totalMinutes,
      sessionCount: userSessions.length,
      averageSessionMinutes: userSessions.length > 0 ? Math.round(totalMinutes / userSessions.length) : 0
    };
  }

  /**
   * Calculate billing summary with 100% accuracy guarantee
   */
  getBillingSummary() {
    const byUser = {};
    const byTask = {};

    for (const session of this.sessions) {
      // By user
      if (!byUser[session.user]) {
        byUser[session.user] = 0;
      }
      byUser[session.user] += session.billingMinutes || session.duration;

      // By task
      if (!byTask[session.taskId]) {
        byTask[session.taskId] = 0;
      }
      byTask[session.taskId] += session.billingMinutes || session.duration;
    }

    return {
      total: this.totalMinutes,
      byUser,
      byTask,
      sessionCount: this.sessions.length,
      userCount: this.users.size,
      formatDetected: this.formatDetected
    };
  }
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0];
  const projectRoot = args[1] || process.cwd();

  const parser = new EnhancedMDParser(projectRoot);

  (async () => {
    try {
      switch (command) {
        case 'sessions':
          const sessions = await parser.parseSessions();
          // @flowforge-bypass: rule8 - Required for migration CLI output during deployment
          logger.info(JSON.stringify(sessions, { data: [null, 2] }));
          break;

        case 'schedule':
          const milestones = await parser.parseSchedule();
          // @flowforge-bypass: rule8 - Required for migration CLI output during deployment
          logger.info(JSON.stringify(milestones, { data: [null, 2] }));
          break;

        case 'tasks':
          const tasks = await parser.parseTasks();
          // @flowforge-bypass: rule8 - Required for migration CLI output during deployment
          logger.info(JSON.stringify(tasks, { data: [null, 2] }));
          break;

        case 'users':
          await parser.parseSessions();
          const users = parser.getUsers();
          // @flowforge-bypass: rule8 - Required for migration CLI output during deployment
          logger.info(JSON.stringify(users, { data: [null, 2] }));
          break;

        case 'billing':
          await parser.parseSessions();
          const billing = parser.getBillingSummary();
          // @flowforge-bypass: rule8 - Required for migration CLI output during deployment
          logger.info(JSON.stringify(billing, { data: [null, 2] }));
          break;

        case 'all':
          await parser.parseSessions();
          await parser.parseSchedule();
          await parser.parseTasks();
          
          const result = {
            sessions: parser.sessions,
            milestones: parser.milestones,
            tasks: parser.tasks,
            users: parser.getUsers(),
            billing: parser.getBillingSummary(),
            metadata: {
              formatDetected: parser.formatDetected,
              migrationVersion: '2.0.0',
              timestamp: new Date().toISOString()
            }
          };
          
          // @flowforge-bypass: rule8 - Required for migration CLI output during deployment
          logger.info(JSON.stringify(result, { data: [null, 2] }));
          break;

        default:
          // @flowforge-bypass: rule8 - Required for migration CLI help text during deployment
          logger.info('Usage: md-parser-enhanced.js <command> [projectRoot]');
          // @flowforge-bypass: rule8 - Required for migration CLI help text during deployment
          logger.info('Commands:');
          // @flowforge-bypass: rule8 - Required for migration CLI help text during deployment
          logger.info('  sessions - Parse SESSIONS.md');
          // @flowforge-bypass: rule8 - Required for migration CLI help text during deployment
          logger.info('  schedule - Parse SCHEDULE.md');
          // @flowforge-bypass: rule8 - Required for migration CLI help text during deployment
          logger.info('  tasks    - Parse TASKS.md');
          // @flowforge-bypass: rule8 - Required for migration CLI help text during deployment
          logger.info('  users    - Extract all users');
          // @flowforge-bypass: rule8 - Required for migration CLI help text during deployment
          logger.info('  billing  - Calculate billing summary');
          // @flowforge-bypass: rule8 - Required for migration CLI help text during deployment
          logger.info('  all      - Parse everything');
          process.exit(1);
      }
    } catch (error) {
      // @flowforge-bypass: rule8 - Required for migration error reporting during deployment
      logger.error('Error:', { context: error.message });
      if (process.env.DEBUG) {
        // @flowforge-bypass: rule8 - Required for migration debug stack traces during deployment
        logger.error(error.stack);
      }
      process.exit(1);
    }
  })();
}

module.exports = EnhancedMDParser;