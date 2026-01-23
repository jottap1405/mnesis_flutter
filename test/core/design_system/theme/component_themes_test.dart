import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_spacings.dart';
import 'package:mnesis_flutter/core/design_system/theme/component_themes.dart';

/// Test suite for MnesisComponentThemes.
///
/// Verifies component theme configurations for:
/// Card, Dialog, BottomSheet, AppBar, SnackBar, Chip, FAB,
/// Divider, ListTile, Switch, Checkbox, Radio, Slider, Tooltip,
/// ProgressIndicator, Icon, and SystemUiOverlay.
void main() {
  group('MnesisComponentThemes', () {
    group('Card Theme', () {
      late CardThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.card;
      });

      test('has proper background color', () {
        expect(theme.color, equals(MnesisColors.surfaceDark));
      });

      test('has subtle elevation', () {
        expect(theme.elevation, equals(MnesisSpacings.elevation1));
      });

      test('has proper margin', () {
        expect(theme.margin, equals(EdgeInsets.all(MnesisSpacings.sm)));
      });

      test('has rounded corners', () {
        expect(theme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusMd)),
        );
      });

      test('has anti-alias clipping', () {
        expect(theme.clipBehavior, equals(Clip.antiAlias));
      });
    });

    group('Dialog Theme', () {
      late DialogThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.dialog;
      });

      test('has proper background color', () {
        expect(theme.backgroundColor, equals(MnesisColors.surfaceDark));
      });

      test('has elevated appearance', () {
        expect(theme.elevation, equals(MnesisSpacings.elevation3));
      });

      test('has rounded corners', () {
        expect(theme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusLg)),
        );
      });

      test('has proper title text style', () {
        expect(theme.titleTextStyle, isNotNull);
      });

      test('has proper content text style', () {
        expect(theme.contentTextStyle, isNotNull);
      });

      test('has proper actions padding', () {
        expect(
          theme.actionsPadding,
          equals(EdgeInsets.all(MnesisSpacings.lg)),
        );
      });

      test('has proper icon color', () {
        expect(theme.iconColor, equals(MnesisColors.textSecondary));
      });
    });

    group('Bottom Sheet Theme', () {
      late BottomSheetThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.bottomSheet;
      });

      test('has proper background color', () {
        expect(theme.backgroundColor, equals(MnesisColors.surfaceDark));
      });

      test('has rounded top corners', () {
        expect(theme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.vertical(
            top: Radius.circular(MnesisSpacings.radiusLg),
          )),
        );
      });

      test('has proper elevation', () {
        expect(theme.elevation, equals(MnesisSpacings.elevation3));
      });

      test('has drag handle configured', () {
        expect(theme.dragHandleColor, equals(MnesisColors.textTertiary));
        expect(theme.dragHandleSize, equals(const Size(32, 4)));
      });
    });

    group('AppBar Theme', () {
      late AppBarTheme theme;

      setUp(() {
        theme = MnesisComponentThemes.appBar;
      });

      test('has transparent background', () {
        expect(theme.backgroundColor, equals(MnesisColors.backgroundDark));
      });

      test('has proper foreground color', () {
        expect(theme.foregroundColor, equals(MnesisColors.textPrimary));
      });

      test('has no elevation', () {
        expect(theme.elevation, equals(0));
        expect(theme.scrolledUnderElevation, equals(0));
      });

      test('title is not centered', () {
        expect(theme.centerTitle, isFalse);
      });

      test('has proper title text style', () {
        expect(theme.titleTextStyle, isNotNull);
      });

      test('has proper toolbar text style', () {
        expect(theme.toolbarTextStyle, isNotNull);
      });

      test('has proper icon theme', () {
        expect(theme.iconTheme?.color, equals(MnesisColors.textPrimary));
        expect(theme.iconTheme?.size, equals(MnesisSpacings.iconSizeMedium));
      });

      test('has proper actions icon theme', () {
        expect(
          theme.actionsIconTheme?.color,
          equals(MnesisColors.textSecondary),
        );
        expect(
          theme.actionsIconTheme?.size,
          equals(MnesisSpacings.iconSizeMedium),
        );
      });

      test('has system overlay style configured', () {
        expect(theme.systemOverlayStyle, isNotNull);
      });
    });

    group('SnackBar Theme', () {
      late SnackBarThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.snackBar;
      });

      test('has proper background color', () {
        expect(theme.backgroundColor, equals(MnesisColors.surfaceElevated));
      });

      test('has proper content text style', () {
        expect(theme.contentTextStyle, isNotNull);
        expect(theme.contentTextStyle?.color, equals(MnesisColors.textPrimary));
      });

      test('has orange action color', () {
        expect(theme.actionTextColor, equals(MnesisColors.primaryOrange));
      });

      test('has disabled action color', () {
        expect(
          theme.disabledActionTextColor,
          equals(MnesisColors.textDisabled),
        );
      });

      test('has rounded corners', () {
        expect(theme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusMd)),
        );
      });

      test('uses floating behavior', () {
        expect(theme.behavior, equals(SnackBarBehavior.floating));
      });

      test('has proper elevation', () {
        expect(theme.elevation, equals(MnesisSpacings.elevation3));
      });

      test('does not show close icon by default', () {
        expect(theme.showCloseIcon, isFalse);
      });
    });

    group('Chip Theme', () {
      late ChipThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.chip;
      });

      test('has proper background color', () {
        expect(theme.backgroundColor, equals(MnesisColors.surfaceDark));
      });

      test('has proper selected color', () {
        expect(theme.selectedColor, equals(MnesisColors.orange20));
      });

      test('has proper disabled color', () {
        expect(theme.disabledColor, equals(MnesisColors.backgroundDarker));
      });

      test('has proper delete icon color', () {
        expect(theme.deleteIconColor, equals(MnesisColors.textSecondary));
      });

      test('has proper padding', () {
        expect(
          theme.padding,
          equals(EdgeInsets.symmetric(
            horizontal: MnesisSpacings.md,
            vertical: MnesisSpacings.sm,
          )),
        );
      });

      test('has pill-shaped borders', () {
        expect(theme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
        );
      });

      test('has no border side', () {
        expect(theme.side, equals(BorderSide.none));
      });

      test('has proper icon theme', () {
        expect(theme.iconTheme?.color, equals(MnesisColors.textSecondary));
        expect(theme.iconTheme?.size, equals(MnesisSpacings.iconSizeSmall));
      });
    });

    group('FloatingActionButton Theme', () {
      late FloatingActionButtonThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.floatingActionButton;
      });

      test('has orange background', () {
        expect(theme.backgroundColor, equals(MnesisColors.primaryOrange));
      });

      test('has proper foreground color', () {
        expect(theme.foregroundColor, equals(MnesisColors.textPrimary));
      });

      test('has proper elevation', () {
        expect(theme.elevation, equals(MnesisSpacings.elevation3));
        expect(theme.focusElevation, equals(MnesisSpacings.elevation3));
        expect(theme.highlightElevation, equals(MnesisSpacings.elevation3));
        expect(theme.hoverElevation, equals(MnesisSpacings.elevation3));
      });

      test('has no elevation when disabled', () {
        expect(theme.disabledElevation, equals(0));
      });

      test('has rounded shape', () {
        expect(theme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusLg)),
        );
      });

      test('has standard FAB size', () {
        expect(theme.sizeConstraints, isNotNull);
        expect(
          theme.sizeConstraints,
          equals(const BoxConstraints.tightFor(width: 56, height: 56)),
        );
      });
    });

    group('Divider Theme', () {
      late DividerThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.divider;
      });

      test('has subtle color', () {
        expect(theme.color, isNotNull);
      });

      test('has proper thickness', () {
        expect(theme.thickness, equals(1));
      });

      test('has proper space', () {
        expect(theme.space, equals(MnesisSpacings.lg));
      });

      test('has no indent', () {
        expect(theme.indent, equals(0));
        expect(theme.endIndent, equals(0));
      });
    });

    group('ListTile Theme', () {
      late ListTileThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.listTile;
      });

      test('has transparent background', () {
        expect(theme.tileColor, equals(Colors.transparent));
      });

      test('has proper selected tile color', () {
        expect(theme.selectedTileColor, isNotNull);
      });

      test('has proper icon color', () {
        expect(theme.iconColor, equals(MnesisColors.textSecondary));
      });

      test('has proper text color', () {
        expect(theme.textColor, equals(MnesisColors.textPrimary));
      });

      test('has proper content padding', () {
        expect(
          theme.contentPadding,
          equals(EdgeInsets.symmetric(
            horizontal: MnesisSpacings.lg,
            vertical: MnesisSpacings.sm,
          )),
        );
      });

      test('has proper minimum vertical padding', () {
        expect(theme.minVerticalPadding, equals(MnesisSpacings.sm));
      });

      test('has rounded shape', () {
        expect(theme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusMd)),
        );
      });

      test('has proper selected color', () {
        expect(theme.selectedColor, equals(MnesisColors.primaryOrange));
      });

      test('has feedback enabled', () {
        expect(theme.enableFeedback, isTrue);
      });

      test('is not dense', () {
        expect(theme.dense, isFalse);
      });
    });

    group('Switch Theme', () {
      late SwitchThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.switchTheme;
      });

      test('selected thumb is orange', () {
        final selectedThumb = theme.thumbColor
            ?.resolve(<WidgetState>{WidgetState.selected});
        expect(selectedThumb, equals(MnesisColors.primaryOrange));
      });

      test('unselected thumb is secondary', () {
        final unselectedThumb = theme.thumbColor?.resolve(<WidgetState>{});
        expect(unselectedThumb, equals(MnesisColors.textSecondary));
      });

      test('selected track color is configured', () {
        final selectedTrack = theme.trackColor
            ?.resolve(<WidgetState>{WidgetState.selected});
        expect(selectedTrack, equals(MnesisColors.orange50));
      });

      test('unselected track color is configured', () {
        final unselectedTrack = theme.trackColor?.resolve(<WidgetState>{});
        expect(unselectedTrack, equals(MnesisColors.textTertiary));
      });

      test('has transparent track outline', () {
        final outline = theme.trackOutlineColor?.resolve(<WidgetState>{});
        expect(outline, equals(Colors.transparent));
      });

      test('uses padded tap target size', () {
        expect(
          theme.materialTapTargetSize,
          equals(MaterialTapTargetSize.padded),
        );
      });
    });

    group('Checkbox Theme', () {
      late CheckboxThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.checkbox;
      });

      test('selected checkbox is orange', () {
        final selectedFill = theme.fillColor
            ?.resolve(<WidgetState>{WidgetState.selected});
        expect(selectedFill, equals(MnesisColors.primaryOrange));
      });

      test('unselected checkbox is transparent', () {
        final unselectedFill = theme.fillColor?.resolve(<WidgetState>{});
        expect(unselectedFill, equals(Colors.transparent));
      });

      test('has proper check color', () {
        final checkColor = theme.checkColor?.resolve(<WidgetState>{});
        expect(checkColor, equals(MnesisColors.textPrimary));
      });

      test('has border', () {
        expect(theme.side, isNotNull);
        expect(theme.side?.color, equals(MnesisColors.textSecondary));
        expect(theme.side?.width, equals(2));
      });

      test('has rounded corners', () {
        expect(theme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusSm)),
        );
      });

      test('uses padded tap target size', () {
        expect(
          theme.materialTapTargetSize,
          equals(MaterialTapTargetSize.padded),
        );
      });
    });

    group('Radio Theme', () {
      late RadioThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.radio;
      });

      test('selected radio is orange', () {
        final selectedFill = theme.fillColor
            ?.resolve(<WidgetState>{WidgetState.selected});
        expect(selectedFill, equals(MnesisColors.primaryOrange));
      });

      test('unselected radio is secondary', () {
        final unselectedFill = theme.fillColor?.resolve(<WidgetState>{});
        expect(unselectedFill, equals(MnesisColors.textSecondary));
      });

      test('uses padded tap target size', () {
        expect(
          theme.materialTapTargetSize,
          equals(MaterialTapTargetSize.padded),
        );
      });
    });

    group('Slider Theme', () {
      late SliderThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.slider;
      });

      test('active track is orange', () {
        expect(theme.activeTrackColor, equals(MnesisColors.primaryOrange));
      });

      test('inactive track is surface dark', () {
        expect(theme.inactiveTrackColor, equals(MnesisColors.surfaceDark));
      });

      test('thumb is orange', () {
        expect(theme.thumbColor, equals(MnesisColors.primaryOrange));
      });

      test('overlay color is configured', () {
        expect(theme.overlayColor, equals(MnesisColors.orange20));
      });

      test('value indicator is configured', () {
        expect(
          theme.valueIndicatorColor,
          equals(MnesisColors.surfaceElevated),
        );
        expect(theme.valueIndicatorTextStyle, isNotNull);
      });

      test('has proper track height', () {
        expect(theme.trackHeight, equals(4));
      });

      test('has proper thumb shape', () {
        expect(theme.thumbShape, isA<RoundSliderThumbShape>());
      });

      test('has proper overlay shape', () {
        expect(theme.overlayShape, isA<RoundSliderOverlayShape>());
      });
    });

    group('Tooltip Theme', () {
      late TooltipThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.tooltip;
      });

      test('has proper decoration', () {
        expect(theme.decoration, isA<BoxDecoration>());
      });

      test('has proper text style', () {
        expect(theme.textStyle, isNotNull);
        expect(theme.textStyle?.color, equals(MnesisColors.textPrimary));
      });

      test('has proper padding', () {
        expect(
          theme.padding,
          equals(EdgeInsets.symmetric(
            horizontal: MnesisSpacings.md,
            vertical: MnesisSpacings.sm,
          )),
        );
      });

      test('has proper margin', () {
        expect(theme.margin, equals(EdgeInsets.all(MnesisSpacings.sm)));
      });

      test('prefers below', () {
        expect(theme.preferBelow, isTrue);
      });

      test('has proper vertical offset', () {
        expect(theme.verticalOffset, equals(MnesisSpacings.lg));
      });

      test('has proper wait duration', () {
        expect(theme.waitDuration, equals(const Duration(seconds: 1)));
      });

      test('has proper show duration', () {
        expect(theme.showDuration, equals(const Duration(seconds: 2)));
      });
    });

    group('Progress Indicator Theme', () {
      late ProgressIndicatorThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.progressIndicator;
      });

      test('has orange color', () {
        expect(theme.color, equals(MnesisColors.primaryOrange));
      });

      test('has proper linear track color', () {
        expect(theme.linearTrackColor, equals(MnesisColors.surfaceDark));
      });

      test('has proper circular track color', () {
        expect(theme.circularTrackColor, equals(MnesisColors.surfaceDark));
      });

      test('has proper minimum height', () {
        expect(theme.linearMinHeight, equals(4));
      });
    });

    group('Icon Theme', () {
      late IconThemeData theme;

      setUp(() {
        theme = MnesisComponentThemes.icon;
      });

      test('has proper color', () {
        expect(theme.color, equals(MnesisColors.textPrimary));
      });

      test('has proper size', () {
        expect(theme.size, equals(MnesisSpacings.iconSizeMedium));
      });

      test('has proper fill', () {
        expect(theme.fill, equals(0));
      });

      test('has proper weight', () {
        expect(theme.weight, equals(400));
      });

      test('has proper grade', () {
        expect(theme.grade, equals(0));
      });

      test('has proper optical size', () {
        expect(theme.opticalSize, equals(24));
      });
    });

    group('System UI Overlay Style', () {
      late SystemUiOverlayStyle style;

      setUp(() {
        style = MnesisComponentThemes.systemUiOverlayStyle;
      });

      test('has transparent status bar', () {
        expect(style.statusBarColor, equals(Colors.transparent));
      });

      test('has light status bar icons', () {
        expect(style.statusBarIconBrightness, equals(Brightness.light));
      });

      test('has dark status bar brightness', () {
        expect(style.statusBarBrightness, equals(Brightness.dark));
      });

      test('has proper navigation bar color', () {
        expect(
          style.systemNavigationBarColor,
          equals(MnesisColors.backgroundDark),
        );
      });

      test('has light navigation bar icons', () {
        expect(
          style.systemNavigationBarIconBrightness,
          equals(Brightness.light),
        );
      });

      test('has transparent navigation bar divider', () {
        expect(
          style.systemNavigationBarDividerColor,
          equals(Colors.transparent),
        );
      });
    });

    group('Theme Consistency', () {
      test('all surface components use surfaceDark background', () {
        expect(
          MnesisComponentThemes.card.color,
          equals(MnesisColors.surfaceDark),
        );
        expect(
          MnesisComponentThemes.dialog.backgroundColor,
          equals(MnesisColors.surfaceDark),
        );
        expect(
          MnesisComponentThemes.bottomSheet.backgroundColor,
          equals(MnesisColors.surfaceDark),
        );
        expect(
          MnesisComponentThemes.chip.backgroundColor,
          equals(MnesisColors.surfaceDark),
        );
      });

      test('selection components use orange color', () {
        final switchSelected = MnesisComponentThemes.switchTheme.thumbColor
            ?.resolve(<WidgetState>{WidgetState.selected});
        final checkboxSelected = MnesisComponentThemes.checkbox.fillColor
            ?.resolve(<WidgetState>{WidgetState.selected});
        final radioSelected = MnesisComponentThemes.radio.fillColor
            ?.resolve(<WidgetState>{WidgetState.selected});

        expect(switchSelected, equals(MnesisColors.primaryOrange));
        expect(checkboxSelected, equals(MnesisColors.primaryOrange));
        expect(radioSelected, equals(MnesisColors.primaryOrange));
      });

      test('all themes are non-null', () {
        expect(MnesisComponentThemes.card, isNotNull);
        expect(MnesisComponentThemes.dialog, isNotNull);
        expect(MnesisComponentThemes.bottomSheet, isNotNull);
        expect(MnesisComponentThemes.appBar, isNotNull);
        expect(MnesisComponentThemes.snackBar, isNotNull);
        expect(MnesisComponentThemes.chip, isNotNull);
        expect(MnesisComponentThemes.floatingActionButton, isNotNull);
        expect(MnesisComponentThemes.divider, isNotNull);
        expect(MnesisComponentThemes.listTile, isNotNull);
        expect(MnesisComponentThemes.switchTheme, isNotNull);
        expect(MnesisComponentThemes.checkbox, isNotNull);
        expect(MnesisComponentThemes.radio, isNotNull);
        expect(MnesisComponentThemes.slider, isNotNull);
        expect(MnesisComponentThemes.tooltip, isNotNull);
        expect(MnesisComponentThemes.progressIndicator, isNotNull);
        expect(MnesisComponentThemes.icon, isNotNull);
        expect(MnesisComponentThemes.systemUiOverlayStyle, isNotNull);
      });
    });
  });
}
