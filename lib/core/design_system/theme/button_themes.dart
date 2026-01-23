import 'package:flutter/material.dart';

import '../mnesis_colors.dart';
import '../mnesis_spacings.dart';
import '../mnesis_text_styles.dart';

/// Mnesis button theme configurations for Material 3.
///
/// This class provides all button theme configurations including:
/// - Elevated buttons (primary action)
/// - Outlined buttons (secondary action)
/// - Text buttons (tertiary action)
/// - Icon buttons (icon-only actions)
///
/// ## Design Principles
/// - Consistent padding and minimum sizes
/// - Rounded corners with radiusLg
/// - Clear disabled states
/// - Orange primary color
///
/// See also:
/// * [MnesisColors] - Color palette
/// * [MnesisSpacings] - Spacing constants
/// * [MnesisTextStyles] - Typography
class MnesisButtonThemes {
  MnesisButtonThemes._(); // Private constructor

  /// Elevated button theme configuration.
  ///
  /// Used for primary actions with orange background.
  static ElevatedButtonThemeData get elevated {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MnesisColors.primaryOrange,
        foregroundColor: MnesisColors.textPrimary,
        disabledBackgroundColor: MnesisColors.orangeDisabled,
        disabledForegroundColor: MnesisColors.textDisabled,
        minimumSize: const Size(88, 48), // Material Design minimum
        padding: EdgeInsets.symmetric(
          horizontal: MnesisSpacings.buttonPaddingHorizontal,
          vertical: MnesisSpacings.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusLg),
        ),
        textStyle: MnesisTextStyles.button,
        elevation: MnesisSpacings.elevation2,
        shadowColor: Colors.black26,
      ),
    );
  }

  /// Outlined button theme configuration.
  ///
  /// Used for secondary actions with orange border.
  static OutlinedButtonThemeData get outlined {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MnesisColors.primaryOrange,
        disabledForegroundColor: MnesisColors.textDisabled,
        minimumSize: const Size(88, 48),
        padding: EdgeInsets.symmetric(
          horizontal: MnesisSpacings.buttonPaddingHorizontal,
          vertical: MnesisSpacings.buttonPaddingVertical,
        ),
        side: const BorderSide(
          color: MnesisColors.primaryOrange,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusLg),
        ),
        textStyle: MnesisTextStyles.button,
      ),
    );
  }

  /// Text button theme configuration.
  ///
  /// Used for tertiary actions with minimal visual weight.
  static TextButtonThemeData get text {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MnesisColors.primaryOrange,
        disabledForegroundColor: MnesisColors.textDisabled,
        minimumSize: const Size(88, 48),
        padding: EdgeInsets.symmetric(
          horizontal: MnesisSpacings.buttonPaddingHorizontal,
          vertical: MnesisSpacings.buttonPaddingVertical,
        ),
        textStyle: MnesisTextStyles.button,
      ),
    );
  }

  /// Filled tonal button theme configuration.
  ///
  /// Used for secondary prominent actions with tonal background.
  static FilledButtonThemeData get filledTonal {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MnesisColors.orange20,
        foregroundColor: MnesisColors.primaryOrange,
        disabledBackgroundColor: MnesisColors.backgroundDarker,
        disabledForegroundColor: MnesisColors.textDisabled,
        minimumSize: const Size(88, 48),
        padding: EdgeInsets.symmetric(
          horizontal: MnesisSpacings.buttonPaddingHorizontal,
          vertical: MnesisSpacings.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusLg),
        ),
        textStyle: MnesisTextStyles.button,
      ),
    );
  }

  /// Icon button theme configuration.
  ///
  /// Used for icon-only actions like navigation and toolbars.
  static IconButtonThemeData get icon {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: MnesisColors.textSecondary,
        disabledForegroundColor: MnesisColors.textDisabled,
        iconSize: MnesisSpacings.iconSizeMedium,
        highlightColor: MnesisColors.orange20,
        padding: EdgeInsets.all(MnesisSpacings.sm),
        minimumSize: const Size(48, 48),
      ),
    );
  }
}