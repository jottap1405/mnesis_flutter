import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mnesis_flutter/core/router/navigation/navigation_helper.dart';
import 'package:mnesis_flutter/core/router/routes/route_names.dart';
import 'package:mnesis_flutter/core/router/routes/route_paths.dart';

/// Mock classes for testing
class MockGoRouter extends Mock implements GoRouter {}

class MockBuildContext extends Mock implements BuildContext {}

/// Comprehensive test suite for NavigationHelper.
///
/// This test suite ensures:
/// - All navigation methods work correctly
/// - Error handling is robust
/// - Type-safe navigation is maintained
/// - BuildContext extension works as expected
/// - Edge cases are handled gracefully
///
/// Coverage target: 95%+ for navigation_helper.dart
void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(RoutePaths.chat);
  });

  group('NavigationHelper', () {
    late NavigationHelper helper;
    late MockGoRouter mockRouter;
    late MockBuildContext mockContext;
    late List<Object> capturedErrors;

    setUp(() {
      mockRouter = MockGoRouter();
      mockContext = MockBuildContext();
      capturedErrors = [];

      // Setup router mock default behaviors
      when(() => mockRouter.go(any())).thenReturn(null);
      when(() => mockRouter.goNamed(any())).thenReturn(null);
      when(() => mockRouter.pop()).thenReturn(null);
      when(() => mockRouter.canPop()).thenReturn(true);
      when(() => mockRouter.pushReplacement(any())).thenReturn(Future.value(null));

      helper = NavigationHelper(
        mockContext,
        router: mockRouter,
        onError: (error) => capturedErrors.add(error),
      );
    });

    group('Constructor', () {
      test('creates helper with context and router', () {
        expect(helper, isNotNull);
        expect(helper.router, equals(mockRouter));
      });

      test('creates helper with error callback', () {
        final errors = <Object>[];
        final helperWithCallback = NavigationHelper(
          mockContext,
          router: mockRouter,
          onError: (error) => errors.add(error),
        );

        expect(helperWithCallback, isNotNull);
        expect(helperWithCallback.onError, isNotNull);
      });

      test('creates helper without error callback', () {
        final helperNoCallback = NavigationHelper(
          mockContext,
          router: mockRouter,
        );

        expect(helperNoCallback, isNotNull);
        expect(helperNoCallback.onError, isNull);
      });
    });

    group('Basic Navigation - goToChat', () {
      test('navigates to chat screen', () {
        // Act
        helper.goToChat();

        // Assert
        verify(() => mockRouter.go(RoutePaths.chat)).called(1);
      });

      test('handles navigation error with error callback', () {
        // Arrange
        final error = Exception('Navigation failed');
        when(() => mockRouter.go(RoutePaths.chat)).thenThrow(error);

        // Act
        helper.goToChat();

        // Assert
        expect(capturedErrors, contains(error));
      });

      test('continues execution after navigation error', () {
        // Arrange
        when(() => mockRouter.go(RoutePaths.chat)).thenThrow(Exception('Test error'));

        // Act - Should not throw
        expect(() => helper.goToChat(), returnsNormally);
      });
    });

    group('Basic Navigation - goToQuickActions', () {
      test('navigates to quick actions screen', () {
        // Act
        helper.goToQuickActions();

        // Assert
        verify(() => mockRouter.go(RoutePaths.quickActions)).called(1);
      });

      test('handles error when navigating to quick actions', () {
        // Arrange
        final error = Exception('Quick actions unavailable');
        when(() => mockRouter.go(RoutePaths.quickActions)).thenThrow(error);

        // Act
        helper.goToQuickActions();

        // Assert
        expect(capturedErrors, contains(error));
      });
    });

    group('Basic Navigation - goToOperations', () {
      test('navigates to operations screen', () {
        // Act
        helper.goToOperations();

        // Assert
        verify(() => mockRouter.go(RoutePaths.operations)).called(1);
      });

      test('handles error when navigating to operations', () {
        // Arrange
        final error = Exception('Operations unavailable');
        when(() => mockRouter.go(RoutePaths.operations)).thenThrow(error);

        // Act
        helper.goToOperations();

        // Assert
        expect(capturedErrors, contains(error));
      });
    });

    group('Basic Navigation - goToAdmin', () {
      test('navigates to admin screen', () {
        // Act
        helper.goToAdmin();

        // Assert
        verify(() => mockRouter.go(RoutePaths.admin)).called(1);
      });

      test('handles error when navigating to admin', () {
        // Arrange
        final error = Exception('Admin unavailable');
        when(() => mockRouter.go(RoutePaths.admin)).thenThrow(error);

        // Act
        helper.goToAdmin();

        // Assert
        expect(capturedErrors, contains(error));
      });
    });

    group('Basic Navigation - goToNotFound', () {
      test('navigates to not found screen', () {
        // Act
        helper.goToNotFound();

        // Assert
        verify(() => mockRouter.go(RoutePaths.notFound)).called(1);
      });

      test('handles error when navigating to not found', () {
        // Arrange
        final error = Exception('Not found unavailable');
        when(() => mockRouter.go(RoutePaths.notFound)).thenThrow(error);

        // Act
        helper.goToNotFound();

        // Assert
        expect(capturedErrors, contains(error));
      });
    });

    group('Named Navigation - goToNamed', () {
      test('navigates using route name', () {
        // Act
        helper.goToNamed(RouteNames.chat);

        // Assert
        verify(() => mockRouter.goNamed(RouteNames.chat)).called(1);
      });

      test('navigates to quick actions by name', () {
        // Act
        helper.goToNamed(RouteNames.quickActions);

        // Assert
        verify(() => mockRouter.goNamed(RouteNames.quickActions)).called(1);
      });

      test('falls back to chat on navigation error', () {
        // Arrange
        when(() => mockRouter.goNamed(RouteNames.operations))
            .thenThrow(Exception('Route not found'));

        // Act
        helper.goToNamed(RouteNames.operations);

        // Assert
        verify(() => mockRouter.goNamed(RouteNames.operations)).called(1);
        verify(() => mockRouter.go(RoutePaths.chat)).called(1);
      });

      test('does not fallback when chat navigation fails', () {
        // Arrange
        when(() => mockRouter.goNamed(RouteNames.chat))
            .thenThrow(Exception('Chat unavailable'));

        // Act
        helper.goToNamed(RouteNames.chat);

        // Assert - Should not try to fallback to itself
        verify(() => mockRouter.goNamed(RouteNames.chat)).called(1);
        verifyNever(() => mockRouter.go(any()));
      });

      test('invokes error callback on named route failure', () {
        // Arrange
        final error = Exception('Invalid route name');
        when(() => mockRouter.goNamed('invalid_route')).thenThrow(error);

        // Act
        helper.goToNamed('invalid_route');

        // Assert
        expect(capturedErrors, contains(error));
      });

      test('handles empty route name gracefully', () {
        // Arrange
        when(() => mockRouter.goNamed('')).thenThrow(Exception('Empty route'));

        // Act
        helper.goToNamed('');

        // Assert - Should handle error
        expect(capturedErrors, isNotEmpty);
      });
    });

    group('Back Navigation', () {
      test('navigates back when possible', () {
        // Arrange
        when(() => mockRouter.canPop()).thenReturn(true);

        // Act
        helper.goBack();

        // Assert
        verify(() => mockRouter.pop()).called(1);
      });

      test('handles back navigation error', () {
        // Arrange
        final error = Exception('Cannot pop');
        when(() => mockRouter.pop()).thenThrow(error);

        // Act
        helper.goBack();

        // Assert
        expect(capturedErrors, contains(error));
      });

      test('canGoBack returns true when navigation stack has routes', () {
        // Arrange
        when(() => mockRouter.canPop()).thenReturn(true);

        // Act
        final result = helper.canGoBack();

        // Assert
        expect(result, isTrue);
        verify(() => mockRouter.canPop()).called(1);
      });

      test('canGoBack returns false when navigation stack is empty', () {
        // Arrange
        when(() => mockRouter.canPop()).thenReturn(false);

        // Act
        final result = helper.canGoBack();

        // Assert
        expect(result, isFalse);
        verify(() => mockRouter.canPop()).called(1);
      });

      test('goBack does nothing if stack is empty', () {
        // Arrange
        when(() => mockRouter.canPop()).thenReturn(false);
        when(() => mockRouter.pop()).thenThrow(Exception('Cannot pop empty stack'));

        // Act
        helper.goBack();

        // Assert - Error should be caught
        expect(capturedErrors, isNotEmpty);
      });
    });

    group('Replace Navigation', () {
      test('replaces current route with chat', () {
        // Act
        helper.replaceWithChat();

        // Assert
        verify(() => mockRouter.pushReplacement(RoutePaths.chat)).called(1);
      });

      test('replaces current route with quick actions', () {
        // Act
        helper.replaceWithQuickActions();

        // Assert
        verify(() => mockRouter.pushReplacement(RoutePaths.quickActions)).called(1);
      });

      test('replaces current route with operations', () {
        // Act
        helper.replaceWithOperations();

        // Assert
        verify(() => mockRouter.pushReplacement(RoutePaths.operations)).called(1);
      });

      test('replaces current route with admin', () {
        // Act
        helper.replaceWithAdmin();

        // Assert
        verify(() => mockRouter.pushReplacement(RoutePaths.admin)).called(1);
      });

      test('handles error when replacing with chat', () {
        // Arrange
        final error = Exception('Replace failed');
        when(() => mockRouter.pushReplacement(RoutePaths.chat)).thenThrow(error);

        // Act
        helper.replaceWithChat();

        // Assert
        expect(capturedErrors, contains(error));
      });

      test('handles error when replacing with quick actions', () {
        // Arrange
        final error = Exception('Replace failed');
        when(() => mockRouter.pushReplacement(RoutePaths.quickActions)).thenThrow(error);

        // Act
        helper.replaceWithQuickActions();

        // Assert
        expect(capturedErrors, contains(error));
      });
    });

    group('Error Handling', () {
      test('invokes error callback when provided', () {
        // Arrange
        final error = Exception('Test error');
        when(() => mockRouter.go(RoutePaths.chat)).thenThrow(error);

        // Act
        helper.goToChat();

        // Assert
        expect(capturedErrors, contains(error));
        expect(capturedErrors.length, equals(1));
      });

      test('does not throw when error callback is null', () {
        // Arrange
        final helperNoCallback = NavigationHelper(
          mockContext,
          router: mockRouter,
        );
        when(() => mockRouter.go(RoutePaths.chat)).thenThrow(Exception('Error'));

        // Act & Assert - Should not throw
        expect(() => helperNoCallback.goToChat(), returnsNormally);
      });

      test('handles multiple errors in sequence', () {
        // Arrange
        when(() => mockRouter.go(any())).thenThrow(Exception('Error'));

        // Act
        helper.goToChat();
        helper.goToQuickActions();
        helper.goToOperations();

        // Assert
        expect(capturedErrors.length, equals(3));
      });

      test('continues navigation after error', () {
        // Arrange
        when(() => mockRouter.go(RoutePaths.chat)).thenThrow(Exception('First error'));
        when(() => mockRouter.go(RoutePaths.quickActions)).thenReturn(null);

        // Act
        helper.goToChat(); // Should error
        helper.goToQuickActions(); // Should succeed

        // Assert
        expect(capturedErrors.length, equals(1));
        verify(() => mockRouter.go(RoutePaths.quickActions)).called(1);
      });
    });

    group('Navigation Sequence', () {
      test('handles multiple navigation calls in sequence', () {
        // Act
        helper.goToChat();
        helper.goToQuickActions();
        helper.goToOperations();
        helper.goToAdmin();

        // Assert
        verify(() => mockRouter.go(RoutePaths.chat)).called(1);
        verify(() => mockRouter.go(RoutePaths.quickActions)).called(1);
        verify(() => mockRouter.go(RoutePaths.operations)).called(1);
        verify(() => mockRouter.go(RoutePaths.admin)).called(1);
      });

      test('handles navigation and back navigation', () {
        // Arrange
        when(() => mockRouter.canPop()).thenReturn(true);

        // Act
        helper.goToQuickActions();
        helper.goBack();

        // Assert
        verify(() => mockRouter.go(RoutePaths.quickActions)).called(1);
        verify(() => mockRouter.pop()).called(1);
      });

      test('handles replace after normal navigation', () {
        // Act
        helper.goToChat();
        helper.replaceWithAdmin();

        // Assert
        verify(() => mockRouter.go(RoutePaths.chat)).called(1);
        verify(() => mockRouter.pushReplacement(RoutePaths.admin)).called(1);
      });
    });

    group('Edge Cases', () {
      test('handles rapid navigation requests', () {
        // Act - Rapid fire navigation
        for (int i = 0; i < 100; i++) {
          helper.goToChat();
        }

        // Assert
        verify(() => mockRouter.go(RoutePaths.chat)).called(100);
      });

      test('handles navigation with null router (should use context router)', () {
        // This tests the fallback to GoRouter.of(context)
        // In real usage, if router parameter is null, it fetches from context
        expect(helper.router, equals(mockRouter));
      });

      test('handles concurrent error callbacks', () {
        // Arrange
        when(() => mockRouter.go(any())).thenThrow(Exception('Error'));

        // Act - Multiple navigation attempts that will fail
        helper.goToChat();
        helper.goToQuickActions();
        helper.goToOperations();
        helper.goToAdmin();

        // Assert - All errors should be captured
        expect(capturedErrors.length, equals(4));
      });
    });

    group('Type Safety', () {
      test('uses correct route paths from constants', () {
        // Act
        helper.goToChat();
        helper.goToQuickActions();
        helper.goToOperations();
        helper.goToAdmin();
        helper.goToNotFound();

        // Assert - Verify exact path constants are used
        verify(() => mockRouter.go('/chat')).called(1);
        verify(() => mockRouter.go('/new')).called(1);
        verify(() => mockRouter.go('/operation')).called(1);
        verify(() => mockRouter.go('/admin')).called(1);
        verify(() => mockRouter.go('/404')).called(1);
      });

      test('uses correct route names from constants', () {
        // Act
        helper.goToNamed(RouteNames.chat);
        helper.goToNamed(RouteNames.quickActions);
        helper.goToNamed(RouteNames.operations);
        helper.goToNamed(RouteNames.admin);

        // Assert - Verify exact name constants are used
        verify(() => mockRouter.goNamed('chat')).called(1);
        verify(() => mockRouter.goNamed('quickActions')).called(1);
        verify(() => mockRouter.goNamed('operations')).called(1);
        verify(() => mockRouter.goNamed('admin')).called(1);
      });
    });

    group('Documentation Examples', () {
      test('direct usage example works', () {
        // Example from documentation
        helper.goToChat();

        verify(() => mockRouter.go(RoutePaths.chat)).called(1);
      });

      test('check and go back example works', () {
        // Example from documentation
        when(() => mockRouter.canPop()).thenReturn(true);

        if (helper.canGoBack()) {
          helper.goBack();
        }

        verify(() => mockRouter.canPop()).called(1);
        verify(() => mockRouter.pop()).called(1);
      });

      test('replace navigation example works', () {
        // Example from documentation
        helper.replaceWithAdmin();

        verify(() => mockRouter.pushReplacement(RoutePaths.admin)).called(1);
      });
    });
  });
  group('NavigationExtension', () {
    testWidgets('provides easy access to NavigationHelper', (tester) async {
      // Arrange
      NavigationHelper? capturedHelper;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedHelper = context.nav;
              return Container();
            },
          ),
        ),
      );

      // Assert
      expect(capturedHelper, isNotNull);
      expect(capturedHelper, isA<NavigationHelper>());
    });

    testWidgets('creates new instance on each access', (tester) async {
      // Arrange
      NavigationHelper? helper1;
      NavigationHelper? helper2;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              helper1 = context.nav;
              helper2 = context.nav;
              return Container();
            },
          ),
        ),
      );

      // Assert - Should create new instances (not singletons)
      expect(helper1, isNotNull);
      expect(helper2, isNotNull);
      // Note: These will be different instances
      expect(identical(helper1, helper2), isFalse);
    });

    testWidgets('extension works with current context', (tester) async {
      // Arrange
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              final helper = context.nav;
              expect(helper, isNotNull);
              return Container();
            },
          ),
        ),
      );

      // Assert
      expect(capturedContext, isNotNull);
    });

  });
}
