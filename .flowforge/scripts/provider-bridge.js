#!/usr/bin/env node
// @flowforge-bypass: rule8:file - CLI tool requires console output for user interaction

/**
 * Provider Bridge Script
 * 
 * Bridges bash commands to the FlowForge provider abstraction system.
 * This allows bash-based commands to interact with multiple task providers
 * (GitHub, JSON, Notion, etc.) through a unified interface.
 * 
 * Usage:
 *   node scripts/provider-bridge.js <action> [options]
 * 
 * Actions:
 *   list-tasks        - List tasks with optional filters
 *   get-task         - Get a specific task by ID
 *   create-task      - Create a new task
 *   update-task      - Update an existing task
 *   start-tracking   - Start time tracking for a task
 *   stop-tracking    - Stop time tracking for a task
 *   search-tasks     - Search tasks across providers
 *   get-provider     - Get active provider info
 *   verify-task      - Verify if a task exists
 *   verify-ticket    - Alias for verify-task (universal terminology)
 *   get-next-task    - Get next task based on implementation order
 *   get-parallel-tasks - Get tasks that can be executed in parallel
 *   validate-dependencies - Validate task dependencies
 *   get-execution-plan - Get optimized execution plan
 *   aggregate        - Trigger batch aggregation of time data
 *   aggregate-status - Get aggregation status and metrics
 *   aggregate-force  - Force immediate flush of pending batches
 *   aggregate-recover - Manually trigger recovery of failed batches
 *   detect-completion - Detect task completion status
 *   get-completion-status - Get completion status for a task
 *   trigger-aggregation - Trigger immediate completion data aggregation
 *   get-session      - Get current session data for context restoration
 *   save-session     - Save session data for future restoration
 *   update-session   - Update existing session with new context
 *   clear-session    - Clear current session data
 * 
 * Options:
 *   --id=<id>        - Task ID
 *   --status=<status> - Task status filter
 *   --priority=<pri>  - Task priority filter
 *   --title=<title>   - Task title
 *   --description=<desc> - Task description
 *   --query=<query>   - Search query
 *   --format=<fmt>    - Output format (json|text|markdown)
 *   --provider=<name> - Specific provider to use
 */

const path = require('path');
const fs = require('fs');

// Import file locking for atomic operations (Issue #542)
const FileLockManager = require('./utils/FileLockManager');
const { logger } = require('./utils/logger.js');
const fileLockManager = new FileLockManager({
    timeout: 30000, // 30 second timeout for lock acquisition
    autoCleanup: true // Automatically clean up locks on exit
});

/**
 * Validates if a task ID is legitimate and not a ghost/PR number.
 *
 * @param {string} taskId - The task ID to validate
 * @returns {boolean} True if valid task ID
 */
function isValidTaskId(taskId) {
    if (!taskId) return false;
    
    // Parse and validate numeric
    const numId = parseInt(taskId);
    if (isNaN(numId)) return false;
    
    // PR numbers are typically >= 300 in our repo
    if (numId >= 300) {
        logger.error(`Warning: Task ID ${taskId} appears to be a PR number (>= 300)`);
        return false;
    }
    
    // Ghost task detection
    if (numId > 10000) {
        logger.error(`Warning: Suspicious task ID ${taskId} - might be corrupted`);
        return false;
    }
    
    return true;
}

// Import provider system
const { ProviderFactory } = require('../dist/providers/base/ProviderFactory.js');
const { initializeProviders } = require('../dist/providers/init.js');
const { createLogger } = require('../dist/utils/logger.js');

// Import dependency resolution utilities
const { DependencyResolver, FailureHandler } = require('./task-dependency-utils.js');

// Import aggregation components for Issue #240
const { SmartBatchAggregator } = require('../src/core/aggregation/SmartBatchAggregator.js');
const { CronRecoveryDaemon } = require('../src/core/aggregation/CronRecoveryDaemon.js');

// Import completion detection components for Issue #104
let EnhancedTaskCompletionDetector, CompletionAggregator;
try {
    EnhancedTaskCompletionDetector = require('../src/core/detection/EnhancedTaskCompletionDetector.js');
} catch (e) {
    // Optional component, continue without it
    EnhancedTaskCompletionDetector = null;
}
try {
    CompletionAggregator = require('../src/core/detection/aggregation/CompletionAggregator.js');
} catch (e) {
    // Optional component, continue without it
    CompletionAggregator = null;
}

// Import session tracking components for real-time updates
let SessionProviderSync, RealTimeSessionTracker;
try {
    ({ SessionProviderSync } = require('../src/core/session/SessionProviderSync.js'));
} catch (e) {
    // Optional component, continue without it
    SessionProviderSync = null;
}
try {
    ({ RealTimeSessionTracker } = require('../src/core/session/RealTimeSessionTracker.js'));
} catch (e) {
    // Optional component, continue without it
    RealTimeSessionTracker = null;
}

// Import multi-developer components for Issue #543
let MultiDeveloperProvider, TeamSyncService, TeamConfigurationService;
try {
    MultiDeveloperProvider = require('../services/MultiDeveloperProvider.js');
} catch (e) {
    // Optional component for multi-developer support
    MultiDeveloperProvider = null;
}
try {
    TeamSyncService = require('../services/TeamSyncService.js');
} catch (e) {
    // Optional component for team synchronization
    TeamSyncService = null;
}
try {
    TeamConfigurationService = require('../services/TeamConfigurationService.js');
} catch (e) {
    // Optional component for team configuration
    TeamConfigurationService = null;
}

// Singleton instances for aggregation (performance optimization)
let aggregatorInstance = null;
let recoveryDaemonInstance = null;

// Singleton instances for completion detection (Issue #104)
let detectorInstance = null;
let completionAggregatorInstance = null;

/**
 * Gets or creates the SmartBatchAggregator singleton instance.
 * 
 * @param {Object} options - Configuration options
 * @returns {SmartBatchAggregator} Aggregator instance
 */
function getAggregator(options = {}) {
    if (!aggregatorInstance) {
        const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
        aggregatorInstance = new SmartBatchAggregator({
            dataPath: path.join(dataPath, 'aggregated'),
            batchSize: 50,
            maxAge: 30000,
            flushThreshold: 0.9,
            atomicOperations: true,
            performance: {
                targetTime: 500,
                maxTime: 1000
            },
            ...options
        });
        // Track start time for uptime calculation
        aggregatorInstance.startTime = Date.now();
    }
    return aggregatorInstance;
}

/**
 * Processes a batch directly (for recovery operations).
 * 
 * @param {SmartBatchAggregator} aggregator - The aggregator instance
 * @param {Object} batchData - Batch data to process
 * @returns {Promise<void>}
 */
