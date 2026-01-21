import 'package:go_router/go_router.dart';
import '../../../features/chat/presentation/chat_screen.dart';
import '../../../features/chat/presentation/conversation_detail_screen.dart';

/// Chat feature route definitions.
///
/// The chat feature is the **core** of Mnesis - an AI-powered medical assistant
/// that handles all interactions via natural language.
///
/// ## Routes
/// - `/chat` - Main chat screen (conversation list)
/// - `/chat/:conversationId` - Specific conversation detail
///
/// ## Philosophy
/// Chat is the primary interface. All features (appointments, patient
/// registration, diagnoses) can be initiated and completed via chat.
///
/// Example:
/// ```dart
/// // Navigate to chat
/// context.go(ChatRoutes.root);
///
/// // Navigate to specific conversation
/// context.go(ChatRoutes.conversation('conv-123'));
/// ```
class ChatRoutes {
  ChatRoutes._(); // Private constructor

  /// Root path for chat feature.
  static const String root = '/chat';

  /// Path for conversation detail.
  static const String conversationPath = '/chat/:conversationId';

  /// Helper to build conversation route.
  static String conversation(String conversationId) =>
      '/chat/$conversationId';

  /// Route definitions.
  static final List<RouteBase> routes = [
    GoRoute(
      path: root,
      name: 'chat',
      builder: (context, state) => const ChatScreen(),
      routes: [
        // Nested route: conversation detail
        GoRoute(
          path: ':conversationId',
          name: 'conversation-detail',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            return ConversationDetailScreen(conversationId: conversationId);
          },
        ),
      ],
    ),
  ];
}
