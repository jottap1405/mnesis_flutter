import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'database_constants.dart';

/// SQLite database helper for managing chat message cache.
///
/// This class provides a singleton instance for database operations
/// including CRUD methods for message caching.
///
/// **Usage:**
/// ```dart
/// final db = DatabaseHelper.instance;
/// await db.insertMessage(messageData);
/// final messages = await db.getAllMessages();
/// ```
///
/// **Cache Strategy:**
/// - Messages cached locally for offline access
/// - Session-based grouping for conversation history
/// - Automatic cleanup of old messages
///
/// See also:
/// * [DatabaseConstants] - Database schema definitions
class DatabaseHelper {
  DatabaseHelper._(); // Private constructor for singleton

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;
  final _logger = Logger();

  // For testing - allows injection of mock database
  Database? _testDatabase;
  
  /// Creates a test instance with injected database for unit testing.
  ///
  /// This factory constructor allows us to inject a mock database
  /// for testing purposes while maintaining the singleton pattern
  /// for production use.
  ///
  /// **Usage (tests only):**
  /// ```dart
  /// final mockDb = MockDatabase();
  /// final helper = DatabaseHelper.testInstance(mockDb);
  /// ```
  factory DatabaseHelper.testInstance(Database database) {
    final instance = DatabaseHelper._();
    instance._testDatabase = database;
    return instance;
  }

  /// Gets the database instance, initializing if needed.
  ///
  /// Returns the test database if injected (for testing),
  /// otherwise returns the singleton database instance.
  ///
  /// Throws [DatabaseException] if initialization fails.
  Future<Database> get database async {
    // Return test database if injected
    if (_testDatabase != null) return _testDatabase!;
    
    // Return existing database if already initialized
    if (_database != null) return _database!;
    
    // Initialize new database
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database.
  ///
  /// Creates the database file in the app's documents directory
  /// and sets up the messages table.
  ///
  /// Throws [DatabaseException] if initialization fails.
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, DatabaseConstants.databaseName);
      
      _logger.i('Initializing database at: $path');
      
      return await openDatabase(
        path,
        version: DatabaseConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize database', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Creates database tables on first run.
  ///
  /// Called when the database is created for the first time.
  /// Creates the messages table with the schema defined in [DatabaseConstants].
  ///
  /// Throws [DatabaseException] if table creation fails.
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute(DatabaseConstants.createMessagesTable);
      await db.execute(DatabaseConstants.createSessionTimestampIndex);
      _logger.i('Messages table and indexes created successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to create messages table', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Handles database upgrades for future versions.
  ///
  /// Currently a no-op as we're on version 1.
  /// Future versions will implement migration logic here.
  ///
  /// [oldVersion] The previous database version
  /// [newVersion] The new database version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 1: Initial version, no upgrades needed yet
    _logger.i('Database upgrade from v$oldVersion to v$newVersion');
    
    // Future migration logic will go here
    // Example for future reference:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE messages ADD COLUMN new_field TEXT');
    // }
  }

  // Public methods for testing support
  
  /// Exposes onCreate for testing purposes.
  ///
  /// This method is public to allow testing of the onCreate callback.
  /// Should not be called directly in production code.
  Future<void> onCreate(Database db, int version) async {
    await _onCreate(db, version);
  }

  /// Exposes onUpgrade for testing purposes.
  ///
  /// This method is public to allow testing of the onUpgrade callback.
  /// Should not be called directly in production code.
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _onUpgrade(db, oldVersion, newVersion);
  }

  // CRUD Methods

  /// Validates message data has all required fields and correct types.
  ///
  /// Throws [ArgumentError] if:
  /// - Any required field is missing
  /// - Any required field is null
  /// - [is_ai] field is not an integer
  /// - [timestamp] field is not an integer
  ///
  /// This provides fail-fast validation with clear error messages.
  void _validateMessageData(Map<String, dynamic> message) {
    final requiredFields = [
      DatabaseConstants.columnId,
      DatabaseConstants.columnContent,
      DatabaseConstants.columnIsAi,
      DatabaseConstants.columnTimestamp,
      DatabaseConstants.columnSessionId,
    ];

    // Check all required fields exist and are not null
    for (final field in requiredFields) {
      if (!message.containsKey(field)) {
        throw ArgumentError('Missing required field: $field');
      }
      if (message[field] == null) {
        throw ArgumentError('Field cannot be null: $field');
      }
    }

    // Type validation for integer fields
    if (message[DatabaseConstants.columnIsAi] is! int) {
      throw ArgumentError(
        'Field ${DatabaseConstants.columnIsAi} must be an integer (0 or 1), '
        'got: ${message[DatabaseConstants.columnIsAi].runtimeType}'
      );
    }

    if (message[DatabaseConstants.columnTimestamp] is! int) {
      throw ArgumentError(
        'Field ${DatabaseConstants.columnTimestamp} must be an integer (milliseconds since epoch), '
        'got: ${message[DatabaseConstants.columnTimestamp].runtimeType}'
      );
    }

    _logger.d('Message validation passed for ID: ${message[DatabaseConstants.columnId]}');
  }

