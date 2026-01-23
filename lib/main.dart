import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'core/config/env_config.dart';
import 'core/database/database_helper.dart';
import 'core/design_system/mnesis_theme.dart';
import 'core/di/injection.dart';
import 'core/providers/provider_logger.dart';
import 'core/router/app_router_simple.dart';

final _logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate theme configuration in debug mode
  assert(() {
    MnesisThemeValidation.validateTheme(MnesisTheme.darkTheme);
    return true;
  }());

  // 1. Initialize Dependency Injection FIRST
  try {
    await configureDependencies();
    _logger.i('✅ Dependency Injection configured successfully');
  } catch (e, stackTrace) {
    _logger.e('❌ DI configuration failed', error: e, stackTrace: stackTrace);
  }

  // 2. Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    _logger.i('✅ Environment variables loaded');

    // Validate required variables
    final config = getIt<EnvConfig>();
    final missing = config.validateRequired();

    if (missing.isNotEmpty && config.isProduction) {
      // CRITICAL: Fail fast in production if required config missing
      _logger.f(
        '❌ FATAL: Missing required environment variables in PRODUCTION: ${missing.join(", ")}',
      );
      throw Exception(
        'Production environment misconfigured. Missing: ${missing.join(", ")}',
      );
    } else if (missing.isNotEmpty) {
      _logger.w(
        '⚠️  WARNING: Missing environment variables (using defaults): ${missing.join(", ")}',
      );
    } else {
      _logger.i('✅ All required environment variables present');
    }
  } catch (e, stackTrace) {
    _logger.e('❌ Environment loading failed', error: e, stackTrace: stackTrace);

    // Only continue in development/debug mode
    if (kReleaseMode) {
      _logger.f('❌ FATAL: Cannot start app in release mode without proper configuration');
      rethrow; // Crash in production
    }

    _logger.w('⚠️  Continuing in debug mode with fallback configuration');
  }

  // 3. Initialize database
  try {
    final db = DatabaseHelper.instance;
    await db.database; // Force initialization
    _logger.i('✅ Database initialized successfully');
  } catch (e, stackTrace) {
    _logger.e('❌ Database initialization failed', error: e, stackTrace: stackTrace);
  }

  runApp(
    ProviderScope(
      // Only enable ProviderLogger in debug mode to:
      // - Prevent sensitive data exposure in production logs
      // - Reduce performance overhead in production builds
      // - Comply with FlowForge Rule #8 (production-ready code)
      observers: kDebugMode ? [ProviderLogger()] : [],
      child: const MnesisApp(),
    ),
  );
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
///
/// Uses Riverpod for state management with ProviderScope at the root.
class MnesisApp extends ConsumerWidget {
  const MnesisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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