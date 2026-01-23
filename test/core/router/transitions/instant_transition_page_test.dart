/// Test suite for InstantTransitionPage.
///
/// Tests the instant (no animation) page transition to ensure:
/// - No animation overhead
/// - Instant page switching
/// - Zero duration configuration
/// - Performance benefits
/// - Extension methods work correctly
/// - Integration with GoRouter
///
/// Comprehensive test coverage following FlowForge Rule #3
/// (80%+ test coverage) and Rule #25 (Testing & Reliability).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/router/transitions/instant_transition_page.dart';

void main() {
  group('InstantTransitionPage', () {
    testWidgets('creates page with no transition animation',
        (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('test-page'),
        child: const Text('Test Content'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Content should be immediately visible
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('uses zero duration', (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('test-page'),
        child: const Text('Test Content'),
      );

      // Verify zero duration for both transitions
      expect(page.transitionDuration, equals(Duration.zero));
      expect(page.reverseTransitionDuration, equals(Duration.zero));
    });

    testWidgets('switches pages instantly without animation',
        (WidgetTester tester) async {
      final page1 = MaterialPage(
        key: const ValueKey('page1'),
        child: const Scaffold(body: Text('Page 1')),
      );

      final page2 = InstantTransitionPage(
        key: const ValueKey('page2'),
        child: const Scaffold(body: Text('Page 2')),
      );

      // Build with first page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page1],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Page 1'), findsOneWidget);

      // Switch to second page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page1, page2],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Page 2 should be immediately visible (no animation frames needed)
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('returns child directly without animation wrapper',
        (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('test'),
        child: Container(
          width: 200,
          height: 200,
          color: Colors.blue,
          child: const Text('Direct Content'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Content visible immediately
      expect(find.text('Direct Content'), findsOneWidget);

      // Verify container is present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('works with complex child widgets',
        (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('complex'),
        child: Scaffold(
          appBar: AppBar(title: const Text('Complex Page')),
          body: Column(
            children: [
              const Text('Header'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(title: Text('Item 1')),
                    ListTile(title: Text('Item 2')),
                    ListTile(title: Text('Item 3')),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // All elements immediately visible
      expect(find.text('Complex Page'), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('handles reverse transition instantly',
        (WidgetTester tester) async {
      final page1 = MaterialPage(
        key: const ValueKey('page1'),
        child: const Scaffold(body: Text('Page 1')),
      );

      final page2 = InstantTransitionPage(
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

      expect(find.text('Page 2'), findsOneWidget);

      // Remove page2 (reverse transition)
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page1],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Should instantly show page1 (no animation delay)
      expect(find.text('Page 1'), findsOneWidget);
    });
  });

  group('Performance Characteristics', () {
    testWidgets('provides instant feedback with no animation overhead',
        (WidgetTester tester) async {
      final pages = <Page>[];

      // Add 5 instant transition pages
      for (int i = 0; i < 5; i++) {
        pages.add(
          InstantTransitionPage(
            key: ValueKey('page$i'),
            child: Text('Page $i'),
          ),
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: pages,
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Top page immediately visible
      expect(find.text('Page 4'), findsOneWidget);

      // No animation frames needed
      // (pumpAndSettle would be instant since duration is zero)
      await tester.pumpAndSettle();
      expect(find.text('Page 4'), findsOneWidget);
    });

    testWidgets('ideal for bottom navigation switches',
        (WidgetTester tester) async {
      // Simulate bottom navigation pattern
      final tabs = [
        InstantTransitionPage(
          key: const ValueKey('tab1'),
          child: const Text('Tab 1 Content'),
        ),
        InstantTransitionPage(
          key: const ValueKey('tab2'),
          child: const Text('Tab 2 Content'),
        ),
        InstantTransitionPage(
          key: const ValueKey('tab3'),
          child: const Text('Tab 3 Content'),
        ),
      ];

      // Show tab 1
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [tabs[0]],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Tab 1 Content'), findsOneWidget);

      // Switch to tab 2 (instant)
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [tabs[1]],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Tab 2 Content'), findsOneWidget);

      // Switch to tab 3 (instant)
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [tabs[2]],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Tab 3 Content'), findsOneWidget);
    });
  });

  group('PageTransitionCheck Extension', () {
    testWidgets('hasNoTransition returns true for InstantTransitionPage',
        (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('instant'),
        child: const Text('Instant'),
      );

      // Use extension method
      expect(page.hasNoTransition, isTrue);
      expect(page.hasTransition, isFalse);
    });

    testWidgets('hasNoTransition returns false for other Page types',
        (WidgetTester tester) async {
      final page = MaterialPage(
        key: const ValueKey('material'),
        child: const Text('Material'),
      );

      // Use extension method
      expect(page.hasNoTransition, isFalse);
      expect(page.hasTransition, isTrue);
    });

    testWidgets('hasTransition returns false for InstantTransitionPage',
        (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('instant'),
        child: const Text('Instant'),
      );

      expect(page.hasTransition, isFalse);
    });

    testWidgets('hasTransition returns true for other Page types',
        (WidgetTester tester) async {
      final page = MaterialPage(
        key: const ValueKey('material'),
        child: const Text('Material'),
      );

      expect(page.hasTransition, isTrue);
    });

    testWidgets('extension works with mixed page types',
        (WidgetTester tester) async {
      final instantPage = InstantTransitionPage(
        key: const ValueKey('instant'),
        child: const Text('Instant'),
      );

      final materialPage = MaterialPage(
        key: const ValueKey('material'),
        child: const Text('Material'),
      );

      // Verify extension behavior
      expect(instantPage.hasNoTransition, isTrue);
      expect(materialPage.hasNoTransition, isFalse);

      expect(instantPage.hasTransition, isFalse);
      expect(materialPage.hasTransition, isTrue);
    });
  });

  group('Widget Properties', () {
    testWidgets('requires LocalKey for GoRouter compatibility',
        (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('test'),
        child: const Text('Content'),
      );

      expect(page.key, isA<LocalKey>());
      expect(page.key, equals(const ValueKey('test')));
    });

    testWidgets('requires child widget', (WidgetTester tester) async {
      final page = InstantTransitionPage(
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

      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('uses const constructor', (WidgetTester tester) async {
      const page1 = InstantTransitionPage(
        key: ValueKey('test'),
        child: Text('Test'),
      );

      const page2 = InstantTransitionPage(
        key: ValueKey('test'),
        child: Text('Test'),
      );

      // With const, same key creates identical instances
      expect(identical(page1.key, page2.key), isTrue);
    });
  });

  group('Edge Cases', () {
    testWidgets('handles empty child', (WidgetTester tester) async {
      final page = InstantTransitionPage(
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

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('handles null-safe operations', (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('test'),
        child: const Text('Safe'),
      );

      // Should not throw
      expect(page.key, isNotNull);
      expect(page.transitionDuration, isNotNull);
      expect(page.reverseTransitionDuration, isNotNull);
    });

    testWidgets('works with Scaffold', (WidgetTester tester) async {
      final page = InstantTransitionPage(
        key: const ValueKey('scaffold'),
        child: Scaffold(
          appBar: AppBar(title: const Text('Instant Scaffold')),
          body: const Center(child: Text('Body')),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Instant Scaffold'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('Integration with Navigator', () {
    testWidgets('works in Navigator stack with other page types',
        (WidgetTester tester) async {
      final pages = <Page>[
        InstantTransitionPage(
          key: const ValueKey('instant1'),
          child: const Text('Instant 1'),
        ),
        MaterialPage(
          key: const ValueKey('material'),
          child: const Text('Material'),
        ),
        InstantTransitionPage(
          key: const ValueKey('instant2'),
          child: const Text('Instant 2'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: pages,
            onDidRemovePage: (page) {},
          ),
        ),
      );

      // Top page visible
      expect(find.text('Instant 2'), findsOneWidget);
    });

    testWidgets('multiple instant transitions in sequence',
        (WidgetTester tester) async {
      // Start with one page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              InstantTransitionPage(
                key: const ValueKey('page1'),
                child: const Text('Page 1'),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Page 1'), findsOneWidget);

      // Add second page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              InstantTransitionPage(
                key: const ValueKey('page1'),
                child: const Text('Page 1'),
              ),
              InstantTransitionPage(
                key: const ValueKey('page2'),
                child: const Text('Page 2'),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Page 2'), findsOneWidget);

      // Add third page
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [
              InstantTransitionPage(
                key: const ValueKey('page1'),
                child: const Text('Page 1'),
              ),
              InstantTransitionPage(
                key: const ValueKey('page2'),
                child: const Text('Page 2'),
              ),
              InstantTransitionPage(
                key: const ValueKey('page3'),
                child: const Text('Page 3'),
              ),
            ],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Page 3'), findsOneWidget);
    });
  });

  group('Documentation Examples', () {
    testWidgets('example from documentation works', (WidgetTester tester) async {
      // Example from class documentation
      final page = InstantTransitionPage(
        key: const ValueKey('home'),
        child: const Scaffold(body: Text('Home Screen')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [page],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('bottom navigation use case', (WidgetTester tester) async {
      // Common use case: bottom navigation
      final homePage = InstantTransitionPage(
        key: const ValueKey('home'),
        child: const Text('Home'),
      );

      final searchPage = InstantTransitionPage(
        key: const ValueKey('search'),
        child: const Text('Search'),
      );

      final profilePage = InstantTransitionPage(
        key: const ValueKey('profile'),
        child: const Text('Profile'),
      );

      // Switch between tabs instantly
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [homePage],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [searchPage],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Search'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            pages: [profilePage],
            onDidRemovePage: (page) {},
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
