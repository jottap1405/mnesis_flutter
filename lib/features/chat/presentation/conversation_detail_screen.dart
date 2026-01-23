import 'package:flutter/material.dart';

/// Conversation detail screen showing messages in a specific conversation.
///
/// Displays the full chat history and allows the user to send new messages
/// to the AI assistant.
///
/// ## Features
/// - Message history with timestamps
/// - Text input for new messages
/// - Voice input support (future)
/// - File attachment support (future)
/// - Context-aware suggestions
class ConversationDetailScreen extends StatelessWidget {
  /// Creates a [ConversationDetailScreen].
  const ConversationDetailScreen({
    required this.conversationId,
    super.key,
  });

  /// The ID of the conversation to display.
  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversa $conversationId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show conversation options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Conversa: $conversationId',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Aqui você poderá conversar com o assistente '
                      'médico da Mnesis.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // TODO: Send message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
