/// Test suite for FadeTransitionPage.
///
/// Tests the fade transition animation to ensure:
/// - Fade animation works correctly
/// - Animation timing matches configuration
/// - Different constructors work as expected
/// - Curve animation is applied properly
/// - Integration with GoRouter
///
/// Comprehensive test coverage following FlowForge Rule #3
/// (80%+ test coverage) and Rule #25 (Testing & Reliability).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/router/transitions/fade_transition_page.dart';
import 'package:mnesis_flutter/core/router/transitions/transition_config.dart';

void main() {
  group('FadeTransitionPage', () {
    testWidgets('creates page with standard fade transition',
        (WidgetTester tester) async {
      // Arrange
      final page = FadeTransitionPage(
        key: const ValueKey('test-page'),
        child: const Text('Test Content'),
      );

      // Build widget tree with Navigator to test transitions
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Assert - content should be visible
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('uses standard duration by default',
        (WidgetTester tester) async {
      // Arrange
      final page = FadeTransitionPage(
        key: const ValueKey('test-page'),
        child: const Text('Test Content'),
      );

      // Assert - verify duration configuration
      expect(page.transitionDuration, equals(TransitionConfig.standardDuration));
      expect(page.reverseTransitionDuration,
          equals(TransitionConfig.standardDuration));
    });

    testWidgets('accepts custom duration', (WidgetTester tester) async {
      // Arrange
      const customDuration = Duration(milliseconds: 500);
      final page = FadeTransitionPage(
        key: const ValueKey('test-page'),
        child: const Text('Test Content'),
        duration: customDuration,
      );

      // Assert
      expect(page.transitionDuration, equals(customDuration));
      expect(page.reverseTransitionDuration, equals(customDuration));
    });

    testWidgets('creates page with fast fade transition',
        (WidgetTester tester) async {
      // Arrange
      final page = FadeTransitionPage.fast(
        key: const ValueKey('test-page'),
        child: const Text('Test Content'),
      );

      // Build widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Assert - content should be visible
      expect(find.text('Test Content'), findsOneWidget);

      // Verify fast duration
      expect(page.transitionDuration, equals(TransitionConfig.fastDuration));
      expect(page.reverseTransitionDuration, equals(TransitionConfig.fastDuration));
    });

    testWidgets('applies fade animation correctly', (WidgetTester tester) async {
      // Arrange
      final page = FadeTransitionPage(
        key: const ValueKey('test-page'),
        child: Container(
          width: 200,
          height: 200,
          color: Colors.blue,
          child: const Text('Animated Content'),
        ),
      );

      // Build initial widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              MaterialPage(
                key: const ValueKey('home'),
                child: const Scaffold(body: Text('Home')),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Add fade transition page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              MaterialPage(
                key: const ValueKey('home'),
                child: const Scaffold(body: Text('Home')),
              ),
              page,
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Pump a few frames to see animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Content should be visible during animation
      expect(find.text('Animated Content'), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();

      // Content fully visible after animation
      expect(find.text('Animated Content'), findsOneWidget);
    });

    testWidgets('uses curved animation', (WidgetTester tester) async {
      // The fade transition uses CurvedAnimation with standardCurve
      // This test verifies the animation widget structure

      final page = FadeTransitionPage(
        key: const ValueKey('test-page'),
        child: const Text('Curved Animation'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Verify FadeTransition is present
      expect(find.byType(FadeTransition), findsOneWidget);

      // Content should be visible
      expect(find.text('Curved Animation'), findsOneWidget);
    });

    testWidgets('handles reverse transition correctly',
        (WidgetTester tester) async {
      // Arrange
      final page1 = MaterialPage(
        key: const ValueKey('page1'),
        child: const Scaffold(body: Text('Page 1')),
      );

      final page2 = FadeTransitionPage(
        key: const ValueKey('page2'),
        child: const Scaffold(body: Text('Page 2')),
      );

      // Build with both pages
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page1, page2],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);

      // Remove page2 (trigger reverse transition)
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page1],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Pump animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Complete reverse animation
      await tester.pumpAndSettle();

      // Should be back to page 1
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('works with complex child widgets',
        (WidgetTester tester) async {
      // Arrange - complex widget tree
      final page = FadeTransitionPage(
        key: const ValueKey('test-page'),
        child: Scaffold(
          appBar: AppBar(title: const Text('Complex Page')),
          body: Column(
            children: [
              const Text('Header'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
              ListView(
                shrinkWrap: true,
                children: const [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                ],
              ),
            ],
          ),
        ),
      );

      // Build
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - all elements visible
      expect(find.text('Complex Page'), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });

  group('FadeTransitionPage.fast', () {
    testWidgets('uses fast duration', (WidgetTester tester) async {
      final page = FadeTransitionPage.fast(
        key: const ValueKey('fast-page'),
        child: const Text('Fast Fade'),
      );

      // Verify fast duration (200ms)
      expect(page.transitionDuration, equals(TransitionConfig.fastDuration));
      expect(page.transitionDuration.inMilliseconds, equals(200));
    });

    testWidgets('animates faster than standard transition',
        (WidgetTester tester) async {
      final fastPage = FadeTransitionPage.fast(
        key: const ValueKey('fast'),
        child: const Text('Fast'),
      );

      final standardPage = FadeTransitionPage(
        key: const ValueKey('standard'),
        child: const Text('Standard'),
      );

      // Verify duration difference
      expect(
        fastPage.transitionDuration < standardPage.transitionDuration,
        isTrue,
        reason: 'Fast transition should be quicker than standard',
      );
    });
  });

  group('Animation Configuration', () {
    test('uses correct curve configuration', () {
      // Verify the standard curve is easeInOut
      expect(
        TransitionConfig.standardCurve,
        equals(Curves.easeInOut),
        reason: 'Fade transitions should use easeInOut for natural motion',
      );
    });

    test('standard duration matches Material Design guidelines', () {
      // Material Design recommends 200-300ms for transitions
      expect(
        TransitionConfig.standardDuration.inMilliseconds,
        inInclusiveRange(200, 300),
        reason: 'Standard duration should follow Material Design guidelines',
      );
    });

    test('fast duration is shorter than standard', () {
      expect(
        TransitionConfig.fastDuration < TransitionConfig.standardDuration,
        isTrue,
        reason: 'Fast duration should be shorter than standard',
      );
    });
  });

  group('Widget Properties', () {
    testWidgets('requires LocalKey for GoRouter compatibility',
        (WidgetTester tester) async {
      // Arrange - using ValueKey (which is a LocalKey)
      final page = FadeTransitionPage(
        key: const ValueKey('test'),
        child: const Text('Content'),
      );

      // Assert - key is properly set
      expect(page.key, isA<LocalKey>());
      expect(page.key, equals(const ValueKey('test')));
    });

    testWidgets('requires child widget', (WidgetTester tester) async {
      final page = FadeTransitionPage(
        key: const ValueKey('test'),
        child: const Placeholder(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Child should be present
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('uses const constructor for fast variant',
        (WidgetTester tester) async {
      // Verify const constructor works
      const page1 = FadeTransitionPage.fast(
        key: ValueKey('test1'),
        child: Text('Test'),
      );

      const page2 = FadeTransitionPage.fast(
        key: ValueKey('test1'),
        child: Text('Test'),
      );

      // Same key and child should create identical instances with const
      expect(identical(page1.key, page2.key), isTrue);
    });
  });

  group('Edge Cases', () {
    testWidgets('handles zero-duration gracefully', (WidgetTester tester) async {
      final page = FadeTransitionPage(
        key: const ValueKey('test'),
        child: const Text('Instant'),
        duration: Duration.zero,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Should work without animation
      expect(find.text('Instant'), findsOneWidget);
    });

    testWidgets('handles very long duration', (WidgetTester tester) async {
      final page = FadeTransitionPage(
        key: const ValueKey('test'),
        child: const Text('Slow'),
        duration: const Duration(seconds: 5),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Content should be visible immediately
      expect(find.text('Slow'), findsOneWidget);
    });

    testWidgets('handles empty child', (WidgetTester tester) async {
      final page = FadeTransitionPage(
        key: const ValueKey('test'),
        child: const SizedBox.shrink(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Should not crash with empty child
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('Integration with Navigator', () {
    testWidgets('works in Navigator stack', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              FadeTransitionPage(
                key: const ValueKey('page1'),
                child: const Text('Page 1'),
              ),
              FadeTransitionPage(
                key: const ValueKey('page2'),
                child: const Text('Page 2'),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Top page should be visible
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('multiple transitions in sequence',
        (WidgetTester tester) async {
      // Start with one page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              FadeTransitionPage(
                key: const ValueKey('page1'),
                child: const Text('Page 1'),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);

      // Add second page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              FadeTransitionPage(
                key: const ValueKey('page1'),
                child: const Text('Page 1'),
              ),
              FadeTransitionPage(
                key: const ValueKey('page2'),
                child: const Text('Page 2'),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);

      // Add third page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              FadeTransitionPage(
                key: const ValueKey('page1'),
                child: const Text('Page 1'),
              ),
              FadeTransitionPage(
                key: const ValueKey('page2'),
                child: const Text('Page 2'),
              ),
              FadeTransitionPage.fast(
                key: const ValueKey('page3'),
                child: const Text('Page 3'),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Page 3'), findsOneWidget);
    });
  });
}
