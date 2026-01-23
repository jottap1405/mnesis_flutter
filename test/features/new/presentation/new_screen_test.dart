import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/new/presentation/new_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

// Mock GoRouter for navigation testing
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('NewScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget() {
      return const MaterialApp(
        home: NewScreen(),
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
      expect(find.text('Novo'), findsOneWidget);

      // Assert - Menu items
      expect(find.text('Novo Atendimento'), findsOneWidget);
      expect(find.text('Iniciar um novo atendimento médico'), findsOneWidget);

      expect(find.text('Novo Paciente'), findsOneWidget);
      expect(find.text('Cadastrar um novo paciente'), findsOneWidget);

      expect(find.text('Novo Agendamento'), findsOneWidget);
      expect(find.text('Criar uma nova entrada na agenda'), findsOneWidget);

      // Assert - Icons
      expect(find.byIcon(Icons.event), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('renders three NewOptionCard widgets', (tester) async {
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
      expect(find.byIcon(Icons.event), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('cards have forward arrow indicators', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Each card should have an arrow_forward_ios icon
      final arrowIcons = find.byIcon(Icons.arrow_forward_ios);
      expect(arrowIcons, findsNWidgets(3));
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const NewScreen(),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Novo'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(NewScreen), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(NewScreen), findsOneWidget);
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
          home: const NewScreen(),
        ),
      );

      // Find title texts
      final titleTexts = [
        find.text('Novo Atendimento'),
        find.text('Novo Paciente'),
        find.text('Novo Agendamento'),
      ];

      for (final titleText in titleTexts) {
        final textWidget = tester.widget<Text>(titleText);
        expect(textWidget.style, isNotNull);
        expect(textWidget.style?.fontSize, greaterThanOrEqualTo(14.0));
      }

      // Find description texts
      final descriptionTexts = [
        find.text('Iniciar um novo atendimento médico'),
        find.text('Cadastrar um novo paciente'),
        find.text('Criar uma nova entrada na agenda'),
      ];

      for (final descText in descriptionTexts) {
        final textWidget = tester.widget<Text>(descText);
        expect(textWidget.style, isNotNull);
      }
    });

    testWidgets('cards are interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find InkWell widgets inside cards (they handle the tap)
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsNWidgets(3));

      // Verify that InkWells exist and are interactive
      // Note: We don't actually tap because GoRouter navigation would fail without proper setup
      for (int i = 0; i < 3; i++) {
        expect(inkWells.at(i), findsOneWidget);
      }
    });

    testWidgets('icon containers have proper decoration', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find containers with specific padding (icon containers)
      final iconContainers = find.byWidgetPredicate(
        (widget) => widget is Container && widget.padding == const EdgeInsets.all(12),
      );

      // Should have 3 icon containers (one for each card)
      expect(iconContainers, findsNWidgets(3));

      // Verify first container has decoration
      final container = tester.widget<Container>(iconContainers.first);
      expect(container.decoration, isNotNull);
      expect(container.padding, const EdgeInsets.all(12));
    });
  });
}