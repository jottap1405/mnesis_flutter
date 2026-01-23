import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_spacings.dart';
import 'package:mnesis_flutter/core/design_system/theme/button_themes.dart';

/// Test suite for MnesisButtonThemes.
///
/// Verifies button theme configurations for all button types:
/// Elevated, Outlined, Text, Filled Tonal, and Icon buttons.
void main() {
  group('MnesisButtonThemes', () {
    group('Elevated Button Theme', () {
      late ElevatedButtonThemeData theme;

      setUp(() {
        theme = MnesisButtonThemes.elevated;
      });

      test('has proper background color', () {
        final backgroundColor =
            theme.style?.backgroundColor?.resolve(<WidgetState>{});
        expect(backgroundColor, equals(MnesisColors.primaryOrange));
      });

      test('has proper foreground color', () {
        final foregroundColor =
            theme.style?.foregroundColor?.resolve(<WidgetState>{});
        expect(foregroundColor, equals(MnesisColors.textPrimary));
      });

      test('has disabled background color', () {
        final disabledBackground = theme.style?.backgroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        expect(disabledBackground, equals(MnesisColors.orangeDisabled));
      });

      test('has disabled foreground color', () {
        final disabledForeground = theme.style?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        expect(disabledForeground, equals(MnesisColors.textDisabled));
      });

      test('has Material Design minimum size', () {
        final minimumSize = theme.style?.minimumSize?.resolve(<WidgetState>{});
        expect(minimumSize, equals(const Size(88, 48)));
      });

      test('has proper padding', () {
        final padding = theme.style?.padding?.resolve(<WidgetState>{});
        expect(
          padding,
          equals(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.buttonPaddingHorizontal,
              vertical: MnesisSpacings.buttonPaddingVertical,
            ),
          ),
        );
      });

      test('has rounded corners', () {
        final shape = theme.style?.shape?.resolve(<WidgetState>{});
        expect(shape, isA<RoundedRectangleBorder>());
        final roundedShape = shape as RoundedRectangleBorder;
        expect(
          roundedShape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusLg)),
        );
      });

      test('has proper elevation', () {
        final elevation = theme.style?.elevation?.resolve(<WidgetState>{});
        expect(elevation, equals(MnesisSpacings.elevation2));
      });

      test('has shadow color', () {
        final shadowColor = theme.style?.shadowColor?.resolve(<WidgetState>{});
        expect(shadowColor, equals(Colors.black26));
      });

      test('style is not null', () {
        expect(theme.style, isNotNull);
      });
    });

    group('Outlined Button Theme', () {
      late OutlinedButtonThemeData theme;

      setUp(() {
        theme = MnesisButtonThemes.outlined;
      });

      test('has proper foreground color', () {
        final foregroundColor =
            theme.style?.foregroundColor?.resolve(<WidgetState>{});
        expect(foregroundColor, equals(MnesisColors.primaryOrange));
      });

      test('has disabled foreground color', () {
        final disabledForeground = theme.style?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        expect(disabledForeground, equals(MnesisColors.textDisabled));
      });

      test('has Material Design minimum size', () {
        final minimumSize = theme.style?.minimumSize?.resolve(<WidgetState>{});
        expect(minimumSize, equals(const Size(88, 48)));
      });

      test('has proper padding', () {
        final padding = theme.style?.padding?.resolve(<WidgetState>{});
        expect(
          padding,
          equals(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.buttonPaddingHorizontal,
              vertical: MnesisSpacings.buttonPaddingVertical,
            ),
          ),
        );
      });

      test('has border with orange color', () {
        final side = theme.style?.side?.resolve(<WidgetState>{});
        expect(side, isNotNull);
        expect(side?.color, equals(MnesisColors.primaryOrange));
        expect(side?.width, equals(2));
      });

      test('has rounded corners', () {
        final shape = theme.style?.shape?.resolve(<WidgetState>{});
        expect(shape, isA<RoundedRectangleBorder>());
        final roundedShape = shape as RoundedRectangleBorder;
        expect(
          roundedShape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusLg)),
        );
      });

      test('style is not null', () {
        expect(theme.style, isNotNull);
      });
    });

    group('Text Button Theme', () {
      late TextButtonThemeData theme;

      setUp(() {
        theme = MnesisButtonThemes.text;
      });

      test('has proper foreground color', () {
        final foregroundColor =
            theme.style?.foregroundColor?.resolve(<WidgetState>{});
        expect(foregroundColor, equals(MnesisColors.primaryOrange));
      });

      test('has disabled foreground color', () {
        final disabledForeground = theme.style?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        expect(disabledForeground, equals(MnesisColors.textDisabled));
      });

      test('has Material Design minimum size', () {
        final minimumSize = theme.style?.minimumSize?.resolve(<WidgetState>{});
        expect(minimumSize, equals(const Size(88, 48)));
      });

      test('has proper padding', () {
        final padding = theme.style?.padding?.resolve(<WidgetState>{});
        expect(
          padding,
          equals(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.buttonPaddingHorizontal,
              vertical: MnesisSpacings.buttonPaddingVertical,
            ),
          ),
        );
      });

      test('style is not null', () {
        expect(theme.style, isNotNull);
      });
    });

    group('Filled Tonal Button Theme', () {
      late FilledButtonThemeData theme;

      setUp(() {
        theme = MnesisButtonThemes.filledTonal;
      });

      test('has tonal background color', () {
        final backgroundColor =
            theme.style?.backgroundColor?.resolve(<WidgetState>{});
        expect(backgroundColor, equals(MnesisColors.orange20));
      });

      test('has proper foreground color', () {
        final foregroundColor =
            theme.style?.foregroundColor?.resolve(<WidgetState>{});
        expect(foregroundColor, equals(MnesisColors.primaryOrange));
      });

      test('has disabled background color', () {
        final disabledBackground = theme.style?.backgroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        expect(disabledBackground, equals(MnesisColors.backgroundDarker));
      });

      test('has disabled foreground color', () {
        final disabledForeground = theme.style?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        expect(disabledForeground, equals(MnesisColors.textDisabled));
      });

      test('has Material Design minimum size', () {
        final minimumSize = theme.style?.minimumSize?.resolve(<WidgetState>{});
        expect(minimumSize, equals(const Size(88, 48)));
      });

      test('has proper padding', () {
        final padding = theme.style?.padding?.resolve(<WidgetState>{});
        expect(
          padding,
          equals(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.buttonPaddingHorizontal,
              vertical: MnesisSpacings.buttonPaddingVertical,
            ),
          ),
        );
      });

      test('has rounded corners', () {
        final shape = theme.style?.shape?.resolve(<WidgetState>{});
        expect(shape, isA<RoundedRectangleBorder>());
        final roundedShape = shape as RoundedRectangleBorder;
        expect(
          roundedShape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusLg)),
        );
      });

      test('style is not null', () {
        expect(theme.style, isNotNull);
      });
    });

    group('Icon Button Theme', () {
      late IconButtonThemeData theme;

      setUp(() {
        theme = MnesisButtonThemes.icon;
      });

      test('has proper foreground color', () {
        final foregroundColor =
            theme.style?.foregroundColor?.resolve(<WidgetState>{});
        expect(foregroundColor, equals(MnesisColors.textSecondary));
      });

      test('has disabled foreground color', () {
        final disabledForeground = theme.style?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        expect(disabledForeground, equals(MnesisColors.textDisabled));
      });

      test('has proper icon size', () {
        final iconSize = theme.style?.iconSize?.resolve(<WidgetState>{});
        expect(iconSize, equals(MnesisSpacings.iconSizeMedium));
      });

      test('has highlight color', () {
        final highlightColor =
            theme.style?.overlayColor?.resolve(<WidgetState>{WidgetState.hovered});
        // Note: highlightColor is deprecated, testing overlay instead
        expect(highlightColor, isNotNull);
      });

      test('has proper padding', () {
        final padding = theme.style?.padding?.resolve(<WidgetState>{});
        expect(padding, equals(EdgeInsets.all(MnesisSpacings.sm)));
      });

      test('has accessibility minimum size', () {
        final minimumSize = theme.style?.minimumSize?.resolve(<WidgetState>{});
        expect(minimumSize, equals(const Size(48, 48)));
      });

      test('style is not null', () {
        expect(theme.style, isNotNull);
      });
    });

    group('Button Theme Consistency', () {
      test('all button types use consistent padding', () {
        final elevatedPadding = MnesisButtonThemes.elevated.style?.padding
            ?.resolve(<WidgetState>{});
        final outlinedPadding = MnesisButtonThemes.outlined.style?.padding
            ?.resolve(<WidgetState>{});
        final textPadding =
            MnesisButtonThemes.text.style?.padding?.resolve(<WidgetState>{});
        final tonalPadding = MnesisButtonThemes.filledTonal.style?.padding
            ?.resolve(<WidgetState>{});

        expect(elevatedPadding, equals(outlinedPadding));
        expect(elevatedPadding, equals(textPadding));
        expect(elevatedPadding, equals(tonalPadding));
      });

      test('all button types use consistent minimum size', () {
        final elevatedSize = MnesisButtonThemes.elevated.style?.minimumSize
            ?.resolve(<WidgetState>{});
        final outlinedSize = MnesisButtonThemes.outlined.style?.minimumSize
            ?.resolve(<WidgetState>{});
        final textSize =
            MnesisButtonThemes.text.style?.minimumSize?.resolve(<WidgetState>{});
        final tonalSize = MnesisButtonThemes.filledTonal.style?.minimumSize
            ?.resolve(<WidgetState>{});

        expect(elevatedSize, equals(const Size(88, 48)));
        expect(outlinedSize, equals(const Size(88, 48)));
        expect(textSize, equals(const Size(88, 48)));
        expect(tonalSize, equals(const Size(88, 48)));
      });

      test('all button types use consistent disabled foreground', () {
        final elevatedDisabled = MnesisButtonThemes.elevated.style?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        final outlinedDisabled = MnesisButtonThemes.outlined.style
            ?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        final textDisabled = MnesisButtonThemes.text.style?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});
        final tonalDisabled = MnesisButtonThemes.filledTonal.style
            ?.foregroundColor
            ?.resolve(<WidgetState>{WidgetState.disabled});

        expect(elevatedDisabled, equals(MnesisColors.textDisabled));
        expect(outlinedDisabled, equals(MnesisColors.textDisabled));
        expect(textDisabled, equals(MnesisColors.textDisabled));
        expect(tonalDisabled, equals(MnesisColors.textDisabled));
      });

      test('filled buttons use consistent border radius', () {
        final elevatedShape = MnesisButtonThemes.elevated.style?.shape
            ?.resolve(<WidgetState>{}) as RoundedRectangleBorder?;
        final outlinedShape = MnesisButtonThemes.outlined.style?.shape
            ?.resolve(<WidgetState>{}) as RoundedRectangleBorder?;
        final tonalShape = MnesisButtonThemes.filledTonal.style?.shape
            ?.resolve(<WidgetState>{}) as RoundedRectangleBorder?;

        expect(elevatedShape?.borderRadius,
            equals(BorderRadius.circular(MnesisSpacings.radiusLg)));
        expect(outlinedShape?.borderRadius,
            equals(BorderRadius.circular(MnesisSpacings.radiusLg)));
        expect(tonalShape?.borderRadius,
            equals(BorderRadius.circular(MnesisSpacings.radiusLg)));
      });
    });

    group('Accessibility', () {
      test('icon button meets touch target size (48x48)', () {
        final minimumSize =
            MnesisButtonThemes.icon.style?.minimumSize?.resolve(<WidgetState>{});
        expect(minimumSize?.width, greaterThanOrEqualTo(48));
        expect(minimumSize?.height, greaterThanOrEqualTo(48));
      });

      test('standard buttons meet minimum touch target height', () {
        final elevatedSize = MnesisButtonThemes.elevated.style?.minimumSize
            ?.resolve(<WidgetState>{});
        final outlinedSize = MnesisButtonThemes.outlined.style?.minimumSize
            ?.resolve(<WidgetState>{});
        final textSize = MnesisButtonThemes.text.style?.minimumSize
            ?.resolve(<WidgetState>{});
        final tonalSize = MnesisButtonThemes.filledTonal.style?.minimumSize
            ?.resolve(<WidgetState>{});

        expect(elevatedSize?.height, greaterThanOrEqualTo(48),
            reason: 'Elevated button height should meet accessibility standards');
        expect(outlinedSize?.height, greaterThanOrEqualTo(48),
            reason: 'Outlined button height should meet accessibility standards');
        expect(textSize?.height, greaterThanOrEqualTo(48),
            reason: 'Text button height should meet accessibility standards');
        expect(tonalSize?.height, greaterThanOrEqualTo(48),
            reason: 'Tonal button height should meet accessibility standards');
      });
    });

    group('Immutability', () {
      test('returns consistent instances', () {
        final elevated1 = MnesisButtonThemes.elevated;
        final elevated2 = MnesisButtonThemes.elevated;

        final bg1 =
            elevated1.style?.backgroundColor?.resolve(<WidgetState>{});
        final bg2 =
            elevated2.style?.backgroundColor?.resolve(<WidgetState>{});

        expect(bg1, equals(bg2));
      });

      test('all theme getters return non-null', () {
        expect(MnesisButtonThemes.elevated, isNotNull);
        expect(MnesisButtonThemes.outlined, isNotNull);
        expect(MnesisButtonThemes.text, isNotNull);
        expect(MnesisButtonThemes.filledTonal, isNotNull);
        expect(MnesisButtonThemes.icon, isNotNull);
      });
    });
  });
}
