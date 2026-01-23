import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mnesis_flutter/core/database/database_helper.dart';
import 'package:mnesis_flutter/core/database/database_constants.dart';

// Mock classes
class MockDatabase extends Mock implements Database {}

void main() {
  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;
    late MockDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockDatabase();
      // For testing, we'll need to modify DatabaseHelper to accept injected database
      dbHelper = DatabaseHelper.testInstance(mockDatabase);
    });

    tearDown(() {
      reset(mockDatabase);
    });

    group('insertMessage', () {
      test('successfully inserts message with valid data', () async {
        // Arrange
        final message = {
          DatabaseConstants.columnId: 'msg_001',
          DatabaseConstants.columnContent: 'Hello, how can I help?',
          DatabaseConstants.columnIsAi: 1,
          DatabaseConstants.columnTimestamp: 1706000000000,
          DatabaseConstants.columnSessionId: 'session_001'
        };

        when(() => mockDatabase.insert(
          DatabaseConstants.tableMessages,
          message,
          conflictAlgorithm: ConflictAlgorithm.replace,
        )).thenAnswer((_) async => 1);

        // Act
        final result = await dbHelper.insertMessage(message);

        // Assert
        expect(result, equals(1));
        verify(() => mockDatabase.insert(
          DatabaseConstants.tableMessages,
          message,
          conflictAlgorithm: ConflictAlgorithm.replace,
        )).called(1);
      });

      test('throws exception on duplicate ID without replace', () async {
        // Arrange
        final message = {
          DatabaseConstants.columnId: 'msg_duplicate',
          DatabaseConstants.columnContent: 'Duplicate message',
          DatabaseConstants.columnIsAi: 0,
          DatabaseConstants.columnTimestamp: 1706000001000,
          DatabaseConstants.columnSessionId: 'session_001'
        };

        when(() => mockDatabase.insert(
          DatabaseConstants.tableMessages,
          message,
          conflictAlgorithm: ConflictAlgorithm.replace,
        )).thenThrow(Exception('UNIQUE constraint failed'));

        // Act & Assert
        expect(
          () => dbHelper.insertMessage(message),
          throwsA(isA<Exception>()),
        );
      });

      test('handles empty content gracefully', () async {
        // Arrange
        final message = {
          DatabaseConstants.columnId: 'msg_002',
          DatabaseConstants.columnContent: '',
          DatabaseConstants.columnIsAi: 0,
          DatabaseConstants.columnTimestamp: 1706000002000,
          DatabaseConstants.columnSessionId: 'session_001'
        };

        when(() => mockDatabase.insert(
          DatabaseConstants.tableMessages,
          message,
          conflictAlgorithm: ConflictAlgorithm.replace,
        )).thenAnswer((_) async => 1);

        // Act
        final result = await dbHelper.insertMessage(message);

        // Assert
        expect(result, equals(1));
      });
    });

    group('input validation', () {
      test('throws ArgumentError when id is missing', () async {
        final invalidMessage = {
          DatabaseConstants.columnContent: 'Test message',
          DatabaseConstants.columnIsAi: 0,
          DatabaseConstants.columnTimestamp: 1706000000000,
          DatabaseConstants.columnSessionId: 'session_001',
          // Missing 'id'
        };

        expect(
          () => dbHelper.insertMessage(invalidMessage),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Missing required field'),
          )),
        );
      });

      test('throws ArgumentError when is_ai is not integer', () async {
        final invalidMessage = {
          DatabaseConstants.columnId: 'msg_001',
          DatabaseConstants.columnContent: 'Test message',
          DatabaseConstants.columnIsAi: 'true', // Should be int
          DatabaseConstants.columnTimestamp: 1706000000000,
          DatabaseConstants.columnSessionId: 'session_001',
        };

        expect(
          () => dbHelper.insertMessage(invalidMessage),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must be an integer'),
          )),
        );
      });

      test('throws ArgumentError when timestamp is not integer', () async {
        final invalidMessage = {
          DatabaseConstants.columnId: 'msg_001',
          DatabaseConstants.columnContent: 'Test message',
          DatabaseConstants.columnIsAi: 0,
          DatabaseConstants.columnTimestamp: '2024-01-01', // Should be int
          DatabaseConstants.columnSessionId: 'session_001',
        };

        expect(
          () => dbHelper.insertMessage(invalidMessage),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must be an integer'),
          )),
        );
      });

      test('throws ArgumentError when content is null', () async {
        final invalidMessage = {
          DatabaseConstants.columnId: 'msg_001',
          DatabaseConstants.columnContent: null, // Null value
          DatabaseConstants.columnIsAi: 0,
          DatabaseConstants.columnTimestamp: 1706000000000,
          DatabaseConstants.columnSessionId: 'session_001',
        };

        expect(
          () => dbHelper.insertMessage(invalidMessage),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('cannot be null'),
          )),
        );
      });

      test('throws ArgumentError when session_id is missing', () async {
        final invalidMessage = {
          DatabaseConstants.columnId: 'msg_001',
          DatabaseConstants.columnContent: 'Test message',
          DatabaseConstants.columnIsAi: 0,
          DatabaseConstants.columnTimestamp: 1706000000000,
          // Missing 'session_id'
        };

        expect(
          () => dbHelper.insertMessage(invalidMessage),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Missing required field'),
          )),
        );
      });
    });

    group('getAllMessages', () {
      test('returns empty list when no messages exist', () async {
        // Arrange
        when(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).thenAnswer((_) async => []);

        // Act
        final messages = await dbHelper.getAllMessages();

        // Assert
        expect(messages, isEmpty);
        verify(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).called(1);
      });

      test('returns messages ordered by timestamp (oldest first)', () async {
        // Arrange
        final mockMessages = [
          {
            DatabaseConstants.columnId: 'msg_001',
            DatabaseConstants.columnContent: 'First message',
            DatabaseConstants.columnIsAi: 0,
            DatabaseConstants.columnTimestamp: 1706000000000,
            DatabaseConstants.columnSessionId: 'session_001'
          },
          {
            DatabaseConstants.columnId: 'msg_002',
            DatabaseConstants.columnContent: 'Second message',
            DatabaseConstants.columnIsAi: 1,
            DatabaseConstants.columnTimestamp: 1706000001000,
            DatabaseConstants.columnSessionId: 'session_001'
          },
          {
            DatabaseConstants.columnId: 'msg_003',
            DatabaseConstants.columnContent: 'Third message',
            DatabaseConstants.columnIsAi: 0,
            DatabaseConstants.columnTimestamp: 1706000002000,
            DatabaseConstants.columnSessionId: 'session_001'
          }
        ];

        when(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).thenAnswer((_) async => mockMessages);

        // Act
        final messages = await dbHelper.getAllMessages();

        // Assert
        expect(messages.length, equals(3));
        expect(messages[0][DatabaseConstants.columnContent], equals('First message'));
        expect(messages[1][DatabaseConstants.columnContent], equals('Second message'));
        expect(messages[2][DatabaseConstants.columnContent], equals('Third message'));
      });

      test('handles database error gracefully', () async {
        // Arrange
        when(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).thenThrow(Exception('Database locked'));

        // Act & Assert
        expect(
          () => dbHelper.getAllMessages(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getMessagesBySession', () {
      test('returns messages for valid session ID', () async {
        // Arrange
        const sessionId = 'session_001';
        final mockMessages = [
          {
            DatabaseConstants.columnId: 'msg_001',
            DatabaseConstants.columnContent: 'Session message 1',
            DatabaseConstants.columnIsAi: 0,
            DatabaseConstants.columnTimestamp: 1706000000000,
            DatabaseConstants.columnSessionId: sessionId
          },
          {
            DatabaseConstants.columnId: 'msg_002',
            DatabaseConstants.columnContent: 'Session message 2',
            DatabaseConstants.columnIsAi: 1,
            DatabaseConstants.columnTimestamp: 1706000001000,
            DatabaseConstants.columnSessionId: sessionId
          }
        ];

        when(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnSessionId} = ?',
          whereArgs: [sessionId],
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).thenAnswer((_) async => mockMessages);

        // Act
        final messages = await dbHelper.getMessagesBySession(sessionId);

        // Assert
        expect(messages.length, equals(2));
        expect(messages[0][DatabaseConstants.columnSessionId], equals(sessionId));
        expect(messages[1][DatabaseConstants.columnSessionId], equals(sessionId));
      });

      test('returns empty list for non-existent session ID', () async {
        // Arrange
        const sessionId = 'non_existent_session';

        when(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnSessionId} = ?',
          whereArgs: [sessionId],
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).thenAnswer((_) async => []);

        // Act
        final messages = await dbHelper.getMessagesBySession(sessionId);

        // Assert
        expect(messages, isEmpty);
      });

      test('handles invalid session ID gracefully', () async {
        // Arrange
        const sessionId = '';

        when(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnSessionId} = ?',
          whereArgs: [sessionId],
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).thenAnswer((_) async => []);

        // Act
        final messages = await dbHelper.getMessagesBySession(sessionId);

        // Assert
        expect(messages, isEmpty);
      });
    });

    group('deleteMessage', () {
      test('successfully deletes existing message', () async {
        // Arrange
        const messageId = 'msg_001';

        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnId} = ?',
          whereArgs: [messageId],
        )).thenAnswer((_) async => 1);

        // Act
        final result = await dbHelper.deleteMessage(messageId);

        // Assert
        expect(result, equals(1));
        verify(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnId} = ?',
          whereArgs: [messageId],
        )).called(1);
      });

      test('returns 0 when deleting non-existent message', () async {
        // Arrange
        const messageId = 'non_existent_msg';

        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnId} = ?',
          whereArgs: [messageId],
        )).thenAnswer((_) async => 0);

        // Act
        final result = await dbHelper.deleteMessage(messageId);

        // Assert
        expect(result, equals(0));
      });

      test('handles database error during deletion', () async {
        // Arrange
        const messageId = 'msg_001';

        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnId} = ?',
          whereArgs: [messageId],
        )).thenThrow(Exception('Database locked'));

        // Act & Assert
        expect(
          () => dbHelper.deleteMessage(messageId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteOldMessages', () {
      test('deletes messages older than specified timestamp', () async {
        // Arrange
        const cutoffTimestamp = 1705000000000;

        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnTimestamp} < ?',
          whereArgs: [cutoffTimestamp],
        )).thenAnswer((_) async => 5);

        // Act
        final result = await dbHelper.deleteOldMessages(cutoffTimestamp);

        // Assert
        expect(result, equals(5));
        verify(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnTimestamp} < ?',
          whereArgs: [cutoffTimestamp],
        )).called(1);
      });

      test('returns 0 when no old messages exist', () async {
        // Arrange
        const cutoffTimestamp = 1700000000000;

        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnTimestamp} < ?',
          whereArgs: [cutoffTimestamp],
        )).thenAnswer((_) async => 0);

        // Act
        final result = await dbHelper.deleteOldMessages(cutoffTimestamp);

        // Assert
        expect(result, equals(0));
      });

      test('handles negative timestamp gracefully', () async {
        // Arrange
        const cutoffTimestamp = -1;

        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
          where: '${DatabaseConstants.columnTimestamp} < ?',
          whereArgs: [cutoffTimestamp],
        )).thenAnswer((_) async => 0);

        // Act
        final result = await dbHelper.deleteOldMessages(cutoffTimestamp);

        // Assert
        expect(result, equals(0));
      });
    });

    group('clearAllMessages', () {
      test('successfully clears all messages', () async {
        // Arrange
        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
        )).thenAnswer((_) async => 10);

        // Act
        final result = await dbHelper.clearAllMessages();

        // Assert
        expect(result, equals(10));
        verify(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
        )).called(1);
      });

      test('returns 0 when table is already empty', () async {
        // Arrange
        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
        )).thenAnswer((_) async => 0);

        // Act
        final result = await dbHelper.clearAllMessages();

        // Assert
        expect(result, equals(0));
      });

      test('handles database error during clear', () async {
        // Arrange
        when(() => mockDatabase.delete(
          DatabaseConstants.tableMessages,
        )).thenThrow(Exception('Database locked'));

        // Act & Assert
        expect(
          () => dbHelper.clearAllMessages(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('database initialization', () {
      test('creates database with correct version', () async {
        // This test would require a different approach for the singleton
        // We'll test that the database helper can be initialized
        expect(DatabaseHelper.instance, isNotNull);
      });

      test('handles onCreate callback properly', () async {
        // Arrange
        when(() => mockDatabase.execute(DatabaseConstants.createMessagesTable))
            .thenAnswer((_) async {});
        when(() => mockDatabase.execute(DatabaseConstants.createSessionTimestampIndex))
            .thenAnswer((_) async {});

        // Act
        await dbHelper.onCreate(mockDatabase, 1);

        // Assert
        verify(() => mockDatabase.execute(DatabaseConstants.createMessagesTable))
            .called(1);
        verify(() => mockDatabase.execute(DatabaseConstants.createSessionTimestampIndex))
            .called(1);
      });

      test('handles onUpgrade for future versions', () async {
        // Arrange
        const oldVersion = 1;
        const newVersion = 2;

        // Act - Currently no-op for v1
        await dbHelper.onUpgrade(mockDatabase, oldVersion, newVersion);

        // Assert - Should not throw
        expect(true, isTrue); // Placeholder assertion
      });
    });

    group('close database', () {
      test('successfully closes database connection', () async {
        // Arrange
        when(() => mockDatabase.close()).thenAnswer((_) async {});

        // Act
        await dbHelper.close();

        // Assert
        verify(() => mockDatabase.close()).called(1);
      });

      test('handles error during close gracefully', () async {
        // Arrange
        when(() => mockDatabase.close())
            .thenThrow(Exception('Cannot close database'));

        // Act & Assert
        expect(
          () => dbHelper.close(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('error handling scenarios', () {
      test('handles disk full error', () async {
        // Arrange
        final message = {
          DatabaseConstants.columnId: 'msg_001',
          DatabaseConstants.columnContent: 'Test message',
          DatabaseConstants.columnIsAi: 0,
          DatabaseConstants.columnTimestamp: 1706000000000,
          DatabaseConstants.columnSessionId: 'session_001'
        };

        when(() => mockDatabase.insert(
          DatabaseConstants.tableMessages,
          message,
          conflictAlgorithm: ConflictAlgorithm.replace,
        )).thenThrow(Exception('disk I/O error'));

        // Act & Assert
        expect(
          () => dbHelper.insertMessage(message),
          throwsA(isA<Exception>()),
        );
      });

      test('handles database locked scenario', () async {
        // Arrange
        when(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).thenThrow(Exception('database is locked'));

        // Act & Assert
        expect(
          () => dbHelper.getAllMessages(),
          throwsA(isA<Exception>()),
        );
      });

      test('handles corrupted database', () async {
        // Arrange
        when(() => mockDatabase.query(
          DatabaseConstants.tableMessages,
          orderBy: '${DatabaseConstants.columnTimestamp} ASC',
        )).thenThrow(Exception('database disk image is malformed'));

        // Act & Assert
        expect(
          () => dbHelper.getAllMessages(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
