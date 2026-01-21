import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/features/chat/presentation/conversation_detail_screen.dart';

void main() {
  group('ConversationDetailScreen', () {
    /// Test helper to wrap widget with MaterialApp for testing
    Widget createTestWidget({String conversationId = 'test-id'}) {
      return MaterialApp(
        home: ConversationDetailScreen(conversationId: conversationId),
      );
    }

    testWidgets('renders correctly with all required widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Assert - AppBar content
      expect(find.text('Conversa test-id'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Assert - Body content
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('accepts different conversation IDs', (tester) async {
      // Test with different IDs
      const testIds = ['conv-1', 'conv-2', 'conv-abc'];

      for (final id in testIds) {
        await tester.pumpWidget(createTestWidget(conversationId: id));

        // Verify screen renders with each ID
        expect(find.byType(ConversationDetailScreen), findsOneWidget);
        expect(find.text('Conversa $id'), findsOneWidget);
      }
    });

    testWidgets('message input field is functional', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Find and interact with TextField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Test message');
      await tester.pump();

      // Assert - Text was entered
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('send button is interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Find send button
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);

      // Verify button can be tapped
      await tester.tap(sendButton);
      await tester.pump();

      // Assert - Button remains visible after tap
      expect(sendButton, findsOneWidget);
    });

    testWidgets('more options button is interactive', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Find more options button
      final moreButton = find.byIcon(Icons.more_vert);
      expect(moreButton, findsOneWidget);

      // Verify button can be tapped
      await tester.tap(moreButton);
      await tester.pump();

      // Assert - Button remains visible after tap
      expect(moreButton, findsOneWidget);
    });

    testWidgets('input container has proper styling', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find the input container
      final containerFinder = find.ancestor(
        of: find.byType(TextField),
        matching: find.byType(Container),
      ).first;

      expect(containerFinder, findsOneWidget);

      // Verify container has decoration
      final container = tester.widget<Container>(containerFinder);
      expect(container.decoration, isNotNull);
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const ConversationDetailScreen(conversationId: 'test'),
        ),
      );

      // Assert - All widgets should still be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Conversa test'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('layout responds to different screen sizes', (tester) async {
      // Test on smaller screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(ConversationDetailScreen), findsOneWidget);

      // Test on larger screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(ConversationDetailScreen), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('message list area is expandable', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find the Expanded widget in the message area
      final expandedWidget = find.byType(Expanded);
      expect(expandedWidget, findsAtLeastNWidgets(1));
    });

    testWidgets('input field has proper hint text', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find TextField and check for hint
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.decoration?.hintText, 'Digite sua mensagem...');
    });

    testWidgets('send button is properly styled', (tester) async {
      // Arrange
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const ConversationDetailScreen(conversationId: 'test'),
        ),
      );

      // Find IconButton.filled containing send icon
      final sendButton = find.byType(IconButton);
      expect(sendButton, findsNWidgets(2)); // AppBar more button + Send button

      // Find the send button specifically
      final sendIconButton = find.widgetWithIcon(IconButton, Icons.send);
      expect(sendIconButton, findsOneWidget);
    });

    testWidgets('center placeholder is displayed', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert - Center widget with placeholder content
      final centerWidget = find.byType(Center);
      expect(centerWidget, findsAtLeastNWidgets(1));

      // Check for placeholder text with conversation ID
      expect(find.text('Conversa: test-id'), findsOneWidget);
      expect(find.text('Aqui você poderá conversar com o assistente médico da Mnesis.'), findsOneWidget);

      // Check for chat icon
      expect(find.byIcon(Icons.chat), findsOneWidget);
    });
  });
}