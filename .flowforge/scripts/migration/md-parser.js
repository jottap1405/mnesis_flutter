#!/usr/bin/env node

/**
 * MD File Parser for FlowForge v2.0 Migration
 * Issue #244 - Parses legacy MD tracking files
 * 
 * Handles:
 * - SESSIONS.md parsing with user extraction
 * - SCHEDULE.md to milestones conversion
 * - TASKS.md preservation
 */

const fs = require('fs').promises;
const path = require('path');

const { logger } = require('../utils/logger.js');
class MDParser {
  constructor(projectRoot) {
    this.projectRoot = projectRoot || process.cwd();
    this.sessions = [];
    this.milestones = [];
    this.tasks = [];
    this.users = new Set();
    this.totalMinutes = 0;
  }

  /**
   * Parse SESSIONS.md file
   * Format: - Issue #XXX [Xh] - Description @username
   */
  async parseSessions(filePath) {
    const possiblePaths = [
      path.join(this.projectRoot, 'SESSIONS.md'),
      path.join(this.projectRoot, 'documentation/development/SESSIONS.md')
    ];

    let content = null;
    for (const p of possiblePaths) {
      try {
        content = await fs.readFile(p, 'utf-8');
        if (process.env.DEBUG) {
          logger.info(`Found SESSIONS.md at ${p}`);
        }
        break;
      } catch (e) {
        continue;
      }
    }

    if (!content) {
      if (process.env.DEBUG) {
        logger.warn('SESSIONS.md not found');
      }
      return [];
    }

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

      // Parse session entries
      // Multiple formats to handle:
      // - Issue #XXX [Xh] - Description @username
      // - Issue #XXX [X.Xh] - Description @username
      // - Issue #XXX [XXm] - Description @username
      const sessionMatch = line.match(
        /-\s+Issue\s+#(\d+)\s+\[(\d+(?:\.\d+)?)(h|m)?\]\s*-?\s*(.*?)\s*@([a-zA-Z0-9_-]+)/
      );

      if (sessionMatch) {
        const [, issueId, duration, unit, description, username] = sessionMatch;
        
        // Convert duration to minutes
        let minutes = 0;
        if (unit === 'm' || !unit) {
          minutes = Math.round(parseFloat(duration));
        } else if (unit === 'h') {
          minutes = Math.round(parseFloat(duration) * 60);
        }

        // Track user
        this.users.add(username);
        this.totalMinutes += minutes;

        // Create session object
        const session = {
          id: `session-${currentDate || 'unknown'}-${sessionId++}`,
          taskId: parseInt(issueId),
          user: username,
          duration: minutes,
          description: description.trim(),
          date: currentDate || new Date().toISOString().split('T')[0],
          timestamp: currentDate ? `${currentDate}T09:00:00Z` : new Date().toISOString(),
          source: 'migrated-from-md'
        };

        this.sessions.push(session);
      }
    }

