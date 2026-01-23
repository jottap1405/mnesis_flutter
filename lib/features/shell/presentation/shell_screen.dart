import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes/chat_routes.dart';
import '../../../core/router/routes/new_routes.dart';
import '../../../core/router/routes/operation_routes.dart';
import '../../../core/router/routes/admin_routes.dart';

/// Shell screen with bottom navigation for the main app tabs.
///
/// This screen wraps all main routes and provides persistent bottom
/// navigation across the 4 main features: Chat, New, Operation, and Admin.
///
/// ## Philosophy
/// - **Chat-First**: Chat tab is the primary interface
/// - **Quick Actions**: New tab provides shortcuts to common workflows
/// - **Operations**: Operations tab shows current activities
/// - **Admin**: Admin tab for profile and settings
///
/// ## Navigation Structure
/// ```
/// Chat     New      Operation    Admin
///  │        │           │          │
///  ├─ /chat          /operation  /admin
///  └─ /chat/:id      /operation/:id
/// ```
class ShellScreen extends StatelessWidget {
  /// Creates a [ShellScreen].
  const ShellScreen({
    required this.child,
    super.key,
  });

  /// The child widget to display in the main content area.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Novo',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Operação',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  /// Calculates the selected index based on the current route.
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith(ChatRoutes.root)) {
      return 0;
    }
    if (location.startsWith(NewRoutes.root)) {
      return 1;
    }
    if (location.startsWith(OperationRoutes.root)) {
      return 2;
    }
    if (location.startsWith(AdminRoutes.root)) {
      return 3;
    }

    // Default to chat
    return 0;
  }

  /// Handles navigation when a bottom navigation item is tapped.
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(ChatRoutes.root);
        break;
      case 1:
        context.go(NewRoutes.root);
        break;
      case 2:
        context.go(OperationRoutes.root);
        break;
      case 3:
        context.go(AdminRoutes.root);
        break;
    }
  }
}
