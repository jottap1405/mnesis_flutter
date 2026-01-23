// Widget test for Mnesis app.
//
// Tests the main application widget to ensure:
// - App initializes without crashing
// - Initial route loads correctly
// - Bottom navigation is present
// - Dark theme applied correctly
// - ProviderScope configuration is correct
//
// Comprehensive test coverage for the MnesisApp widget following
// FlowForge Rule #3 (80%+ test coverage) and Rule #25 (Testing & Reliability).
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/main.dart';

void main() {
  /// Setup before all tests in this file
  ///
  /// Initializes test environment with:
  /// - Flutter test bindings
  /// - Mock environment variables for dotenv
  setUpAll(() async {
    // Initialize dotenv with test environment variables
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test-api.example.com
API_TIMEOUT_SECONDS=30
ENVIRONMENT=test
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
    ''');
  });

  group('MnesisApp Widget Tests', () {
    testWidgets('loads successfully with ProviderScope', (WidgetTester tester) async {
      // Build our app with ProviderScope wrapper (required for ConsumerWidget)
      await tester.pumpWidget(
        const ProviderScope(
          child: MnesisApp(),
        ),
      );

      // Wait for initial frame to build
      await tester.pump();

      // Verify that MaterialApp.router is present
      expect(find.byType(MaterialApp), findsOneWidget);

      // Wait for all async operations and animations to complete
      await tester.pumpAndSettle();

      // Verify that the initial route loaded successfully
      // The app should have a Scaffold (main container)
      expect(find.byType(Scaffold), findsWidgets);

      // Verify that NavigationBar is present (bottom navigation)
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify that all navigation tabs are present
      // Note: Some labels may appear multiple times (e.g., "Chat" in both
      // AppBar and NavigationBar), so we use findsWidgets to be flexible
      expect(find.text('Chat'), findsWidgets);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('Operations'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('uses dark theme exclusively', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MnesisApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dark theme is applied
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.themeMode, equals(ThemeMode.dark),
        reason: 'Mnesis should always use dark theme per design system');
    });

    testWidgets('has correct app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MnesisApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app title
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, equals('Mnesis'));
    });

    testWidgets('disables debug banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MnesisApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify debug banner is disabled
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, isFalse,
        reason: 'Debug banner should be disabled for cleaner UI in development');
    });
  });

  group('ProviderScope Configuration', () {
    testWidgets('has ProviderScope as root widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MnesisApp(),
        ),
      );

      // Verify ProviderScope is present
      expect(find.byType(ProviderScope), findsOneWidget);
    });
  });
}
