import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/operation/presentation/operation_detail_screen.dart';

void main() {
  group('OperationDetailScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget({String operationId = 'test-id'}) {
      return MaterialApp(
        home: OperationDetailScreen(operationId: operationId),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Assert - AppBar content
      expect(find.text('Atendimento test-id'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Assert - Body content
      expect(find.byType(Center), findsOneWidget);
      expect(find.byIcon(Icons.medical_information), findsOneWidget);
      expect(find.text('Atendimento: test-id'), findsOneWidget);
      expect(find.text('Detalhes do atendimento médico aparecerão aqui.'), findsOneWidget);
    });

    testWidgets('accepts different operation IDs', (tester) async {
      // Test with different IDs
      const testIds = ['op-1', 'op-2', 'op-abc'];

      for (final id in testIds) {
        await tester.pumpWidget(createTestWidget(operationId: id));

        // Verify screen renders with each ID
        expect(find.byType(OperationDetailScreen), findsOneWidget);
        expect(find.text('Atendimento $id'), findsOneWidget);
        expect(find.text('Atendimento: $id'), findsOneWidget);
      }
    });

    testWidgets('edit button is interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);

      // Verify button can be tapped
      await tester.tap(editButton);
      await tester.pump();

      // Assert - Button remains visible after tap
      expect(editButton, findsOneWidget);
    });

    testWidgets('more options button is interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final moreButton = find.byIcon(Icons.more_vert);
      expect(moreButton, findsOneWidget);

      // Verify button can be tapped
      await tester.tap(moreButton);
      await tester.pump();

      // Assert - Button remains visible after tap
      expect(moreButton, findsOneWidget);
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
          home: const OperationDetailScreen(operationId: 'test'),
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
          home: const OperationDetailScreen(operationId: 'test'),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Atendimento test'), findsOneWidget);
      expect(find.text('Atendimento: test'), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(OperationDetailScreen), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(OperationDetailScreen), findsOneWidget);

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
        'Detalhes do atendimento médico aparecerão aqui.',
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
          home: const OperationDetailScreen(operationId: 'test'),
        ),
      );

      // Find title text
      final titleText = find.text('Atendimento: test');
      final titleWidget = tester.widget<Text>(titleText);
      expect(titleWidget.style, theme.textTheme.headlineSmall);

      // Find description text
      final descriptionText = find.text('Detalhes do atendimento médico aparecerão aqui.');
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

      // Find IconButtons in AppBar actions
      final iconButtons = find.descendant(
        of: appBar,
        matching: find.byType(IconButton),
      );
      expect(iconButtons, findsNWidgets(2)); // Edit and More buttons

      // Verify edit button
      final editButton = find.widgetWithIcon(IconButton, Icons.edit);
      expect(editButton, findsOneWidget);

      // Verify more button
      final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
      expect(moreButton, findsOneWidget);
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

    testWidgets('operationId is properly displayed in multiple places', (tester) async {
      // Arrange
      const testId = 'unique-123';
      await tester.pumpWidget(createTestWidget(operationId: testId));

      // Assert - ID appears in AppBar and body
      expect(find.text('Atendimento $testId'), findsOneWidget); // AppBar
      expect(find.text('Atendimento: $testId'), findsOneWidget); // Body
    });
  });
}