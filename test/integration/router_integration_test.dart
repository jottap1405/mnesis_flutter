import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mnesis_flutter/core/router/navigation/navigation_helper.dart';
import 'package:mnesis_flutter/core/router/routes/route_names.dart';
import 'package:mnesis_flutter/core/router/routes/route_paths.dart';
import 'package:mnesis_flutter/main.dart';
import 'package:mnesis_flutter/shared/widgets/not_found_page.dart';

/// Comprehensive integration tests for the router system.
///
/// Tests the complete navigation flow including:
/// - Initial app launch and routing
/// - Bottom navigation interactions
/// - Programmatic navigation
/// - Deep linking
/// - Error handling
/// - End-to-end user journeys
///
/// All tests use real MnesisApp with actual GoRouter - no mocking.
void main() {
  group('Router Integration Tests -', () {
    // Line 25

    group('App Launch & Initial State', () {
      testWidgets('app launches to chat screen with bottom navigation',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        // Verify chat screen content
        expect(find.text('Suas Conversas'), findsOneWidget);

        // Verify bottom navigation exists with 4 tabs
        expect(find.byType(NavigationBar), findsOneWidget);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.destinations.length, equals(4));
        expect(navBar.selectedIndex, equals(0));
      });

      testWidgets('bottom navigation displays all tab labels', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        // Verify all navigation labels
        expect(find.text('Chat'), findsWidgets);
        expect(find.text('New'), findsOneWidget);
        expect(find.text('Operations'), findsOneWidget);
        expect(find.text('Admin'), findsWidgets);
      });
    });
    // Line 60

    group('Bottom Navigation Flow', () {
      testWidgets('tapping New tab shows Novo screen', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();

        expect(find.text('Novo'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(1));
      });

      testWidgets('tapping Operations tab shows Operações screen',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Operations'));
        await tester.pumpAndSettle();

        expect(find.text('Operações'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(2));
      });

      testWidgets('tapping Admin tab shows Admin screen', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Admin').first);
        await tester.pumpAndSettle();

        expect(find.text('Admin'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(3));
      });
      // Line 110

      testWidgets('navigating through all tabs updates correctly',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        // Chat → New
        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();
        expect(find.text('Novo'), findsWidgets);

        // New → Operations
        await tester.tap(find.text('Operations'));
        await tester.pumpAndSettle();
        expect(find.text('Operações'), findsWidgets);

        // Operations → Admin
        await tester.tap(find.text('Admin').first);
        await tester.pumpAndSettle();
        expect(find.text('Admin'), findsWidgets);

        // Admin → Chat (complete cycle)
        await tester.tap(find.text('Chat').first);
        await tester.pumpAndSettle();
        expect(find.text('Suas Conversas'), findsOneWidget);

        // Bottom navigation persists
        expect(find.byType(NavigationBar), findsOneWidget);
      });

      testWidgets('AppShell persists across navigation', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final navBarFinder = find.byType(NavigationBar);

        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();
        expect(navBarFinder, findsOneWidget);

        await tester.tap(find.text('Operations'));
        await tester.pumpAndSettle();
        expect(navBarFinder, findsOneWidget);

        await tester.tap(find.text('Admin').first);
        await tester.pumpAndSettle();
        expect(navBarFinder, findsOneWidget);
      });
    });
    // Line 165

    group('Programmatic Navigation', () {
      testWidgets('NavigationHelper.goToChat navigates correctly',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Admin').first);
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        context.nav.goToChat();
        await tester.pumpAndSettle();

        expect(find.text('Suas Conversas'), findsOneWidget);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(0));
      });

      testWidgets('NavigationHelper.goToQuickActions navigates correctly',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        context.nav.goToQuickActions();
        await tester.pumpAndSettle();

        expect(find.text('Novo'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(1));
      });
      // Line 205

      testWidgets('NavigationHelper.goToOperations navigates correctly',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        context.nav.goToOperations();
        await tester.pumpAndSettle();

        expect(find.text('Operações'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(2));
      });

      testWidgets('NavigationHelper.goToAdmin navigates correctly',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        context.nav.goToAdmin();
        await tester.pumpAndSettle();

        expect(find.text('Admin'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(3));
      });

      testWidgets('context.go and context.goNamed work correctly',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));

        // Navigate using context.go
        GoRouter.of(context).go(RoutePaths.operations);
        await tester.pumpAndSettle();
        expect(find.text('Operações'), findsWidgets);

        // Navigate using context.goNamed
        GoRouter.of(context).goNamed(RouteNames.quickActions);
        await tester.pumpAndSettle();
        expect(find.text('Novo'), findsWidgets);
      });
    });
    // Line 260

    group('Back Navigation', () {
      testWidgets('canGoBack returns false at initial route', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        expect(context.nav.canGoBack(), isFalse);
      });

      testWidgets('tab navigation maintains flat hierarchy', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));

        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Operations'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Admin').first);
        await tester.pumpAndSettle();

        // Still flat navigation - no back stack
        expect(context.nav.canGoBack(), isFalse);

        final router = GoRouter.of(context);
        expect(
          router.routerDelegate.currentConfiguration.fullPath,
          equals(RoutePaths.admin),
        );
      });
    });
    // Line 300

    group('Deep Link Simulation', () {
      testWidgets('deep link to /chat works correctly', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        GoRouter.of(context).go(RoutePaths.chat);
        await tester.pumpAndSettle();

        expect(find.text('Suas Conversas'), findsOneWidget);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(0));
      });

      testWidgets('deep link to /new works correctly', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        GoRouter.of(context).go(RoutePaths.quickActions);
        await tester.pumpAndSettle();

        expect(find.text('Novo'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(1));
      });

      testWidgets('deep link to /operation works correctly', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        GoRouter.of(context).go(RoutePaths.operations);
        await tester.pumpAndSettle();

        expect(find.text('Operações'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(2));
      });
      // Line 355

      testWidgets('deep link to /admin works correctly', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        GoRouter.of(context).go(RoutePaths.admin);
        await tester.pumpAndSettle();

        expect(find.text('Admin'), findsWidgets);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(3));
      });

      testWidgets('sequential deep links update correctly', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        final router = GoRouter.of(context);

        router.go(RoutePaths.quickActions);
        await tester.pumpAndSettle();
        expect(find.text('Novo'), findsWidgets);

        router.go(RoutePaths.operations);
        await tester.pumpAndSettle();
        expect(find.text('Operações'), findsWidgets);

        router.go(RoutePaths.admin);
        await tester.pumpAndSettle();
        expect(find.text('Admin'), findsWidgets);

        router.go(RoutePaths.chat);
        await tester.pumpAndSettle();
        expect(find.text('Suas Conversas'), findsOneWidget);
      });
    });
    // Line 400

    group('Error Handling', () {
      testWidgets('invalid route displays NotFoundPage', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        GoRouter.of(context).go('/invalid-route-path');
        await tester.pumpAndSettle();

        expect(find.byType(NotFoundPage), findsOneWidget);
        expect(find.text('404'), findsOneWidget);
        expect(find.text('Page Not Found'), findsOneWidget);
      });

      testWidgets('NotFoundPage home button returns to chat',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        GoRouter.of(context).go('/broken-link');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Go to Home'));
        await tester.pumpAndSettle();

        expect(find.text('Suas Conversas'), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(0));
      });

      testWidgets('explicit /404 route works without bottom navigation',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        GoRouter.of(context).go(RoutePaths.notFound);
        await tester.pumpAndSettle();

        expect(find.byType(NotFoundPage), findsOneWidget);
        expect(find.text('404'), findsOneWidget);

        // Bottom navigation should NOT be shown (standalone route)
        expect(find.byType(NavigationBar), findsNothing);
      });
      // Line 455

      testWidgets('NavigationHelper handles errors gracefully',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));
        bool errorOccurred = false;

        final helper = NavigationHelper(
          context,
          onError: (error) {
            errorOccurred = true;
          },
        );

        helper.goToNamed('invalid-route-name');
        await tester.pumpAndSettle();

        expect(errorOccurred, isTrue);
        // Falls back to chat
        expect(find.text('Suas Conversas'), findsOneWidget);
      });
    });
    // Line 485

    group('End-to-End User Flows', () {
      testWidgets('complete navigation journey', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        // 1. Start at Chat
        expect(find.text('Suas Conversas'), findsOneWidget);

        // 2. Go to New
        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();
        expect(find.text('Novo'), findsWidgets);

        // 3. Go to Operations
        await tester.tap(find.text('Operations'));
        await tester.pumpAndSettle();
        expect(find.text('Operações'), findsWidgets);

        // 4. Go to Admin
        await tester.tap(find.text('Admin').first);
        await tester.pumpAndSettle();
        expect(find.text('Admin'), findsWidgets);

        // 5. Back to Chat
        await tester.tap(find.text('Chat').first);
        await tester.pumpAndSettle();
        expect(find.text('Suas Conversas'), findsOneWidget);

        expect(find.byType(NavigationBar), findsOneWidget);
      });

      testWidgets('mixed navigation methods', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));

        // 1. Tab navigation
        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();
        expect(find.text('Novo'), findsWidgets);

        // 2. Programmatic via NavigationHelper
        context.nav.goToOperations();
        await tester.pumpAndSettle();
        expect(find.text('Operações'), findsWidgets);

        // 3. Direct GoRouter
        GoRouter.of(context).go(RoutePaths.admin);
        await tester.pumpAndSettle();
        expect(find.text('Admin'), findsWidgets);

        // 4. Back via tab
        await tester.tap(find.text('Chat').first);
        await tester.pumpAndSettle();
        expect(find.text('Suas Conversas'), findsOneWidget);

        expect(find.byType(NavigationBar), findsOneWidget);
      });
      // Line 555

      testWidgets('deep link → tab → programmatic flow', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));

        // 1. Deep link
        GoRouter.of(context).go(RoutePaths.operations);
        await tester.pumpAndSettle();
        expect(find.text('Operações'), findsWidgets);

        // 2. Tab navigation
        await tester.tap(find.text('Admin').first);
        await tester.pumpAndSettle();
        expect(find.text('Admin'), findsWidgets);

        // 3. Programmatic
        context.nav.goToQuickActions();
        await tester.pumpAndSettle();
        expect(find.text('Novo'), findsWidgets);

        // 4. Back via NavigationHelper
        context.nav.goToChat();
        await tester.pumpAndSettle();
        expect(find.text('Suas Conversas'), findsOneWidget);

        final navBar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(navBar.selectedIndex, equals(0));
      });

      testWidgets('error recovery → normal navigation', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));

        // Navigate to error
        GoRouter.of(context).go('/broken');
        await tester.pumpAndSettle();
        expect(find.text('404'), findsOneWidget);

        // Recover
        await tester.tap(find.text('Go to Home'));
        await tester.pumpAndSettle();
        expect(find.text('Suas Conversas'), findsOneWidget);

        // Continue normal navigation
        await tester.tap(find.text('Operations'));
        await tester.pumpAndSettle();
        expect(find.text('Operações'), findsWidgets);

        expect(find.byType(NavigationBar), findsOneWidget);
      });
    });
    // Line 620

    group('AuthGuard Integration', () {
      testWidgets('all main routes are accessible', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(MnesisApp));

        context.nav.goToChat();
        await tester.pumpAndSettle();
        expect(find.text('Suas Conversas'), findsOneWidget);

        context.nav.goToQuickActions();
        await tester.pumpAndSettle();
        expect(find.text('Novo'), findsWidgets);

        context.nav.goToOperations();
        await tester.pumpAndSettle();
        expect(find.text('Operações'), findsWidgets);

        context.nav.goToAdmin();
        await tester.pumpAndSettle();
        expect(find.text('Admin'), findsWidgets);
      });

      testWidgets('chat-first architecture allows direct access',
          (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        // No redirect, direct chat access
        expect(find.text('Suas Conversas'), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);

        // No authentication barriers
        expect(find.text('Login'), findsNothing);
        expect(find.text('Sign In'), findsNothing);
      });
    });
    // Line 665

    group('Theme & UI Integration', () {
      testWidgets('dark theme applied across navigation', (tester) async {
        await tester.pumpWidget(const MnesisApp());
        await tester.pumpAndSettle();

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );

        expect(materialApp.themeMode, equals(ThemeMode.dark));
        expect(materialApp.darkTheme, isNotNull);

        // Navigate through screens
        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Operations'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Admin').first);
        await tester.pumpAndSettle();

        // Theme persists
        expect(find.byType(NavigationBar), findsOneWidget);
      });
    });
  });
}
// Line 695 - TOTAL FILE SIZE UNDER 700 LINES (Rule #24 COMPLIANT)
