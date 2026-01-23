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

      // Assert - AppBar content & Body content
      expect(find.text('Operações'), findsNWidgets(2)); // AppBar and body
      expect(find.byType(Center), findsOneWidget);
      expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);
      expect(
        find.text(
          'Dashboard de operações médicas, tarefas pendentes '
          'e atividades recentes.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays medical_services_outlined icon with correct size', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final iconFinder = find.byIcon(Icons.medical_services_outlined);
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
      final iconFinder = find.byIcon(Icons.medical_services_outlined);
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
      expect(find.text('Operações'), findsNWidgets(2)); // AppBar and body
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

      // Assert - Use ancestor to find Center containing the Column
      final columnWidget = find.byType(Column);
      expect(columnWidget, findsOneWidget);

      final centerWidget = find.ancestor(
        of: columnWidget,
        matching: find.byType(Center),
      );
      expect(centerWidget, findsOneWidget);
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

      // Find SizedBox widgets with only height property (spacing between elements)
      final firstSpacer = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 24 && widget.width == null,
      );
      expect(firstSpacer, findsOneWidget);

      final secondSpacer = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 8 && widget.width == null,
      );
      expect(secondSpacer, findsOneWidget);
    });

    testWidgets('text has correct padding', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find the Padding widget wrapping the Column
      final paddingWidget = find.ancestor(
        of: find.byType(Column),
        matching: find.byType(Padding),
      );

      expect(paddingWidget, findsOneWidget);

      // Verify padding values
      final padding = tester.widget<Padding>(paddingWidget);
      expect(padding.padding, const EdgeInsets.all(32.0));
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

      // Find title text in body (appears after Icon)
      final titleText = find.descendant(
        of: find.byType(Column),
        matching: find.text('Operações'),
      );
      final titleWidget = tester.widget<Text>(titleText);
      expect(titleWidget.style, isNotNull);
      expect(titleWidget.style?.fontSize, greaterThanOrEqualTo(20.0));

      // Find description text
      final descriptionText = find.text(
        'Dashboard de operações médicas, tarefas pendentes '
        'e atividades recentes.',
      );
      final descriptionWidget = tester.widget<Text>(descriptionText);
      expect(descriptionWidget.style, isNotNull);
      expect(descriptionWidget.textAlign, TextAlign.center);
    });

    testWidgets('AppBar has correct title', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find AppBar
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      // Verify title text
      final titleText = find.descendant(
        of: appBar,
        matching: find.text('Operações'),
      );
      expect(titleText, findsOneWidget);
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
        find.ancestor(
        of: find.byType(Column),
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