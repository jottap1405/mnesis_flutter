import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Base interface for route guards.
///
/// Route guards inspect navigation requests and optionally redirect
/// to different routes based on application state. They integrate with
/// `go_router`'s redirect callback mechanism.
///
/// Guards are useful for:
/// - Authentication checks
/// - Authorization validation
/// - Feature flag enforcement
/// - Analytics/logging of navigation
/// - Conditional navigation flows
///
/// Example:
/// ```dart
/// class MyGuard implements RouteGuard {
///   @override
///   Future<String?> redirect(BuildContext context, GoRouterState state) async {
///     // Check some condition
///     if (shouldRedirect) {
///       return '/other-route';
///     }
///     return null; // Allow navigation
///   }
/// }
/// ```
///
/// See also:
/// * [AuthGuard], the authentication guard implementation
/// * [GoRouter.redirect], the go_router redirect callback
abstract class RouteGuard {
  /// Checks if navigation should be redirected.
  ///
  /// This method is called before each navigation event and can inspect
  /// the navigation state to determine if a redirect is needed.
  ///
  /// Returns:
  /// - `null` if navigation is allowed to proceed as requested
  /// - A path `String` to redirect to instead of the requested route
  ///
  /// Parameters:
  /// - [context]: The BuildContext for accessing providers, theme, etc.
  /// - [state]: The GoRouterState containing route information including:
  ///   - `matchedLocation`: The matched route path
  ///   - `uri`: The full URI including query parameters
  ///   - `pathParameters`: Dynamic path parameters
  ///   - `extra`: Additional data passed during navigation
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<String?> redirect(BuildContext context, GoRouterState state) async {
  ///   final isLoggedIn = await checkAuthStatus();
  ///   
  ///   if (!isLoggedIn && state.matchedLocation.startsWith('/protected')) {
  ///     return '/login';
  ///   }
  ///   
  ///   return null;
  /// }
  /// ```
  Future<String?> redirect(BuildContext context, GoRouterState state);
}
