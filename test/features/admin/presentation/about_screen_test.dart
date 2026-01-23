import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/admin/presentation/about_screen.dart';

void main() {
  group('AboutScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget() {
      return const MaterialApp(
        home: AboutScreen(),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Assert - AppBar content
      expect(find.text('Sobre'), findsOneWidget);

      // Assert - Body content (Center is in body)
      expect(find.byType(Center), findsWidgets);
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text('Sobre o Mnesis'), findsOneWidget);
      expect(find.text('Informações sobre o aplicativo, versão, créditos e licenças.'), findsOneWidget);
    });

    testWidgets('displays info icon with correct size', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final iconFinder = find.byIcon(Icons.info);
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
          home: const AboutScreen(),
        ),
      );

      // Act
      final iconFinder = find.byIcon(Icons.info);
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
          home: const AboutScreen(),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Sobre'), findsOneWidget);
      expect(find.text('Sobre o Mnesis'), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(AboutScreen), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(AboutScreen), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('content is centered properly', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert - Column should be inside a Center
      final columnWidget = find.byType(Column);
      expect(columnWidget, findsOneWidget);

      // Verify Column has Center as ancestor
      expect(find.ancestor(
        of: columnWidget,
        matching: find.byType(Center),
      ), findsOneWidget);
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

      // Find specific SizedBox widgets by their height values
      final sizedBox24 = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 24,
      );
      expect(sizedBox24, findsOneWidget);

      final sizedBox8 = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 8,
      );
      expect(sizedBox8, findsOneWidget);
    });

    testWidgets('text has correct padding', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find the main Padding widget around the Column
      final centerFinder = find.descendant(
        of: find.byType(Scaffold),
        matching: find.byType(Center),
      );
      final paddingWidget = find.descendant(
        of: centerFinder,
        matching: find.byType(Padding),
      );

      expect(paddingWidget, findsOneWidget);

      // Verify padding values
      final padding = tester.widget<Padding>(paddingWidget);
      expect(padding.padding, const EdgeInsets.all(32.0));
    });

    testWidgets('text styles use theme typography', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find title text
      final titleText = find.text('Sobre o Mnesis');
      final titleWidget = tester.widget<Text>(titleText);
      // Verify style is applied (not null)
      expect(titleWidget.style, isNotNull);
      expect(titleWidget.style?.fontSize, isNotNull);

      // Find description text
      final descriptionText = find.text('Informações sobre o aplicativo, versão, créditos e licenças.');
      final descriptionWidget = tester.widget<Text>(descriptionText);
      expect(descriptionWidget.style, isNotNull);
      expect(descriptionWidget.textAlign, TextAlign.center);
    });

    testWidgets('widget tree structure is correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert widget hierarchy
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);

      // Verify Column is inside a Center
      expect(find.ancestor(
        of: find.byType(Column),
        matching: find.byType(Center),
      ), findsOneWidget);
    });

    testWidgets('all text content is present and correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert - Check all text strings
      expect(find.text('Sobre'), findsOneWidget); // AppBar
      expect(find.text('Sobre o Mnesis'), findsOneWidget); // Body title
      expect(find.text('Informações sobre o aplicativo, versão, créditos e licenças.'), findsOneWidget);

      // Ensure no unexpected text
      expect(find.textContaining('Error'), findsNothing);
      expect(find.textContaining('null'), findsNothing);
    });

    testWidgets('description text is properly aligned', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find description text widget
      final descriptionText = find.text('Informações sobre o aplicativo, versão, créditos e licenças.');
      final textWidget = tester.widget<Text>(descriptionText);

      // Assert text is center aligned
      expect(textWidget.textAlign, TextAlign.center);
    });
  });
}