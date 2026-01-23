import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mnesis_colors.dart';
import '../mnesis_spacings.dart';
import '../mnesis_text_styles.dart';

/// Mnesis component theme configurations for Material 3.
///
/// This class provides theme configurations for various UI components:
/// - Card, Dialog, BottomSheet
/// - AppBar, SnackBar, Tooltip
/// - Chip, FAB, Divider
/// - ListTile, Switch, Checkbox, Radio
/// - Slider, ProgressIndicator
///
/// ## Design Principles
/// - Consistent rounded corners
/// - Elevated surfaces for depth
/// - Orange accent for interactive elements
/// - Dark theme optimized
///
/// See also:
/// * [MnesisColors] - Color palette
/// * [MnesisSpacings] - Spacing constants
/// * [MnesisTextStyles] - Typography
class MnesisComponentThemes {
  MnesisComponentThemes._(); // Private constructor

  /// Card theme with subtle elevation and rounded corners.
  static CardThemeData get card {
    return CardThemeData(
      color: MnesisColors.surfaceDark,
      elevation: MnesisSpacings.elevation1,
      margin: EdgeInsets.all(MnesisSpacings.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// Dialog theme with rounded corners and elevated surface.
  static DialogThemeData get dialog {
    return DialogThemeData(
      backgroundColor: MnesisColors.surfaceDark,
      elevation: MnesisSpacings.elevation3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusLg),
      ),
      titleTextStyle: MnesisTextStyles.headlineMedium,
      contentTextStyle: MnesisTextStyles.bodyMedium,
      actionsPadding: EdgeInsets.all(MnesisSpacings.lg),
      iconColor: MnesisColors.textSecondary,
    );
  }

  /// Bottom sheet theme configuration.
  static BottomSheetThemeData get bottomSheet {
    return BottomSheetThemeData(
      backgroundColor: MnesisColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MnesisSpacings.radiusLg),
        ),
      ),
      elevation: MnesisSpacings.elevation3,
      dragHandleColor: MnesisColors.textTertiary,
      dragHandleSize: const Size(32, 4),
    );
  }

  /// App bar theme with transparent background and no elevation.
  static AppBarTheme get appBar {
    return AppBarTheme(
      backgroundColor: MnesisColors.backgroundDark,
      foregroundColor: MnesisColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: MnesisTextStyles.headlineMedium,
      toolbarTextStyle: MnesisTextStyles.bodyLarge,
      iconTheme: const IconThemeData(
        color: MnesisColors.textPrimary,
        size: MnesisSpacings.iconSizeMedium,
      ),
      actionsIconTheme: const IconThemeData(
        color: MnesisColors.textSecondary,
        size: MnesisSpacings.iconSizeMedium,
      ),
      systemOverlayStyle: systemUiOverlayStyle,
    );
  }

  /// Snackbar theme with floating behavior and rounded corners.
  static SnackBarThemeData get snackBar {
    return SnackBarThemeData(
      backgroundColor: MnesisColors.surfaceElevated,
      contentTextStyle: MnesisTextStyles.bodyMedium.copyWith(
        color: MnesisColors.textPrimary,
      ),
      actionTextColor: MnesisColors.primaryOrange,
      disabledActionTextColor: MnesisColors.textDisabled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: MnesisSpacings.elevation3,
      width: null, // Full width minus margins
      showCloseIcon: false,
    );
  }

  /// Chip theme with pill-shaped borders.
  static ChipThemeData get chip {
    return ChipThemeData(
      backgroundColor: MnesisColors.surfaceDark,
      selectedColor: MnesisColors.orange20,
      disabledColor: MnesisColors.backgroundDarker,
      deleteIconColor: MnesisColors.textSecondary,
      labelStyle: MnesisTextStyles.labelMedium,
      secondaryLabelStyle: MnesisTextStyles.labelSmall,
      padding: EdgeInsets.symmetric(
        horizontal: MnesisSpacings.md,
        vertical: MnesisSpacings.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
      ),
      side: BorderSide.none,
      iconTheme: const IconThemeData(
        color: MnesisColors.textSecondary,
        size: MnesisSpacings.iconSizeSmall,
      ),
    );
  }

  /// Floating action button theme configuration.
  static FloatingActionButtonThemeData get floatingActionButton {
    return FloatingActionButtonThemeData(
      backgroundColor: MnesisColors.primaryOrange,
      foregroundColor: MnesisColors.textPrimary,
      disabledElevation: 0,
      elevation: MnesisSpacings.elevation3,
      focusElevation: MnesisSpacings.elevation3,
      highlightElevation: MnesisSpacings.elevation3,
      hoverElevation: MnesisSpacings.elevation3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusLg),
      ),
      sizeConstraints: const BoxConstraints.tightFor(
        width: 56,
        height: 56,
      ),
    );
  }

  /// Divider theme with subtle color.
  static DividerThemeData get divider {
    return DividerThemeData(
      color: MnesisColors.textTertiary.withValues(alpha: 0.2),
      thickness: 1,
      space: MnesisSpacings.lg,
      indent: 0,
      endIndent: 0,
    );
  }

  /// List tile theme with consistent padding and colors.
  static ListTileThemeData get listTile {
    return ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: MnesisColors.primaryOrange.withValues(alpha: 0.1),
      iconColor: MnesisColors.textSecondary,
      textColor: MnesisColors.textPrimary,
      titleTextStyle: MnesisTextStyles.bodyLarge,
      subtitleTextStyle: MnesisTextStyles.bodySmall.copyWith(
        color: MnesisColors.textSecondary,
      ),
      leadingAndTrailingTextStyle: MnesisTextStyles.labelMedium,
      contentPadding: EdgeInsets.symmetric(
        horizontal: MnesisSpacings.lg,
        vertical: MnesisSpacings.sm,
      ),
      minVerticalPadding: MnesisSpacings.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
      ),
      selectedColor: MnesisColors.primaryOrange,
      enableFeedback: true,
      dense: false,
    );
  }

  /// Switch theme configuration.
  static SwitchThemeData get switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MnesisColors.primaryOrange;
        }
        return MnesisColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MnesisColors.orange50;
        }
        return MnesisColors.textTertiary;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  /// Checkbox theme configuration.
  static CheckboxThemeData get checkbox {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MnesisColors.primaryOrange;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(MnesisColors.textPrimary),
      side: const BorderSide(
        color: MnesisColors.textSecondary,
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusSm),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  /// Radio button theme configuration.
  static RadioThemeData get radio {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MnesisColors.primaryOrange;
        }
        return MnesisColors.textSecondary;
      }),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  /// Slider theme configuration.
  static SliderThemeData get slider {
    return SliderThemeData(
      activeTrackColor: MnesisColors.primaryOrange,
      inactiveTrackColor: MnesisColors.surfaceDark,
      thumbColor: MnesisColors.primaryOrange,
      overlayColor: MnesisColors.orange20,
      valueIndicatorColor: MnesisColors.surfaceElevated,
      valueIndicatorTextStyle: MnesisTextStyles.labelSmall,
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
    );
  }

  /// Tooltip theme configuration.
  static TooltipThemeData get tooltip {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: MnesisColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusSm),
      ),
      textStyle: MnesisTextStyles.labelSmall.copyWith(
        color: MnesisColors.textPrimary,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: MnesisSpacings.md,
        vertical: MnesisSpacings.sm,
      ),
      margin: EdgeInsets.all(MnesisSpacings.sm),
      preferBelow: true,
      verticalOffset: MnesisSpacings.lg,
      waitDuration: const Duration(seconds: 1),
      showDuration: const Duration(seconds: 2),
    );
  }

  /// Progress indicator theme configuration.
  static ProgressIndicatorThemeData get progressIndicator {
    return const ProgressIndicatorThemeData(
      color: MnesisColors.primaryOrange,
      linearTrackColor: MnesisColors.surfaceDark,
      circularTrackColor: MnesisColors.surfaceDark,
      linearMinHeight: 4,
    );
  }

  /// Icon theme for general icons.
  static IconThemeData get icon {
    return const IconThemeData(
      color: MnesisColors.textPrimary,
      size: MnesisSpacings.iconSizeMedium,
      fill: 0,
      weight: 400,
      grade: 0,
      opticalSize: 24,
    );
  }

  /// System UI overlay style for dark theme.
  ///
  /// Configures status bar and navigation bar appearance.
  static SystemUiOverlayStyle get systemUiOverlayStyle {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: MnesisColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }
}