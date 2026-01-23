import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Riverpod provider observer for logging state changes.
///
/// Monitors and logs all provider lifecycle events to help with debugging
/// state management issues during development.
///
/// Events logged:
/// - Provider creation (didAddProvider)
/// - Provider disposal (didDisposeProvider)
/// - Provider updates (didUpdateProvider)
/// - Provider errors (providerDidFail)
///
/// Usage:
/// ```dart
/// runApp(
///   ProviderScope(
///     observers: [ProviderLogger()],
///     child: const MyApp(),
///   ),
/// );
/// ```
///
/// Log output is automatically filtered based on build mode.
/// Verbose logging only occurs in debug builds.
class ProviderLogger extends ProviderObserver {
  final Logger _logger;

  /// Creates a ProviderLogger with custom Logger configuration.
  ///
  /// The logger is configured for concise output suitable for
  /// provider state monitoring.
  ProviderLogger()
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            dateTimeFormat: DateTimeFormat.onlyTime,
          ),
          level: Level.debug,
        );

  /// Called when a provider is initialized and added to the container.
  ///
  /// Logs the provider name or runtime type for debugging.
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    _logger.d('📦 Provider added: ${_getProviderName(provider)}');
  }

  /// Called when a provider is removed from the container.
  ///
  /// Useful for tracking provider lifecycle and detecting memory leaks.
  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    _logger.d('🗑️ Provider disposed: ${_getProviderName(provider)}');
  }

  /// Called when a provider's value changes.
  ///
  /// Logs state transitions to help debug state management flow.
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    _logger.d('🔄 Provider updated: ${_getProviderName(provider)}');

    // Only log values in debug mode to avoid exposing sensitive data
    assert(() {
      _logger.t('  Previous: $previousValue');
      _logger.t('  New: $newValue');
      return true;
    }());
  }

  /// Called when a provider throws an error.
  ///
  /// Logs the error with stack trace for debugging.
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _logger.e(
      '❌ Provider error: ${_getProviderName(provider)}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Extracts a readable name from the provider.
  ///
  /// Returns the provider's name property if available,
  /// otherwise falls back to the runtime type.
  String _getProviderName(ProviderBase<Object?> provider) {
    return provider.name ?? provider.runtimeType.toString();
  }
}