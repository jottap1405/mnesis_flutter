import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Test suite for v1→v2 migration schema validation.
///
/// Tests table schemas, column definitions, and index creation.
void runMigrationSchemaTests() {
  group('Schema Validation', () {
    late Database testDb;
    late DatabaseHelper helper;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE messages (
              id TEXT PRIMARY KEY,
              content TEXT NOT NULL,
              is_ai INTEGER NOT NULL,
              timestamp INTEGER NOT NULL,
              session_id TEXT NOT NULL
            )
          ''');
        },
      );
      helper = DatabaseHelper.testInstance(testDb);
      await helper.onUpgrade(testDb, 1, 2);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('patients_cache has correct columns', () async {
      // Act
      final columns = await testDb.rawQuery('PRAGMA table_info(patients_cache)');

      // Assert: Verify all 16 columns exist
      final columnNames = columns.map((col) => col['name'] as String).toList();

      expect(columnNames, containsAll([
        'id',
        'active',
        'created_at',
        'updated_at',
        'full_name',
        'age',
        'appointment_type',
        'appointment_date',
        'appointment_time',
        'appointment_status',
        'is_recent',
        'is_upcoming',
        'last_synced_at',
        'supabase_id',
        'sync_status',
        'metadata',
      ]));

      // Verify column count
      expect(columns.length, 16);

      // Verify primary key
      final pkColumn = columns.firstWhere((col) => col['pk'] == 1);
      expect(pkColumn['name'], 'id');

      // Verify NOT NULL constraints
      final activeColumn = columns.firstWhere((col) => col['name'] == 'active');
      expect(activeColumn['notnull'], 1);

      final fullNameColumn =
          columns.firstWhere((col) => col['name'] == 'full_name');
      expect(fullNameColumn['notnull'], 1);
    });

    test('attachments_cache has correct columns', () async {
      // Act
      final columns = await testDb.rawQuery('PRAGMA table_info(attachments_cache)');

      // Assert: Verify all 17 columns exist
      final columnNames = columns.map((col) => col['name'] as String).toList();

      expect(columnNames, containsAll([
        'id',
        'active',
        'created_at',
        'updated_at',
        'filename',
        'file_type',
        'file_size_bytes',
        'patient_id',
        'local_path',
        'remote_url',
        'download_status',
        'file_size_display',
        'thumbnail_path',
        'last_synced_at',
        'supabase_id',
        'sync_status',
        'metadata',
      ]));

      expect(columns.length, 17);

      // Verify primary key
      final pkColumn = columns.firstWhere((col) => col['pk'] == 1);
      expect(pkColumn['name'], 'id');

      // Verify required NOT NULL constraints
      final filenameColumn =
          columns.firstWhere((col) => col['name'] == 'filename');
      expect(filenameColumn['notnull'], 1);

      final fileTypeColumn =
          columns.firstWhere((col) => col['name'] == 'file_type');
      expect(fileTypeColumn['notnull'], 1);
    });

    test('auth_tokens has correct columns', () async {
      // Act
      final columns = await testDb.rawQuery('PRAGMA table_info(auth_tokens)');

      // Assert: Verify all 15 columns exist
      final columnNames = columns.map((col) => col['name'] as String).toList();

      expect(columnNames, containsAll([
        'id',
        'active',
        'created_at',
        'updated_at',
        'user_id',
        'token_type',
        'expires_at',
        'is_expired',
        'last_refreshed_at',
        'refresh_count',
        'device_id',
        'ip_address',
        'last_synced_at',
        'sync_status',
        'metadata',
      ]));

      expect(columns.length, 15);

      // Verify primary key
      final pkColumn = columns.firstWhere((col) => col['pk'] == 1);
      expect(pkColumn['name'], 'id');

      // Verify required NOT NULL constraints
      final userIdColumn = columns.firstWhere((col) => col['name'] == 'user_id');
      expect(userIdColumn['notnull'], 1);

      final expiresAtColumn =
          columns.firstWhere((col) => col['name'] == 'expires_at');
      expect(expiresAtColumn['notnull'], 1);
    });

    test('patients_cache has all 5 indexes', () async {
      // Act
      final indexes = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='patients_cache'",
      );

      // Assert: 5 custom indexes
      final indexNames = indexes.map((idx) => idx['name'] as String).toList();

      expect(indexNames, containsAll([
        'idx_patients_active',
        'idx_patients_supabase_id',
        'idx_patients_recent',
        'idx_patients_upcoming',
        'idx_patients_sync_status',
      ]));

      // Note: May have additional auto-created indexes (e.g., for UNIQUE constraints)
      expect(indexNames.length, greaterThanOrEqualTo(5));
    });

    test('attachments_cache has all 5 indexes', () async {
      // Act
      final indexes = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='attachments_cache'",
      );

      // Assert
      final indexNames = indexes.map((idx) => idx['name'] as String).toList();

      expect(indexNames, containsAll([
        'idx_attachments_active',
        'idx_attachments_patient_id',
        'idx_attachments_supabase_id',
        'idx_attachments_download_status',
        'idx_attachments_sync_status',
      ]));

      expect(indexNames.length, greaterThanOrEqualTo(5));
    });

    test('auth_tokens has all 4 indexes', () async {
      // Act
      final indexes = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='auth_tokens'",
      );

      // Assert
      final indexNames = indexes.map((idx) => idx['name'] as String).toList();

      expect(indexNames, containsAll([
        'idx_auth_tokens_active',
        'idx_auth_tokens_user_id',
        'idx_auth_tokens_expires_at',
        'idx_auth_tokens_device_id',
      ]));

      expect(indexNames.length, greaterThanOrEqualTo(4));
    });
  });
}
