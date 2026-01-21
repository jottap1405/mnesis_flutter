import 'package:go_router/go_router.dart';

import 'guards/auth_guard.dart';
import 'router_observer.dart';
import 'routes/route_names.dart';
import 'routes/route_paths.dart';
import 'shell/app_shell.dart';
import 'transitions/fade_transition_page.dart';
import 'transitions/instant_transition_page.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/new/presentation/new_screen.dart';
import '../../features/operation/presentation/operation_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../shared/widgets/not_found_page.dart';

/// Main GoRouter configuration for Mnesis Flutter application.
///
/// This class provides a singleton router instance configured with all
/// the application routes and navigation logic.
///
/// ## Architecture
/// - Uses GoRouter for declarative routing
/// - Implements ShellRoute for persistent bottom navigation
/// - Integrates [AuthGuard] for route protection (currently pass-through)
/// - Integrates [MnesisRouterObserver] for navigation logging and analytics
/// - Initial location set to `/chat` as the home route
/// - Handles 404 errors with custom [NotFoundPage]
/// - Custom page transitions for smooth navigation:
///   - No transition for bottom navigation (instant switch)
///   - Fade transition for error pages and deep links
///   - Slide transition available for programmatic navigation
///
/// ## Route Structure
/// ```
/// ShellRoute (with AppShell providing bottom navigation):
///   /chat         - Main chat interface (home)
///   /new          - Quick actions screen
///   /operation    - Operations management
///   /admin        - Admin and settings
///
/// Standalone routes (no bottom navigation):
///   /404          - Error page for invalid routes
/// ```
///
/// ## Usage
/// ```dart
/// // In MaterialApp
/// MaterialApp.router(
///   routerConfig: AppRouter.router,
/// )
///
/// // Navigate programmatically
/// context.go(RoutePaths.chat);
/// context.goNamed(RouteNames.quickActions);
/// ```
///
/// ## Singleton Pattern
/// The router is implemented as a singleton to ensure consistent
/// navigation state across the application. Access via:
/// ```dart
/// final router = AppRouter.router;
/// ```
///
/// See also:
/// * [RouteNames] - Named route constants
/// * [RoutePaths] - URL path constants
/// * [AuthGuard] - Authentication guard implementation
/// * [MnesisRouterObserver] - Navigation observer for logging and analytics
class AppRouter {
  /// Private constructor prevents instantiation.
  ///
  /// This ensures the class is used as a singleton through
  /// the static [router] property only.
  AppRouter._();

  /// Singleton instance of the authentication guard.
  ///
  /// Used for route protection and authentication checks.
  static const AuthGuard _authGuard = AuthGuard();

  /// Singleton GoRouter instance for the application.
  ///
  /// This is the main router configuration that should be passed
  /// to MaterialApp.router. It includes:
  /// - All application routes
  /// - Authentication redirect logic
  /// - Navigation observers for logging and analytics
  /// - Error handling for 404 pages
  /// - Initial location configuration
  ///
  /// Example:
  /// ```dart
  /// MaterialApp.router(
  ///   routerConfig: AppRouter.router,
  /// )
  /// ```
  static final GoRouter router = GoRouter(
    // Initial route when app starts
    initialLocation: RoutePaths.chat,

    // Enable debug logging in debug mode
    debugLogDiagnostics: true,

    // Authentication redirect logic
    redirect: _authGuard.redirect,

    // Navigation observers for logging and analytics
    observers: [MnesisRouterObserver()],

    // Error handler for invalid routes
    // Note: errorBuilder doesn't support custom transitions, but when
    // navigating to /404 programmatically, FadeTransitionPage is used
    errorBuilder: (context, state) => const NotFoundPage(),

    // Route definitions
    routes: [
      /// Shell route with bottom navigation.
      ///
      /// This ShellRoute wraps the main application screens with
      /// the AppShell widget, providing persistent bottom navigation
      /// across the four main sections of the app.
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          /// Chat route - Main interface.
          ///
          /// The home route of the application where users
          /// interact with the AI medical assistant.
          /// Uses [InstantTransitionPage] for instant switching within bottom navigation.
          GoRoute(
            path: RoutePaths.chat,
            name: RouteNames.chat,
            pageBuilder: (context, state) => InstantTransitionPage(
              key: state.pageKey,
              child: const ChatScreen(),
            ),
          ),

          /// Quick Actions route.
          ///
          /// Provides quick access to common actions like
          /// creating appointments, registering patients, etc.
          /// Uses [InstantTransitionPage] for instant switching within bottom navigation.
          GoRoute(
            path: RoutePaths.quickActions,
            name: RouteNames.quickActions,
            pageBuilder: (context, state) => InstantTransitionPage(
              key: state.pageKey,
              child: const NewScreen(),
            ),
          ),

          /// Operations route.
          ///
          /// Management interface for medical operations
          /// and procedures.
          /// Uses [InstantTransitionPage] for instant switching within bottom navigation.
          GoRoute(
            path: RoutePaths.operations,
            name: RouteNames.operations,
            pageBuilder: (context, state) => InstantTransitionPage(
              key: state.pageKey,
              child: const OperationScreen(),
            ),
          ),

          /// Admin route.
          ///
          /// Administrative interface for settings,
          /// profile management, and app configuration.
          /// Uses [InstantTransitionPage] for instant switching within bottom navigation.
          GoRoute(
            path: RoutePaths.admin,
            name: RouteNames.admin,
            pageBuilder: (context, state) => InstantTransitionPage(
              key: state.pageKey,
              child: const AdminScreen(),
            ),
          ),
        ],
      ),

      /// 404 Not Found route.
      ///
      /// Explicit route for 404 errors. While the errorBuilder
      /// handles undefined routes, this allows programmatic
      /// navigation to the 404 page. This route is outside the
      /// ShellRoute so it doesn't show the bottom navigation bar.
      /// Uses [FadeTransitionPage] for a gentle error display.
      GoRoute(
        path: RoutePaths.notFound,
        name: RouteNames.notFound,
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const NotFoundPage(),
        ),
      ),
    ],
  );
}