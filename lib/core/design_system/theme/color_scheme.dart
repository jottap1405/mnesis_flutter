import 'package:flutter/material.dart';

import '../mnesis_colors.dart';

/// Mnesis color scheme configuration for Material 3.
///
/// This class provides the ColorScheme configuration for the Mnesis dark theme,
/// mapping design system colors to Material 3 color roles.
///
/// ## Color Roles
/// - Primary: Orange accent (#FF7043)
/// - Secondary: Muted gray for supporting elements
/// - Tertiary: Info blue for informational states
/// - Error: Red for error states
/// - Surface: Dark elevated surfaces
///
/// See also:
/// * [MnesisColors] - Core color palette
/// * [ColorScheme] - Material 3 color system
class MnesisColorScheme {
  MnesisColorScheme._(); // Private constructor

  /// Material 3 dark color scheme configuration.
  ///
  /// Maps Mnesis design system colors to Material 3 color roles
  /// following Material Design 3 guidelines.
  static ColorScheme get dark {
    return ColorScheme.dark(
      // Primary colors
      primary: MnesisColors.primaryOrange,
      onPrimary: MnesisColors.textPrimary,
      primaryContainer: MnesisColors.primaryOrangeDark,
      onPrimaryContainer: MnesisColors.primaryOrangeLight,

      // Secondary colors
      secondary: MnesisColors.textSecondary,
      onSecondary: MnesisColors.backgroundDark,
      secondaryContainer: MnesisColors.surfaceDark,
      onSecondaryContainer: MnesisColors.textPrimary,

      // Tertiary colors
      tertiary: MnesisColors.info,
      onTertiary: MnesisColors.textPrimary,
      tertiaryContainer: MnesisColors.infoBackground,
      onTertiaryContainer: MnesisColors.info,

      // Background colors
      surface: MnesisColors.backgroundDark,
      onSurface: MnesisColors.textPrimary,

      // Surface colors
      surfaceContainerHighest: MnesisColors.surfaceDark,
      surfaceContainerHigh: MnesisColors.surfaceElevated,
      surfaceContainerLow: MnesisColors.surfaceOverlay,
      onSurfaceVariant: MnesisColors.textSecondary,

      // Error colors
      error: MnesisColors.error,
      onError: MnesisColors.textPrimary,
      errorContainer: MnesisColors.errorBackground,
      onErrorContainer: MnesisColors.error,

      // Outline colors
      outline: MnesisColors.textTertiary,
      outlineVariant: MnesisColors.backgroundDarker,

      // Other colors
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: MnesisColors.textPrimary,
      onInverseSurface: MnesisColors.backgroundDark,
      inversePrimary: MnesisColors.primaryOrangeDark,
      surfaceTint: MnesisColors.primaryOrange,
    );
  }
}