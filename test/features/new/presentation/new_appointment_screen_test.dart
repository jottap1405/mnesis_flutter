import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/new/presentation/new_appointment_screen.dart';

void main() {
  group('NewAppointmentScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget() {
      return const MaterialApp(
        home: NewAppointmentScreen(),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Assert - AppBar content (appears twice: AppBar + Body)
      expect(find.text('Novo Atendimento'), findsNWidgets(2));

      // Assert - Body content
      expect(find.byType(Center), findsWidgets);
      expect(find.byIcon(Icons.event), findsOneWidget);
      expect(find.text('Novo Atendimento'), findsNWidgets(2)); // AppBar + Body
      expect(find.text('Formulário para criar um novo atendimento médico.'), findsOneWidget);
    });

    testWidgets('displays event icon with correct size', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final iconFinder = find.byIcon(Icons.event);
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
          home: const NewAppointmentScreen(),
        ),
      );

      // Act
      final iconFinder = find.byIcon(Icons.event);
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
          home: const NewAppointmentScreen(),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Novo Atendimento'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.event), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(NewAppointmentScreen), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(NewAppointmentScreen), findsOneWidget);

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

      // Find the Padding widget with specific padding value
      final paddingWidget = find.byWidgetPredicate(
        (widget) => widget is Padding && widget.padding == const EdgeInsets.all(32.0),
      );

      expect(paddingWidget, findsOneWidget);
    });

    testWidgets('text styles use theme typography', (tester) async {
      // Arrange
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const NewAppointmentScreen(),
        ),
      );

      // Find title text (excluding AppBar)
      final centerColumn = find.byType(Column);
      final titleText = find.descendant(
        of: centerColumn,
        matching: find.text('Novo Atendimento'),
      );

      final titleWidget = tester.widget<Text>(titleText);
      expect(titleWidget.style, isNotNull);
      expect(titleWidget.style?.fontSize, greaterThanOrEqualTo(20.0));

      // Find description text
      final descriptionText = find.text('Formulário para criar um novo atendimento médico.');
      final descriptionWidget = tester.widget<Text>(descriptionText);
      expect(descriptionWidget.style, isNotNull);
      expect(descriptionWidget.textAlign, TextAlign.center);
    });
  });
}