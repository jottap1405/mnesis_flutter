import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_guard.dart';

/// Authentication guard for route protection in Mnesis.
///
/// **IMPORTANT: Mnesis uses a chat-first authentication model.**
///
/// Unlike traditional apps, Mnesis does NOT have a dedicated login screen.
/// Authentication happens through the chat interface, which means:
///
/// - All routes are accessible regardless of authentication state
/// - Unauthenticated users can navigate anywhere in the app
/// - Authentication state affects UI features within screens, not navigation
/// - No redirects to login screens occur
///
/// This guard currently allows all navigation and serves as:
/// - A foundation for future extensibility
/// - A placeholder for analytics/logging
/// - A potential hook for enterprise features
/// - Documentation of the chat-first authentication model
///
/// Future extensibility examples:
/// ```dart
/// // Future: Log navigation events
/// Future<String?> redirect(BuildContext context, GoRouterState state) async {
///   analyticsService.logNavigation(state.matchedLocation);
///   return null;
/// }
///
/// // Future: Check enterprise features
/// Future<String?> redirect(BuildContext context, GoRouterState state) async {
///   if (state.matchedLocation.startsWith('/enterprise')) {
///     final hasAccess = await checkEnterpriseAccess();
///     if (!hasAccess) return '/upgrade';
///   }
///   return null;
/// }
/// ```
///
/// See also:
/// * [RouteGuard], the base interface for all guards
/// * Chat authentication flow documentation
class AuthGuard implements RouteGuard {
  /// Creates an authentication guard.
  ///
  /// This guard uses a const constructor as it has no state
  /// and can be shared across the application.
  const AuthGuard();

  /// Checks authentication state and determines navigation routing.
  ///
  /// In Mnesis, this method ALWAYS returns `null` because:
  /// - Authentication happens in the chat interface, not login screens
  /// - All routes are accessible to all users
  /// - Authentication state affects UI within screens, not navigation blocking
  ///
  /// The method signature matches `go_router`'s redirect callback expectations,
  /// allowing this guard to be used directly:
  /// ```dart
  /// GoRouter(
  ///   redirect: authGuard.redirect,
  ///   // ...
  /// );
  /// ```
  ///
  /// Parameters:
  /// - [context]: BuildContext (currently unused, available for future features)
  /// - [state]: GoRouterState with navigation information
  ///
  /// Returns:
  /// - Always `null` to allow all navigation
  ///
  /// Example:
  /// ```dart
  /// final authGuard = const AuthGuard();
  /// final shouldRedirect = await authGuard.redirect(context, state);
  /// // shouldRedirect is always null in Mnesis
  /// ```
  @override
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    // Mnesis architectural decision: NO LOGIN SCREEN
    // Authentication happens through chat interface
    // All routes are accessible regardless of auth state
    // Auth state affects UI features within screens, not navigation

    // Future extensibility hooks:
    // - Analytics/logging of navigation events
    // - Enterprise feature access checks
    // - Token refresh triggers
    // - Auth state event dispatching

    return null; // Allow all navigation
  }
}
