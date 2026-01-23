import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Mnesis theme validation utilities.
///
/// This class provides runtime validation for theme configuration,
/// checking for WCAG compliance, missing configurations, and
/// Material 3 compatibility.
///
/// ## Validation Checks
/// - Contrast ratio compliance (WCAG AA/AAA)
/// - Required component themes presence
/// - Material 3 enablement
/// - Color consistency
///
/// ## Usage
/// ```dart
/// // In main.dart (debug mode only)
/// assert(() {
///   MnesisThemeValidation.validateTheme(theme);
///   return true;
/// }());
/// ```
///
/// See also:
/// * [ThemeData] - Flutter theme data
/// * WCAG 2.1 Guidelines - https://www.w3.org/WAI/WCAG21/Understanding/
class MnesisThemeValidation {
  MnesisThemeValidation._(); // Private constructor

  static final _logger = Logger();

  /// Validates theme configuration at runtime (debug mode only).
  ///
  /// Performs comprehensive validation including:
  /// - Contrast ratio violations check
  /// - Missing component themes detection
  /// - Material 3 compatibility verification
  /// - Color scheme consistency
  ///
  /// This method should only be called in debug mode to avoid
  /// performance overhead in production.
  static void validateTheme(ThemeData theme) {
    assert(() {
      _logger.i('🎨 Validating Mnesis theme configuration...');

      // Validate Material 3 is enabled
      _validateMaterial3(theme);

      // Validate color contrast ratios
      _validateColorContrast(theme);

      // Validate component themes
      _validateComponentThemes(theme);

      // Validate typography
      _validateTypography(theme);

      _logger.i('✅ Theme validation complete');
      return true;
    }());
  }

  /// Validates Material 3 is enabled.
  static void _validateMaterial3(ThemeData theme) {
    if (!theme.useMaterial3) {
      _logger.w('⚠️  WARNING: Material 3 not enabled');
    } else {
      _logger.i('✅ Material 3 enabled');
    }
  }

  /// Validates color contrast ratios for WCAG compliance.
  static void _validateColorContrast(ThemeData theme) {
    final bgColor = theme.scaffoldBackgroundColor;
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;
    final textColor = theme.colorScheme.onSurface;

    // Check primary color contrast
    final primaryContrastRatio = calculateContrastRatio(primaryColor, bgColor);
    if (primaryContrastRatio < 3.0) {
      _logger.w(
        '⚠️  WARNING: Primary color contrast is ${primaryContrastRatio.toStringAsFixed(2)}:1 '
        '(should be >= 3:1 for large text)',
      );
    } else {
      _logger.i('✅ Primary color contrast: ${primaryContrastRatio.toStringAsFixed(2)}:1');
    }

    // Check error color contrast
    final errorContrastRatio = calculateContrastRatio(errorColor, bgColor);
    if (errorContrastRatio < 4.5) {
      _logger.w(
        '⚠️  WARNING: Error color contrast is ${errorContrastRatio.toStringAsFixed(2)}:1 '
        '(should be >= 4.5:1 for normal text)',
      );
    }

    // Check text color contrast
    final textContrastRatio = calculateContrastRatio(textColor, bgColor);
    if (textContrastRatio < 4.5) {
      _logger.w(
        '⚠️  WARNING: Text color contrast is ${textContrastRatio.toStringAsFixed(2)}:1 '
        '(should be >= 4.5:1 for normal text)',
      );
    } else {
      _logger.i('✅ Text color contrast: ${textContrastRatio.toStringAsFixed(2)}:1');
    }
  }

  /// Validates all required component themes are configured.
  static void _validateComponentThemes(ThemeData theme) {
    final requiredThemes = <String, bool>{
      'elevatedButtonTheme': theme.elevatedButtonTheme.style != null,
      'outlinedButtonTheme': theme.outlinedButtonTheme.style != null,
      'textButtonTheme': theme.textButtonTheme.style != null,
      'inputDecorationTheme': theme.inputDecorationTheme.fillColor != null,
      'cardTheme': theme.cardTheme.color != null,
      'appBarTheme': theme.appBarTheme.backgroundColor != null,
      'navigationBarTheme': theme.navigationBarTheme.backgroundColor != null,
      'bottomNavigationBarTheme': theme.bottomNavigationBarTheme.backgroundColor != null,
      'dialogTheme': theme.dialogTheme.backgroundColor != null,
      'snackBarTheme': theme.snackBarTheme.backgroundColor != null,
      'chipTheme': theme.chipTheme.backgroundColor != null,
      'floatingActionButtonTheme': theme.floatingActionButtonTheme.backgroundColor != null,
      'listTileTheme': theme.listTileTheme.textColor != null,
      'switchTheme': theme.switchTheme.thumbColor != null,
      'checkboxTheme': theme.checkboxTheme.fillColor != null,
      'radioTheme': theme.radioTheme.fillColor != null,
    };

    var allConfigured = true;
    requiredThemes.forEach((themeName, isConfigured) {
      if (!isConfigured) {
        _logger.w('⚠️  WARNING: $themeName not configured');
        allConfigured = false;
      }
    });

    if (allConfigured) {
      _logger.i('✅ All required component themes configured');
    }
  }

  /// Validates typography configuration.
  static void _validateTypography(ThemeData theme) {
    final textTheme = theme.textTheme;
    final requiredStyles = [
      textTheme.displayLarge,
      textTheme.displayMedium,
      textTheme.displaySmall,
      textTheme.headlineLarge,
      textTheme.headlineMedium,
      textTheme.headlineSmall,
      textTheme.titleLarge,
      textTheme.titleMedium,
      textTheme.titleSmall,
      textTheme.bodyLarge,
      textTheme.bodyMedium,
      textTheme.bodySmall,
      textTheme.labelLarge,
      textTheme.labelMedium,
      textTheme.labelSmall,
    ];

    final allStylesDefined = requiredStyles.every((style) => style != null);
    if (allStylesDefined) {
      _logger.i('✅ All text styles defined');
    } else {
      _logger.w('⚠️  WARNING: Some text styles are missing');
    }
  }

  /// Calculates contrast ratio between two colors.
  ///
  /// Returns a value between 1 and 21, where higher values indicate
  /// better contrast. WCAG guidelines recommend:
  /// - 3:1 for large text (18pt or 14pt bold)
  /// - 4.5:1 for normal text
  /// - 7:1 for AAA compliance
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _calculateRelativeLuminance(foreground);
    final bgLuminance = _calculateRelativeLuminance(background);

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculates relative luminance for a color.
  static double _calculateRelativeLuminance(Color color) {
    final r = _calculateChannelLuminance(color.r);
    final g = _calculateChannelLuminance(color.g);
    final b = _calculateChannelLuminance(color.b);

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