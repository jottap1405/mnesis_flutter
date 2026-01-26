/// Database constants for SQLite message cache.
///
/// This file defines the schema and constants for the messages table
/// used to cache chat messages locally.
class DatabaseConstants {
  DatabaseConstants._();

  // Database metadata
  static const String databaseName = 'mnesis.db';
  static const int databaseVersion = 2;

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

  // Patients cache table
  static const String tablePatientsCache = 'patients_cache';
  static const String columnFullName = 'full_name';
  static const String columnAge = 'age';
  static const String columnAppointmentType = 'appointment_type';
  static const String columnAppointmentDate = 'appointment_date';
  static const String columnAppointmentTime = 'appointment_time';
  static const String columnAppointmentStatus = 'appointment_status';
  static const String columnIsRecent = 'is_recent';
  static const String columnIsUpcoming = 'is_upcoming';
  static const String columnLastSyncedAt = 'last_synced_at';
  static const String columnSupabaseId = 'supabase_id';
  static const String columnSyncStatus = 'sync_status';
  static const String columnMetadata = 'metadata';
  static const String columnActive = 'active';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Attachments cache table
  static const String tableAttachmentsCache = 'attachments_cache';
  static const String columnFilename = 'filename';
  static const String columnFileType = 'file_type';
  static const String columnFileSizeBytes = 'file_size_bytes';
  static const String columnPatientId = 'patient_id';
  static const String columnLocalPath = 'local_path';
  static const String columnRemoteUrl = 'remote_url';
  static const String columnDownloadStatus = 'download_status';
  static const String columnFileSizeDisplay = 'file_size_display';
  static const String columnThumbnailPath = 'thumbnail_path';

  // Auth tokens table
  static const String tableAuthTokens = 'auth_tokens';
  static const String columnUserId = 'user_id';
  static const String columnTokenType = 'token_type';
  static const String columnExpiresAt = 'expires_at';
  static const String columnIsExpired = 'is_expired';
  static const String columnLastRefreshedAt = 'last_refreshed_at';
  static const String columnRefreshCount = 'refresh_count';
  static const String columnDeviceId = 'device_id';
  static const String columnIpAddress = 'ip_address';

  // SQL Create Tables (v2 migration)
  static const String createPatientsCacheTable = '''
    CREATE TABLE $tablePatientsCache (
      $columnId TEXT PRIMARY KEY,
      $columnActive INTEGER NOT NULL DEFAULT 1,
      $columnCreatedAt INTEGER NOT NULL,
      $columnUpdatedAt INTEGER NOT NULL,
      $columnFullName TEXT NOT NULL,
      $columnAge INTEGER,
      $columnAppointmentType TEXT,
      $columnAppointmentDate TEXT,
      $columnAppointmentTime TEXT,
      $columnAppointmentStatus TEXT,
      $columnIsRecent INTEGER NOT NULL DEFAULT 0,
      $columnIsUpcoming INTEGER NOT NULL DEFAULT 0,
      $columnLastSyncedAt INTEGER,
      $columnSupabaseId TEXT UNIQUE,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced',
      $columnMetadata TEXT
    )
  ''';

  static const String createAttachmentsCacheTable = '''
    CREATE TABLE $tableAttachmentsCache (
      $columnId TEXT PRIMARY KEY,
      $columnActive INTEGER NOT NULL DEFAULT 1,
      $columnCreatedAt INTEGER NOT NULL,
      $columnUpdatedAt INTEGER NOT NULL,
      $columnFilename TEXT NOT NULL,
      $columnFileType TEXT NOT NULL,
      $columnFileSizeBytes INTEGER NOT NULL,
      $columnPatientId TEXT NOT NULL,
      $columnLocalPath TEXT,
      $columnRemoteUrl TEXT,
      $columnDownloadStatus TEXT NOT NULL DEFAULT 'pending',
      $columnFileSizeDisplay TEXT,
      $columnThumbnailPath TEXT,
      $columnLastSyncedAt INTEGER,
      $columnSupabaseId TEXT UNIQUE,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced',
      $columnMetadata TEXT,
      FOREIGN KEY ($columnPatientId) REFERENCES $tablePatientsCache($columnId) ON DELETE CASCADE
    )
  ''';

