import 'package:flutter/material.dart';

import '../mnesis_colors.dart';
import '../mnesis_spacings.dart';
import '../mnesis_text_styles.dart';

/// Mnesis input field theme configuration for Material 3.
///
/// This class provides the InputDecorationTheme for text fields,
/// featuring pill-shaped borders and consistent styling.
///
/// ## Design Features
/// - Pill-shaped borders (fully rounded)
/// - Filled background for better visibility
/// - Orange focus state
/// - Clear error states
/// - Consistent padding
///
/// See also:
/// * [MnesisColors] - Color palette
/// * [MnesisSpacings] - Spacing constants
/// * [MnesisTextStyles] - Typography
class MnesisInputTheme {
  MnesisInputTheme._(); // Private constructor

  /// Input field decoration theme with pill-shaped borders.
  ///
  /// Creates a filled input style with rounded corners and
  /// clear state indicators for focus, error, and disabled states.
  static InputDecorationTheme get inputDecoration {
    return InputDecorationTheme(
      filled: true,
      fillColor: MnesisColors.surfaceDark,
      contentPadding: EdgeInsets.symmetric(
        horizontal: MnesisSpacings.inputPaddingHorizontal,
        vertical: MnesisSpacings.inputPaddingVertical,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
        borderSide: const BorderSide(
          color: MnesisColors.primaryOrange,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
        borderSide: const BorderSide(
          color: MnesisColors.error,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
        borderSide: const BorderSide(
          color: MnesisColors.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
        borderSide: BorderSide.none,
      ),
      labelStyle: MnesisTextStyles.labelMedium,
      floatingLabelStyle: MnesisTextStyles.labelMedium.copyWith(
        color: MnesisColors.primaryOrange,
      ),
      hintStyle: MnesisTextStyles.labelMedium.copyWith(
        color: MnesisColors.textSecondary,
      ),
      errorStyle: MnesisTextStyles.labelSmall.copyWith(
        color: MnesisColors.error,
      ),
      helperStyle: MnesisTextStyles.labelSmall.copyWith(
        color: MnesisColors.textTertiary,
      ),
      prefixStyle: MnesisTextStyles.bodyMedium,
      suffixStyle: MnesisTextStyles.bodyMedium,
      counterStyle: MnesisTextStyles.labelSmall.copyWith(
        color: MnesisColors.textTertiary,
      ),
      errorMaxLines: 2,
      isDense: false,
      alignLabelWithHint: true,
    );
  }
}