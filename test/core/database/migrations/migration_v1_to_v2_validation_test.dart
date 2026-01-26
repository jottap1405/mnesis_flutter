import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/database/database_constants.dart';
import 'package:mnesis_flutter/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Test suite for v1→v2 migration validation.
///
/// Tests migration execution, table creation, and data preservation.
void runMigrationValidationTests() {
  group('Migration Validation', () {
    late Database testDb;
    late DatabaseHelper helper;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(DatabaseConstants.createMessagesTable);
          await db.execute(DatabaseConstants.createSessionTimestampIndex);
        },
      );
      helper = DatabaseHelper.testInstance(testDb);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('migration from v1 to v2 creates patients_cache table', () async {
      // Act: Trigger migration
      await helper.onUpgrade(testDb, 1, 2);

      // Assert: Verify table exists
      final tables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='patients_cache'",
      );
      expect(tables.length, 1);
      expect(tables[0]['name'], 'patients_cache');
    });

    test('migration from v1 to v2 creates attachments_cache table', () async {
      // Act
      await helper.onUpgrade(testDb, 1, 2);

      // Assert
      final tables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='attachments_cache'",
      );
      expect(tables.length, 1);
      expect(tables[0]['name'], 'attachments_cache');
    });

    test('migration from v1 to v2 creates auth_tokens table', () async {
      // Act
      await helper.onUpgrade(testDb, 1, 2);

      // Assert
      final tables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='auth_tokens'",
      );
      expect(tables.length, 1);
      expect(tables[0]['name'], 'auth_tokens');
    });

    test('migration creates all 14 indexes', () async {
      // Act
      await helper.onUpgrade(testDb, 1, 2);

      // Assert: Count indexes (excluding auto-created sqlite indexes)
      final indexes = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
      );

      // 14 new indexes + 1 existing (idx_session_timestamp) = 15 total
      expect(indexes.length, 15);
    });

    test('migration preserves existing messages table', () async {
      // Arrange: Insert test message before migration
      await testDb.insert('messages', {
        'id': 'test-message-1',
        'content': 'Test message content',
        'is_ai': 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'session_id': 'test-session',
      });

      // Act
      await helper.onUpgrade(testDb, 1, 2);

      // Assert: Verify messages table still exists
      final tables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='messages'",
      );
      expect(tables.length, 1);

      // Verify table structure preserved
      final columns = await testDb.rawQuery('PRAGMA table_info(messages)');
      expect(columns.length, 5); // id, content, is_ai, timestamp, session_id
    });

    test('migration preserves existing data', () async {
      // Arrange: Insert test messages
      final testMessages = [
        {
          'id': 'msg-1',
          'content': 'Message 1',
          'is_ai': 0,
          'timestamp': 1000,
          'session_id': 'session-1',
        },
        {
          'id': 'msg-2',
          'content': 'Message 2',
          'is_ai': 1,
          'timestamp': 2000,
          'session_id': 'session-1',
        },
      ];

      for (final msg in testMessages) {
        await testDb.insert('messages', msg);
      }

      // Act: Perform migration
      await helper.onUpgrade(testDb, 1, 2);

      // Assert: Verify all messages preserved
      final messages = await testDb.query('messages');
      expect(messages.length, 2);
      expect(messages[0]['id'], 'msg-1');
      expect(messages[0]['content'], 'Message 1');
      expect(messages[1]['id'], 'msg-2');
      expect(messages[1]['content'], 'Message 2');
    });

    test('migration from v0 to v2 skips v1 migration properly', () async {
      // Note: This tests idempotency - if oldVersion < 2, we run v2 migration
      // Act
      await helper.onUpgrade(testDb, 0, 2);

      // Assert: All v2 tables should exist
      final tables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('patients_cache', 'attachments_cache', 'auth_tokens')",
      );
      expect(tables.length, 3);
    });

    test('migration idempotency prevents duplicate runs', () async {
      // Act: Run migration twice
      await helper.onUpgrade(testDb, 1, 2);

      // Try to run migration again (should not fail or duplicate)
      // In practice, this won't happen as DB version prevents it,
      // but we test the condition logic
      await helper.onUpgrade(testDb, 2, 2);

      // Assert: Verify tables still exist and are not duplicated
      final tables = await testDb.rawQuery(
        "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table'",
      );
      // Should have: messages, patients_cache, attachments_cache, auth_tokens = 4 tables
      expect(tables[0]['count'], 4);
    });
  });
}
