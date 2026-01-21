import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A custom page that provides no transition animation (instant switch).
///
/// This page transition creates an instant switch between screens with no
/// animation. It's particularly suitable for:
/// - Bottom navigation tab switches
/// - Tab bar navigation
/// - Any navigation where instant feedback is preferred
/// - Performance-critical scenarios
///
/// The instant switch provides the best perceived performance and is the
/// recommended approach for bottom navigation according to Material Design
/// guidelines, as it maintains context and provides immediate feedback.
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: '/home',
///   pageBuilder: (context, state) => InstantTransitionPage(
///     key: state.pageKey,
///     child: HomeScreen(),
///   ),
/// )
/// ```
///
/// Performance benefits:
/// - Zero animation overhead
/// - Instant visual feedback
/// - No frame drops during navigation
/// - Ideal for frequent navigation patterns
///
/// See also:
/// * [FadeTransitionPage] for fade animations
/// * [SlideTransitionPage] for horizontal slide animations
/// * [TransitionConfig] for animation constants
class InstantTransitionPage extends CustomTransitionPage<void> {
  /// Creates a page with no transition animation.
  ///
  /// The [key] parameter is required for GoRouter to properly manage page state.
  /// The [child] parameter is the widget to display without any animation.
  ///
  /// This is the most performant transition type as it avoids any animation
  /// overhead, making it ideal for frequently accessed pages like bottom
  /// navigation destinations.
  const InstantTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: _noTransitionBuilder,
        );

  /// Builds the no-transition animation (instant switch).
  ///
  /// Simply returns the child widget without any animation wrapper,
  /// providing the fastest possible navigation experience.
  static Widget _noTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Return the child directly without any animation
    // This provides instant switching between pages
    return child;
  }
}

/// Extension on [Page] to check if it uses no transition.
///
/// Useful for conditionally applying behaviors based on transition type.
extension PageTransitionCheck on Page {
  /// Returns true if this page uses no transition animation.
  bool get hasNoTransition => this is InstantTransitionPage;

  /// Returns true if this page uses a transition animation.
  bool get hasTransition => this is! InstantTransitionPage;
}