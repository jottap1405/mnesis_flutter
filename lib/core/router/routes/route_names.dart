/// Route name constants for the Mnesis navigation system.
///
/// This class provides static constants for all route names used throughout
/// the application. Route names are used internally by the navigation system
/// to identify routes programmatically.
///
/// All route names follow camelCase naming convention for consistency with
/// Dart best practices.
///
/// Example:
/// ```dart
/// GoRouter.of(context).goNamed(RouteNames.chat);
/// ```
///
/// See also:
/// * [RoutePaths] - The corresponding URL paths for these routes
class RouteNames {
  /// Private constructor to prevent instantiation.
  ///
  /// This class is designed to be used as a namespace for constants only.
  const RouteNames._();

  /// Route name for the main chat interface.
  ///
  /// This is the default/home route of the application where users interact
  /// with the AI assistant.
  static const String chat = 'chat';

  /// Route name for quick actions screen.
  ///
  /// Provides access to quick actions such as new appointments, scheduling,
  /// and registration.
  static const String quickActions = 'quickActions';

  /// Route name for general operations screen.
  ///
  /// Contains general operational features and functionality.
  static const String operations = 'operations';

  /// Route name for admin/settings screen.
  ///
  /// Provides access to user profile, application settings, and configuration
  /// options.
  static const String admin = 'admin';

  /// Route name for the 404 not found screen.
  ///
  /// Displayed when a user navigates to an undefined route.
  static const String notFound = 'notFound';
}
