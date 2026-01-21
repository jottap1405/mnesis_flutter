import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/route_paths.dart';

/// The main application shell widget that provides the bottom navigation bar
/// and manages navigation between the four main sections of the app.
///
/// This widget wraps around the current route's content and displays a
/// persistent Material 3 NavigationBar at the bottom. It handles navigation
/// state management and integrates with GoRouter for declarative routing.
///
/// The shell maintains four main navigation destinations:
/// - Chat: The main AI assistant interface
/// - Quick Actions: Quick access to common medical tasks
/// - Operations: Medical operations and procedures
/// - Admin: Administrative settings and configurations
///
/// Example usage within GoRouter:
/// ```dart
/// ShellRoute(
///   builder: (context, state, child) {
///     return AppShell(child: child);
///   },
///   routes: [
///     // Child routes here
///   ],
/// )
/// ```
///
/// See also:
/// * [NavigationBar] - Material 3 navigation component
/// * [GoRouter] - Declarative routing package
class AppShell extends StatefulWidget {
  /// Creates an [AppShell] widget.
  ///
  /// The [child] parameter is required and represents the current route's
  /// content that will be displayed above the navigation bar.
  ///
  /// The optional [currentLocation] parameter is used primarily for testing
  /// to simulate different route locations. In production, the current
  /// location is obtained from GoRouter.
  ///
  /// The optional [onNavigate] callback is used for testing navigation
  /// events. In production, GoRouter.of(context).go() is used.
  const AppShell({
    required this.child,
    this.currentLocation,
    this.onNavigate,
    super.key,
  });

  /// The current route's content to display.
  ///
  /// This child widget is preserved across navigation changes,
  /// ensuring smooth transitions between tabs.
  final Widget child;

  /// Optional current location for testing purposes.
  ///
  /// If not provided, the widget will attempt to get the current
  /// location from GoRouter.of(context).
  final String? currentLocation;

  /// Optional navigation callback for testing.
  ///
  /// If not provided, the widget will use GoRouter.of(context).go()
  /// for navigation.
  final void Function(String path)? onNavigate;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Navigation destinations for the bottom navigation bar.
  ///
  /// Each destination corresponds to a main section of the app
  /// with an icon and label following Material Design guidelines.
  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.chat),
      label: 'Chat',
    ),
    NavigationDestination(
      icon: Icon(Icons.add_circle),
      label: 'New',
    ),
    NavigationDestination(
      icon: Icon(Icons.work),
      label: 'Operations',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings),
      label: 'Admin',
    ),
  ];

  /// Maps route paths to their corresponding navigation bar indices.
  ///
  /// This mapping ensures the correct tab is highlighted based on
  /// the current route location.
  static final Map<String, int> _routeToIndex = {
    RoutePaths.chat: 0,
    RoutePaths.quickActions: 1,
    RoutePaths.operations: 2,
    RoutePaths.admin: 3,
  };

  /// Maps navigation bar indices to their corresponding route paths.
  ///
  /// Used when a user taps on a navigation destination to determine
  /// which route to navigate to.
  static final List<String> _indexToRoute = [
    RoutePaths.chat,
    RoutePaths.quickActions,
    RoutePaths.operations,
    RoutePaths.admin,
  ];

  /// Gets the current selected index based on the route location.
  ///
  /// Returns the index corresponding to the current route, or 0 (Chat)
  /// as the default if the route is not recognized.
  int get _selectedIndex {
    final location = _getCurrentLocation();

    // Check exact match first
    if (_routeToIndex.containsKey(location)) {
      return _routeToIndex[location]!;
    }

    // Check if location starts with any of the route paths
    for (final entry in _routeToIndex.entries) {
      if (location.startsWith(entry.key)) {
        return entry.value;
      }
    }

    // Default to Chat tab
    return 0;
  }

  /// Gets the current location from either the widget parameter or GoRouter.
  ///
  /// This method first checks if a location was provided via widget parameter
  /// (useful for testing), otherwise attempts to get it from GoRouter context.
  String _getCurrentLocation() {
    if (widget.currentLocation != null) {
      return widget.currentLocation!;
    }

    try {
      final router = GoRouter.of(context);
      // fullPath is never null in current GoRouter versions
      final location = router.routerDelegate.currentConfiguration.fullPath;
      return location.isEmpty ? RoutePaths.chat : location;
    } catch (e) {
      // If GoRouter is not available (e.g., in tests), default to chat
      return RoutePaths.chat;
    }
  }

  /// Handles navigation when a destination is tapped.
  ///
  /// Uses the provided onNavigate callback if available (for testing),
  /// otherwise uses GoRouter.of(context).go() for actual navigation.
  void _onDestinationSelected(int index) {
    final route = _indexToRoute[index];

    if (widget.onNavigate != null) {
      widget.onNavigate!(route);
    } else {
      try {
        context.go(route);
      } catch (e) {
        // Handle navigation error gracefully
        debugPrint('Navigation error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
        // Material 3 styling is automatically applied based on theme
        // The navigation bar will use the color scheme from the app theme
      ),
    );
  }
}