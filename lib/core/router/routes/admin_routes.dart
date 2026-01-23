import 'package:go_router/go_router.dart';
import '../../../features/admin/presentation/admin_screen.dart';
import '../../../features/admin/presentation/profile_screen.dart';
import '../../../features/admin/presentation/settings_screen.dart';
import '../../../features/admin/presentation/about_screen.dart';
import '../../design_system/design_system_test_screen.dart';

/// Admin feature route definitions.
///
/// This feature provides access to **profile, settings, and app configuration**.
///
/// ## Philosophy
/// Admin screen shows user profile options, app settings, and configuration.
/// While many actions can be performed via chat (chat-first), this screen
/// provides direct access to administrative functions.
///
/// ## Routes
/// - `/admin` - Admin overview (profile, settings)
/// - `/admin/profile` - Profile editing
/// - `/admin/settings` - App settings and configuration
/// - `/admin/about` - About screen
///
/// Example:
/// ```dart
/// // Navigate to admin
/// context.go(AdminRoutes.root);
///
/// // Navigate to profile
/// context.go(AdminRoutes.profile);
/// ```
class AdminRoutes {
  AdminRoutes._(); // Private constructor

  /// Root path for admin.
  static const String root = '/admin';

  /// Path for profile editing.
  static const String profile = '/admin/profile';

  /// Path for settings.
  static const String settings = '/admin/settings';

  /// Path for about screen.
  static const String about = '/admin/about';

  /// Path for design system test screen.
  static const String designSystem = '/admin/design-system';

  /// Route definitions.
  static final List<RouteBase> routes = [
    GoRoute(
      path: root,
      name: 'admin',
      builder: (context, state) => const AdminScreen(),
      routes: [
        // Nested route: profile
        GoRoute(
          path: 'profile',
          name: 'admin-profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // Nested route: settings
        GoRoute(
          path: 'settings',
          name: 'admin-settings',
          builder: (context, state) => const SettingsScreen(),
        ),

        // Nested route: about
        GoRoute(
          path: 'about',
          name: 'admin-about',
          builder: (context, state) => const AboutScreen(),
        ),

        // Nested route: design system test
        GoRoute(
          path: 'design-system',
          name: 'admin-design-system',
          builder: (context, state) => const DesignSystemTestScreen(),
        ),
      ],
    ),
  ];
}
