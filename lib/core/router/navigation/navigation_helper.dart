import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:mnesis_flutter/core/router/routes/route_names.dart';
import 'package:mnesis_flutter/core/router/routes/route_paths.dart';

/// Type-safe navigation helper for Mnesis app.
///
/// Provides a centralized, type-safe API for navigation throughout the app.
/// This helper ensures compile-time safety for route navigation, eliminating
/// runtime errors from incorrect route names or paths.
///
/// Benefits:
/// - Type safety: Compile-time errors instead of runtime failures
/// - IDE autocomplete: Better developer experience
/// - Refactoring support: Change routes in one place
/// - Centralized logic: All navigation logic in one place
/// - Error handling: Graceful fallbacks for invalid routes
///
/// Example usage:
/// ```dart
/// // Direct usage
/// final helper = NavigationHelper(context);
/// helper.goToChat();
///
/// // Using extension
/// context.nav.goToChat();
/// context.nav.goToQuickActions();
///
/// // Check if can go back
/// if (context.nav.canGoBack()) {
///   context.nav.goBack();
/// }
///
/// // Replace navigation (no back stack)
/// context.nav.replaceWithAdmin();
/// ```
class NavigationHelper {
  /// Creates a navigation helper for the given context.
  ///
  /// The [context] must have a GoRouter available via GoRouter.of(context).
  /// An optional [onError] callback can be provided to handle navigation errors.
  /// The [router] parameter is exposed for testing purposes only.
  NavigationHelper(
    this._context, {
    this.onError,
    GoRouter? router,
  }) : _router = router;

  final BuildContext _context;
  final GoRouter? _router;

  /// Optional error callback for handling navigation errors.
  ///
  /// This callback is invoked when navigation fails, allowing custom
  /// error handling logic such as showing snackbars or logging.
  final void Function(Object error)? onError;

  static final _logger = Logger();

  /// Gets the GoRouter instance from the context or uses the injected router.
  GoRouter get router => _router ?? GoRouter.of(_context);

  // ============================================================================
  // Basic Navigation Methods
  // ============================================================================

  /// Navigates to the Chat screen (home).
  ///
  /// This is the default screen and main entry point of the app.
  void goToChat() {
    _navigate(() => router.go(RoutePaths.chat));
  }

  /// Navigates to the Quick Actions screen.
  ///
  /// Shows frequently used medical actions for quick access.
  void goToQuickActions() {
    _navigate(() => router.go(RoutePaths.quickActions));
  }

  /// Navigates to the Operations screen.
  ///
  /// Displays ongoing and scheduled medical operations.
  void goToOperations() {
    _navigate(() => router.go(RoutePaths.operations));
  }

  /// Navigates to the Admin screen.
  ///
  /// Administrative functions and settings management.
  void goToAdmin() {
    _navigate(() => router.go(RoutePaths.admin));
  }

  /// Navigates to the Not Found screen.
  ///
  /// Shown when an invalid route is accessed.
  void goToNotFound() {
    _navigate(() => router.go(RoutePaths.notFound));
  }

  // ============================================================================
  // Named Navigation
  // ============================================================================

  /// Navigates to a route using its name.
  ///
  /// This method provides flexibility for dynamic navigation while still
  /// maintaining type safety through the RouteNames constants.
  ///
  /// Falls back to the chat screen if navigation fails.
  ///
  /// Example:
  /// ```dart
  /// context.nav.goToNamed(RouteNames.quickActions);
  /// ```
  void goToNamed(String routeName) {
    try {
      router.goNamed(routeName);
    } catch (error) {
      _logger.e('Failed to navigate to named route: $routeName', error: error);
      onError?.call(error);

      // Fallback to home on error
      if (routeName != RouteNames.chat) {
        _navigate(() => router.go(RoutePaths.chat));
      }
    }
  }

  // ============================================================================
  // Back Navigation
  // ============================================================================

  /// Navigates back to the previous screen.
  ///
  /// Pops the current route from the navigation stack.
  /// If there's no previous route, this method does nothing.
  void goBack() {
    _navigate(() => router.pop());
  }

  /// Checks if the user can navigate back.
  ///
  /// Returns `true` if there's a previous route in the navigation stack,
  /// `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (context.nav.canGoBack()) {
  ///   context.nav.goBack();
  /// } else {
  ///   // Show "Are you sure you want to exit?" dialog
  /// }
  /// ```
  bool canGoBack() {
    return router.canPop();
  }

  // ============================================================================
  // Replace Navigation (No Back Stack)
  // ============================================================================

  /// Replaces the current route with the Chat screen.
  ///
  /// The current route is removed from the navigation stack,
  /// preventing the user from navigating back to it.
  void replaceWithChat() {
    _navigate(() => router.pushReplacement(RoutePaths.chat));
  }

  /// Replaces the current route with the Quick Actions screen.
  ///
  /// The current route is removed from the navigation stack.
  void replaceWithQuickActions() {
    _navigate(() => router.pushReplacement(RoutePaths.quickActions));
  }

  /// Replaces the current route with the Operations screen.
  ///
  /// The current route is removed from the navigation stack.
  void replaceWithOperations() {
    _navigate(() => router.pushReplacement(RoutePaths.operations));
  }

  /// Replaces the current route with the Admin screen.
  ///
  /// The current route is removed from the navigation stack.
  void replaceWithAdmin() {
    _navigate(() => router.pushReplacement(RoutePaths.admin));
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Executes a navigation action with error handling.
  ///
  /// Catches any errors during navigation and invokes the error callback
  /// if provided. This ensures the app doesn't crash due to navigation errors.
  void _navigate(void Function() navigationAction) {
    try {
      navigationAction();
    } catch (error) {
      _logger.e('Navigation error', error: error);
      onError?.call(error);
    }
  }
}

// ============================================================================
// BuildContext Extension
// ============================================================================

/// Extension on BuildContext to provide easy access to NavigationHelper.
///
/// This extension allows for cleaner, more intuitive navigation syntax
/// throughout the app.
///
/// Example usage:
/// ```dart
/// // Instead of:
/// NavigationHelper(context).goToChat();
///
/// // Use:
/// context.nav.goToChat();
///
/// // Navigate to different screens
/// context.nav.goToQuickActions();
/// context.nav.goToOperations();
/// context.nav.goToAdmin();
///
/// // Check and go back
/// if (context.nav.canGoBack()) {
///   context.nav.goBack();
/// }
///
/// // Replace current route
/// context.nav.replaceWithChat();
/// ```
extension NavigationExtension on BuildContext {
  /// Gets a NavigationHelper instance for this context.
  ///
  /// Creates a new NavigationHelper each time it's accessed to ensure
  /// the context is always current.
  NavigationHelper get nav => NavigationHelper(this);
}