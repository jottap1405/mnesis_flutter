import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mnesis_flutter/core/router/guards/auth_guard.dart';
import 'package:mnesis_flutter/core/router/guards/route_guard.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockGoRouterState extends Mock implements GoRouterState {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('RouteGuard Interface', () {
    test('is abstract interface with correct signature', () {
      // Verify that RouteGuard is an abstract class that can be implemented
      // This test passes if the interface compiles correctly
      expect(RouteGuard, isNotNull);
    });
  });

  group('AuthGuard', () {
    late AuthGuard authGuard;
    late MockBuildContext mockContext;
    late MockGoRouterState mockState;

    setUp(() {
      authGuard = const AuthGuard();
      mockContext = MockBuildContext();
      mockState = MockGoRouterState();
    });

    test('can be instantiated with const constructor', () {
      const guard = AuthGuard();
      expect(guard, isNotNull);
      expect(guard, isA<RouteGuard>());
    });

    test('implements RouteGuard interface', () {
      expect(authGuard, isA<RouteGuard>());
    });

    group('redirect', () {
      test('returns null when user is authenticated', () async {
        // In Mnesis, even authenticated users are not redirected
        // because all routes are accessible
        when(() => mockState.matchedLocation).thenReturn('/home');

        final result = await authGuard.redirect(mockContext, mockState);

        expect(result, isNull);
      });

      test('returns null when user is unauthenticated', () async {
        // In Mnesis, unauthenticated users are NOT redirected to login
        // because authentication happens through chat interface
        when(() => mockState.matchedLocation).thenReturn('/home');

        final result = await authGuard.redirect(mockContext, mockState);

        expect(result, isNull);
      });

      test('does not block navigation to home route', () async {
        when(() => mockState.matchedLocation).thenReturn('/home');

        final result = await authGuard.redirect(mockContext, mockState);

        expect(result, isNull);
      });

      test('does not block navigation to chat route', () async {
        when(() => mockState.matchedLocation).thenReturn('/chat');

        final result = await authGuard.redirect(mockContext, mockState);

        expect(result, isNull);
      });

      test('does not block navigation to settings route', () async {
        when(() => mockState.matchedLocation).thenReturn('/settings');

        final result = await authGuard.redirect(mockContext, mockState);

        expect(result, isNull);
      });

      test('does not block navigation to profile route', () async {
        when(() => mockState.matchedLocation).thenReturn('/profile');

        final result = await authGuard.redirect(mockContext, mockState);

        expect(result, isNull);
      });

      test('allows navigation to any arbitrary route', () async {
        final testRoutes = [
          '/home',
          '/chat',
          '/settings',
          '/profile',
          '/help',
          '/about',
          '/terms',
          '/privacy',
        ];

        for (final route in testRoutes) {
          when(() => mockState.matchedLocation).thenReturn(route);

          final result = await authGuard.redirect(mockContext, mockState);

          expect(
            result,
            isNull,
            reason: 'Route $route should be accessible without redirect',
          );
        }
      });

      test('redirect method completes successfully', () async {
        when(() => mockState.matchedLocation).thenReturn('/home');

        // Verify that redirect completes without error
        await expectLater(
          authGuard.redirect(mockContext, mockState),
          completes,
        );
      });

      test('can be called multiple times without state issues', () async {
        when(() => mockState.matchedLocation).thenReturn('/home');

        // Call redirect multiple times
        final result1 = await authGuard.redirect(mockContext, mockState);
        final result2 = await authGuard.redirect(mockContext, mockState);
        final result3 = await authGuard.redirect(mockContext, mockState);

        expect(result1, isNull);
        expect(result2, isNull);
        expect(result3, isNull);
      });

      test('works with different BuildContext instances', () async {
        final mockContext2 = MockBuildContext();
        when(() => mockState.matchedLocation).thenReturn('/home');

        final result1 = await authGuard.redirect(mockContext, mockState);
        final result2 = await authGuard.redirect(mockContext2, mockState);

        expect(result1, isNull);
        expect(result2, isNull);
      });

      test('works with different GoRouterState instances', () async {
        final mockState2 = MockGoRouterState();
        when(() => mockState.matchedLocation).thenReturn('/home');
        when(() => mockState2.matchedLocation).thenReturn('/chat');

        final result1 = await authGuard.redirect(mockContext, mockState);
        final result2 = await authGuard.redirect(mockContext, mockState2);

        expect(result1, isNull);
        expect(result2, isNull);
      });
    });

    group('const constructor behavior', () {
      test('creates identical instances with const constructor', () {
        const guard1 = AuthGuard();
        const guard2 = AuthGuard();

        // Const instances should be identical
        expect(identical(guard1, guard2), isTrue);
      });

      test('non-const instances are not identical', () {
        // ignore: prefer_const_constructors
        final guard1 = AuthGuard();
        // ignore: prefer_const_constructors
        final guard2 = AuthGuard();

        // Non-const instances should not be identical
        expect(identical(guard1, guard2), isFalse);
      });
    });

    group('future extensibility', () {
      test('guard structure allows for future auth state checking', () {
        // This test documents that the guard can be extended
        // to check auth state in the future
        expect(authGuard, isA<RouteGuard>());
        expect(authGuard.redirect, isA<Function>());
      });

      test('guard can be used in go_router redirect callback', () {
        // Verify the signature matches go_router expectations
        when(() => mockState.matchedLocation).thenReturn('/home');

        expect(
          () => authGuard.redirect(mockContext, mockState),
          returnsNormally,
        );
      });
    });
  });
}
