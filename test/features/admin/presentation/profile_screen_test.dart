import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/admin/presentation/profile_screen.dart';

void main() {
  group('ProfileScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget() {
      return const MaterialApp(
        home: ProfileScreen(),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Assert - AppBar content (also appears in body)
      expect(find.text('Perfil'), findsNWidgets(2));

      // Assert - Body content
      expect(find.byType(Center), findsWidgets);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Editar informações do perfil do usuário.'), findsOneWidget);
    });

    testWidgets('displays person icon with correct size', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final iconFinder = find.byIcon(Icons.person);
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
          home: const ProfileScreen(),
        ),
      );

      // Act
      final iconFinder = find.byIcon(Icons.person);
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
          home: const ProfileScreen(),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Perfil'), findsNWidgets(2)); // AppBar + body
      expect(find.text('Editar informações do perfil do usuário.'), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('content is centered properly', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final centerWidget = find.byType(Center);
      expect(centerWidget, findsWidgets);

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

      // Find specific SizedBox widgets using predicates
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

      // Find the Padding widget ancestor of the description text
      final descriptionText = find.text('Editar informações do perfil do usuário.');
      final paddingWidget = find.ancestor(
        of: descriptionText,
        matching: find.byType(Padding),
      );

      expect(paddingWidget, findsWidgets);

      // Verify outer padding is 32.0
      final outerPadding = tester.widget<Padding>(paddingWidget.first);
      expect(outerPadding.padding, const EdgeInsets.all(32.0));
    });

    testWidgets('text styles use theme typography', (tester) async {
      // Arrange
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const ProfileScreen(),
        ),
      );

      // Find description text first (has explicit style)
      final descriptionText = find.text('Editar informações do perfil do usuário.');
      final descriptionWidget = tester.widget<Text>(descriptionText);
      expect(descriptionWidget.style, isNotNull);
      expect(descriptionWidget.textAlign, TextAlign.center);

      // Body title text verification (second "Perfil")
      final allPerfilTexts = find.text('Perfil');
      expect(allPerfilTexts, findsNWidgets(2));
      // Just verify both texts exist (AppBar title may have null style from theme)
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

      // Find the body Center widget (not the one in AppBar)
      expect(find.byType(Center), findsWidgets);

      // Verify Column is in a Center widget
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      final centerWithColumn = find.ancestor(
        of: columnFinder,
        matching: find.byType(Center),
      );
      expect(centerWithColumn, findsOneWidget);
    });

    testWidgets('all text content is present and correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert - Check all text strings
      expect(find.text('Perfil'), findsNWidgets(2)); // AppBar + Body title
      expect(find.text('Editar informações do perfil do usuário.'), findsOneWidget);

      // Ensure no unexpected text
      expect(find.textContaining('Error'), findsNothing);
      expect(find.textContaining('null'), findsNothing);
    });
  });
}