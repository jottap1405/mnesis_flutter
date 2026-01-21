import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mnesis_flutter/core/router/navigation/navigation_helper.dart';
import 'package:mnesis_flutter/core/router/routes/route_names.dart';
import 'package:mnesis_flutter/core/router/routes/route_paths.dart';
import 'package:mocktail/mocktail.dart';

// ============================================================================
// Mock Classes
// ============================================================================

/// Mock GoRouter for testing navigation behavior.
class MockGoRouter extends Mock implements GoRouter {}

/// Mock BuildContext for testing.
class MockBuildContext extends Mock implements BuildContext {}

// ============================================================================
// Test Suite
// ============================================================================

void main() {
  group('NavigationHelper', () {
    late MockGoRouter mockRouter;
    late MockBuildContext mockContext;
    late NavigationHelper navigationHelper;

    setUp(() {
      mockRouter = MockGoRouter();
      mockContext = MockBuildContext();
    });

    // ==========================================================================
    // Constructor & Initialization Tests
    // ==========================================================================

    group('Constructor & Initialization', () {
      test('creates instance with context and no router', () {
        final helper = NavigationHelper(mockContext);

        expect(helper, isNotNull);
        expect(helper.onError, isNull);
      });

      test('creates instance with context and custom router', () {
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );

        expect(helper, isNotNull);
        expect(helper.router, equals(mockRouter));
      });

      test('creates instance with onError callback', () {
        void onErrorCallback(Object error) {}
        final helper = NavigationHelper(
          mockContext,
          onError: onErrorCallback,
          router: mockRouter,
        );

        expect(helper, isNotNull);
        expect(helper.onError, equals(onErrorCallback));
      });

      test('router getter returns injected router when provided', () {
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );

        expect(helper.router, equals(mockRouter));
      });
    });

    // ==========================================================================
    // Basic Navigation Methods Tests
    // ==========================================================================

    group('Basic Navigation Methods', () {
      setUp(() {
        navigationHelper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );
      });

      test('goToChat navigates to chat path', () {
        navigationHelper.goToChat();

        verify(() => mockRouter.go(RoutePaths.chat)).called(1);
      });

      test('goToQuickActions navigates to quick actions path', () {
        navigationHelper.goToQuickActions();

        verify(() => mockRouter.go(RoutePaths.quickActions)).called(1);
      });

      test('goToOperations navigates to operations path', () {
        navigationHelper.goToOperations();

        verify(() => mockRouter.go(RoutePaths.operations)).called(1);
      });

      test('goToAdmin navigates to admin path', () {
        navigationHelper.goToAdmin();

        verify(() => mockRouter.go(RoutePaths.admin)).called(1);
      });

      test('goToNotFound navigates to not found path', () {
        navigationHelper.goToNotFound();

        verify(() => mockRouter.go(RoutePaths.notFound)).called(1);
      });
    });

    // ==========================================================================
    // Named Navigation Tests
    // ==========================================================================

    group('Named Navigation', () {
      setUp(() {
        navigationHelper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );
      });

      test('goToNamed successfully navigates to valid route name', () {
        when(() => mockRouter.goNamed(any())).thenAnswer((_) {});

        navigationHelper.goToNamed(RouteNames.chat);

        verify(() => mockRouter.goNamed(RouteNames.chat)).called(1);
      });

      test('goToNamed navigates to quick actions by name', () {
        when(() => mockRouter.goNamed(any())).thenAnswer((_) {});

        navigationHelper.goToNamed(RouteNames.quickActions);

        verify(() => mockRouter.goNamed(RouteNames.quickActions)).called(1);
      });

      test('goToNamed navigates to operations by name', () {
        when(() => mockRouter.goNamed(any())).thenAnswer((_) {});

        navigationHelper.goToNamed(RouteNames.operations);

        verify(() => mockRouter.goNamed(RouteNames.operations)).called(1);
      });

      test('goToNamed calls onError callback when navigation fails', () {
        Object? capturedError;
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
          onError: (error) => capturedError = error,
        );

        final testError = Exception('Navigation failed');
        when(() => mockRouter.goNamed(any())).thenThrow(testError);
        when(() => mockRouter.go(any())).thenAnswer((_) {});

        helper.goToNamed(RouteNames.admin);

        expect(capturedError, equals(testError));
      });

      test('goToNamed falls back to chat screen on error', () {
        when(() => mockRouter.goNamed(any())).thenThrow(Exception('Failed'));
        when(() => mockRouter.go(any())).thenAnswer((_) {});

        navigationHelper.goToNamed(RouteNames.admin);

        // Should attempt the named route first, then fall back to chat
        verify(() => mockRouter.goNamed(RouteNames.admin)).called(1);
        verify(() => mockRouter.go(RoutePaths.chat)).called(1);
      });

      test('goToNamed does not fallback when failing on chat route', () {
        when(() => mockRouter.goNamed(any())).thenThrow(Exception('Failed'));
        when(() => mockRouter.go(any())).thenAnswer((_) {});

        navigationHelper.goToNamed(RouteNames.chat);

        // Should attempt the named route but NOT fall back to itself
        verify(() => mockRouter.goNamed(RouteNames.chat)).called(1);
        verifyNever(() => mockRouter.go(RoutePaths.chat));
      });

      test('goToNamed handles multiple failed navigation attempts', () {
        var errorCount = 0;
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
          onError: (_) => errorCount++,
        );

        when(() => mockRouter.goNamed(any())).thenThrow(Exception('Failed'));
        when(() => mockRouter.go(any())).thenAnswer((_) {});

        helper.goToNamed(RouteNames.admin);
        helper.goToNamed(RouteNames.operations);
        helper.goToNamed(RouteNames.quickActions);

        expect(errorCount, equals(3));
      });
    });

    // ==========================================================================
    // Back Navigation Tests
    // ==========================================================================

    group('Back Navigation', () {
      setUp(() {
        navigationHelper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );
      });

      test('goBack pops current route', () {
        navigationHelper.goBack();

        verify(() => mockRouter.pop()).called(1);
      });

      test('canGoBack returns true when router can pop', () {
        when(() => mockRouter.canPop()).thenReturn(true);

        final result = navigationHelper.canGoBack();

        expect(result, isTrue);
        verify(() => mockRouter.canPop()).called(1);
      });

      test('canGoBack returns false when router cannot pop', () {
        when(() => mockRouter.canPop()).thenReturn(false);

        final result = navigationHelper.canGoBack();

        expect(result, isFalse);
        verify(() => mockRouter.canPop()).called(1);
      });

      test('goBack handles navigation errors gracefully', () {
        Object? capturedError;
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
          onError: (error) => capturedError = error,
        );

        final testError = Exception('Pop failed');
        when(() => mockRouter.pop()).thenThrow(testError);

        helper.goBack();

        expect(capturedError, equals(testError));
      });
    });

    // ==========================================================================
    // Replace Navigation Tests
    // ==========================================================================

    group('Replace Navigation', () {
      setUp(() {
        navigationHelper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );
      });

      test('replaceWithChat replaces current route with chat', () {
        navigationHelper.replaceWithChat();

        verify(() => mockRouter.pushReplacement(RoutePaths.chat)).called(1);
      });

      test('replaceWithQuickActions replaces current route', () {
        navigationHelper.replaceWithQuickActions();

        verify(
          () => mockRouter.pushReplacement(RoutePaths.quickActions),
        ).called(1);
      });

      test('replaceWithOperations replaces current route', () {
        navigationHelper.replaceWithOperations();

        verify(
          () => mockRouter.pushReplacement(RoutePaths.operations),
        ).called(1);
      });

      test('replaceWithAdmin replaces current route', () {
        navigationHelper.replaceWithAdmin();

        verify(() => mockRouter.pushReplacement(RoutePaths.admin)).called(1);
      });

      test('replaceWithChat handles errors with onError callback', () {
        Object? capturedError;
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
          onError: (error) => capturedError = error,
        );

        final testError = Exception('Replace failed');
        when(() => mockRouter.pushReplacement(any())).thenThrow(testError);

        helper.replaceWithChat();

        expect(capturedError, equals(testError));
      });
    });

    // ==========================================================================
    // Error Handling Tests
    // ==========================================================================

    group('Error Handling', () {
      test('navigation errors invoke onError callback', () {
        final errors = <Object>[];
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
          onError: errors.add,
        );

        final testError = Exception('Navigation failed');
        when(() => mockRouter.go(any())).thenThrow(testError);

        helper.goToChat();

        expect(errors, contains(testError));
      });

      test('navigation errors are silently handled when no callback', () {
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );

        when(() => mockRouter.go(any())).thenThrow(Exception('Error'));

        // Should not throw
        expect(() => helper.goToChat(), returnsNormally);
      });

      test('multiple navigation errors invoke callback multiple times', () {
        var errorCount = 0;
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
          onError: (_) => errorCount++,
        );

        when(() => mockRouter.go(any())).thenThrow(Exception('Error'));
        when(() => mockRouter.pop()).thenThrow(Exception('Error'));
        when(() => mockRouter.pushReplacement(any()))
            .thenThrow(Exception('Error'));

        helper.goToChat();
        helper.goBack();
        helper.replaceWithAdmin();

        expect(errorCount, equals(3));
      });

      test('onError callback receives actual error object', () {
        Object? receivedError;
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
          onError: (error) => receivedError = error,
        );

        final specificError = ArgumentError('Invalid route');
        when(() => mockRouter.go(any())).thenThrow(specificError);

        helper.goToOperations();

        expect(receivedError, isA<ArgumentError>());
        expect(receivedError, equals(specificError));
      });
    });

    // ==========================================================================
    // Integration Tests
    // ==========================================================================

    group('Integration Scenarios', () {
      test('navigation sequence works correctly', () {
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );

        helper.goToChat();
        helper.goToQuickActions();
        helper.goToOperations();

        verifyInOrder([
          () => mockRouter.go(RoutePaths.chat),
          () => mockRouter.go(RoutePaths.quickActions),
          () => mockRouter.go(RoutePaths.operations),
        ]);
      });

      test('mix of navigation and replace operations', () {
        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );

        helper.goToChat();
        helper.replaceWithQuickActions();
        helper.goToAdmin();

        verifyInOrder([
          () => mockRouter.go(RoutePaths.chat),
          () => mockRouter.pushReplacement(RoutePaths.quickActions),
          () => mockRouter.go(RoutePaths.admin),
        ]);
      });

      test('conditional back navigation based on canGoBack', () {
        when(() => mockRouter.canPop()).thenReturn(true);

        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );

        if (helper.canGoBack()) {
          helper.goBack();
        }

        verify(() => mockRouter.canPop()).called(1);
        verify(() => mockRouter.pop()).called(1);
      });

      test('no back navigation when cannot go back', () {
        when(() => mockRouter.canPop()).thenReturn(false);

        final helper = NavigationHelper(
          mockContext,
          router: mockRouter,
        );

        if (helper.canGoBack()) {
          helper.goBack();
        }

        verify(() => mockRouter.canPop()).called(1);
        verifyNever(() => mockRouter.pop());
      });
    });
  });

  // ============================================================================
  // BuildContext Extension Tests
  // ============================================================================

  group('NavigationExtension', () {
    testWidgets('context.nav returns NavigationHelper instance',
        (tester) async {
      late NavigationHelper helper;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              helper = context.nav;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(helper, isA<NavigationHelper>());
    });

    testWidgets('context.nav creates new instance on each access',
        (tester) async {
      NavigationHelper? helper1;
      NavigationHelper? helper2;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              helper1 = context.nav;
              helper2 = context.nav;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(helper1, isA<NavigationHelper>());
      expect(helper2, isA<NavigationHelper>());
      // Should be different instances
      expect(identical(helper1, helper2), isFalse);
    });

    testWidgets('extension works with real BuildContext', (tester) async {
      var navigationCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Verify extension is accessible
              context.nav;  // Access the extension
              navigationCalled = true;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(navigationCalled, isTrue);
    });
  });

  // ============================================================================
  // Edge Cases & Stress Tests
  // ============================================================================

  group('Edge Cases', () {
    late MockGoRouter mockRouter;
    late MockBuildContext mockContext;

    setUp(() {
      mockRouter = MockGoRouter();
      mockContext = MockBuildContext();
    });

    test('rapid successive navigation calls', () {
      final helper = NavigationHelper(
        mockContext,
        router: mockRouter,
      );

      // Simulate rapid navigation
      for (var i = 0; i < 10; i++) {
        helper.goToChat();
      }

      verify(() => mockRouter.go(RoutePaths.chat)).called(10);
    });

    test('navigation with null onError callback', () {
      final helper = NavigationHelper(
        mockContext,
        router: mockRouter,
        onError: null,
      );

      when(() => mockRouter.go(any())).thenThrow(Exception('Error'));

      // Should not throw even with error and null callback
      expect(() => helper.goToChat(), returnsNormally);
    });

    test('different error types are handled correctly', () {
      final errors = <Object>[];
      final helper = NavigationHelper(
        mockContext,
        router: mockRouter,
        onError: errors.add,
      );

      when(() => mockRouter.go(RoutePaths.chat))
          .thenThrow(Exception('Exception'));
      when(() => mockRouter.go(RoutePaths.quickActions))
          .thenThrow(ArgumentError('ArgumentError'));
      when(() => mockRouter.go(RoutePaths.operations))
          .thenThrow(StateError('StateError'));

      helper.goToChat();
      helper.goToQuickActions();
      helper.goToOperations();

      expect(errors.length, equals(3));
      expect(errors[0], isA<Exception>());
      expect(errors[1], isA<ArgumentError>());
      expect(errors[2], isA<StateError>());
    });

    test('all route paths are distinct', () {
      final paths = {
        RoutePaths.chat,
        RoutePaths.quickActions,
        RoutePaths.operations,
        RoutePaths.admin,
        RoutePaths.notFound,
      };

      // All paths should be unique
      expect(paths.length, equals(5));
    });

    test('navigation methods use correct path constants', () {
      final helper = NavigationHelper(
        mockContext,
        router: mockRouter,
      );

      helper.goToChat();
      verify(() => mockRouter.go('/chat')).called(1);

      helper.goToQuickActions();
      verify(() => mockRouter.go('/new')).called(1);

      helper.goToOperations();
      verify(() => mockRouter.go('/operation')).called(1);

      helper.goToAdmin();
      verify(() => mockRouter.go('/admin')).called(1);

      helper.goToNotFound();
      verify(() => mockRouter.go('/404')).called(1);
    });

    test('replace operations do not add to navigation stack', () {
      final helper = NavigationHelper(
        mockContext,
        router: mockRouter,
      );

      // Replace operations should use pushReplacement, not go
      helper.replaceWithChat();
      helper.replaceWithQuickActions();
      helper.replaceWithOperations();
      helper.replaceWithAdmin();

      verify(() => mockRouter.pushReplacement(RoutePaths.chat)).called(1);
      verify(
        () => mockRouter.pushReplacement(RoutePaths.quickActions),
      ).called(1);
      verify(
        () => mockRouter.pushReplacement(RoutePaths.operations),
      ).called(1);
      verify(() => mockRouter.pushReplacement(RoutePaths.admin)).called(1);
      verifyNever(() => mockRouter.go(any()));
    });

    test('all route names match route paths', () {
      // Verify naming consistency
      expect(RouteNames.chat, equals('chat'));
      expect(RoutePaths.chat, equals('/chat'));

      expect(RouteNames.quickActions, equals('quickActions'));
      expect(RoutePaths.quickActions, equals('/new'));

      expect(RouteNames.operations, equals('operations'));
      expect(RoutePaths.operations, equals('/operation'));

      expect(RouteNames.admin, equals('admin'));
      expect(RoutePaths.admin, equals('/admin'));

      expect(RouteNames.notFound, equals('notFound'));
      expect(RoutePaths.notFound, equals('/404'));
    });
  });
}
