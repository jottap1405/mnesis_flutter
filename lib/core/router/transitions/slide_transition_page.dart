import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'transition_config.dart';

/// A custom page that provides a horizontal slide transition animation.
///
/// This page transition creates a smooth sliding effect when navigating
/// between screens, with the new page sliding in from the right and the
/// old page sliding out to the left. It's particularly suitable for:
/// - Programmatic navigation with directional context
/// - Detail views and drill-down navigation
/// - Forward navigation flow where spatial relationship matters
///
/// The animation follows Material Design motion guidelines with a 300ms duration
/// and easeInOut curve for natural motion.
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: '/details/:id',
///   pageBuilder: (context, state) => SlideTransitionPage(
///     key: state.pageKey,
///     child: DetailScreen(id: state.params['id']!),
///   ),
/// )
/// ```
///
/// See also:
/// * [FadeTransitionPage] for fade animations
/// * [InstantTransitionPage] for instant transitions
/// * [TransitionConfig] for animation constants
class SlideTransitionPage extends CustomTransitionPage<void> {
  /// Creates a slide transition page with standard horizontal slide.
  ///
  /// The [key] parameter is required for GoRouter to properly manage page state.
  /// The [child] parameter is the widget to display with the slide animation.
  /// The [duration] parameter defaults to [TransitionConfig.standardDuration].
  /// The [slideFromRight] parameter controls the slide direction (default: true).
  const SlideTransitionPage({
    required LocalKey super.key,
    required super.child,
    Duration duration = TransitionConfig.standardDuration,
    bool slideFromRight = true,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: slideFromRight
              ? _slideFromRightTransitionBuilder
              : _slideFromLeftTransitionBuilder,
        );

  /// Creates a slide transition page that slides from the left.
  ///
  /// Useful for back navigation or RTL language support.
  const SlideTransitionPage.fromLeft({
    required LocalKey super.key,
    required super.child,
    Duration duration = TransitionConfig.standardDuration,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: _slideFromLeftTransitionBuilder,
        );

  /// Creates a slide transition page with subtle slide effect.
  ///
  /// Uses [TransitionConfig.partialSlideOffset] for a more subtle animation.
  /// Useful for modal-like pages or secondary navigation.
  const SlideTransitionPage.subtle({
    required LocalKey super.key,
    required super.child,
    Duration duration = TransitionConfig.standardDuration,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: _subtleSlideTransitionBuilder,
        );

  /// Builds the slide-from-right transition animation.
  ///
  /// The new page slides in from the right (offset 1.0, 0.0) to center (0.0, 0.0).
  /// The old page slides out to the left from center to (-0.3, 0.0) for parallax effect.
  static Widget _slideFromRightTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Entering page animation (slides from right)
    final primaryTween = Tween<Offset>(
      begin: const Offset(TransitionConfig.slideOffset, 0.0),
      end: Offset.zero,
    );

    // Exiting page animation (slides to left with parallax)
    final secondaryTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-TransitionConfig.partialSlideOffset, 0.0),
    );

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: TransitionConfig.standardCurve,
      reverseCurve: TransitionConfig.standardCurve.flipped,
    );

    final secondaryCurvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: TransitionConfig.standardCurve,
      reverseCurve: TransitionConfig.standardCurve.flipped,
    );

    return SlideTransition(
      position: primaryTween.animate(curvedAnimation),
      child: SlideTransition(
        position: secondaryTween.animate(secondaryCurvedAnimation),
        child: child,
      ),
    );
  }

  /// Builds the slide-from-left transition animation.
  ///
  /// The new page slides in from the left (offset -1.0, 0.0) to center (0.0, 0.0).
  /// Useful for back navigation or RTL language support.
  static Widget _slideFromLeftTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Entering page animation (slides from left)
    final primaryTween = Tween<Offset>(
      begin: const Offset(-TransitionConfig.slideOffset, 0.0),
      end: Offset.zero,
    );

    // Exiting page animation (slides to right with parallax)
    final secondaryTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(TransitionConfig.partialSlideOffset, 0.0),
    );

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: TransitionConfig.standardCurve,
      reverseCurve: TransitionConfig.standardCurve.flipped,
    );

    final secondaryCurvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: TransitionConfig.standardCurve,
      reverseCurve: TransitionConfig.standardCurve.flipped,
    );

    return SlideTransition(
      position: primaryTween.animate(curvedAnimation),
      child: SlideTransition(
        position: secondaryTween.animate(secondaryCurvedAnimation),
        child: child,
      ),
    );
  }

  /// Builds a subtle slide transition animation.
  ///
  /// Uses a smaller offset for a more subtle effect, suitable for modal-like pages.
  static Widget _subtleSlideTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Subtle entering animation
    final primaryTween = Tween<Offset>(
      begin: const Offset(TransitionConfig.partialSlideOffset, 0.0),
      end: Offset.zero,
    );

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: TransitionConfig.enteringCurve,
      reverseCurve: TransitionConfig.exitingCurve,
    );

    // Combine with fade for smoother effect
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: primaryTween.animate(curvedAnimation),
        child: child,
      ),
    );
  }
}