import 'package:flutter/material.dart';

/// Main chat screen showing conversation list.
///
/// This is the **primary interface** of Mnesis - an AI-powered medical
/// assistant where all features can be accessed via natural language.
///
/// ## Features
/// - List of conversations
/// - Quick access to start new conversation
/// - Search through conversations
/// - Conversation previews with last message
///
/// ## Philosophy
/// Chat-first: This screen is the main entry point for all app functionality.
/// Users can create appointments, register patients, view schedules, and
/// perform all other actions directly through chat conversations.
class ChatScreen extends StatelessWidget {
  /// Creates a [ChatScreen].
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Suas Conversas',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Converse com o assistente médico da Mnesis para gerenciar '
                'atendimentos, agendamentos e pacientes.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Start new conversation
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Conversa'),
      ),
    );
  }
}
