import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/operation/presentation/operation_screen.dart';

void main() {
  group('OperationScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget() {
      return const MaterialApp(
        home: OperationScreen(),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Assert - AppBar content
      expect(find.text('Operação'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      // Assert - Body content
      expect(find.byType(Center), findsOneWidget);
      expect(find.byIcon(Icons.medical_information), findsOneWidget);
      expect(find.text('Seus Atendimentos'), findsOneWidget);
      expect(
        find.text(
          'Visualize e gerencie todos os atendimentos médicos realizados.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('filter button is interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final filterButton = find.byIcon(Icons.filter_list);
      expect(filterButton, findsOneWidget);

      // Verify button can be tapped
      await tester.tap(filterButton);
      await tester.pump();

      // Assert - Button remains visible after tap
      expect(filterButton, findsOneWidget);
    });

    testWidgets('displays medical_information icon with correct size', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final iconFinder = find.byIcon(Icons.medical_information);
      expect(iconFinder, findsOneWidget);

      // Assert
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, 64);
    });

    testWidgets('icon uses theme primary color', (tester) async {
      // Arrange
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const OperationScreen(),
        ),
      );

      // Act
      final iconFinder = find.byIcon(Icons.medical_information);
      final icon = tester.widget<Icon>(iconFinder);

      // Assert
      expect(icon.color, theme.colorScheme.primary);
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const OperationScreen(),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Operação'), findsOneWidget);
      expect(find.text('Seus Atendimentos'), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(OperationScreen), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(OperationScreen), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('content is centered properly', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final centerWidget = find.byType(Center);
      expect(centerWidget, findsOneWidget);

      // Assert - Column should be inside Center
      final columnWidget = find.descendant(
        of: centerWidget,
        matching: find.byType(Column),
      );
      expect(columnWidget, findsOneWidget);
    });

    testWidgets('column has correct main axis alignment', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final columnWidget = find.byType(Column);
      final column = tester.widget<Column>(columnWidget);

      // Assert
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('spacing between elements is correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find all SizedBox widgets for spacing
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsNWidgets(2));

      // Verify spacing values
      final firstSpacer = tester.widget<SizedBox>(sizedBoxes.at(0));
      expect(firstSpacer.height, 24);

      final secondSpacer = tester.widget<SizedBox>(sizedBoxes.at(1));
      expect(secondSpacer.height, 8);
    });

    testWidgets('text has correct padding', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find the Padding widget containing the description text
      final paddingWidget = find.widgetWithText(
        Padding,
        'Visualize e gerencie todos os atendimentos médicos realizados.',
      );

      expect(paddingWidget, findsOneWidget);

      // Verify padding values
      final padding = tester.widget<Padding>(paddingWidget);
      expect(padding.padding, const EdgeInsets.symmetric(horizontal: 32.0));
    });

    testWidgets('text styles use theme typography', (tester) async {
      // Arrange
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const OperationScreen(),
        ),
      );

      // Find title text
      final titleText = find.text('Seus Atendimentos');
      final titleWidget = tester.widget<Text>(titleText);
      expect(titleWidget.style, theme.textTheme.headlineMedium);

      // Find description text
      final descriptionText = find.text(
        'Visualize e gerencie todos os atendimentos médicos realizados.',
      );
      final descriptionWidget = tester.widget<Text>(descriptionText);
      expect(descriptionWidget.style, theme.textTheme.bodyMedium);
      expect(descriptionWidget.textAlign, TextAlign.center);
    });

    testWidgets('AppBar actions are properly configured', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find AppBar
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      // Find IconButton in AppBar actions
      final iconButton = find.descendant(
        of: appBar,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);

      // Verify it contains the filter icon
      final filterIcon = find.descendant(
        of: iconButton,
        matching: find.byIcon(Icons.filter_list),
      );
      expect(filterIcon, findsOneWidget);
    });

    testWidgets('widget tree structure is correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert widget hierarchy
      expect(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(AppBar),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
    });
  });
}