async function processBatch(aggregator, batchData) {
    // Re-add entries to aggregator for processing
    if (batchData.data && batchData.data.sessions) {
        for (const session of batchData.data.sessions) {
            // Map session to proper format
            await aggregator.add({
                userId: session.user || 'unknown',
                action: session.action || 'time-tracking',
                timestamp: session.startTime || Date.now(),
                metadata: {
                    sessionId: session.id,
                    taskId: session.taskId,
                    duration: session.duration
                }
            });
        }
    } else if (batchData.entries) {
        for (const entry of batchData.entries) {
            // Ensure entry has required fields
            const mappedEntry = {
                userId: entry.userId || entry.user || 'unknown',
                action: entry.action || 'time-tracking',
                timestamp: entry.timestamp || entry.startTime || Date.now(),
                metadata: entry.metadata || {}
            };
            await aggregator.add(mappedEntry);
        }
    }
    
    // Flush to persist
    await aggregator.flush();
}

/**
 * Gets or creates the CronRecoveryDaemon singleton instance.
 * 
 * @param {Object} options - Configuration options
 * @returns {CronRecoveryDaemon} Recovery daemon instance
 */
function getRecoveryDaemon(options = {}) {
    if (!recoveryDaemonInstance) {
        const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
        recoveryDaemonInstance = new CronRecoveryDaemon({
            dataPath: path.join(dataPath, 'aggregated'),
            checkInterval: 60000, // 1 minute
            maxRetries: 3,
            ...options
        });
    }
    return recoveryDaemonInstance;
}

/**
 * Gets or creates the EnhancedTaskCompletionDetector singleton instance.
 * 
 * @param {Object} options - Configuration options
 * @returns {EnhancedTaskCompletionDetector|null} Detector instance or null if not available
 */
function getCompletionDetector(options = {}) {
    if (!EnhancedTaskCompletionDetector) {
        return null;
    }
    
    if (!detectorInstance) {
        const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
        detectorInstance = new EnhancedTaskCompletionDetector({
            dataPath,
            checkInterval: 30000,
            confidenceThreshold: 0.7,
            enableAggregation: true,
            ...options
        });
    }
    return detectorInstance;
}

/**
 * Gets or creates the CompletionAggregator singleton instance.
 * 
 * @param {Object} options - Configuration options
 * @returns {CompletionAggregator|null} Aggregator instance or null if not available
 */
function getCompletionAggregator(options = {}) {
    if (!CompletionAggregator) {
        return null;
    }
    
    if (!completionAggregatorInstance) {
        const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
        completionAggregatorInstance = new CompletionAggregator({
            dataPath,
            enablePrivacy: true,
            batchSize: 10,
            flushInterval: 60000,
            ...options
        });
    }
    return completionAggregatorInstance;
}

/**
 * Detects provider mode from team configuration.
 *
 * @param {string} configPath - Path to team configuration file
 * @returns {string} Provider mode: 'multi-developer' or 'single-developer'
 */
function detectMode(configPath) {
    try {
        if (!fs.existsSync(configPath)) {
            return 'single-developer';
        }

        const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        return config.provider?.mode || 'single-developer';
    } catch (error) {
        // Default to single-developer on any error
        return 'single-developer';
    }
}

/**
 * Gets the appropriate provider based on mode.
 *
 * @param {string} mode - Provider mode
 * @returns {Object|null} Provider instance or null
 */
function getProvider(mode) {
    if (mode === 'multi-developer' && MultiDeveloperProvider) {
        const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
        return new MultiDeveloperProvider({
            dataPath,
            configPath: path.join(dataPath, 'team', 'config.json')
        });
    }
    return null; // Fall back to default provider
}

/**
 * Gets the current developer namespace.
 *
 * @returns {string} Developer namespace identifier
 */
function getDeveloperNamespace() {
    const username = process.env.FLOWFORGE_USER || process.env.USER || 'unknown';

    // Check team configuration for mapping
    if (TeamConfigurationService) {
        try {
            const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
            const configService = new TeamConfigurationService({
                configPath: path.join(dataPath, 'team', 'config.json')
            });

            const developer = configService.getDeveloperByUsername(username);
            if (developer) {
                return developer.namespace;
            }
        } catch (error) {
            // Fall back to username-based namespace
        }
    }

    // Generate namespace from username
    return username.toLowerCase().replace(/[^a-z0-9]/g, '');
}

/**
 * Handles missing team configuration gracefully.
 *
 * @returns {Object} Fallback configuration
 */
function handleMissingConfig() {
    return {
        fallbackMode: 'single-developer',
        warning: 'No team configuration found, falling back to single-developer mode'
    };
}

/**
 * Parse command line arguments safely with input sanitization
 * @param {string[]} args - Command line arguments from process.argv
 * @returns {{action: string, options: object}} Parsed action and options
 */
