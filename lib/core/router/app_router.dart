import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router_observer.dart';
import 'routes/chat_routes.dart';
import 'routes/new_routes.dart';
import 'routes/operation_routes.dart';
import 'routes/admin_routes.dart';
import '../../features/shell/presentation/shell_screen.dart';

/// Mnesis app router configuration using go_router.
///
/// ## Architecture
/// - **Chat-First Philosophy**: All features accessible via chat
/// - **Bottom Navigation**: 4 main tabs (Chat, New, Operation, Admin)
/// - **No Auth Guards**: Login handled via chat interface
/// - **Deep Linking**: Full support for sharing conversations and operations
///
/// ## Route Structure
/// ```
/// / (redirects to /chat)
/// /chat - Main chat interface
/// /chat/:conversationId - Specific conversation
/// /new - Quick actions screen
/// /new/appointment - New appointment flow
/// /new/patient - New patient registration
/// /new/schedule - New schedule entry
/// /operation - Operations overview
/// /operation/:operationId - Specific operation detail
/// /admin - Admin/profile screen
/// /admin/profile - Profile editing
/// /admin/settings - App settings
/// /admin/about - About screen
/// ```
///
/// ## Usage
/// ```dart
/// // Navigate to chat
/// context.go('/chat');
///
/// // Navigate to specific conversation
/// context.go('/chat/conversation-123');
///
/// // Navigate with parameters
/// context.go('/new/appointment');
/// ```
///
/// See also:
/// * [ChatRoutes] for chat-specific routes
/// * [NewRoutes] for quick action routes
/// * [OperationRoutes] for operation routes
/// * [AdminRoutes] for admin/settings routes
class AppRouter {
  AppRouter._(); // Private constructor

  /// Global router instance.
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    observers: [MnesisRouterObserver()],

    // Initial location (defaults to chat)
    initialLocation: ChatRoutes.root,

    // Error handler
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),

    // Route configuration
    routes: [
      // Root redirect to chat
      GoRoute(
        path: '/',
        redirect: (context, state) => ChatRoutes.root,
      ),

      // Shell route for bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return ShellScreen(child: child);
        },
        routes: [
          // Chat routes (main feature)
          ...ChatRoutes.routes,

          // New/Quick action routes
          ...NewRoutes.routes,

          // Operation routes
          ...OperationRoutes.routes,

          // Admin routes
          ...AdminRoutes.routes,
        ],
      ),
    ],
  );
}

/// Error screen shown when navigation fails.
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erro de Navegação'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Página não encontrada',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error?.toString() ?? 'Rota inválida',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/chat'),
                icon: const Icon(Icons.home),
                label: const Text('Voltar ao Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
