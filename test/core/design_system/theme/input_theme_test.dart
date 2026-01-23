import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_spacings.dart';
import 'package:mnesis_flutter/core/design_system/theme/input_theme.dart';

/// Test suite for MnesisInputTheme.
///
/// Verifies input field decoration theme configuration
/// including borders, colors, and text styles.
void main() {
  group('MnesisInputTheme', () {
    late InputDecorationTheme theme;

    setUp(() {
      theme = MnesisInputTheme.inputDecoration;
    });

    group('Basic Configuration', () {
      test('has filled background', () {
        expect(theme.filled, isTrue);
      });

      test('has proper fill color', () {
        expect(theme.fillColor, equals(MnesisColors.surfaceDark));
      });

      test('has proper content padding', () {
        expect(
          theme.contentPadding,
          equals(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.inputPaddingHorizontal,
              vertical: MnesisSpacings.inputPaddingVertical,
            ),
          ),
        );
      });

      test('has dense set to false', () {
        expect(theme.isDense, isFalse);
      });

      test('aligns label with hint', () {
        expect(theme.alignLabelWithHint, isTrue);
      });

      test('has error max lines configured', () {
        expect(theme.errorMaxLines, equals(2));
      });
    });

    group('Border Configuration', () {
      test('default border has pill shape with no border side', () {
        expect(theme.border, isA<OutlineInputBorder>());
        final border = theme.border as OutlineInputBorder;
        expect(
          border.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
        );
        expect(border.borderSide, equals(BorderSide.none));
      });

      test('enabled border has pill shape with no border side', () {
        expect(theme.enabledBorder, isA<OutlineInputBorder>());
        final border = theme.enabledBorder as OutlineInputBorder;
        expect(
          border.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
        );
        expect(border.borderSide, equals(BorderSide.none));
      });

      test('focused border has orange border', () {
        expect(theme.focusedBorder, isA<OutlineInputBorder>());
        final border = theme.focusedBorder as OutlineInputBorder;
        expect(
          border.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
        );
        expect(border.borderSide.color, equals(MnesisColors.primaryOrange));
        expect(border.borderSide.width, equals(2));
      });

      test('error border has red border', () {
        expect(theme.errorBorder, isA<OutlineInputBorder>());
        final border = theme.errorBorder as OutlineInputBorder;
        expect(
          border.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
        );
        expect(border.borderSide.color, equals(MnesisColors.error));
        expect(border.borderSide.width, equals(2));
      });

      test('focused error border has red border', () {
        expect(theme.focusedErrorBorder, isA<OutlineInputBorder>());
        final border = theme.focusedErrorBorder as OutlineInputBorder;
        expect(
          border.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
        );
        expect(border.borderSide.color, equals(MnesisColors.error));
        expect(border.borderSide.width, equals(2));
      });

      test('disabled border has pill shape with no border side', () {
        expect(theme.disabledBorder, isA<OutlineInputBorder>());
        final border = theme.disabledBorder as OutlineInputBorder;
        expect(
          border.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
        );
        expect(border.borderSide, equals(BorderSide.none));
      });
    });

    group('Text Styles', () {
      test('label style is configured', () {
        expect(theme.labelStyle, isNotNull);
      });

      test('floating label style has orange color', () {
        expect(theme.floatingLabelStyle, isNotNull);
        expect(theme.floatingLabelStyle?.color, equals(MnesisColors.primaryOrange));
      });

      test('hint style has secondary text color', () {
        expect(theme.hintStyle, isNotNull);
        expect(theme.hintStyle?.color, equals(MnesisColors.textSecondary));
      });

      test('error style has error color', () {
        expect(theme.errorStyle, isNotNull);
        expect(theme.errorStyle?.color, equals(MnesisColors.error));
      });

      test('helper style has tertiary text color', () {
        expect(theme.helperStyle, isNotNull);
        expect(theme.helperStyle?.color, equals(MnesisColors.textTertiary));
      });

      test('prefix style is configured', () {
        expect(theme.prefixStyle, isNotNull);
      });

      test('suffix style is configured', () {
        expect(theme.suffixStyle, isNotNull);
      });

      test('counter style has tertiary text color', () {
        expect(theme.counterStyle, isNotNull);
        expect(theme.counterStyle?.color, equals(MnesisColors.textTertiary));
      });
    });

    group('Border Consistency', () {
      test('all borders use pill-shaped radius', () {
        final borders = [
          theme.border as OutlineInputBorder,
          theme.enabledBorder as OutlineInputBorder,
          theme.focusedBorder as OutlineInputBorder,
          theme.errorBorder as OutlineInputBorder,
          theme.focusedErrorBorder as OutlineInputBorder,
          theme.disabledBorder as OutlineInputBorder,
        ];

        for (final border in borders) {
          expect(
            border.borderRadius,
            equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
            reason: 'All borders should use pill-shaped radius',
          );
        }
      });

      test('focused and error borders have same width', () {
        final focusedBorder = theme.focusedBorder as OutlineInputBorder;
        final errorBorder = theme.errorBorder as OutlineInputBorder;
        final focusedErrorBorder = theme.focusedErrorBorder as OutlineInputBorder;

        expect(focusedBorder.borderSide.width, equals(2));
        expect(errorBorder.borderSide.width, equals(2));
        expect(focusedErrorBorder.borderSide.width, equals(2));
      });

      test('non-focused borders have no border side', () {
        final border = theme.border as OutlineInputBorder;
        final enabledBorder = theme.enabledBorder as OutlineInputBorder;
        final disabledBorder = theme.disabledBorder as OutlineInputBorder;

        expect(border.borderSide, equals(BorderSide.none));
        expect(enabledBorder.borderSide, equals(BorderSide.none));
        expect(disabledBorder.borderSide, equals(BorderSide.none));
      });
    });

    group('Color States', () {
      test('normal state uses surface color background', () {
        expect(theme.fillColor, equals(MnesisColors.surfaceDark));
      });

      test('focus state uses orange border', () {
        final focusedBorder = theme.focusedBorder as OutlineInputBorder;
        expect(focusedBorder.borderSide.color, equals(MnesisColors.primaryOrange));
      });

      test('error state uses error color', () {
        final errorBorder = theme.errorBorder as OutlineInputBorder;
        expect(errorBorder.borderSide.color, equals(MnesisColors.error));
      });

      test('error text uses error color', () {
        expect(theme.errorStyle?.color, equals(MnesisColors.error));
      });

      test('secondary elements use appropriate colors', () {
        expect(theme.hintStyle?.color, equals(MnesisColors.textSecondary));
        expect(theme.helperStyle?.color, equals(MnesisColors.textTertiary));
        expect(theme.counterStyle?.color, equals(MnesisColors.textTertiary));
      });
    });

    group('Accessibility', () {
      test('focus state is visually distinct', () {
        final enabledBorder = theme.enabledBorder as OutlineInputBorder;
        final focusedBorder = theme.focusedBorder as OutlineInputBorder;

        expect(enabledBorder.borderSide, equals(BorderSide.none));
        expect(focusedBorder.borderSide.width, equals(2));
        expect(
          focusedBorder.borderSide.color,
          isNot(equals(enabledBorder.borderSide.color)),
        );
      });

      test('error state is visually distinct', () {
        final enabledBorder = theme.enabledBorder as OutlineInputBorder;
        final errorBorder = theme.errorBorder as OutlineInputBorder;

        expect(enabledBorder.borderSide, equals(BorderSide.none));
        expect(errorBorder.borderSide.width, equals(2));
        expect(errorBorder.borderSide.color, equals(MnesisColors.error));
      });

      test('error messages can display multiple lines', () {
        expect(theme.errorMaxLines, equals(2));
      });
    });

    group('Immutability', () {
      test('returns consistent instance', () {
        final theme1 = MnesisInputTheme.inputDecoration;
        final theme2 = MnesisInputTheme.inputDecoration;

        expect(theme1.fillColor, equals(theme2.fillColor));
        expect(theme1.filled, equals(theme2.filled));
        expect(theme1.contentPadding, equals(theme2.contentPadding));
      });

      test('theme is not null', () {
        expect(MnesisInputTheme.inputDecoration, isNotNull);
      });
    });

    group('Material 3 Compatibility', () {
      test('can be used in Material 3 theme', () {
        expect(
          () => ThemeData(
            inputDecorationTheme: MnesisInputTheme.inputDecoration,
            useMaterial3: true,
          ),
          returnsNormally,
        );
      });

      test('border shapes are compatible with Material 3', () {
        final border = theme.border as OutlineInputBorder;
        expect(border, isA<OutlineInputBorder>());
        expect(border.borderRadius, isNotNull);
      });
    });
  });
}