function parseArgs(args) {
    const action = args[2];
    const options = {};
    
    for (let i = 3; i < args.length; i++) {
        const arg = args[i];
        if (arg.startsWith('--')) {
            const [key, ...valueParts] = arg.slice(2).split('=');
            let value = valueParts.join('=') || true;
            
            // Sanitize string values to prevent command injection
            if (typeof value === 'string') {
                // Remove dangerous shell characters
                value = value.replace(/[;&|`$()<>\\]/g, '');
                // Limit length to prevent buffer overflow
                if (value.length > 1000) {
                    value = value.substring(0, 1000);
                }
            }
            
            options[key] = value;
        }
    }
    
    return { action, options };
}

/**
 * Format output data based on requested format
 * @param {any} data - The data to format (task object or array of tasks)
 * @param {string} format - Output format: 'json', 'text', 'markdown', or 'simple'
 * @returns {string} Formatted output string
 * @example
 * formatOutput({id: '123', title: 'Test', status: 'open'}, 'text')
 * // Returns: "#123: Test [open]"
 */
function formatOutput(data, format = 'json') {
    switch (format) {
        case 'json':
            return JSON.stringify(data, null, 2);
        
        case 'text':
            if (Array.isArray(data)) {
                return data.map(task => 
                    `#${task.id}: ${task.title} [${task.status}]`
                ).join('\n');
            }
            return `#${data.id}: ${data.title} [${data.status}]`;
        
        case 'markdown':
            if (Array.isArray(data)) {
                return data.map(task => 
                    `- [ ] #${task.id}: ${task.title} [${task.status}]`
                ).join('\n');
            }
            return `## Task #${data.id}\n**Title:** ${data.title}\n**Status:** ${data.status}\n**Description:** ${data.description || 'N/A'}`;
        
        case 'simple':
            // Simple format for easy bash parsing
            if (Array.isArray(data)) {
                return data.map(task => task.id).join('\n');
            }
            return data.id;
        
        default:
            return JSON.stringify(data, null, 2);
    }
}

// Main execution
async function main() {
    const { action, options } = parseArgs(process.argv);
    
    if (!action) {
                // @flowforge-bypass: rule8 - CLI error output for user
        logger.error('❌ No action specified');
                // @flowforge-bypass: rule8 - CLI error output for user
        logger.error('Usage: node scripts/provider-bridge.js <action> [options]');
        process.exit(1);
    }
    
    // Initialize logger (silent by default for command usage)
    const logger = createLogger({ silent: !options.debug });

    let factory = null;
    let multiDeveloperMode = false;

    try {
        // Check for multi-developer mode
        const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
        const teamConfigPath = path.join(dataPath, 'team', 'config.json');
        const mode = detectMode(teamConfigPath);

        if (mode === 'multi-developer' && MultiDeveloperProvider) {
            multiDeveloperMode = true;

            // Initialize multi-developer provider
            const multiProvider = getProvider('multi-developer');
            if (multiProvider) {
                // Use multi-developer provider for this session
                factory = {
                    getActiveProvider: () => ({ success: true, data: multiProvider }),
                    getProvider: (name) => ({ success: true, data: multiProvider }),
                    getAllProviders: () => [multiProvider],
                    setActiveProvider: () => {},
                    cleanup: async () => {
                        if (multiProvider.cleanup) {
                            await multiProvider.cleanup();
                        }
                    }
                };

                // Set current developer namespace
                const namespace = getDeveloperNamespace();
                multiProvider.setCurrentDeveloper(namespace);

                if (options.debug) {
                    process.stderr.write(`Multi-developer mode active: namespace=${namespace}\n`);
                }
            }
        }

        if (!multiDeveloperMode) {
            // Initialize standard provider factory
            factory = initializeProviders(logger);
        }

        // Create a default JSON provider if none exists
        const providers = factory.getAllProviders();
        if (providers.length === 0) {
            // Create default JSON provider for local storage
            const jsonConfig = {
                name: 'json-default',
                type: 'json',
                enabled: true,
                settings: {
                    filePath: '.flowforge/tasks.json',
                    autoSave: true,
                    saveInterval: 5000
                }
            };
            
            const createResult = await factory.createProvider(jsonConfig);
            if (!createResult.success) {
                throw new Error(`Failed to create default JSON provider: ${createResult.error.message}`);
            }
            
            // Set as active provider
            factory.setActiveProvider('json-default');
        }
        
        // Get the appropriate provider
        let provider;
        if (options.provider) {
            const providerResult = factory.getProvider(options.provider);
            if (!providerResult.success) {
                throw new Error(`Failed to get provider '${options.provider}': ${providerResult.error.message}`);
            }
            provider = providerResult.data;
        } else {
            const providerResult = factory.getActiveProvider();
            if (!providerResult.success) {
                // Try to get the first available provider
                const allProviders = factory.getAllProviders();
                if (allProviders.length > 0) {
                    provider = allProviders[0];
                } else {
                    throw new Error(`No providers available`);
                }
            } else {
                provider = providerResult.data;
            }
        }
        
        const format = options.format || 'json';
        
        // Execute action
        switch (action) {
            case 'list-tasks': {
                const filter = {};
                if (options.status) filter.status = options.status;
                if (options.priority) filter.priority = options.priority;
                if (options.assignee) filter.assignee = options.assignee;
                
                const result = await provider.listTasks(filter);
                if (!result.success) {
                    throw new Error(`Failed to list tasks: ${result.error.message}`);
                }
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output needed
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'get-task': {
                if (!options.id) {
                    throw new Error('Task ID required (--id=<id>)');
                }
                
                const result = await provider.getTask(options.id);
                if (!result.success) {
                    throw new Error(`Failed to get task: ${result.error.message}`);
                }
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'verify-task':
            case 'verify-ticket': {
                if (!options.id) {
                    throw new Error('Ticket ID required (--id=<id>)');
                }

                // Enhanced ticket ID validation for universal support
                const ticketId = options.id;

                // Support various ticket formats (GitHub: 123, Linear: LIN-456, Jira: PROJ-789, etc.)
                if (!ticketId || ticketId.trim() === '') {
                    logger.error(`Invalid ticket ID: ${ticketId}`);
                    process.exit(1);
                }

                // For numeric IDs, use existing validation to prevent ghost tasks
                if (/^\d+$/.test(ticketId) && !isValidTaskId(ticketId)) {
                    logger.error(`Invalid task ID: ${ticketId}`);
                    process.exit(1);
                }

                const result = await provider.getTask(ticketId);
                if (!result.success) {
                    // For verify, we return a simple response
                    // Exit with error code 1 to indicate not found
                    if (format === 'json') {
                        // @flowforge-bypass: rule8 - CLI output for user interaction
                        logger.info(JSON.stringify({
                            found: false, { data: [ticketId: ticketId, provider: provider.name, error: result.error?.message || 'Not found'
                        }, null, 2] }));
                    } else {
                        // @flowforge-bypass: rule8 - CLI output for user interaction
                        logger.info('NOT_FOUND');
                    }

                    // Clean up before exit
                    if (factory) {
                        await factory.cleanup();
                    }
                    process.exit(1);
                    return; // Never reached but makes intent clear
                }

                // Return ticket information for verification
                if (format === 'json') {
                    // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(JSON.stringify({
                        found: true, { data: [ticketId: ticketId, title: result.data.title, status: result.data.status, state: result.data.state || result.data.status, provider: provider.name, providerType: provider.type
                    }, null, 2] }));
                } else {
                    // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(result.data.status || result.data.state || 'OPEN');
                }
                break;
            }
            
            case 'create-task': {
                if (!options.title) {
                    throw new Error('Task title required (--title=<title>)');
                }
                
                const taskData = {
                    title: options.title,
                    description: options.description || '',
                    status: options.status || 'todo',
                    priority: options.priority || 'medium',
                    labels: options.labels ? options.labels.split(',') : []
                };
                
                const result = await provider.createTask(taskData);
                if (!result.success) {
                    throw new Error(`Failed to create task: ${result.error.message}`);
                }
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'update-task': {
                if (!options.id) {
                    throw new Error('Task ID required (--id=<id>)');
                }
                
                const updates = {};
                if (options.title) updates.title = options.title;
                if (options.description) updates.description = options.description;
                if (options.status) updates.status = options.status;
                if (options.priority) updates.priority = options.priority;
                if (options.labels) updates.labels = options.labels.split(',');
                
                const result = await provider.updateTask(options.id, updates);
                if (!result.success) {
                    throw new Error(`Failed to update task: ${result.error.message}`);
                }
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'start-tracking': {
                if (!options.id) {
                    throw new Error('Task ID required (--id=<id>)');
                }
                
                const user = options.user || process.env.USER || 'unknown';
                const instanceId = options.instance || `session-${Date.now()}`;
                
                const result = await provider.startTimeTracking(options.id, user, instanceId);
                if (!result.success) {
                    throw new Error(`Failed to start tracking: ${result.error.message}`);
                }
                
                // Start real-time session tracking if enabled
                if (options['enable-realtime'] !== 'false' && RealTimeSessionTracker) {
                    try {
                        const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
                        const tracker = new RealTimeSessionTracker({
                            dataPath,
                            updateInterval: 5000,
                            privacyMode: false,
                            atomicWrites: true
                        });
                        
                        // Get task details from provider
                        const taskResult = await provider.getTask(options.id);
                        const taskTitle = taskResult.success ? taskResult.data.title : `Task #${options.id}`;
                        
                        // Start session with real-time tracking
                        await tracker.startSession({
                            sessionId: instanceId,
                            taskId: options.id,
                            user: user,
                            taskTitle: taskTitle,
                            branch: options.branch || 'unknown',
                            startTime: new Date().toISOString()
                        });
                        
                        // Initialize sync if provider sync is enabled
                        if (options['enable-sync'] !== 'false' && SessionProviderSync) {
                            const sync = new SessionProviderSync({
                                dataPath,
                                syncInterval: 30000,
                                batchSize: 10
                            });
                            
                            // Start sync in background (non-blocking)
                            sync.startSync().catch(error => {
                                // Log but don't fail the command
                                if (options.debug) {
                                    // @flowforge-bypass: rule8 - CLI debug output
                                    logger.error(`Warning: Session sync failed: ${error.message}`);
                                }
                            });
                        }
                    } catch (rtError) {
                        // Don't fail if real-time tracking fails, just warn
                        if (options.debug) {
                            // @flowforge-bypass: rule8 - CLI debug output
                            logger.error(`Warning: Real-time tracking setup failed: ${rtError.message}`);
                        }
                    }
                }
                
                if (format === 'text' || format === 'simple') {
                // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info('✅ Time tracking started');
                } else {
                    // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                }
                break;
            }
            
            case 'stop-tracking': {
                if (!options.id) {
                    throw new Error('Task ID required (--id=<id>)');
                }
                
                if (!options.session) {
                    throw new Error('Session ID required (--session=<id>)');
                }
                
                const result = await provider.stopTimeTracking(options.id, options.session);
                if (!result.success) {
                    throw new Error(`Failed to stop tracking: ${result.error.message}`);
                }
                
                // Stop real-time session tracking if enabled
                if (options['enable-realtime'] !== 'false' && RealTimeSessionTracker) {
                    try {
                        const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
                        const tracker = new RealTimeSessionTracker({
                            dataPath,
                            updateInterval: 5000,
                            privacyMode: false,
                            atomicWrites: true
                        });
                        
                        // End the session
                        await tracker.endSession(options.session, {
                            duration: Date.now() - Date.parse(new Date().toISOString()),
                            endTime: new Date().toISOString()
                        });
                        
                        // Sync final data if enabled
                        if (options['enable-sync'] !== 'false' && SessionProviderSync) {
                            const sync = new SessionProviderSync({
                                dataPath,
                                syncInterval: 30000,
                                batchSize: 10
                            });
                            
                            // Force sync on session end
                            await sync.syncToProvider({ force: true });
                        }
                    } catch (rtError) {
                        // Don't fail if real-time tracking fails, just warn
                        if (options.debug) {
                            // @flowforge-bypass: rule8 - CLI debug output
                            logger.error(`Warning: Real-time tracking stop failed: ${rtError.message}`);
                        }
                    }
                }
                
                if (format === 'text' || format === 'simple') {
                // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info('✅ Time tracking stopped');
                } else {
                    // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                }
                break;
            }
            
            case 'search-tasks': {
                if (!options.query) {
                    throw new Error('Search query required (--query=<query>)');
                }
                
                const filter = {};
                if (options.status) filter.status = options.status;
                if (options.priority) filter.priority = options.priority;
                
                const result = await provider.searchTasks(options.query, filter);
                if (!result.success) {
                    throw new Error(`Failed to search tasks: ${result.error.message}`);
                }
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'get-provider': {
                const info = {
                    name: provider.name,
                    type: provider.type,
                    capabilities: provider.getCapabilities(),
                    enabled: provider.enabled
                };

                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(info, { context: format }));
                break;
            }

            // Session Management Methods for Issue #544
            case 'get-session': {
                // Get current session data from local storage
                const sessionFile = '.flowforge/local/session.json';

                try {
                    if (fs.existsSync(sessionFile)) {
                        const sessionData = JSON.parse(fs.readFileSync(sessionFile, 'utf8'));

                        // Enhance with real-time data if available
                        if (sessionData.taskId && provider.getTask) {
                            const taskResult = await provider.getTask(sessionData.taskId);
                            if (taskResult.success) {
                                sessionData.taskDetails = taskResult.data;
                            }
                        }

                        // Add current git branch info
                        try {
                            const { execSync } = require('child_process');
                            const currentBranch = execSync('git branch --show-current', { encoding: 'utf8' }).trim();
                            sessionData.currentBranch = currentBranch;
                        } catch (e) {
                            sessionData.currentBranch = 'unknown';
                        }

                        // @flowforge-bypass: rule8 - CLI output for session data
                        logger.info(formatOutput(sessionData, { context: format }));
                    } else {
                        // @flowforge-bypass: rule8 - CLI output for user feedback
                        logger.info(formatOutput({ error: 'No active session found' }, { context: format }));
                        process.exit(1);
                    }
                } catch (error) {
                    throw new Error(`Failed to get session data: ${error.message}`);
                }
                break;
            }

            case 'save-session': {
                // Save session data for context restoration
                const sessionData = {
                    sessionId: options.sessionId || `session-${Date.now()}`,
                    taskId: options.taskId || options.id,
                    taskTitle: options.taskTitle || options.title || '',
                    user: options.user || process.env.USER || 'unknown',
                    branch: options.branch || 'unknown',
                    startTime: options.startTime || new Date().toISOString(),
                    lastActivity: new Date().toISOString(),
                    files: options.files ? options.files.split(',') : [],
                    context: options.context || {}
                };

                // Ensure session directory exists
                const sessionDir = '.flowforge/local';
                if (!fs.existsSync(sessionDir)) {
                    fs.mkdirSync(sessionDir, { recursive: true });
                }

                // Save session data
                const sessionFile = path.join(sessionDir, 'session.json');
                fs.writeFileSync(sessionFile, JSON.stringify(sessionData, null, 2));

                // @flowforge-bypass: rule8 - CLI output for user feedback
                logger.info(formatOutput({ success: true, { data: [sessionId: sessionData.sessionId }, format] }));
                break;
            }

            case 'update-session': {
                // Update existing session data
                const sessionFile = '.flowforge/local/session.json';

                if (fs.existsSync(sessionFile)) {
                    const sessionData = JSON.parse(fs.readFileSync(sessionFile, 'utf8'));

                    // Update fields
                    if (options.files) sessionData.files = options.files.split(',');
                    if (options.lastAction) sessionData.lastAction = options.lastAction;
                    if (options.context) sessionData.context = JSON.parse(options.context);
                    sessionData.lastActivity = new Date().toISOString();

                    // Save updated data
                    fs.writeFileSync(sessionFile, JSON.stringify(sessionData, null, 2));

                    // @flowforge-bypass: rule8 - CLI output for user feedback
                    logger.info(formatOutput({ success: true, { data: [updated: true }, format] }));
                } else {
                    throw new Error('No active session to update');
                }
                break;
            }

            case 'clear-session': {
                // Clear session data
                const sessionFile = '.flowforge/local/session.json';

                if (fs.existsSync(sessionFile)) {
                    fs.unlinkSync(sessionFile);
                    // @flowforge-bypass: rule8 - CLI output for user feedback
                    logger.info(formatOutput({ success: true, { data: [cleared: true }, format] }));
                } else {
                    // @flowforge-bypass: rule8 - CLI output for user feedback
                    logger.info(formatOutput({ success: true, { data: [message: 'No session to clear' }, format] }));
                }
                break;
            }
            
            case 'aggregate-tasks': {
                // Use factory to get tasks from all providers
                const filter = {};
                if (options.status) filter.status = options.status;
                if (options.priority) filter.priority = options.priority;
                
                const result = await factory.aggregateTasks(filter);
                if (!result.success) {
                    throw new Error(`Failed to aggregate tasks: ${result.error.message}`);
                }
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'get-parallel-tasks': {
                // Get tasks that can be executed in parallel
                const tasksFilePath = options['tasks-file'] || '.flowforge/tasks.json';

                if (!fs.existsSync(tasksFilePath)) {
                    throw new Error(`Tasks file not found: ${tasksFilePath}`);
                }

                let tasksData;
                try {
                    // Use file locking for atomic read operation
                    tasksData = await fileLockManager.withLock(tasksFilePath, async () => {
                        const fileContent = await fs.promises.readFile(tasksFilePath, 'utf8');
                        return JSON.parse(fileContent);
                    });
                } catch (error) {
                    throw new Error(`Failed to parse tasks file: ${error.message}`);
                }
                
                const tasks = tasksData.tasks || [];
                const completedTaskIds = tasksData.metadata?.v2_2_0_completed || [];
                
                // Use DependencyResolver for parallel task detection
                const resolver = new DependencyResolver(tasks);
                const result = resolver.getParallelTasks(completedTaskIds);
                
                if (!result.success) {
                    throw new Error(`Failed to get parallel tasks: ${result.error.message}`);
                }
                
                // Include phase information if available
                const phases = tasksData.v2_2_0_phases || 
                              (tasksData.metadata && tasksData.metadata.v2_2_0_phases) || 
                              {};
                
                // Enrich with phase data
                result.data.phases = phases;
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'validate-dependencies': {
                // Validate dependencies for a specific task
                if (!options.id) {
                    throw new Error('Task ID required (--id=<id>)');
                }

                const tasksFilePath = options['tasks-file'] || '.flowforge/tasks.json';

                if (!fs.existsSync(tasksFilePath)) {
                    throw new Error(`Tasks file not found: ${tasksFilePath}`);
                }

                let tasksData;
                try {
                    // Use file locking for atomic read operation
                    tasksData = await fileLockManager.withLock(tasksFilePath, async () => {
                        const fileContent = await fs.promises.readFile(tasksFilePath, 'utf8');
                        return JSON.parse(fileContent);
                    });
                } catch (error) {
                    throw new Error(`Failed to parse tasks file: ${error.message}`);
                }
                
                const tasks = tasksData.tasks || [];
                const taskId = parseInt(options.id, 10);
                
                // Use DependencyResolver for validation
                const resolver = new DependencyResolver(tasks);
                const result = resolver.validateDependencies(taskId, {
                    checkPhaseGates: options['check-phase-gates'] === 'true'
                });
                
                if (!result.success) {
                    throw new Error(`Failed to validate dependencies: ${result.error.message}`);
                }
                
                // Check GitHub state if requested
                if (options['check-github'] === 'true' && provider.type === 'github') {
                    try {
                        const githubResult = await provider.getTask(taskId);
                        if (githubResult.success) {
                            result.data.githubStatus = githubResult.data.status;
                        }
                    } catch (error) {
                        // Non-fatal, continue without GitHub status
                        result.data.githubStatus = 'unknown';
                    }
                }
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'get-execution-plan': {
                // Get optimized execution plan
                const tasksFilePath = options['tasks-file'] || '.flowforge/tasks.json';

                if (!fs.existsSync(tasksFilePath)) {
                    throw new Error(`Tasks file not found: ${tasksFilePath}`);
                }

                let tasksData;
                try {
                    // Use file locking for atomic read operation
                    tasksData = await fileLockManager.withLock(tasksFilePath, async () => {
                        const fileContent = await fs.promises.readFile(tasksFilePath, 'utf8');
                        return JSON.parse(fileContent);
                    });
                } catch (error) {
                    throw new Error(`Failed to parse tasks file: ${error.message}`);
                }
                
                const tasks = tasksData.tasks || [];
                
                // Use DependencyResolver for execution planning
                const resolver = new DependencyResolver(tasks);
                const result = resolver.getExecutionPlan({
                    maxParallel: parseInt(options['max-parallel'] || '3', 10),
                    includeCompleted: options['include-completed'] === 'true',
                    groupByPhase: options['group-by-phase'] !== 'false'
                });
                
                if (!result.success) {
                    throw new Error(`Failed to get execution plan: ${result.error.message}`);
                }
                
                // Add metadata from tasks.json
                result.data.metadata = {
                    totalTasks: tasks.length,
                    activeMilestone: tasksData.metadata?.activeMilestone,
                    implementationOrder: tasksData.metadata?.v2_2_0_implementation_order || []
                };
                
                // @flowforge-bypass: rule8 - CLI output required for user feedback
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result.data, { context: format }));
                break;
            }
            
            case 'get-next-task': {
                // Enhanced get-next-task with dependency resolution and GitHub state checking
                const startTime = Date.now();

                // Allow override of tasks file for testing
                const tasksFilePath = options['tasks-file'] || '.flowforge/tasks.json';

                // Read tasks.json with file locking for atomic read
                if (!fs.existsSync(tasksFilePath)) {
                    throw new Error(`Tasks file not found: ${tasksFilePath}`);
                }

                let tasksData;
                try {
                    // Use file locking for atomic read operation
                    tasksData = await fileLockManager.withLock(tasksFilePath, async () => {
                        const fileContent = await fs.promises.readFile(tasksFilePath, 'utf8');
                        return JSON.parse(fileContent);
                    });
                } catch (error) {
                    throw new Error(`Failed to parse tasks file: ${error.message}`);
                }
                
                // Get implementation order - check both root and metadata locations
                const implementationOrder = tasksData.v2_2_0_implementation_order || 
                                           (tasksData.metadata && tasksData.metadata.v2_2_0_implementation_order) || 
                                           [];
                const phases = tasksData.v2_2_0_phases || 
                              (tasksData.metadata && tasksData.metadata.v2_2_0_phases) || 
                              {};
                const tasks = tasksData.tasks || [];
                
                // Use DependencyResolver for advanced dependency handling
                const resolver = new DependencyResolver(tasks);
                const taskMap = new Map();
                tasks.forEach(task => taskMap.set(task.id, task));
                
                // Check for circular dependencies upfront
                const cycleCheck = resolver.detectCycles();
                if (cycleCheck.hasCycles) {
                    throw new Error(`Circular dependencies detected: ${cycleCheck.cycles.join('; ')}`);
                }
                
                // Enhanced helper with GitHub state checking
                const areDependenciesMet = async (taskId) => {
                    const task = taskMap.get(taskId);
                    if (!task || !task.dependencies) return true;
                    
                    // Use resolver for validation
                    const validation = resolver.validateDependencies(taskId);
                    if (!validation.success) {
                        throw validation.error;
                    }
                    
                    // Check GitHub state if requested and available
                    if (options['check-github'] === 'true' && provider.type === 'github') {
                        for (const depId of task.dependencies) {
                            try {
                                const githubResult = await provider.getTask(depId);
                                if (githubResult.success) {
                                    const depTask = taskMap.get(depId);
                                    if (depTask && githubResult.data.status) {
                                        depTask.status = githubResult.data.status;
                                    }
                                }
                            } catch (error) {
                                // Non-fatal, continue with local state
                                if (options.debug) {
                // @flowforge-bypass: rule8 - CLI error output for user
                                    logger.error(`Warning: Could not check GitHub state for task ${depId}`);
                                }
                            }
                        }
                    }
                    
                    return validation.data.canStart;
                };
                
                // Enhanced helper with phase gate checking
                const isTaskAvailable = async (taskId) => {
                    const task = taskMap.get(taskId);
                    if (!task) return false;
                    
                    // Skip completed, blocked, or cancelled tasks
                    if (['completed', 'blocked', 'cancelled'].includes(task.status)) {
                        return false;
                    }
                    
                    // Check dependencies
                    const depsOk = await areDependenciesMet(taskId);
                    if (!depsOk) {
                        return false;
                    }
                    
                    // Check phase gates if enabled
                    if (options['check-phase-gates'] === 'true') {
                        const phaseGatesOk = resolver.checkPhaseGates(task);
                        if (!phaseGatesOk) {
                            return false;
                        }
                    }
                    
                    return true;
                };
                
                // Find next task with enhanced logic
                let nextTaskId = null;
                let reason = '';
                let parallelTasks = [];
                let suggestions = [];
                
                // First, try to find next task from implementation order
                for (const taskId of implementationOrder) {
                    const available = await isTaskAvailable(taskId);
                    if (available) {
                        nextTaskId = taskId;
                        reason = 'Next in implementation order';
                        
                        // If requested, find parallel tasks from same phase
                        if (options['include-parallel'] === 'true') {
                            // Find which phase this task belongs to
                            for (const [phaseName, phaseTasks] of Object.entries(phases)) {
                                if (phaseTasks.includes(taskId)) {
                                    // Add other available tasks from same phase
                                    for (const id of phaseTasks) {
                                        if (id !== taskId) {
                                            const parallelAvailable = await isTaskAvailable(id);
                                            if (parallelAvailable) {
                                                parallelTasks.push(id);
                                            }
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                        
                        break;
                    }
                }
                
                // If no task found, suggest what's blocking progress
                if (!nextTaskId && options['show-blockers'] === 'true') {
                    const blockers = [];
                    for (const taskId of implementationOrder) {
                        const task = taskMap.get(taskId);
                        if (task && !['completed', 'cancelled'].includes(task.status)) {
                            const validation = resolver.validateDependencies(taskId);
                            if (validation.success && validation.data.blockedBy.length > 0) {
                                blockers.push({
                                    taskId: taskId,
                                    title: task.title,
                                    blockedBy: validation.data.blockedBy
                                });
                            }
                        }
                    }
                    suggestions = blockers;
                }
                
                // Calculate performance metrics
                const executionTime = Date.now() - startTime;
                
                // Format output based on requested format
                if (format === 'simple') {
                // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(nextTaskId || 'NONE');
                } else if (format === 'json') {
                    const output = {
                        taskId: nextTaskId,
                        task: nextTaskId ? taskMap.get(nextTaskId) : null,
                        reason: nextTaskId ? reason : 'No available tasks',
                        parallel: parallelTasks,
                        suggestions: suggestions,
                        performance: {
                            executionTimeMs: executionTime,
                            tasksAnalyzed: tasks.length
                        }
                    };
                // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(JSON.stringify(output, { data: [null, 2] }));
                } else {
                    // Default text format
                    if (nextTaskId) {
                        const task = taskMap.get(nextTaskId);
                        // @flowforge-bypass: rule8 - CLI output needed
                // @flowforge-bypass: rule8 - CLI output needed
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(`Next task: #${nextTaskId} - ${task.title}`);
                        // @flowforge-bypass: rule8 - CLI output needed
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(`Reason: ${reason}`);
                        if (parallelTasks.length > 0) {
                            // @flowforge-bypass: rule8 - CLI output needed
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(`Parallel tasks available: ${parallelTasks.join(', { context: ' })}`);
                        }
                    } else {
                        // @flowforge-bypass: rule8 - CLI output needed
                // @flowforge-bypass: rule8 - CLI output needed
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info('No available tasks');
                        if (suggestions.length > 0) {
                // @flowforge-bypass: rule8 - CLI output for user interaction
                            logger.info('\nBlocked tasks:');
                            suggestions.forEach(s => {
                                // @flowforge-bypass: rule8 - CLI output needed
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(`  #${s.taskId} - ${s.title}`);
                // @flowforge-bypass: rule8 - CLI output for user interaction
                                logger.info(`    Blocked by: ${s.blockedBy.join(', { context: ' })}`);
                            });
                        }
                    }
                    if (options.debug) {
                // @flowforge-bypass: rule8 - CLI output for user interaction
                        logger.info(`\nExecution time: ${executionTime}ms`);
                    }
                }
                
                break;
            }
            
            case 'aggregate': {
                // Aggregate time data based on source and target
                const source = options.source || 'user';
                const target = options.target || 'team';
                const privacyMode = options['privacy-mode'] === 'true';
                const requireAuth = options['require-auth'] === 'true';
                
                // Validate source type
                const validSources = ['user', 'task', 'session'];
                if (!validSources.includes(source)) {
                    throw new Error(`Invalid source type: ${source}. Valid types: ${validSources.join(', ')}`);
                }
                
                // Check auth if required
                if (requireAuth && !process.env.FLOWFORGE_AUTH_TOKEN) {
                    throw new Error('Authentication required. Missing permission to aggregate to org level.');
                }
                
                const startTime = Date.now();
                const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
                const aggregator = getAggregator();
                
                try {
                    // Read source data
                    let sourceData = {};
                    if (source === 'user') {
                        const userPath = path.join(dataPath, 'user');
                        if (fs.existsSync(userPath)) {
                            const users = fs.readdirSync(userPath);
                            for (const user of users) {
                                const timePath = path.join(userPath, user, 'time.json');
                                if (fs.existsSync(timePath)) {
                                    const timeData = JSON.parse(fs.readFileSync(timePath, 'utf8'));
                                    sourceData[user] = timeData;
                                }
                            }
                        }
                    }
                    
                    // Process through aggregator
                    const aggregated = {};
                    for (const [key, data] of Object.entries(sourceData)) {
                        if (data.sessions) {
                            for (const session of data.sessions) {
                                // Map session data to aggregator format
                                await aggregator.add({
                                    userId: privacyMode ? 'anonymous' : (session.user || key),
                                    action: session.action || 'time-tracking',
                                    timestamp: session.startTime || Date.now(),
                                    metadata: {
                                        sessionId: session.id,
                                        taskId: session.taskId,
                                        duration: session.duration,
                                        endTime: session.endTime,
                                        sourceKey: privacyMode ? 'anonymous' : key
                                    }
                                });
                            }
                        }
                    }
                    
                    // Flush batches
                    let entriesProcessed = 0;
                    for (const [key, data] of Object.entries(sourceData)) {
                        if (data.sessions) {
                            entriesProcessed += data.sessions.length;
                        }
                    }
                    
                    await aggregator.flush();
                    
                    const result = {
                        aggregated: privacyMode ? { summary: { processed: entriesProcessed } } : sourceData,
                        metrics: {
                            processTime: Date.now() - startTime,
                            entriesProcessed: entriesProcessed,
                            batchesCreated: Math.ceil(entriesProcessed / 50) // Based on batch size
                        },
                        privacy: privacyMode
                    };
                    
                // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(formatOutput(result, { context: format }));
                } catch (error) {
                    throw new Error(`Aggregation failed: ${error.message}`);
                }
                break;
            }
            
            case 'aggregate-status': {
                // Get aggregation status and metrics
                const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
                const metricsPath = path.join(dataPath, 'aggregated', 'metrics.json');
                
                let metrics = {
                    totalBatches: 0,
                    successRate: 100,
                    lastRun: null,
                    pendingBatches: 0
                };
                
                let status = 'idle';
                
                // Try to read existing metrics
                if (fs.existsSync(metricsPath)) {
                    try {
                        const fileContent = fs.readFileSync(metricsPath, 'utf8');
                        metrics = JSON.parse(fileContent);
                        status = 'active';
                    } catch (error) {
                        // Corrupted file, recover
                        status = 'recovered';
                        // Write default metrics
                        fs.writeFileSync(metricsPath, JSON.stringify(metrics, null, 2));
                    }
                }
                
                // Check for pending batches
                const aggregator = getAggregator();
                const pendingCount = aggregator.batch ? aggregator.batch.length : 0;
                metrics.pendingBatches = pendingCount;
                
                const result = {
                    status,
                    metrics,
                    uptime: aggregatorInstance ? Date.now() - aggregatorInstance.startTime : 0
                };
                
                // @flowforge-bypass: rule8 - CLI output for user interaction
                logger.info(formatOutput(result, { context: format }));
                break;
            }
            
            case 'aggregate-force': {
                // Force immediate flush of pending batches
                const aggregator = getAggregator();
                const startTime = Date.now();
                
                try {
                    // Check for lock
                    const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
                    const lockPath = path.join(dataPath, 'aggregated', '.lock');
                    
                    if (fs.existsSync(lockPath)) {
                        const lockData = JSON.parse(fs.readFileSync(lockPath, 'utf8'));
                        if (Date.now() - lockData.timestamp < 5000) {
                            // Lock is active
                            const result = {
                                flushed: 0,
                                locked: true,
                                lockOwner: lockData.owner,
                                timestamp: new Date().toISOString()
                            };
                // @flowforge-bypass: rule8 - CLI output for user interaction
                            logger.info(formatOutput(result, { context: format }));
                            break;
                        }
                    }
                    
                    // Create lock
                    fs.mkdirSync(path.dirname(lockPath), { recursive: true });
                    fs.writeFileSync(lockPath, JSON.stringify({
                        owner: process.pid,
                        timestamp: Date.now()
                    }));
                    
                    // Force flush
                    const pendingBefore = aggregator.batch ? aggregator.batch.length : 0;
                    await aggregator.flush();
                    
                    // Remove lock
                    if (fs.existsSync(lockPath)) {
                        fs.unlinkSync(lockPath);
                    }
                    
                    const result = {
                        flushed: pendingBefore,
                        timestamp: new Date().toISOString(),
                        executionTime: Date.now() - startTime
                    };
                    
                // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(formatOutput(result, { context: format }));
                } catch (error) {
                    throw new Error(`Force flush failed: ${error.message}`);
                }
                break;
            }
            
            case 'aggregate-recover': {
                // Recover failed batches
                const batchId = options['batch-id'];
                const dataPath = process.env.FLOWFORGE_DATA_PATH || '.flowforge';
                const failedPath = path.join(dataPath, 'aggregated', 'failed');
                
                if (!fs.existsSync(failedPath)) {
                    fs.mkdirSync(failedPath, { recursive: true });
                }
                
                if (batchId) {
                    // Recover specific batch
                    const batchPath = path.join(failedPath, `${batchId}.json`);
                    if (!fs.existsSync(batchPath)) {
                        throw new Error(`Batch not found: ${batchId}`);
                    }
                    
                    const batchData = JSON.parse(fs.readFileSync(batchPath, 'utf8'));
                    
                    // Attempt recovery
                    const aggregator = getAggregator();
                    await processBatch(aggregator, batchData);
                    
                    // Remove from failed
                    fs.unlinkSync(batchPath);
                    
                    const result = {
                        recovered: batchId,
                        status: 'success',
                        timestamp: new Date().toISOString()
                    };
                    
                // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(formatOutput(result, { context: format }));
                } else {
                    // Recover all failed batches
                    const failedBatches = fs.readdirSync(failedPath)
                        .filter(f => f.endsWith('.json'));
                    
                    let recoveredCount = 0;
                    const aggregator = getAggregator();
                    
                    for (const batchFile of failedBatches) {
                        try {
                            const batchPath = path.join(failedPath, batchFile);
                            const batchData = JSON.parse(fs.readFileSync(batchPath, 'utf8'));
                            
                            await processBatch(aggregator, batchData);
                            fs.unlinkSync(batchPath);
                            recoveredCount++;
                        } catch (error) {
                            // Continue with next batch
                            if (options.debug) {
                // @flowforge-bypass: rule8 - CLI error output for user
                                logger.error(`Failed to recover ${batchFile}: ${error.message}`);
                            }
                        }
                    }
                    
                    const result = {
                        recoveredCount,
                        totalFailed: failedBatches.length,
                        successRate: failedBatches.length > 0 
                            ? (recoveredCount / failedBatches.length * 100).toFixed(2) 
                            : 100,
                        timestamp: new Date().toISOString()
                    };
                    
                // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(formatOutput(result, { context: format }));
                }
                break;
            }
            
            case 'detect-completion': {
                // Detect task completion status
                if (!options.id) {
                    throw new Error('Task ID required (--id=<id>)');
                }
                
                const detector = getCompletionDetector();
                if (!detector) {
                    throw new Error('EnhancedTaskCompletionDetector not available');
                }
                
                const taskId = options.id;
                const monitor = options.monitor === 'true';
                const confidenceThreshold = options.threshold ? parseFloat(options.threshold) : 0.7;
                
                if (monitor) {
                    // Start monitoring mode
                    const timeout = parseInt(options.timeout || '3600000', 10); // 1 hour default
                    
                    detector.startMonitoring(taskId, (result) => {
                        if (format === 'json') {
                            // @flowforge-bypass: rule8 - CLI output for user interaction
                            logger.info(JSON.stringify(result, { data: [null, 2] }));
                        } else {
                            // @flowforge-bypass: rule8 - CLI output for user interaction
                            logger.info(`✅ Task #${taskId} completed with ${(result.confidence * 100).toFixed(1)}% confidence`);
                            if (result.detectionMethods && result.detectionMethods.length > 0) {
                                // @flowforge-bypass: rule8 - CLI output for user interaction
                                logger.info(`Detection methods: ${result.detectionMethods.join(', { context: ' })}`);
                            }
                        }
                        process.exit(0);
                    }, { timeout });
                    
                    // Keep process alive for monitoring
                    process.on('SIGINT', () => {
                        detector.stopSync();
                        process.exit(0);
                    });
                    
                } else {
                    // Single check mode
                    const result = await detector.checkCompletion(taskId);
                    
                    if (format === 'json') {
                        // @flowforge-bypass: rule8 - CLI output for user interaction
                        logger.info(JSON.stringify(result, { data: [null, 2] }));
                    } else {
                        const status = result.completed ? '✅ COMPLETED' : '⏳ IN PROGRESS';
                        const confidence = (result.confidence * 100).toFixed(1);
                        
                        // @flowforge-bypass: rule8 - CLI output for user interaction
                        logger.info(`Task #${taskId}: ${status} (${confidence}% confidence)`);
                        
                        if (result.detectionMethods && result.detectionMethods.length > 0) {
                            // @flowforge-bypass: rule8 - CLI output for user interaction
                            logger.info(`Methods: ${result.detectionMethods.join(', { context: ' })}`);
                        }
                        
                        if (result.errors && result.errors.length > 0 && options.verbose) {
                            // @flowforge-bypass: rule8 - CLI output for user interaction
                            logger.info(`Errors: ${result.errors.join('; ')}`);
                        }
                    }
                    
                    // Exit with appropriate code
                    process.exit(result.completed && result.confidence >= confidenceThreshold ? 0 : 1);
                }
                break;
            }
            
            case 'get-completion-status': {
                // Get completion status for a task (simplified version of detect-completion)
                if (!options.id) {
                    throw new Error('Task ID required (--id=<id>)');
                }
                
                const detector = getCompletionDetector();
                if (!detector) {
                    throw new Error('EnhancedTaskCompletionDetector not available');
                }
                
                const result = await detector.checkCompletion(options.id);
                
                if (format === 'simple') {
                    // Simple output for bash scripting
                    // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(result.completed ? 'COMPLETED' : 'IN_PROGRESS');
                } else if (format === 'json') {
                    // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(JSON.stringify(result, { data: [null, 2] }));
                } else {
                    // Human-readable output
                    const status = result.completed ? 'COMPLETED' : 'IN_PROGRESS';
                    const confidence = (result.confidence * 100).toFixed(1);
                    
                    // @flowforge-bypass: rule8 - CLI output for user interaction
                    logger.info(`${status}|${confidence}|${result.detectionMethods?.join(', { context: ' }) || 'none'}`);
                }
                
                break;
            }
            
            case 'trigger-aggregation': {
                // Trigger immediate completion data aggregation
                const aggregator = getCompletionAggregator();
                if (!aggregator) {
                    throw new Error('CompletionAggregator not available');
                }
                
                const force = options.force === 'true';
                const teamSummary = options['team-summary'] === 'true';
                
                try {
                    const result = await aggregator.triggerAggregation();
                    
                    if (teamSummary) {
                        // Generate and update team summary
                        const stats = await aggregator.generateStatistics([]);
                        await aggregator.updateTeamSummary({
                            aggregationTriggered: true,
                            timestamp: new Date().toISOString(),
                            ...stats
                        });
                    }
                    
                    if (format === 'json') {
                        // @flowforge-bypass: rule8 - CLI output for user interaction
                        logger.info(JSON.stringify(result, { data: [null, 2] }));
                    } else {
                        if (result.success) {
                            // @flowforge-bypass: rule8 - CLI output for user interaction
                            logger.info('✅ Completion data aggregation triggered successfully');
                            if (result.stats) {
                                // @flowforge-bypass: rule8 - CLI output for user interaction
                                logger.info(`Processed: ${result.stats.processed}, { data: [Failed: ${result.stats.failed}`] });
                            }
                        } else {
                            // @flowforge-bypass: rule8 - CLI output for user interaction
                            logger.info(`❌ Aggregation failed: ${result.error}`);
                        }
                    }
                    
                } catch (error) {
                    throw new Error(`Aggregation trigger failed: ${error.message}`);
                }
                break;
            }
            
            default:
                // @flowforge-bypass: rule8 - CLI error output for user
                logger.error(`❌ Unknown action: ${action}`);
                // @flowforge-bypass: rule8 - CLI error output for user
                logger.error('Available actions: list-tasks, { data: [get-task, create-task, update-task, start-tracking, stop-tracking, search-tasks, get-provider, verify-task, verify-ticket, aggregate-tasks, get-next-task, get-parallel-tasks, validate-dependencies, get-execution-plan, aggregate, aggregate-status, aggregate-force, aggregate-recover, detect-completion, get-completion-status, trigger-aggregation'] });
                process.exit(1);
        }
        
    } catch (error) {
                // @flowforge-bypass: rule8 - CLI error output for user
        logger.error(`❌ ${error.message}`);
        if (options.debug) {
                // @flowforge-bypass: rule8 - CLI error output for user
            logger.error(error.stack);
        }
        
        // Clean up before error exit
        if (factory) {
            await factory.cleanup();
        }
        process.exit(1);
    }
    
    // Clean up after successful execution
    if (factory) {
        await factory.cleanup();
    }
    
    // Allow natural process termination
    // Node will exit when event loop is empty
}

// Run if executed directly
if (require.main === module) {
    main().catch(error => {
                // @flowforge-bypass: rule8 - CLI error output for user
        logger.error(`❌ Fatal error: ${error.message}`);
        process.exit(1);
    });
}

module.exports = {
    parseArgs,
    formatOutput,
    getAggregator,
    getRecoveryDaemon,
    processBatch,
    getCompletionDetector,
    getCompletionAggregator,
    detectMode,
    getProvider,
    getDeveloperNamespace,
    handleMissingConfig
};