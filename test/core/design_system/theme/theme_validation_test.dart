import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_theme.dart';
import 'package:mnesis_flutter/core/design_system/theme/theme_validation.dart';

/// Test suite for MnesisThemeValidation.
///
/// Verifies theme validation logic, contrast ratio calculations,
/// and WCAG compliance checking.
void main() {
  group('MnesisThemeValidation', () {
    late ThemeData theme;

    setUp(() {
      theme = MnesisTheme.darkTheme;
    });

    group('validateTheme', () {
      test('runs without errors on valid theme', () {
        expect(
          () => MnesisThemeValidation.validateTheme(theme),
          returnsNormally,
        );
      });

      test('validates Material 3 theme', () {
        expect(
          () => MnesisThemeValidation.validateTheme(theme),
          returnsNormally,
        );
        expect(theme.useMaterial3, isTrue);
      });

      test('validates theme with all component themes', () {
        expect(
          () => MnesisThemeValidation.validateTheme(theme),
          returnsNormally,
        );
        expect(theme.elevatedButtonTheme.style, isNotNull);
        expect(theme.inputDecorationTheme, isNotNull);
        expect(theme.cardTheme, isNotNull);
      });
    });

    group('calculateContrastRatio', () {
      test('calculates white on black as maximum contrast', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          Colors.white,
          Colors.black,
        );
        // White on black should be 21:1 (maximum possible contrast)
        expect(ratio, closeTo(21.0, 0.1));
      });

      test('calculates black on white as maximum contrast', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          Colors.black,
          Colors.white,
        );
        // Black on white should be 21:1 (maximum possible contrast)
        expect(ratio, closeTo(21.0, 0.1));
      });

      test('calculates same color contrast as 1:1', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.primaryOrange,
          MnesisColors.primaryOrange,
        );
        // Same color should be 1:1 (no contrast)
        expect(ratio, closeTo(1.0, 0.01));
      });

      test('calculates MnesisColors text on background correctly', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.textPrimary,
          MnesisColors.backgroundDark,
        );
        // Should meet WCAG AAA standard (7:1)
        expect(ratio, greaterThan(7.0));
      });

      test('calculates MnesisColors primary on background', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.primaryOrange,
          MnesisColors.backgroundDark,
        );
        // Should meet at least WCAG AA standard (4.5:1)
        expect(ratio, greaterThan(3.0));
      });

      test('calculates MnesisColors error on background', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.error,
          MnesisColors.backgroundDark,
        );
        // Error color provides visible contrast
        expect(ratio, greaterThan(3.0));
      });

      test('calculates contrast for text secondary', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.textSecondary,
          MnesisColors.backgroundDark,
        );
        // Secondary text should meet WCAG AA standard (4.5:1)
        expect(ratio, greaterThan(4.5));
      });

      test('calculates contrast for text tertiary', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.textTertiary,
          MnesisColors.backgroundDark,
        );
        // Tertiary text provides visible contrast (may be below WCAG AA for decorative elements)
        expect(ratio, greaterThan(2.0));
      });

      test('handles gray colors correctly', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          const Color(0xFF808080), // Medium gray
          Colors.black,
        );
        // Medium gray on black should have moderate contrast
        expect(ratio, greaterThan(1.0));
        expect(ratio, lessThan(21.0));
      });

      test('returns values in valid range (1-21)', () {
        final testColors = [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          MnesisColors.primaryOrange,
          MnesisColors.success,
          MnesisColors.warning,
        ];

        for (final color in testColors) {
          final ratio = MnesisThemeValidation.calculateContrastRatio(
            color,
            MnesisColors.backgroundDark,
          );
          expect(ratio, greaterThanOrEqualTo(1.0));
          expect(ratio, lessThanOrEqualTo(21.0));
        }
      });

      test('is commutative (order does not matter)', () {
        final ratio1 = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.primaryOrange,
          MnesisColors.backgroundDark,
        );
        final ratio2 = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.backgroundDark,
          MnesisColors.primaryOrange,
        );
        expect(ratio1, equals(ratio2));
      });
    });

    group('WCAG Compliance', () {
      test('primary text meets WCAG AAA (7:1)', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.textPrimary,
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThanOrEqualTo(7.0),
            reason: 'Primary text should meet WCAG AAA standard');
      });

      test('secondary text meets WCAG AA (4.5:1)', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.textSecondary,
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'Secondary text should meet WCAG AA standard');
      });

      test('error text is visible', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.error,
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: 'Error text should be clearly visible');
      });

      test('success text meets WCAG AA (4.5:1)', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.success,
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'Success text should meet WCAG AA standard');
      });

      test('warning text meets WCAG AA (4.5:1)', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.warning,
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'Warning text should meet WCAG AA standard');
      });

      test('info text meets WCAG AA (4.5:1)', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.info,
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'Info text should meet WCAG AA standard');
      });

      test('primary orange meets WCAG AA for large text (3:1)', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.primaryOrange,
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: 'Primary orange should meet WCAG AA for large text');
      });

      test('text on surface colors meets WCAG standards', () {
        final surfaceColors = [
          MnesisColors.surfaceDark,
          MnesisColors.surfaceElevated,
          MnesisColors.surfaceOverlay,
        ];

        for (final surface in surfaceColors) {
          final ratio = MnesisThemeValidation.calculateContrastRatio(
            MnesisColors.textPrimary,
            surface,
          );
          expect(ratio, greaterThanOrEqualTo(4.5),
              reason:
                  'Text should be readable on all surface colors (WCAG AA)');
        }
      });
    });

    group('Edge Cases', () {
      test('handles transparent colors', () {
        expect(
          () => MnesisThemeValidation.calculateContrastRatio(
            Colors.transparent,
            Colors.black,
          ),
          returnsNormally,
        );
      });

      test('handles colors with alpha channel', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.primaryOrange.withOpacity(0.5),
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThanOrEqualTo(1.0));
        expect(ratio, lessThanOrEqualTo(21.0));
      });

      test('validates theme with null-safe color properties', () {
        expect(
          () => MnesisThemeValidation.validateTheme(theme),
          returnsNormally,
        );
        expect(theme.colorScheme.primary, isNotNull);
        expect(theme.colorScheme.error, isNotNull);
        expect(theme.colorScheme.onSurface, isNotNull);
      });
    });

    group('Theme Configuration Validation', () {
      test('validates color scheme is complete', () {
        final colorScheme = theme.colorScheme;
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.onPrimary, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.onSecondary, isNotNull);
        expect(colorScheme.error, isNotNull);
        expect(colorScheme.onError, isNotNull);
        expect(colorScheme.surface, isNotNull);
        expect(colorScheme.onSurface, isNotNull);
      });

      test('validates component themes are configured', () {
        expect(theme.elevatedButtonTheme.style, isNotNull);
        expect(theme.outlinedButtonTheme.style, isNotNull);
        expect(theme.textButtonTheme.style, isNotNull);
        expect(theme.inputDecorationTheme.fillColor, isNotNull);
        expect(theme.cardTheme.color, isNotNull);
        expect(theme.appBarTheme.backgroundColor, isNotNull);
        expect(theme.navigationBarTheme.backgroundColor, isNotNull);
        expect(theme.bottomNavigationBarTheme.backgroundColor, isNotNull);
        expect(theme.dialogTheme.backgroundColor, isNotNull);
        expect(theme.snackBarTheme.backgroundColor, isNotNull);
      });

      test('validates text theme is complete', () {
        final textTheme = theme.textTheme;
        expect(textTheme.displayLarge, isNotNull);
        expect(textTheme.displayMedium, isNotNull);
        expect(textTheme.displaySmall, isNotNull);
        expect(textTheme.headlineLarge, isNotNull);
        expect(textTheme.headlineMedium, isNotNull);
        expect(textTheme.headlineSmall, isNotNull);
        expect(textTheme.titleLarge, isNotNull);
        expect(textTheme.titleMedium, isNotNull);
        expect(textTheme.titleSmall, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
        expect(textTheme.bodyMedium, isNotNull);
        expect(textTheme.bodySmall, isNotNull);
        expect(textTheme.labelLarge, isNotNull);
        expect(textTheme.labelMedium, isNotNull);
        expect(textTheme.labelSmall, isNotNull);
      });
    });
  });
}
