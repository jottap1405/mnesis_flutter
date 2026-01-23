import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_theme.dart';
import 'package:mnesis_flutter/core/design_system/theme/theme_validation.dart';

void main() {
  group('MnesisTheme - Refactored Theme Tests', () {
    late ThemeData theme;

    setUp(() {
      theme = MnesisTheme.darkTheme;
    });

    group('Theme Configuration', () {
      test('Material 3 is enabled', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('scaffold background is correct', () {
        expect(theme.scaffoldBackgroundColor, equals(MnesisColors.backgroundDark));
      });

      test('color scheme is configured', () {
        expect(theme.colorScheme.primary, equals(MnesisColors.primaryOrange));
        expect(theme.colorScheme.surface, equals(MnesisColors.backgroundDark));
        expect(theme.colorScheme.error, equals(MnesisColors.error));
      });
    });

    group('Component Themes', () {
      test('elevated button theme is configured', () {
        expect(theme.elevatedButtonTheme, isNotNull);
        expect(theme.elevatedButtonTheme.style, isNotNull);
      });

      test('input decoration theme is configured', () {
        expect(theme.inputDecorationTheme, isNotNull);
        expect(theme.inputDecorationTheme.fillColor, equals(MnesisColors.surfaceDark));
      });

      test('card theme is configured', () {
        expect(theme.cardTheme, isNotNull);
        expect(theme.cardTheme.color, equals(MnesisColors.surfaceDark));
      });

      test('app bar theme is configured', () {
        expect(theme.appBarTheme, isNotNull);
        expect(theme.appBarTheme.backgroundColor, equals(MnesisColors.backgroundDark));
      });

      test('navigation bar theme is configured', () {
        expect(theme.navigationBarTheme, isNotNull);
        expect(theme.navigationBarTheme.backgroundColor, equals(MnesisColors.surfaceDark));
      });

      test('dialog theme is configured', () {
        expect(theme.dialogTheme, isNotNull);
        expect(theme.dialogTheme.backgroundColor, equals(MnesisColors.surfaceDark));
      });
    });

    group('Text Theme', () {
      test('all text styles are defined', () {
        expect(theme.textTheme.displayLarge, isNotNull);
        expect(theme.textTheme.displayMedium, isNotNull);
        expect(theme.textTheme.displaySmall, isNotNull);
        expect(theme.textTheme.headlineLarge, isNotNull);
        expect(theme.textTheme.headlineMedium, isNotNull);
        expect(theme.textTheme.headlineSmall, isNotNull);
        expect(theme.textTheme.bodyLarge, isNotNull);
        expect(theme.textTheme.bodyMedium, isNotNull);
        expect(theme.textTheme.bodySmall, isNotNull);
        expect(theme.textTheme.labelLarge, isNotNull);
        expect(theme.textTheme.labelMedium, isNotNull);
        expect(theme.textTheme.labelSmall, isNotNull);
      });
    });

    group('Theme Validation', () {
      test('theme passes validation without errors', () {
        // This should not throw
        expect(
          () => MnesisThemeValidation.validateTheme(theme),
          returnsNormally,
        );
      });

      test('contrast ratio calculation works', () {
        final ratio = MnesisThemeValidation.calculateContrastRatio(
          MnesisColors.textPrimary,
          MnesisColors.backgroundDark,
        );
        expect(ratio, greaterThan(4.5)); // WCAG AA standard
      });
    });

    group('Backward Compatibility', () {
      test('MnesisTheme.darkTheme returns valid ThemeData', () {
        expect(MnesisTheme.darkTheme, isA<ThemeData>());
      });

      test('all exports are accessible', () {
        // These should compile without errors
        expect(MnesisColorScheme.dark, isNotNull);
        expect(MnesisButtonThemes.elevated, isNotNull);
        expect(MnesisInputTheme.inputDecoration, isNotNull);
        expect(MnesisNavigationThemes.navigationBar, isNotNull);
        expect(MnesisComponentThemes.card, isNotNull);
      });
    });
  });
}