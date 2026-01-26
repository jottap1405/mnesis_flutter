import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/database/database_constants.dart';
import 'package:mnesis_flutter/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Test suite for v1→v2 migration constraints and behavior validation.
///
/// Tests foreign keys, soft deletes, defaults, and error handling.
void runMigrationConstraintsTests() {
  group('Constraints & Behavior', () {
    late Database testDb;
    late DatabaseHelper helper;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(DatabaseConstants.createMessagesTable);
        },
      );
      helper = DatabaseHelper.testInstance(testDb);
      await helper.onUpgrade(testDb, 1, 2);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('foreign key cascade delete attachments to patients', () async {
      // Arrange: Enable foreign keys
      await testDb.execute('PRAGMA foreign_keys = ON');

      // Insert patient
      await testDb.insert('patients_cache', {
        'id': 'patient-1',
        'active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'full_name': 'John Doe',
        'sync_status': 'synced',
      });

      // Insert attachment linked to patient
      await testDb.insert('attachments_cache', {
        'id': 'attachment-1',
        'active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'filename': 'test.pdf',
        'file_type': 'pdf',
        'file_size_bytes': 1024,
        'patient_id': 'patient-1',
        'download_status': 'pending',
        'sync_status': 'synced',
      });

      // Act: Delete patient
      await testDb
          .delete('patients_cache', where: 'id = ?', whereArgs: ['patient-1']);

      // Assert: Attachment should be cascade deleted
      final attachments = await testDb.query('attachments_cache');
      expect(attachments.length, 0);
    });

    test('soft delete pattern with active column', () async {
      // Arrange: Insert patient
      await testDb.insert('patients_cache', {
        'id': 'patient-1',
        'active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'full_name': 'Jane Doe',
        'sync_status': 'synced',
      });

      // Act: Soft delete (set active = 0)
      await testDb.update(
        'patients_cache',
        {'active': 0},
        where: 'id = ?',
        whereArgs: ['patient-1'],
      );

      // Assert: Record still exists but marked inactive
      final allPatients = await testDb.query('patients_cache');
      expect(allPatients.length, 1);

      final activePatients = await testDb.query(
        'patients_cache',
        where: 'active = 1',
      );
      expect(activePatients.length, 0);

      final inactivePatients = await testDb.query(
        'patients_cache',
        where: 'active = 0',
      );
      expect(inactivePatients.length, 1);
    });

    test('default values applied correctly', () async {
      // Arrange & Act: Insert minimal patient data
      await testDb.insert('patients_cache', {
        'id': 'patient-1',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'full_name': 'Default Test',
      });

      // Assert: Verify default values
      final result = await testDb.query(
        'patients_cache',
        where: 'id = ?',
        whereArgs: ['patient-1'],
      );

      expect(result[0]['active'], 1); // DEFAULT 1
      expect(result[0]['is_recent'], 0); // DEFAULT 0
      expect(result[0]['is_upcoming'], 0); // DEFAULT 0
      expect(result[0]['sync_status'], 'synced'); // DEFAULT 'synced'
    });

    test('unique constraint on supabase_id', () async {
      // Arrange: Insert first patient
      await testDb.insert('patients_cache', {
        'id': 'patient-1',
        'active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'full_name': 'Patient 1',
        'supabase_id': 'supabase-123',
        'sync_status': 'synced',
      });

      // Act & Assert: Try to insert duplicate supabase_id
      expect(
        () async => await testDb.insert('patients_cache', {
          'id': 'patient-2',
          'active': 1,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'full_name': 'Patient 2',
          'supabase_id': 'supabase-123', // Duplicate
          'sync_status': 'synced',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('partial index effectiveness', () async {
      // Arrange: Insert patients with different active states
      await testDb.insert('patients_cache', {
        'id': 'patient-1',
        'active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'full_name': 'Active Patient',
        'sync_status': 'synced',
      });

      await testDb.insert('patients_cache', {
        'id': 'patient-2',
        'active': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'full_name': 'Inactive Patient',
        'sync_status': 'synced',
      });

      // Act: Query using partial index (active = 1)
      final activePatients = await testDb.query(
        'patients_cache',
        where: 'active = 1',
      );

      // Assert: Verify partial index returns correct results
      expect(activePatients.length, 1);
      expect(activePatients[0]['id'], 'patient-1');

      // Verify index exists and is partial
      final indexes = await testDb.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='index' AND name='idx_patients_active'",
      );
      expect(indexes.isNotEmpty, true);
      expect(indexes[0]['sql'].toString().toLowerCase(), contains('where'));
    });

    test('migration error handling rethrows', () async {
      // Arrange: Close database to cause error
      await testDb.close();

      // Act & Assert: Verify error is rethrown
      expect(
        () async => await helper.onUpgrade(testDb, 1, 2),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
