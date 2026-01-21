import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'transition_config.dart';

/// A custom page that provides a fade transition animation.
///
/// This page transition creates a smooth fade-in/fade-out effect when navigating
/// between screens. It's particularly suitable for:
/// - Deep links from external sources
/// - Error pages and modal-like content
/// - Non-directional navigation where spatial relationship isn't important
///
/// The animation follows Material Design motion guidelines with a 300ms duration
/// and easeInOut curve for natural motion.
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: '/error',
///   pageBuilder: (context, state) => FadeTransitionPage(
///     key: state.pageKey,
///     child: ErrorScreen(),
///   ),
/// )
/// ```
///
/// See also:
/// * [SlideTransitionPage] for horizontal slide animations
/// * [InstantTransitionPage] for instant transitions
/// * [TransitionConfig] for animation constants
class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a fade transition page.
  ///
  /// The [key] parameter is required for GoRouter to properly manage page state.
  /// The [child] parameter is the widget to display with the fade animation.
  /// The [duration] parameter defaults to [TransitionConfig.standardDuration].
  const FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
    Duration duration = TransitionConfig.standardDuration,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: _fadeTransitionBuilder,
        );

  /// Creates a fade transition page with fast animation.
  ///
  /// Uses [TransitionConfig.fastDuration] for quicker transitions.
  /// Useful for less important or frequently accessed pages.
  const FadeTransitionPage.fast({
    required LocalKey super.key,
    required super.child,
  }) : super(
          transitionDuration: TransitionConfig.fastDuration,
          reverseTransitionDuration: TransitionConfig.fastDuration,
          transitionsBuilder: _fadeTransitionBuilder,
        );

  /// Builds the fade transition animation.
  ///
  /// Creates a simple opacity animation that fades the child widget
  /// in and out. The animation value goes from 0.0 (invisible) to 1.0 (visible).
  static Widget _fadeTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use CurvedAnimation for more natural motion
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: TransitionConfig.standardCurve,
      reverseCurve: TransitionConfig.standardCurve.flipped,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: child,
    );
  }
}