  /// Inserts a new message into the cache.
  ///
  /// Replaces existing message if ID already exists.
  ///
  /// [message] Map containing message data with the following keys:
  /// - id: Unique message identifier (TEXT)
  /// - content: Message text content (TEXT)
  /// - is_ai: 1 if AI message, 0 if user message (INTEGER)
  /// - timestamp: Message timestamp in milliseconds since epoch (INTEGER)
  /// - session_id: Session identifier for grouping messages (TEXT)
  ///
  /// Returns the row ID of the inserted message.
  ///
  /// Throws [ArgumentError] if message data is invalid (missing fields, wrong types).
  /// Throws [DatabaseException] if insertion fails.
  ///
  /// Example:
  /// ```dart
  /// final message = {
  ///   'id': 'msg_123',
  ///   'content': 'Hello, doctor',
  ///   'is_ai': 0,
  ///   'timestamp': DateTime.now().millisecondsSinceEpoch,
  ///   'session_id': 'session_456',
  /// };
  /// await db.insertMessage(message);
  /// ```
  Future<int> insertMessage(Map<String, dynamic> message) async {
    _validateMessageData(message);

    try {
      final db = await database;

      // Use test database if available
      final targetDb = _testDatabase ?? db;

      final result = await targetDb.insert(
        DatabaseConstants.tableMessages,
        message,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.d('Message inserted with ID: ${message[DatabaseConstants.columnId]}');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Failed to insert message', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Gets all messages ordered by timestamp (oldest first).
  ///
  /// Returns a list of message maps containing all fields
  /// from the messages table, ordered by timestamp ascending.
  ///
  /// Returns an empty list if no messages exist.
  ///
  /// Throws [DatabaseException] if query fails.
  Future<List<Map<String, dynamic>>> getAllMessages() async {
    try {
      final db = await database;
      
      // Use test database if available
      final targetDb = _testDatabase ?? db;
      
      final messages = await targetDb.query(
        DatabaseConstants.tableMessages,
        orderBy: '${DatabaseConstants.columnTimestamp} ASC',
      );
      
      _logger.d('Retrieved ${messages.length} messages');
      return messages;
    } catch (e, stackTrace) {
      _logger.e('Failed to get all messages', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Gets messages for a specific session.
  ///
  /// [sessionId] The session identifier to filter messages by
  ///
  /// Returns a list of message maps for the specified session,
  /// ordered by timestamp ascending.
  ///
  /// Returns an empty list if no messages exist for the session.
  ///
  /// Throws [DatabaseException] if query fails.
  Future<List<Map<String, dynamic>>> getMessagesBySession(String sessionId) async {
    try {
      final db = await database;
      
      // Use test database if available
      final targetDb = _testDatabase ?? db;
      
      final messages = await targetDb.query(
        DatabaseConstants.tableMessages,
        where: '${DatabaseConstants.columnSessionId} = ?',
        whereArgs: [sessionId],
        orderBy: '${DatabaseConstants.columnTimestamp} ASC',
      );
      
      _logger.d('Retrieved ${messages.length} messages for session: $sessionId');
      return messages;
    } catch (e, stackTrace) {
      _logger.e('Failed to get messages for session: $sessionId', 
                error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes a message by ID.
  ///
  /// [id] The unique identifier of the message to delete
  ///
  /// Returns the number of rows affected (1 if deleted, 0 if not found).
  ///
  /// Throws [DatabaseException] if deletion fails.
  Future<int> deleteMessage(String id) async {
    try {
      final db = await database;
      
      // Use test database if available
      final targetDb = _testDatabase ?? db;
      
      final result = await targetDb.delete(
        DatabaseConstants.tableMessages,
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [id],
      );
      
      _logger.d('Deleted $result message(s) with ID: $id');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Failed to delete message with ID: $id', 
                error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes messages older than specified timestamp.
  ///
  /// [timestampBefore] Delete messages with timestamp less than this value
  ///
  /// Returns the number of messages deleted.
  ///
  /// Throws [DatabaseException] if deletion fails.
  Future<int> deleteOldMessages(int timestampBefore) async {
    try {
      final db = await database;
      
      // Use test database if available
      final targetDb = _testDatabase ?? db;
      
      final result = await targetDb.delete(
        DatabaseConstants.tableMessages,
        where: '${DatabaseConstants.columnTimestamp} < ?',
        whereArgs: [timestampBefore],
      );
      
      _logger.d('Deleted $result old messages before timestamp: $timestampBefore');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Failed to delete old messages', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Clears all messages from cache.
  ///
  /// Deletes all messages from the messages table.
  /// Use with caution as this operation cannot be undone.
  ///
  /// Returns the number of messages deleted.
  ///
  /// Throws [DatabaseException] if deletion fails.
  Future<int> clearAllMessages() async {
    try {
      final db = await database;
      
      // Use test database if available
      final targetDb = _testDatabase ?? db;
      
      final result = await targetDb.delete(DatabaseConstants.tableMessages);
      
      _logger.i('Cleared all $result messages from cache');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Failed to clear all messages', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Closes the database connection.
  ///
  /// Should be called when the app is terminating or when
  /// the database is no longer needed.
  ///
  /// Throws [DatabaseException] if close operation fails.
  Future<void> close() async {
    try {
      if (_testDatabase != null) {
        await _testDatabase!.close();
        _testDatabase = null;
        _logger.d('Test database connection closed');
      } else if (_database != null) {
        await _database!.close();
        _database = null;
        _logger.i('Database connection closed');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to close database', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
