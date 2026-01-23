import 'package:flutter/material.dart';

import '../mnesis_colors.dart';
import '../mnesis_text_styles.dart';
import 'button_themes.dart';
import 'color_scheme.dart';
import 'component_themes.dart';
import 'input_theme.dart';
import 'navigation_themes.dart';

/// Mnesis application theme configuration for Material 3.
///
/// This class provides the complete Material Design 3 theme configuration
/// for the Mnesis medical AI assistant application, orchestrating all
/// theme components from the modular theme system.
///
/// ## Architecture
/// The theme is split into focused modules:
/// - [MnesisColorScheme] - Color configuration
/// - [MnesisButtonThemes] - All button variants
/// - [MnesisInputTheme] - Text field styling
/// - [MnesisNavigationThemes] - Navigation components
/// - [MnesisComponentThemes] - Other UI components
/// - [MnesisThemeValidation] - Runtime validation
///
/// ## Features
/// - Dark-first design optimized for medical environments
/// - Orange (#FF7043) primary accent color
/// - Material 3 components with custom styling
/// - WCAG AA/AAA compliant color combinations
/// - Consistent spacing using 4px grid system
///
/// ## Usage
/// ```dart
/// MaterialApp(
///   theme: MnesisTheme.darkTheme,
///   themeMode: ThemeMode.dark,
/// )
/// ```
///
/// ## Validation (Debug Mode)
/// ```dart
/// // In main.dart
/// assert(() {
///   MnesisThemeValidation.validateTheme(MnesisTheme.darkTheme);
///   return true;
/// }());
/// ```
///
/// See also:
/// * [MnesisColors] - Core color palette
/// * [MnesisTextStyles] - Typography system
/// * [MnesisSpacings] - Spacing constants
/// * [ThemeData] - Flutter theme data
class MnesisTheme {
  MnesisTheme._(); // Private constructor

  /// Dark theme for Mnesis application (primary theme).
  ///
  /// This is the main theme used throughout the application.
  /// It implements Material 3 design with custom Mnesis branding,
  /// composing all theme modules into a complete [ThemeData].
  ///
  /// The theme includes:
  /// - Dark color scheme with orange accent
  /// - Complete component theming
  /// - Custom typography
  /// - Material 3 features
  static ThemeData get darkTheme {
    return ThemeData(
      // Enable Material 3 design system
      useMaterial3: true,

      // Color scheme configuration
      colorScheme: MnesisColorScheme.dark,

      // Typography configuration
      textTheme: _textTheme,

      // Button themes
      elevatedButtonTheme: MnesisButtonThemes.elevated,
      outlinedButtonTheme: MnesisButtonThemes.outlined,
      textButtonTheme: MnesisButtonThemes.text,
      iconButtonTheme: MnesisButtonThemes.icon,

      // Input decoration
      inputDecorationTheme: MnesisInputTheme.inputDecoration,

      // Navigation themes
      navigationBarTheme: MnesisNavigationThemes.navigationBar,
      bottomNavigationBarTheme: MnesisNavigationThemes.bottomNavigationBar,
      navigationRailTheme: MnesisNavigationThemes.navigationRail,

      // Component themes
      cardTheme: MnesisComponentThemes.card,
      dialogTheme: MnesisComponentThemes.dialog,
      bottomSheetTheme: MnesisComponentThemes.bottomSheet,
      appBarTheme: MnesisComponentThemes.appBar,
      snackBarTheme: MnesisComponentThemes.snackBar,
      chipTheme: MnesisComponentThemes.chip,
      floatingActionButtonTheme: MnesisComponentThemes.floatingActionButton,
      dividerTheme: MnesisComponentThemes.divider,
      listTileTheme: MnesisComponentThemes.listTile,
      switchTheme: MnesisComponentThemes.switchTheme,
      checkboxTheme: MnesisComponentThemes.checkbox,
      radioTheme: MnesisComponentThemes.radio,
      sliderTheme: MnesisComponentThemes.slider,
      tooltipTheme: MnesisComponentThemes.tooltip,
      progressIndicatorTheme: MnesisComponentThemes.progressIndicator,
      iconTheme: MnesisComponentThemes.icon,

      // Scaffold background
      scaffoldBackgroundColor: MnesisColors.backgroundDark,

      // Platform configuration
      platform: TargetPlatform.android,
    );
  }

  /// Complete text theme mapping Material 3 to MnesisTextStyles.
  static TextTheme get _textTheme {
    return TextTheme(
      // Display styles (largest)
      displayLarge: MnesisTextStyles.displayLarge,
      displayMedium: MnesisTextStyles.displayMedium,
      displaySmall: MnesisTextStyles.displaySmall,

      // Headline styles
      headlineLarge: MnesisTextStyles.headlineLarge,
      headlineMedium: MnesisTextStyles.headlineMedium,
      headlineSmall: MnesisTextStyles.headlineSmall,

      // Title styles
      titleLarge: MnesisTextStyles.headlineMedium,
      titleMedium: MnesisTextStyles.headlineSmall,
      titleSmall: MnesisTextStyles.labelLarge,

      // Body styles
      bodyLarge: MnesisTextStyles.bodyLarge,
      bodyMedium: MnesisTextStyles.bodyMedium,
      bodySmall: MnesisTextStyles.bodySmall,

      // Label styles
      labelLarge: MnesisTextStyles.labelLarge,
      labelMedium: MnesisTextStyles.labelMedium,
      labelSmall: MnesisTextStyles.labelSmall,
    );
  }
}