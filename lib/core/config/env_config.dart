import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

/// Environment configuration service.
///
/// Provides type-safe access to environment variables loaded from .env file.
/// All sensitive configuration should be stored in .env and accessed through
/// this service rather than hard-coded in the application.
///
/// Configuration is loaded once at app startup via flutter_dotenv.
///
/// Usage:
/// ```dart
/// final config = getIt<EnvConfig>();
/// final apiUrl = config.apiBaseUrl;
/// if (config.isDevelopment) {
///   // Enable debug features
/// }
/// ```
///
/// Environment variables are defined in .env file (see .env.example).
@lazySingleton
class EnvConfig {
  /// API base URL for backend services.
  ///
  /// Defaults to example URL if not specified in .env.
  /// Production apps should always provide this value.
  String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'https://api.mnesis.example.com');

  /// API request timeout in seconds.
  ///
  /// Controls how long to wait for API responses before timing out.
  /// Default: 30 seconds
  int get apiTimeoutSeconds =>
      int.parse(dotenv.get('API_TIMEOUT_SECONDS', fallback: '30'));

  /// Supabase project URL.
  ///
  /// Required for Supabase authentication and database access.
  /// Returns null if not configured (allows graceful degradation).
  String? get supabaseUrl => dotenv.maybeGet('SUPABASE_URL');

  /// Supabase anonymous key for client access.
  ///
  /// Public key used for Supabase client initialization.
  /// Returns null if not configured.
  String? get supabaseAnonKey => dotenv.maybeGet('SUPABASE_ANON_KEY');

  /// Whether analytics tracking is enabled.
  ///
  /// Controls whether the app sends analytics events.
  /// Useful for disabling analytics in development/testing.
  /// Default: false
  bool get analyticsEnabled =>
      dotenv.get('ENABLE_ANALYTICS', fallback: 'false').toLowerCase() == 'true';

  /// Whether crash reporting is enabled.
  ///
  /// Controls whether the app sends crash reports to monitoring service.
  /// Should be disabled in development to avoid noise.
  /// Default: false
  bool get crashReportingEnabled =>
      dotenv.get('ENABLE_CRASH_REPORTING', fallback: 'false').toLowerCase() == 'true';

  /// Current environment name.
  ///
  /// Valid values: 'development', 'staging', 'production'
  /// Used to enable environment-specific features and behaviors.
  /// Default: 'development'
  String get environment =>
      dotenv.get('ENVIRONMENT', fallback: 'development');

  /// Whether the app is running in production environment.
  ///
  /// Returns true only when environment == 'production'.
  /// Use this to gate production-only features.
  bool get isProduction => environment == 'production';

  /// Whether the app is running in development environment.
  ///
  /// Returns true when environment == 'development'.
  /// Use this to enable development tools and debug features.
  bool get isDevelopment => environment == 'development';

  /// Whether the app is running in staging environment.
  ///
  /// Returns true when environment == 'staging'.
  /// Use this for pre-production testing configuration.
  bool get isStaging => environment == 'staging';

  /// Validates that all required environment variables are present.
  ///
  /// Call this during app initialization to fail fast if configuration
  /// is missing. This prevents runtime errors from missing config.
  ///
  /// Returns a list of missing required variable names.
  /// Empty list means all required variables are present.
  ///
  /// **Required in production:**
  /// - None currently (all have sensible defaults)
  ///
  /// **Required when Supabase is enabled:**
  /// - SUPABASE_URL (when using backend features)
  /// - SUPABASE_ANON_KEY (when using backend features)
  List<String> validateRequired() {
    final missing = <String>[];

    // Check production-specific requirements
    if (isProduction) {
      // Add variables that MUST be set in production
      // Example: if using real backend
      // if (supabaseUrl == null) missing.add('SUPABASE_URL');
      // if (supabaseAnonKey == null) missing.add('SUPABASE_ANON_KEY');
    }

    return missing;
  }

  /// Gets a raw environment variable value.
  ///
  /// Use this for custom environment variables not exposed as properties.
  /// Returns null if the variable is not set.
  ///
  /// Prefer using typed properties when available.
  String? getRaw(String key) => dotenv.maybeGet(key);
}