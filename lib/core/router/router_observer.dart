import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Router observer for navigation logging and analytics.
///
/// This observer tracks navigation events and can be extended
/// to integrate with analytics platforms like Firebase Analytics,
/// Mixpanel, or custom logging solutions.
///
/// ## Features
/// - Logs all route transitions
/// - Tracks navigation stack changes
/// - Provides hooks for analytics integration
///
/// ## Usage
/// ```dart
/// GoRouter(
///   observers: [MnesisRouterObserver()],
///   // ...
/// );
/// ```
class MnesisRouterObserver extends NavigatorObserver {
  /// Creates a [MnesisRouterObserver].
  ///
  /// An optional [logger] can be provided for custom logging configuration.
  MnesisRouterObserver({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('POP', route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logNavigation('REMOVE', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logNavigation('REPLACE', newRoute, oldRoute);
    }
  }

  /// Logs navigation events using the logger framework.
  ///
  /// In production, this integrates with proper analytics
  /// tracking (Firebase, Mixpanel, etc.).
  void _logNavigation(
    String action,
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    final routeName = route.settings.name ?? 'Unknown';
    final previousRouteName = previousRoute?.settings.name ?? 'None';

    _logger.d('🧭 Navigation [$action]: $previousRouteName → $routeName');

    // TODO: Add analytics tracking here
    // Example:
    // _analytics.logEvent(
    //   name: 'screen_view',
    //   parameters: {
    //     'screen_name': routeName,
    //     'previous_screen': previousRouteName,
    //     'action': action,
    //   },
    // );
  }
}
