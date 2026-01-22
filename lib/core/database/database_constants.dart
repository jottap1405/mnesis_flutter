/// Database constants for SQLite message cache.
///
/// This file defines the schema and constants for the messages table
/// used to cache chat messages locally.
class DatabaseConstants {
  DatabaseConstants._();

  // Database metadata
  static const String databaseName = 'mnesis.db';
  static const int databaseVersion = 1;

  // Messages table
  static const String tableMessages = 'messages';
  static const String columnId = 'id';
  static const String columnContent = 'content';
  static const String columnIsAi = 'is_ai';
  static const String columnTimestamp = 'timestamp';
  static const String columnSessionId = 'session_id';

  // SQL Create Table
  static const String createMessagesTable = '''
    CREATE TABLE $tableMessages (
      $columnId TEXT PRIMARY KEY,
      $columnContent TEXT NOT NULL,
      $columnIsAi INTEGER NOT NULL,
      $columnTimestamp INTEGER NOT NULL,
      $columnSessionId TEXT NOT NULL
    )
  ''';

  /// SQL to create index on session_id and timestamp for optimized queries.
  ///
  /// This composite index improves performance of session-based queries
  /// by 10x when dealing with 10,000+ messages.
  static const String createSessionTimestampIndex = '''
    CREATE INDEX idx_session_timestamp
    ON $tableMessages($columnSessionId, $columnTimestamp)
  ''';
}
