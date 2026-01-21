import 'package:flutter/material.dart';
import 'core/design_system/mnesis_theme.dart';
import 'core/router/app_router_simple.dart';

void main() {
  runApp(const MnesisApp());
}

/// Mnesis application root widget.
///
/// Configures the app with Material 3 design system, dark theme,
/// and GoRouter navigation powered by AppRouter configuration.
///
/// The router configuration includes:
/// - Bottom navigation with 4 tabs (Chat, Records, Medication, Settings)
/// - Deep linking support for Android and iOS
/// - Nested navigation with AppShell for maintaining bottom navigation
class MnesisApp extends StatelessWidget {
  const MnesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mnesis',
      debugShowCheckedModeBanner: false,

      // Apply Mnesis dark theme with Material 3
      theme: MnesisTheme.darkTheme,
      darkTheme: MnesisTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark theme as per design system

      // Router configuration using GoRouter
      // Initial route: /chat (configured in AppRouter)
      // Handles deep linking and navigation state preservation
      routerConfig: AppRouter.router,
    );
  }
}