  static const String createAuthTokensTable = '''
    CREATE TABLE $tableAuthTokens (
      $columnId TEXT PRIMARY KEY,
      $columnActive INTEGER NOT NULL DEFAULT 1,
      $columnCreatedAt INTEGER NOT NULL,
      $columnUpdatedAt INTEGER NOT NULL,
      $columnUserId TEXT NOT NULL,
      $columnTokenType TEXT NOT NULL,
      $columnExpiresAt INTEGER NOT NULL,
      $columnIsExpired INTEGER NOT NULL DEFAULT 0,
      $columnLastRefreshedAt INTEGER,
      $columnRefreshCount INTEGER NOT NULL DEFAULT 0,
      $columnDeviceId TEXT,
      $columnIpAddress TEXT,
      $columnLastSyncedAt INTEGER,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced',
      $columnMetadata TEXT
    )
  ''';

  // SQL Create Indexes (v2 migration)

  // Patients cache indexes
  static const String createPatientsActiveIndex = '''
    CREATE INDEX idx_patients_active
    ON $tablePatientsCache($columnActive)
    WHERE $columnActive = 1
  ''';

  static const String createPatientsSupabaseIdIndex = '''
    CREATE INDEX idx_patients_supabase_id
    ON $tablePatientsCache($columnSupabaseId)
  ''';

  static const String createPatientsRecentIndex = '''
    CREATE INDEX idx_patients_recent
    ON $tablePatientsCache($columnIsRecent, $columnCreatedAt DESC)
    WHERE $columnIsRecent = 1 AND $columnActive = 1
  ''';

  static const String createPatientsUpcomingIndex = '''
    CREATE INDEX idx_patients_upcoming
    ON $tablePatientsCache($columnIsUpcoming, $columnAppointmentDate ASC)
    WHERE $columnIsUpcoming = 1 AND $columnActive = 1
  ''';

  static const String createPatientsSyncStatusIndex = '''
    CREATE INDEX idx_patients_sync_status
    ON $tablePatientsCache($columnSyncStatus, $columnLastSyncedAt DESC)
    WHERE $columnActive = 1
  ''';

  // Attachments cache indexes
  static const String createAttachmentsActiveIndex = '''
    CREATE INDEX idx_attachments_active
    ON $tableAttachmentsCache($columnActive)
    WHERE $columnActive = 1
  ''';

  static const String createAttachmentsPatientIdIndex = '''
    CREATE INDEX idx_attachments_patient_id
    ON $tableAttachmentsCache($columnPatientId, $columnCreatedAt DESC)
    WHERE $columnActive = 1
  ''';

  static const String createAttachmentsSupabaseIdIndex = '''
    CREATE INDEX idx_attachments_supabase_id
    ON $tableAttachmentsCache($columnSupabaseId)
  ''';

  static const String createAttachmentsDownloadStatusIndex = '''
    CREATE INDEX idx_attachments_download_status
    ON $tableAttachmentsCache($columnDownloadStatus, $columnCreatedAt DESC)
    WHERE $columnActive = 1
  ''';

  static const String createAttachmentsSyncStatusIndex = '''
    CREATE INDEX idx_attachments_sync_status
    ON $tableAttachmentsCache($columnSyncStatus, $columnLastSyncedAt DESC)
    WHERE $columnActive = 1
  ''';

  // Auth tokens indexes
  static const String createAuthTokensActiveIndex = '''
    CREATE INDEX idx_auth_tokens_active
    ON $tableAuthTokens($columnActive)
    WHERE $columnActive = 1
  ''';

  static const String createAuthTokensUserIdIndex = '''
    CREATE INDEX idx_auth_tokens_user_id
    ON $tableAuthTokens($columnUserId, $columnTokenType)
    WHERE $columnActive = 1
  ''';

  static const String createAuthTokensExpiresAtIndex = '''
    CREATE INDEX idx_auth_tokens_expires_at
    ON $tableAuthTokens($columnExpiresAt ASC)
    WHERE $columnActive = 1 AND $columnIsExpired = 0
  ''';

  static const String createAuthTokensDeviceIdIndex = '''
    CREATE INDEX idx_auth_tokens_device_id
    ON $tableAuthTokens($columnDeviceId, $columnCreatedAt DESC)
    WHERE $columnActive = 1
  ''';
}
