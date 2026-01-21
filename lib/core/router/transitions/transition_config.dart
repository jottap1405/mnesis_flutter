import 'package:flutter/material.dart';

/// Configuration constants for route transitions following Material Design motion guidelines.
///
/// These constants ensure consistent animation behavior across the entire app
/// while maintaining optimal performance at 60 FPS.
///
/// Motion principles:
/// - Standard duration: 300ms for smooth but responsive animations
/// - Standard curve: easeInOut for natural acceleration/deceleration
/// - Reverse animations use the same duration for consistency
///
/// See also:
/// * [Material Design Motion Guidelines](https://m3.material.io/styles/motion)
/// * [FadeTransitionPage] for fade animations
/// * [SlideTransitionPage] for horizontal slide animations
/// * [InstantTransitionPage] for instant transitions
class TransitionConfig {
  TransitionConfig._();

  /// Standard animation duration for all route transitions.
  ///
  /// 300ms provides a smooth animation that feels responsive without being
  /// too slow. This follows Material Design guidelines for screen transitions.
  static const Duration standardDuration = Duration(milliseconds: 300);

  /// Fast animation duration for quick transitions.
  ///
  /// 200ms is used for simpler transitions or when performance is critical.
  static const Duration fastDuration = Duration(milliseconds: 200);

  /// Standard animation curve for natural motion.
  ///
  /// Curves.easeInOut provides smooth acceleration at the beginning and
  /// deceleration at the end, creating a natural feeling animation.
  static const Curve standardCurve = Curves.easeInOut;

  /// Curve for entering animations (appearing content).
  ///
  /// Curves.easeOut decelerates as content comes into view,
  /// creating a gentle landing effect.
  static const Curve enteringCurve = Curves.easeOut;

  /// Curve for exiting animations (disappearing content).
  ///
  /// Curves.easeIn accelerates content as it leaves,
  /// creating a quick exit effect.
  static const Curve exitingCurve = Curves.easeIn;

  /// Slide offset for horizontal transitions.
  ///
  /// 1.0 means the page slides in from completely off-screen.
  static const double slideOffset = 1.0;

  /// Partial slide offset for subtle transitions.
  ///
  /// 0.3 creates a more subtle slide effect, useful for modal-like pages.
  static const double partialSlideOffset = 0.3;
}