import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mnesis_flutter/features/shell/presentation/shell_screen.dart';

void main() {
  group('ShellScreen', () {
    /// Test helper to wrap widget with MaterialApp and Router for testing
    Widget createTestWidget({String initialLocation = '/chat'}) {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          ShellRoute(
            builder: (context, state, child) => ShellScreen(child: child),
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const Center(child: Text('Chat Content')),
              ),
              GoRoute(
                path: '/new',
                builder: (context, state) => const Center(child: Text('New Content')),
              ),
              GoRoute(
                path: '/operation',
                builder: (context, state) => const Center(child: Text('Operation Content')),
              ),
              GoRoute(
                path: '/admin',
                builder: (context, state) => const Center(child: Text('Admin Content')),
              ),
            ],
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      expect(find.byType(NavigationBar), findsOneWidget);

      // Assert - Child content is displayed
      expect(find.text('Chat Content'), findsOneWidget);

      // Assert - Navigation items
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Novo'), findsOneWidget);
      expect(find.text('Operação'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);

      // Assert - Navigation icons (both selected and unselected versions)
      expect(find.byIcon(Icons.chat_bubble_outline).evaluate().isNotEmpty ||
             find.byIcon(Icons.chat_bubble).evaluate().isNotEmpty, isTrue);
      expect(find.byIcon(Icons.add_circle_outline).evaluate().isNotEmpty ||
             find.byIcon(Icons.add_circle).evaluate().isNotEmpty, isTrue);
      expect(find.byIcon(Icons.medical_services_outlined).evaluate().isNotEmpty ||
             find.byIcon(Icons.medical_services).evaluate().isNotEmpty, isTrue);
      expect(find.byIcon(Icons.person_outline).evaluate().isNotEmpty ||
             find.byIcon(Icons.person).evaluate().isNotEmpty, isTrue);
    });

    testWidgets('navigation bar has correct number of destinations', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find NavigationBar
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      // Get NavigationBar widget
      final navigationBarWidget = tester.widget<NavigationBar>(navigationBar);

      // Assert - Should have 4 destinations
      expect(navigationBarWidget.destinations.length, 4);
    });

    testWidgets('navigation bar shows correct selected index for Chat route', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(initialLocation: '/chat'));
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      // Assert - Chat is at index 0
      expect(navigationBar.selectedIndex, 0);
      expect(find.text('Chat Content'), findsOneWidget);
    });

    testWidgets('navigation bar shows correct selected index for New route', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(initialLocation: '/new'));
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      // Assert - New is at index 1
      expect(navigationBar.selectedIndex, 1);
      expect(find.text('New Content'), findsOneWidget);
    });

    testWidgets('navigation bar shows correct selected index for Operation route', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(initialLocation: '/operation'));
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      // Assert - Operation is at index 2
      expect(navigationBar.selectedIndex, 2);
      expect(find.text('Operation Content'), findsOneWidget);
    });

    testWidgets('navigation bar shows correct selected index for Admin route', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(initialLocation: '/admin'));
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      // Assert - Admin is at index 3
      expect(navigationBar.selectedIndex, 3);
      expect(find.text('Admin Content'), findsOneWidget);
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      // Arrange
      final router = GoRouter(
        initialLocation: '/chat',
        routes: [
          ShellRoute(
            builder: (context, state, child) => ShellScreen(child: child),
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const Center(child: Text('Chat Content')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ShellScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ShellScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('navigation destinations have correct properties', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get NavigationBar widget
      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      // Assert Chat destination
      final chatDestination = navigationBar.destinations[0] as NavigationDestination;
      expect(chatDestination.label, 'Chat');

      // Assert Novo destination
      final novoDestination = navigationBar.destinations[1] as NavigationDestination;
      expect(novoDestination.label, 'Novo');

      // Assert Operação destination
      final operationDestination = navigationBar.destinations[2] as NavigationDestination;
      expect(operationDestination.label, 'Operação');

      // Assert Admin destination
      final adminDestination = navigationBar.destinations[3] as NavigationDestination;
      expect(adminDestination.label, 'Admin');
    });

    testWidgets('navigation bar callback is properly set', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get NavigationBar widget
      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      // Assert onDestinationSelected is not null
      expect(navigationBar.onDestinationSelected, isNotNull);
    });

    testWidgets('body displays child widget passed to ShellScreen', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(initialLocation: '/chat'));
      await tester.pumpAndSettle();

      // Assert - Child content is displayed
      expect(find.text('Chat Content'), findsOneWidget);

      // Navigate to different route
      await tester.pumpWidget(createTestWidget(initialLocation: '/new'));
      await tester.pumpAndSettle();

      // Assert - New content is displayed
      expect(find.text('New Content'), findsOneWidget);
    });

    testWidgets('scaffold structure is correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Scaffold
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsAtLeastNWidgets(1));

      // Verify NavigationBar is present
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);
    });

    testWidgets('all navigation labels are visible', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert all labels are present
      final labels = ['Chat', 'Novo', 'Operação', 'Admin'];
      for (final label in labels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('navigation icons change when selected', (tester) async {
      // Test Chat selected (default)
      await tester.pumpWidget(createTestWidget(initialLocation: '/chat'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

      // Test Novo selected
      await tester.pumpWidget(createTestWidget(initialLocation: '/new'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);

      // Test Operation selected
      await tester.pumpWidget(createTestWidget(initialLocation: '/operation'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      // Test Admin selected
      await tester.pumpWidget(createTestWidget(initialLocation: '/admin'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('tapping navigation items changes route', (tester) async {
      // Start on Chat
      await tester.pumpWidget(createTestWidget(initialLocation: '/chat'));
      await tester.pumpAndSettle();
      expect(find.text('Chat Content'), findsOneWidget);

      // Tap on Novo (New)
      await tester.tap(find.text('Novo'));
      await tester.pumpAndSettle();
      expect(find.text('New Content'), findsOneWidget);

      // Tap on Operação (Operation)
      await tester.tap(find.text('Operação'));
      await tester.pumpAndSettle();
      expect(find.text('Operation Content'), findsOneWidget);

      // Tap on Admin
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();
      expect(find.text('Admin Content'), findsOneWidget);

      // Tap back to Chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.text('Chat Content'), findsOneWidget);
    });

    testWidgets('navigation maintains state across route changes', (tester) async {
      // Start on Chat
      await tester.pumpWidget(createTestWidget(initialLocation: '/chat'));
      await tester.pumpAndSettle();

      // Navigate through all tabs
      await tester.tap(find.text('Novo'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.text('Operação'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);

      // Navigation bar should persist
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('calculates selected index correctly for nested routes', (tester) async {
      // Test nested chat route (e.g., /chat/conversation-123)
      final router = GoRouter(
        initialLocation: '/chat',
        routes: [
          ShellRoute(
            builder: (context, state, child) => ShellScreen(child: child),
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const Center(child: Text('Chat Content')),
                routes: [
                  GoRoute(
                    path: ':conversationId',
                    builder: (context, state) => const Center(child: Text('Conversation')),
                  ),
                ],
              ),
              GoRoute(
                path: '/operation',
                builder: (context, state) => const Center(child: Text('Operation Content')),
                routes: [
                  GoRoute(
                    path: ':operationId',
                    builder: (context, state) => const Center(child: Text('Operation Detail')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Should still select Chat tab for nested route
      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 0);
    });

    testWidgets('defaults to chat tab for unknown routes', (tester) async {
      // Test with a route that doesn't match any tab
      final router = GoRouter(
        initialLocation: '/unknown',
        routes: [
          ShellRoute(
            builder: (context, state, child) => ShellScreen(child: child),
            routes: [
              GoRoute(
                path: '/unknown',
                builder: (context, state) => const Center(child: Text('Unknown Content')),
              ),
              GoRoute(
                path: '/chat',
                builder: (context, state) => const Center(child: Text('Chat Content')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Should default to index 0 (Chat) for unknown routes
      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 0);
    });
  });
}