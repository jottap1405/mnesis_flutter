import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mnesis_flutter/core/router/router_observer.dart';

/// Mock classes for testing
class MockLogger extends Mock implements Logger {}

class MockRoute extends Mock implements Route<dynamic> {}

class MockRouteSettings extends Mock implements RouteSettings {}

/// Simplified comprehensive test suite for MnesisRouterObserver.
///
/// This test suite ensures all navigation lifecycle methods work correctly
/// without getting bogged down in complex mock verification.
///
/// Coverage target: 95%+ for router_observer.dart
void main() {
  group('MnesisRouterObserver', () {
    late MnesisRouterObserver observer;
    late MockLogger mockLogger;
    late MockRoute mockRoute;
    late MockRoute mockPreviousRoute;
    late MockRouteSettings mockSettings;
    late MockRouteSettings mockPreviousSettings;
    late List<String> loggedMessages;

    setUp(() {
      mockLogger = MockLogger();
      mockRoute = MockRoute();
      mockPreviousRoute = MockRoute();
      mockSettings = MockRouteSettings();
      mockPreviousSettings = MockRouteSettings();
      loggedMessages = [];

      // Setup default behavior
      when(() => mockRoute.settings).thenReturn(mockSettings);
      when(() => mockPreviousRoute.settings).thenReturn(mockPreviousSettings);
      when(() => mockSettings.name).thenReturn('TestRoute');
      when(() => mockPreviousSettings.name).thenReturn('PreviousRoute');

      // Capture all log messages
      when(() => mockLogger.d(
            any(),
            time: any(named: 'time'),
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          )).thenAnswer((invocation) {
        loggedMessages.add(invocation.positionalArguments[0] as String);
        return;
      });

      observer = MnesisRouterObserver(logger: mockLogger);
    });

    group('Constructor', () {
      test('creates observer with custom logger', () {
        final customLogger = MockLogger();
        final customObserver = MnesisRouterObserver(logger: customLogger);

        expect(customObserver, isNotNull);
        expect(customObserver, isA<NavigatorObserver>());
      });

      test('creates observer with default logger when none provided', () {
        final defaultObserver = MnesisRouterObserver();

        expect(defaultObserver, isNotNull);
        expect(defaultObserver, isA<NavigatorObserver>());
      });

      test('is a NavigatorObserver subclass', () {
        expect(observer, isA<NavigatorObserver>());
      });
    });

    group('didPush Navigation', () {
      test('logs push navigation with route names', () {
        // Act
        observer.didPush(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('PUSH'));
        expect(loggedMessages.first, contains('PreviousRoute'));
        expect(loggedMessages.first, contains('TestRoute'));
      });

      test('logs push navigation when previous route is null', () {
        // Act
        observer.didPush(mockRoute, null);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('PUSH'));
        expect(loggedMessages.first, contains('None'));
        expect(loggedMessages.first, contains('TestRoute'));
      });

      test('logs push navigation with Unknown when route name is null', () {
        // Arrange
        when(() => mockSettings.name).thenReturn(null);
        when(() => mockPreviousSettings.name).thenReturn(null);

        // Act
        observer.didPush(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('PUSH'));
        expect(loggedMessages.first, contains('Unknown'));
      });

      test('handles push navigation with empty route name', () {
        // Arrange
        when(() => mockSettings.name).thenReturn('');

        // Act
        observer.didPush(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('PUSH'));
      });
    });

    group('didPop Navigation', () {
      test('logs pop navigation with route names', () {
        // Act
        observer.didPop(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('POP'));
        expect(loggedMessages.first, contains('PreviousRoute'));
        expect(loggedMessages.first, contains('TestRoute'));
      });

      test('logs pop navigation when previous route is null', () {
        // Act
        observer.didPop(mockRoute, null);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('POP'));
        expect(loggedMessages.first, contains('None'));
      });

      test('logs pop navigation with Unknown when route name is null', () {
        // Arrange
        when(() => mockSettings.name).thenReturn(null);
        when(() => mockPreviousSettings.name).thenReturn(null);

        // Act
        observer.didPop(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('POP'));
        expect(loggedMessages.first, contains('Unknown'));
      });
    });

    group('didRemove Navigation', () {
      test('logs remove navigation with route names', () {
        // Act
        observer.didRemove(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('REMOVE'));
        expect(loggedMessages.first, contains('PreviousRoute'));
        expect(loggedMessages.first, contains('TestRoute'));
      });

      test('logs remove navigation when previous route is null', () {
        // Act
        observer.didRemove(mockRoute, null);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('REMOVE'));
        expect(loggedMessages.first, contains('None'));
      });

      test('logs remove navigation with Unknown when route name is null', () {
        // Arrange
        when(() => mockSettings.name).thenReturn(null);
        when(() => mockPreviousSettings.name).thenReturn(null);

        // Act
        observer.didRemove(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('REMOVE'));
        expect(loggedMessages.first, contains('Unknown'));
      });
    });

    group('didReplace Navigation', () {
      test('logs replace navigation with both routes', () {
        // Act
        observer.didReplace(newRoute: mockRoute, oldRoute: mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('REPLACE'));
        expect(loggedMessages.first, contains('PreviousRoute'));
        expect(loggedMessages.first, contains('TestRoute'));
      });

      test('does not log when new route is null', () {
        // Act
        observer.didReplace(newRoute: null, oldRoute: mockPreviousRoute);

        // Assert
        expect(loggedMessages, isEmpty);
      });

      test('logs replace navigation when old route is null', () {
        // Act
        observer.didReplace(newRoute: mockRoute, oldRoute: null);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('REPLACE'));
        expect(loggedMessages.first, contains('None'));
      });

      test('logs replace navigation with Unknown when route names are null', () {
        // Arrange
        when(() => mockSettings.name).thenReturn(null);
        when(() => mockPreviousSettings.name).thenReturn(null);

        // Act
        observer.didReplace(newRoute: mockRoute, oldRoute: mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('REPLACE'));
        expect(loggedMessages.first, contains('Unknown'));
      });
    });

    group('Navigation Event Sequence', () {
      test('handles multiple push events in sequence', () {
        // Arrange
        final route1 = MockRoute();
        final route2 = MockRoute();
        final settings1 = MockRouteSettings();
        final settings2 = MockRouteSettings();

        when(() => route1.settings).thenReturn(settings1);
        when(() => route2.settings).thenReturn(settings2);
        when(() => settings1.name).thenReturn('Route1');
        when(() => settings2.name).thenReturn('Route2');

        // Act
        observer.didPush(route1, null);
        observer.didPush(route2, route1);

        // Assert
        expect(loggedMessages, hasLength(2));
        expect(loggedMessages[0], contains('Route1'));
        expect(loggedMessages[1], contains('Route2'));
      });

      test('handles push then pop sequence', () {
        // Act
        observer.didPush(mockRoute, mockPreviousRoute);
        observer.didPop(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(2));
        expect(loggedMessages[0], contains('PUSH'));
        expect(loggedMessages[1], contains('POP'));
      });

      test('handles multiple navigation types in succession', () {
        // Act
        observer.didPush(mockRoute, mockPreviousRoute);
        observer.didPop(mockRoute, mockPreviousRoute);
        observer.didRemove(mockRoute, mockPreviousRoute);
        observer.didReplace(newRoute: mockRoute, oldRoute: mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(4));
        expect(loggedMessages[0], contains('PUSH'));
        expect(loggedMessages[1], contains('POP'));
        expect(loggedMessages[2], contains('REMOVE'));
        expect(loggedMessages[3], contains('REPLACE'));
      });
    });

    group('Edge Cases', () {
      test('handles route with very long name', () {
        // Arrange
        final longRouteName = 'VeryLongRouteName' * 20;
        when(() => mockSettings.name).thenReturn(longRouteName);

        // Act
        observer.didPush(mockRoute, mockPreviousRoute);

        // Assert - Should not throw
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains(longRouteName));
      });

      test('handles route with special characters in name', () {
        // Arrange
        when(() => mockSettings.name).thenReturn('/route-with-special_chars.123');

        // Act
        observer.didPush(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('/route-with-special_chars.123'));
      });

      test('handles route with unicode characters', () {
        // Arrange
        when(() => mockSettings.name).thenReturn('设置页面');

        // Act
        observer.didPush(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, contains('设置页面'));
      });

      test('handles simultaneous route events', () {
        // Act
        for (int i = 0; i < 100; i++) {
          observer.didPush(mockRoute, mockPreviousRoute);
        }

        // Assert
        expect(loggedMessages, hasLength(100));
      });
    });

    group('Logger Integration', () {
      test('logger receives properly formatted message', () {
        // Act
        observer.didPush(mockRoute, mockPreviousRoute);

        // Assert
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages.first, startsWith('🧭'));
        expect(loggedMessages.first, contains('[PUSH]'));
      });

      test('logger icon emoji is included in all navigation events', () {
        // Act
        observer.didPush(mockRoute, mockPreviousRoute);
        observer.didPop(mockRoute, mockPreviousRoute);
        observer.didRemove(mockRoute, mockPreviousRoute);
        observer.didReplace(newRoute: mockRoute, oldRoute: mockPreviousRoute);

        // Assert
        for (final message in loggedMessages) {
          expect(message, startsWith('🧭'));
        }
      });
    });

    group('Performance Considerations', () {
      test('logging does not block navigation events', () {
        // Act
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 1000; i++) {
          observer.didPush(mockRoute, mockPreviousRoute);
        }
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(loggedMessages, hasLength(1000));
      });

      test('observer handles high frequency navigation', () {
        // Act
        const eventCount = 500;
        for (int i = 0; i < eventCount; i++) {
          observer.didPush(mockRoute, mockPreviousRoute);
          observer.didPop(mockRoute, mockPreviousRoute);
        }

        // Assert
        expect(loggedMessages, hasLength(eventCount * 2));
      });
    });
  });
}
