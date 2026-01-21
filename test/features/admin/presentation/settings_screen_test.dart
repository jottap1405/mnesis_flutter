import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/admin/presentation/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget() {
      return const MaterialApp(
        home: SettingsScreen(),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Assert - AppBar content
      expect(find.text('Configurações'), findsOneWidget);

      // Assert - Body content
      expect(find.byType(Center), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Configurações'), findsNWidgets(2)); // AppBar + Body
      expect(find.text('Configure as preferências do aplicativo.'), findsOneWidget);
    });

    testWidgets('displays settings icon with correct size', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final iconFinder = find.byIcon(Icons.settings);
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
          home: const SettingsScreen(),
        ),
      );

      // Act
      final iconFinder = find.byIcon(Icons.settings);
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
          home: const SettingsScreen(),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Configurações'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(SettingsScreen), findsOneWidget);

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
        'Configure as preferências do aplicativo.',
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
          home: const SettingsScreen(),
        ),
      );

      // Find title text (excluding AppBar)
      final centerColumn = find.byType(Column);
      final titleText = find.descendant(
        of: centerColumn,
        matching: find.text('Configurações'),
      );

      final titleWidget = tester.widget<Text>(titleText);
      expect(titleWidget.style, theme.textTheme.headlineMedium);

      // Find description text
      final descriptionText = find.text('Configure as preferências do aplicativo.');
      final descriptionWidget = tester.widget<Text>(descriptionText);
      expect(descriptionWidget.style, theme.textTheme.bodyMedium);
      expect(descriptionWidget.textAlign, TextAlign.center);
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

    testWidgets('all text content is present and correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert - Check all text strings
      expect(find.text('Configurações'), findsNWidgets(2)); // AppBar + Body title
      expect(find.text('Configure as preferências do aplicativo.'), findsOneWidget);

      // Ensure no unexpected text
      expect(find.textContaining('Error'), findsNothing);
      expect(find.textContaining('null'), findsNothing);
    });
  });
}