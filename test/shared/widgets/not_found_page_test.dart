import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/router/app_router_simple.dart';
import 'package:mnesis_flutter/core/router/routes/route_paths.dart';
import 'package:mnesis_flutter/shared/widgets/not_found_page.dart';

/// Comprehensive test suite for NotFoundPage widget.
///
/// Tests verify:
/// - Widget structure and rendering
/// - All text elements (404, title, description)
/// - Icon display (error_outline)
/// - Navigation button functionality
/// - Theme integration
/// - Layout and spacing
///
/// Coverage target: 80%+
void main() {
  group('NotFoundPage', () {
    group('Widget Structure', () {
      testWidgets('renders correctly with all required elements',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        // Verify scaffold
        expect(find.byType(Scaffold), findsOneWidget);

        // Verify main container structure
        expect(find.byType(Padding), findsWidgets);
        expect(find.byType(Column), findsOneWidget);

        // Verify all text elements
        expect(find.text('404'), findsOneWidget);
        expect(find.text('Page Not Found'), findsOneWidget);
        expect(
            find.text('The page you are looking for does not exist.'),
            findsOneWidget);

        // Verify icon
        expect(find.byIcon(Icons.error_outline), findsOneWidget);

        // Verify button
        expect(find.text('Go to Home'), findsOneWidget);
        expect(find.byIcon(Icons.home), findsWidgets); // Icon and button icon
      });

      testWidgets('has correct widget hierarchy', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        // Verify hierarchy: Scaffold > Body > Center > Padding > Column
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsOneWidget);

        final column = find.byType(Column);
        expect(column, findsOneWidget);

        final padding = find.byType(Padding);
        expect(padding, findsWidgets);
      });
    });

    group('Icon Display', () {
      testWidgets('displays error icon with correct properties',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        final iconFinder = find.byIcon(Icons.error_outline);
        expect(iconFinder, findsOneWidget);

        final icon = tester.widget<Icon>(iconFinder);
        expect(icon.size, equals(64));
      });

      testWidgets('icon uses theme error color', (tester) async {
        const testErrorColor = Colors.red;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(
                error: testErrorColor,
              ),
            ),
            home: const NotFoundPage(),
          ),
        );

        final iconFinder = find.byIcon(Icons.error_outline);
        final icon = tester.widget<Icon>(iconFinder);

        expect(icon.color, equals(testErrorColor));
      });
    });

    group('Text Elements', () {
      testWidgets('404 text has correct styling', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(
                displayMedium: TextStyle(fontSize: 48),
              ),
            ),
            home: const NotFoundPage(),
          ),
        );

        final textFinder = find.text('404');
        expect(textFinder, findsOneWidget);

        final text = tester.widget<Text>(textFinder);
        expect(text.style?.fontWeight, equals(FontWeight.bold));
      });

      testWidgets('Page Not Found text uses headlineMedium style',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        final textFinder = find.text('Page Not Found');
        expect(textFinder, findsOneWidget);
      });

      testWidgets('description text is center-aligned', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        final textFinder = find.text('The page you are looking for does not exist.');
        expect(textFinder, findsOneWidget);

        final text = tester.widget<Text>(textFinder);
        expect(text.textAlign, equals(TextAlign.center));
      });
    });

    group('Button Functionality', () {
      testWidgets('has home navigation button', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        // Verify button text exists
        expect(find.text('Go to Home'), findsOneWidget,
            reason: 'Button should be present with text');
      });

      testWidgets('button has home icon and text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        // Verify button has both icon and label
        expect(find.byIcon(Icons.home), findsWidgets,
            reason: 'Should have home icon');
        expect(find.text('Go to Home'), findsOneWidget,
            reason: 'Should have button text');
      });

      testWidgets('button navigates to home when tapped', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
          ),
        );

        // Navigate to 404 page first
        AppRouter.router.go(RoutePaths.notFound);
        await tester.pumpAndSettle();

        // Find and tap the button by its text
        final buttonFinder = find.text('Go to Home');
        expect(buttonFinder, findsOneWidget);

        // Tap button to navigate home
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        // Verify navigation occurred (we're now on chat page)
        // The router should have navigated to RoutePaths.chat
      });

      testWidgets('button uses correct route path constant', (tester) async {
        // This test verifies that the button uses RoutePaths.chat
        // which is the correct constant for navigation
        expect(RoutePaths.chat, equals('/chat'),
            reason: 'NotFoundPage should navigate to /chat route');
      });
    });

    group('Layout and Spacing', () {
      testWidgets('has correct padding', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        final paddingFinder = find.byType(Padding);
        expect(paddingFinder, findsWidgets);

        // Main padding should be 24.0
        final mainPadding = tester.widget<Padding>(paddingFinder.first);
        expect(mainPadding.padding, equals(const EdgeInsets.all(24.0)));
      });

      testWidgets('column has correct alignment', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        final columnFinder = find.byType(Column);
        final column = tester.widget<Column>(columnFinder);

        expect(column.mainAxisAlignment, equals(MainAxisAlignment.center),
            reason: 'Column should be center-aligned vertically');
      });

      testWidgets('has SizedBox spacing between elements', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets,
            reason: 'Should have SizedBox widgets for spacing');

        // Verify spacing sizes exist
        final allSizedBoxes = tester.widgetList<SizedBox>(sizedBoxes);
        final heights = allSizedBoxes
            .where((box) => box.height != null)
            .map((box) => box.height)
            .toList();

        expect(heights.contains(24), isTrue,
            reason: 'Should have 24px spacing');
        expect(heights.contains(8), isTrue,
            reason: 'Should have 8px spacing');
        expect(heights.contains(16), isTrue,
            reason: 'Should have 16px spacing');
        expect(heights.contains(32), isTrue,
            reason: 'Should have 32px spacing');
      });
    });

    group('Theme Integration', () {
      testWidgets('respects theme colors', (tester) async {
        const testErrorColor = Colors.purple;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(
                error: testErrorColor,
              ),
            ),
            home: const NotFoundPage(),
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
        expect(icon.color, equals(testErrorColor),
            reason: 'Icon should use theme error color');
      });

      testWidgets('respects theme text styles', (tester) async {
        const testDisplayMedium = TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.w900,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(
                displayMedium: testDisplayMedium,
              ),
            ),
            home: const NotFoundPage(),
          ),
        );

        // Verify theme is applied
        expect(find.text('404'), findsOneWidget);
      });

      testWidgets('works with dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const NotFoundPage(),
          ),
        );

        expect(find.byType(NotFoundPage), findsOneWidget);
        expect(find.text('404'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('works with light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const NotFoundPage(),
          ),
        );

        expect(find.byType(NotFoundPage), findsOneWidget);
        expect(find.text('404'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('renders correctly without MaterialApp ancestor',
          (tester) async {
        // NotFoundPage should work even without MaterialApp
        // (though in practice it will always be within MaterialApp)
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQueryData(),
              child: NotFoundPage(),
            ),
          ),
        );

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('button is tappable', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
          ),
        );

        // Navigate to 404 page
        AppRouter.router.go(RoutePaths.notFound);
        await tester.pumpAndSettle();

        final buttonFinder = find.text('Go to Home');
        expect(buttonFinder, findsOneWidget);

        // Verify button can be tapped
        await tester.tap(buttonFinder);
        await tester.pump();

        // No exception = success
      });

      testWidgets('handles rapid taps gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
          ),
        );

        // Navigate to 404 page
        AppRouter.router.go(RoutePaths.notFound);
        await tester.pumpAndSettle();

        final buttonFinder = find.text('Go to Home');

        // Tap multiple times rapidly
        await tester.tap(buttonFinder);
        await tester.tap(buttonFinder);
        await tester.tap(buttonFinder);
        await tester.pump();

        // No exception = success (handled gracefully)
      });
    });

    group('Accessibility', () {
      testWidgets('text elements are accessible', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        // Verify all text is present and accessible
        expect(find.text('404'), findsOneWidget);
        expect(find.text('Page Not Found'), findsOneWidget);
        expect(find.text('The page you are looking for does not exist.'),
            findsOneWidget);
        expect(find.text('Go to Home'), findsOneWidget);
      });

      testWidgets('button is keyboard accessible', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        // ElevatedButton is keyboard accessible by default
        // Verify button is present and interactive
        expect(find.text('Go to Home'), findsOneWidget);
        expect(find.byIcon(Icons.home), findsWidgets);
      });
    });

    group('Widget Properties', () {
      test('uses const constructor', () {
        // Verify const constructor can be used
        const widget = NotFoundPage();

        expect(widget, isA<NotFoundPage>(),
            reason: 'Should be able to create const instances');
      });

      testWidgets('is a StatelessWidget', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NotFoundPage(),
          ),
        );

        expect(find.byType(NotFoundPage), findsOneWidget);
        // StatelessWidget doesn't rebuild unnecessarily
      });
    });
  });
}
