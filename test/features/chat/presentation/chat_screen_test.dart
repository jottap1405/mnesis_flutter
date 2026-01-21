import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/chat/presentation/chat_screen.dart';

void main() {
  group('ChatScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget() {
      return const MaterialApp(
        home: ChatScreen(),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Assert - AppBar content
      expect(find.text('Chat'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Assert - Body content
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.text('Suas Conversas'), findsOneWidget);
      expect(
        find.text(
          'Converse com o assistente médico da Mnesis para gerenciar '
          'atendimentos, agendamentos e pacientes.',
        ),
        findsOneWidget,
      );

      // Assert - FAB content
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Nova Conversa'), findsOneWidget);
    });

    testWidgets('search button is interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);

      // Verify button can be tapped
      await tester.tap(searchButton);
      await tester.pump();

      // Assert - Button remains visible after tap
      expect(searchButton, findsOneWidget);
    });

    testWidgets('floating action button is interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      // Verify FAB can be tapped
      await tester.tap(fab);
      await tester.pump();

      // Assert - FAB remains visible after tap
      expect(fab, findsOneWidget);
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const ChatScreen(),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Suas Conversas'), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(ChatScreen), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(ChatScreen), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('center content is properly aligned', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert
      final centerWidget = find.byType(Center);
      expect(centerWidget, findsOneWidget);

      final columnWidget = find.descendant(
        of: centerWidget,
        matching: find.byType(Column),
      );
      expect(columnWidget, findsOneWidget);
    });

    testWidgets('padding is correctly applied to description text', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find the Padding widget containing the description text
      final paddingWidget = find.widgetWithText(Padding,
        'Converse com o assistente médico da Mnesis para gerenciar '
        'atendimentos, agendamentos e pacientes.');

      expect(paddingWidget, findsOneWidget);

      // Verify padding values
      final padding = tester.widget<Padding>(paddingWidget);
      expect(padding.padding, const EdgeInsets.symmetric(horizontal: 32.0));
    });

    testWidgets('icon has correct size and uses theme color', (tester) async {
      // Arrange
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const ChatScreen(),
        ),
      );

      // Find the chat bubble icon
      final iconFinder = find.byIcon(Icons.chat_bubble_outline);
      expect(iconFinder, findsOneWidget);

      // Verify icon properties
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, 64);
      expect(icon.color, theme.colorScheme.primary);
    });

    testWidgets('spacing between elements is correct', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find all SizedBox widgets
      final sizedBoxes = find.byType(SizedBox);

      // Should have 2 SizedBox widgets for spacing
      expect(sizedBoxes, findsNWidgets(2));

      // Verify spacing values
      final firstSpacer = tester.widget<SizedBox>(sizedBoxes.at(0));
      expect(firstSpacer.height, 24);

      final secondSpacer = tester.widget<SizedBox>(sizedBoxes.at(1));
      expect(secondSpacer.height, 8);
    });

    testWidgets('text styles use correct theme typography', (tester) async {
      // Arrange
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const ChatScreen(),
        ),
      );

      // Find text widgets
      final titleText = find.text('Suas Conversas');
      final titleWidget = tester.widget<Text>(titleText);

      // Verify text styles match theme
      expect(titleWidget.style, theme.textTheme.headlineMedium);

      // Find description text
      final descriptionText = find.text(
        'Converse com o assistente médico da Mnesis para gerenciar '
        'atendimentos, agendamentos e pacientes.',
      );
      final descriptionWidget = tester.widget<Text>(descriptionText);
      expect(descriptionWidget.style, theme.textTheme.bodyMedium);
      expect(descriptionWidget.textAlign, TextAlign.center);
    });
  });
}