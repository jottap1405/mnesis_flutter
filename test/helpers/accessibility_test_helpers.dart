import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helpers for accessibility validation.
///
/// Provides utilities for WCAG compliance testing including
/// contrast ratio calculation and assertion helpers.
class AccessibilityTestHelpers {
  AccessibilityTestHelpers._();

  /// Calculates WCAG contrast ratio between two colors.
  ///
  /// Returns a value between 1:1 (no contrast) and 21:1 (maximum contrast).
  /// WCAG 2.1 requirements:
  /// - AA: 4.5:1 for normal text, 3:1 for large text
  /// - AAA: 7:1 for normal text, 4.5:1 for large text
  ///
  /// Example:
  /// ```dart
  /// final ratio = AccessibilityTestHelpers.calculateContrastRatio(
  ///   Colors.white,
  ///   Colors.black,
  /// );
  /// expect(ratio, equals(21.0)); // Maximum contrast
  /// ```
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _calculateRelativeLuminance(foreground);
    final bgLuminance = _calculateRelativeLuminance(background);

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Asserts WCAG AA compliance (4.5:1 for normal text).
  ///
  /// Throws if contrast ratio is below 4.5:1.
  ///
  /// Example:
  /// ```dart
  /// AccessibilityTestHelpers.expectWCAGAA(
  ///   MnesisColors.textPrimary,
  ///   MnesisColors.backgroundDark,
  /// );
  /// ```
  static void expectWCAGAA(Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    expect(
      ratio,
      greaterThanOrEqualTo(4.5),
      reason: 'WCAG AA requires 4.5:1 contrast ratio. Got: ${ratio.toStringAsFixed(2)}:1',
    );
  }

  /// Asserts WCAG AAA compliance (7:1 for normal text).
  ///
  /// Throws if contrast ratio is below 7:1.
  ///
  /// Example:
  /// ```dart
  /// AccessibilityTestHelpers.expectWCAGAAA(
  ///   MnesisColors.textPrimary,
  ///   MnesisColors.backgroundDark,
  /// );
  /// ```
  static void expectWCAGAAA(Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    expect(
      ratio,
      greaterThanOrEqualTo(7.0),
      reason: 'WCAG AAA requires 7:1 contrast ratio. Got: ${ratio.toStringAsFixed(2)}:1',
    );
  }

  /// Asserts WCAG AA compliance for large text (3:1).
  ///
  /// Large text is defined as 18pt+ or 14pt+ bold.
  static void expectWCAGAALargeText(Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    expect(
      ratio,
      greaterThanOrEqualTo(3.0),
      reason: 'WCAG AA (large text) requires 3:1 contrast ratio. Got: ${ratio.toStringAsFixed(2)}:1',
    );
  }

  /// Calculates relative luminance for a color.
  ///
  /// Uses WCAG 2.1 formula: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  static double _calculateRelativeLuminance(Color color) {
    final r = _calculateChannelLuminance(((color.r * 255.0).round() & 0xff) / 255.0);
    final g = _calculateChannelLuminance(((color.g * 255.0).round() & 0xff) / 255.0);
    final b = _calculateChannelLuminance(((color.b * 255.0).round() & 0xff) / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates luminance for a single color channel.
  static double _calculateChannelLuminance(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }
}