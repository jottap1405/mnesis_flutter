import 'package:flutter/material.dart' as flutter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Application lifecycle state enumeration for Mnesis.
///
/// Represents the current state of the application in the
/// mobile operating system's app lifecycle.
enum MnesisLifecycleState {
  /// Application is visible and responding to user input.
  resumed,

  /// Application is transitioning between states.
  inactive,

  /// Application is not visible but still running in background.
  paused,

  /// Application is suspended (iOS) or destroyed (Android).
  detached,
}

/// Provider for tracking application lifecycle state.
///
/// Monitors whether the app is in foreground, background, or transitioning.
/// Useful for pausing/resuming operations based on app visibility.
///
/// States:
/// - [MnesisLifecycleState.resumed]: App is in foreground and active
/// - [MnesisLifecycleState.inactive]: App is transitioning (e.g., app switcher)
/// - [MnesisLifecycleState.paused]: App is in background
/// - [MnesisLifecycleState.detached]: App is being terminated
///
/// Usage:
/// ```dart
/// // Watch lifecycle changes
/// final lifecycle = ref.watch(appLifecycleProvider);
///
/// if (lifecycle == MnesisLifecycleState.resumed) {
///   // Resume network polling
///   startDataSync();
/// } else if (lifecycle == MnesisLifecycleState.paused) {
///   // Pause expensive operations
///   pauseDataSync();
/// }
/// ```
///
/// To update the lifecycle state (typically from AppLifecycleListener):
/// ```dart
/// ref.read(appLifecycleProvider.notifier).state = MnesisLifecycleState.paused;
/// ```
final appLifecycleProvider = StateProvider<MnesisLifecycleState>(
  (ref) => MnesisLifecycleState.resumed,
  name: 'appLifecycleProvider',
);

/// Widget that automatically tracks app lifecycle changes.
///
/// Add this widget high in your widget tree to automatically
/// update the [appLifecycleProvider] when the app lifecycle changes.
///
/// Example:
/// ```dart
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return AppLifecycleObserver(
///       child: MaterialApp(...),
///     );
///   }
/// }
/// ```
class AppLifecycleObserver extends ConsumerStatefulWidget {
  /// The child widget to wrap.
  final flutter.Widget child;

  /// Creates an AppLifecycleObserver.
  ///
  /// The [child] parameter must not be null.
  const AppLifecycleObserver({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with flutter.WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    flutter.WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    flutter.WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(flutter.AppLifecycleState state) {
    // Map Flutter's AppLifecycleState to our custom enum
    final customState = switch (state) {
      flutter.AppLifecycleState.resumed => MnesisLifecycleState.resumed,
      flutter.AppLifecycleState.inactive => MnesisLifecycleState.inactive,
      flutter.AppLifecycleState.paused => MnesisLifecycleState.paused,
      flutter.AppLifecycleState.detached => MnesisLifecycleState.detached,
      flutter.AppLifecycleState.hidden => MnesisLifecycleState.inactive,
    };

    // Update the provider with the new state
    ref.read(appLifecycleProvider.notifier).state = customState;
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return widget.child;
  }
}