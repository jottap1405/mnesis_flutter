/// Route path constants for the Mnesis navigation system.
///
/// This class provides static constants for all URL paths used throughout
/// the application. Route paths define the actual URLs that users see in
/// their browser or deep links.
///
/// All route paths:
/// - Start with a forward slash (/)
/// - Follow URL conventions (lowercase, alphanumeric with dash/underscore)
/// - Are unique across the application
///
/// Example:
/// ```dart
/// GoRouter.of(context).go(RoutePaths.chat);
/// ```
///
/// See also:
/// * [RouteNames] - The corresponding route names for these paths
class RoutePaths {
  /// Private constructor to prevent instantiation.
  ///
  /// This class is designed to be used as a namespace for constants only.
  const RoutePaths._();

  /// Path for the main chat interface.
  ///
  /// This is the default/home route path of the application.
  /// URL: `/chat`
  static const String chat = '/chat';

  /// Path for quick actions screen.
  ///
  /// Provides access to create new items (appointments, schedules, etc.).
  /// URL: `/new`
  static const String quickActions = '/new';

  /// Path for general operations screen.
  ///
  /// Contains general operational features and functionality.
  /// URL: `/operation`
  static const String operations = '/operation';

  /// Path for admin/settings screen.
  ///
  /// Provides access to user profile and application configuration.
  /// URL: `/admin`
  static const String admin = '/admin';

  /// Path for the 404 not found screen.
  ///
  /// Displayed when a user navigates to an undefined route.
  /// URL: `/404`
  static const String notFound = '/404';
}
