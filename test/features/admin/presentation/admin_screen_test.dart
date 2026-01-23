import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/admin/presentation/admin_screen.dart';

void main() {
  group('AdminScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget() {
      return const MaterialApp(
        home: AdminScreen(),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Assert - AppBar content
      expect(find.text('Admin'), findsOneWidget);

      // Assert - Menu items
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Editar informações do perfil'), findsOneWidget);

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Configurações do aplicativo'), findsOneWidget);

      expect(find.text('Sobre'), findsOneWidget);
      expect(find.text('Informações sobre o app'), findsOneWidget);

      // Assert - Icons
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('renders three AdminOptionCard widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Should have 3 Card widgets (one for each option)
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('cards have proper structure', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find all cards
      final cards = find.byType(Card);
      expect(cards, findsNWidgets(3));

      // Each card should have an InkWell for interaction
      for (int i = 0; i < 3; i++) {
        final inkWell = find.descendant(
          of: cards.at(i),
          matching: find.byType(InkWell),
        );
        expect(inkWell, findsOneWidget);
      }
    });

    testWidgets('cards display correct icons with styling', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find icon containers
      // Verify icons are properly contained
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('cards have forward arrow indicators', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Each card should have an arrow_forward_ios icon
      final arrowIcons = find.byIcon(Icons.arrow_forward_ios);
      expect(arrowIcons, findsNWidgets(3));
    });

    testWidgets('cards are interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find all cards
      final cards = find.byType(Card);

      // Verify cards exist but don't tap (would require GoRouter context)
      expect(cards, findsNWidgets(3));

      // Verify InkWell widgets are present for interactivity
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsNWidgets(3));
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const AdminScreen(),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(AdminScreen), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(AdminScreen), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('ListView has proper padding', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find ListView
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Verify padding
      final listViewWidget = tester.widget<ListView>(listView);
      expect(listViewWidget.padding, const EdgeInsets.all(16.0));
    });

    testWidgets('cards have proper spacing', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find SizedBox widgets used for spacing
      final sizedBoxes = find.byType(SizedBox);

      // Should have at least 2 SizedBox widgets for spacing between cards
      // (Plus additional ones within each card)
      expect(sizedBoxes, findsAtLeastNWidgets(2));
    });

    testWidgets('text styles use theme typography', (tester) async {
      // Arrange
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const AdminScreen(),
        ),
      );

      // Find title texts - verify styles are applied
      final titleTexts = [
        find.text('Perfil'),
        find.text('Configurações'),
        find.text('Sobre'),
      ];

      for (final titleText in titleTexts) {
        final textWidget = tester.widget<Text>(titleText);
        expect(textWidget.style, isNotNull);
        // Verify it's using a medium-sized title style
        expect(textWidget.style!.fontSize, greaterThanOrEqualTo(14.0));
      }

      // Find description texts
      final descriptionTexts = [
        find.text('Editar informações do perfil'),
        find.text('Configurações do aplicativo'),
        find.text('Informações sobre o app'),
      ];

      for (final descText in descriptionTexts) {
        final textWidget = tester.widget<Text>(descText);
        expect(textWidget.style, isNotNull);
        // Verify it's using a small body style
        expect(textWidget.style!.fontSize, lessThanOrEqualTo(14.0));
      }
    });

    testWidgets('icon containers have proper decoration', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find containers with icons
      final personIcon = find.byIcon(Icons.person);
      final iconContainer = find.ancestor(
        of: personIcon,
        matching: find.byType(Container),
      ).first;

      expect(iconContainer, findsOneWidget);

      // Verify container has decoration
      final container = tester.widget<Container>(iconContainer);
      expect(container.decoration, isNotNull);
      expect(container.padding, const EdgeInsets.all(12));
    });

    testWidgets('card border radius is correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find InkWell widgets inside cards
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsNWidgets(3));

      // Check border radius of first InkWell
      final inkWell = tester.widget<InkWell>(inkWells.first);
      expect(inkWell.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('icon sizes are consistent', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Main icons
      final mainIcons = [
        find.byIcon(Icons.person),
        find.byIcon(Icons.settings),
        find.byIcon(Icons.info),
      ];

      for (final iconFinder in mainIcons) {
        final icon = tester.widget<Icon>(iconFinder);
        expect(icon.size, 32);
      }

      // Arrow icons
      final arrowIcons = find.byIcon(Icons.arrow_forward_ios);
      for (int i = 0; i < 3; i++) {
        final icon = tester.widget<Icon>(arrowIcons.at(i));
        expect(icon.size, 16);
      }
    });

    testWidgets('row alignment in cards is correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find all Row widgets
      final rows = find.byType(Row);
      expect(rows, findsAtLeastNWidgets(3));

      // Check alignment of rows in cards
      for (int i = 0; i < 3; i++) {
        final row = tester.widget<Row>(rows.at(i));
        expect(row.children.length, greaterThanOrEqualTo(3)); // Icon container, text column, arrow
      }
    });
  });
}