    // Only log in debug mode
    if (process.env.DEBUG) {
      logger.info(`Parsed ${this.sessions.length} sessions from ${this.users.size} users`);
    }
    return this.sessions;
  }

  /**
   * Parse SCHEDULE.md file
   * Format: ## Milestone - YYYY-MM-DD followed by - Issue #XXX
   */
  async parseSchedule(filePath) {
    const schedulePath = path.join(this.projectRoot, 'SCHEDULE.md');

    let content;
    try {
      content = await fs.readFile(schedulePath, 'utf-8');
    } catch (e) {
      if (process.env.DEBUG) {
        logger.warn('SCHEDULE.md not found');
      }
      return [];
    }

    const lines = content.split('\n');
    let currentMilestone = null;

    for (const line of lines) {
      // Parse milestone headers
      const milestoneMatch = line.match(/^##\s+(.+?)\s+-\s+(\d{4}-\d{2}-\d{2})/);
      if (milestoneMatch) {
        // Save previous milestone if exists
        if (currentMilestone) {
          this.milestones.push(currentMilestone);
        }

        currentMilestone = {
          title: milestoneMatch[1].trim(),
          dueDate: milestoneMatch[2],
          tasks: [],
          status: 'active'
        };
        continue;
      }

      // Parse task references
      const taskMatch = line.match(/-\s+Issue\s+#(\d+)/);
      if (taskMatch && currentMilestone) {
        currentMilestone.tasks.push(parseInt(taskMatch[1]));
      }
    }

    // Save last milestone
    if (currentMilestone) {
      this.milestones.push(currentMilestone);
    }

    // Only log in debug mode
    if (process.env.DEBUG) {
      logger.info(`Parsed ${this.milestones.length} milestones`);
    }
    return this.milestones;
  }

  /**
   * Parse TASKS.md file (preserve existing structure)
   * Format: - [ ] Issue #XXX - Description
   */
  async parseTasks(filePath) {
    const tasksPath = path.join(this.projectRoot, 'TASKS.md');

    let content;
    try {
      content = await fs.readFile(tasksPath, 'utf-8');
    } catch (e) {
      if (process.env.DEBUG) {
        logger.warn('TASKS.md not found');
      }
      return [];
    }

    const lines = content.split('\n');

    for (const line of lines) {
      // Parse task entries with different states
      const taskMatch = line.match(/-\s+\[([ x]|in-progress)\]\s+\*?\*?Issue\s+#(\d+)\*?\*?\s*-?\s*(.*)/);
      if (taskMatch) {
        const [, status, issueId, description] = taskMatch;
        
        let taskStatus = 'pending';
        if (status === 'x') {
          taskStatus = 'completed';
        } else if (status === 'in-progress') {
          taskStatus = 'in_progress';
        }

        const task = {
          id: parseInt(issueId),
          title: description.trim() || `Issue #${issueId}`,
          status: taskStatus,
          source: 'migrated-from-md',
          createdAt: new Date().toISOString()
        };

        this.tasks.push(task);
      }
    }

    // Only log in debug mode
    if (process.env.DEBUG) {
      logger.info(`Parsed ${this.tasks.length} tasks`);
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
   * Calculate billing summary
   */
  getBillingSummary() {
    const byUser = {};
    const byTask = {};

    for (const session of this.sessions) {
      // By user
      if (!byUser[session.user]) {
        byUser[session.user] = 0;
      }
      byUser[session.user] += session.duration;

      // By task
      if (!byTask[session.taskId]) {
        byTask[session.taskId] = 0;
      }
      byTask[session.taskId] += session.duration;
    }

    return {
      total: this.totalMinutes,
      byUser,
      byTask,
      sessionCount: this.sessions.length,
      userCount: this.users.size
    };
  }
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0];
  const projectRoot = args[1] || process.cwd();

  const parser = new MDParser(projectRoot);

  (async () => {
    try {
      switch (command) {
        case 'sessions':
          const sessions = await parser.parseSessions();
          logger.info(JSON.stringify(sessions, { data: [null, 2] }));
          break;

        case 'schedule':
          const milestones = await parser.parseSchedule();
          logger.info(JSON.stringify(milestones, { data: [null, 2] }));
          break;

        case 'tasks':
          const tasks = await parser.parseTasks();
          logger.info(JSON.stringify(tasks, { data: [null, 2] }));
          break;

        case 'users':
          await parser.parseSessions();
          const users = parser.getUsers();
          logger.info(JSON.stringify(users, { data: [null, 2] }));
          break;

        case 'billing':
          await parser.parseSessions();
          const billing = parser.getBillingSummary();
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
            billing: parser.getBillingSummary()
          };
          
          logger.info(JSON.stringify(result, { data: [null, 2] }));
          break;

        default:
          logger.info('Usage: md-parser.js <command> [projectRoot]');
          logger.info('Commands:');
          logger.info('  sessions - Parse SESSIONS.md');
          logger.info('  schedule - Parse SCHEDULE.md');
          logger.info('  tasks    - Parse TASKS.md');
          logger.info('  users    - Extract all users');
          logger.info('  billing  - Calculate billing summary');
          logger.info('  all      - Parse everything');
          process.exit(1);
      }
    } catch (error) {
      logger.error('Error:', { context: error.message });
      process.exit(1);
    }
  })();
}

module.exports = MDParser;