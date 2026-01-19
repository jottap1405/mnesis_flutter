import 'package:flutter/material.dart';
import 'mnesis_colors.dart';
import 'mnesis_text_styles.dart';
import 'mnesis_spacings.dart';

/// Mnesis complete dark theme configuration.
///
/// This theme configures all Material Design components with Mnesis design tokens:
/// - **Material 3**: Modern Material Design with enhanced components
/// - **Dark-First**: Optimized for medical environments and reduced eye strain
/// - **Complete Coverage**: All component themes configured for consistency
///
/// ## Theme Structure
/// - **ColorScheme**: Complete semantic color mapping
/// - **TextTheme**: Typography scale from MnesisTextStyles
/// - **Component Themes**: Button, Input, Card, Dialog, AppBar, Navigation, etc.
///
/// ## Usage
/// ```dart
/// MaterialApp(
///   theme: MnesisTheme.darkTheme,
///   home: ChatScreen(),
/// )
/// ```
///
/// ## Accessibility
/// - WCAG AA+ contrast ratios
/// - Sufficient touch targets (48dp minimum)
/// - High-contrast focus indicators
///
/// See also:
/// * [MnesisColors] for color system
/// * [MnesisTextStyles] for typography
/// * [MnesisSpacings] for spacing system
/// * Technical docs: `documentation/mnesis/MNESIS_DESIGN_SYSTEM.md`
class MnesisTheme {
  MnesisTheme._(); // Private constructor to prevent instantiation

  /// Main Mnesis dark theme configuration.
  ///
  /// This is the complete production-ready theme with all component
  /// customizations following Mnesis design system.
  static ThemeData get darkTheme {
    return ThemeData(
      // ========================================================================
      // BASE THEME CONFIGURATION
      // ========================================================================

      /// Dark theme brightness
      brightness: Brightness.dark,

      /// Enable Material 3 design system
      useMaterial3: true,

      // ========================================================================
      // COLOR SCHEME
      // ========================================================================

      colorScheme: ColorScheme.dark(
        // Primary colors
        primary: MnesisColors.primaryOrange,
        primaryContainer: MnesisColors.primaryOrangeDark,
        onPrimary: MnesisColors.textOnOrange,
        onPrimaryContainer: MnesisColors.textOnOrange,

        // Secondary colors
        secondary: MnesisColors.surfaceDark,
        secondaryContainer: MnesisColors.surfaceElevated,
        onSecondary: MnesisColors.textPrimary,
        onSecondaryContainer: MnesisColors.textPrimary,

        // Tertiary colors (using surface variants)
        tertiary: MnesisColors.surfaceElevated,
        tertiaryContainer: MnesisColors.surfaceOverlay,
        onTertiary: MnesisColors.textPrimary,
        onTertiaryContainer: MnesisColors.textPrimary,

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
        onError: MnesisColors.textOnOrange,
        errorContainer: MnesisColors.errorBackground,
        onErrorContainer: MnesisColors.error,

        // Outline colors
        outline: MnesisColors.borderDefault,
        outlineVariant: MnesisColors.borderSubtle,

        // Shadow
        shadow: const Color(0x4D000000), // 30% black opacity
        scrim: const Color(0x80000000), // 50% black opacity
      ),

      // ========================================================================
      // TYPOGRAPHY
      // ========================================================================

      textTheme: TextTheme(
        // Display styles
        displayLarge: MnesisTextStyles.displayLarge,
        displayMedium: MnesisTextStyles.displayMedium,
        displaySmall: MnesisTextStyles.displaySmall,

        // Headline styles
        headlineLarge: MnesisTextStyles.headlineLarge,
        headlineMedium: MnesisTextStyles.headlineMedium,
        headlineSmall: MnesisTextStyles.headlineSmall,

        // Body styles
        bodyLarge: MnesisTextStyles.bodyLarge,
        bodyMedium: MnesisTextStyles.bodyMedium,
        bodySmall: MnesisTextStyles.bodySmall,

        // Label styles
        labelLarge: MnesisTextStyles.labelLarge,
        labelMedium: MnesisTextStyles.labelMedium,
        labelSmall: MnesisTextStyles.labelSmall,

        // Title styles (mapped to headline)
        titleLarge: MnesisTextStyles.headlineLarge,
        titleMedium: MnesisTextStyles.headlineMedium,
        titleSmall: MnesisTextStyles.headlineSmall,
      ),

      // ========================================================================
      // SCAFFOLD
      // ========================================================================

      scaffoldBackgroundColor: MnesisColors.backgroundDark,

      // ========================================================================
      // APP BAR
      // ========================================================================

      appBarTheme: AppBarTheme(
        backgroundColor: MnesisColors.backgroundDark,
        foregroundColor: MnesisColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: MnesisTextStyles.headlineMedium,
        iconTheme: const IconThemeData(
          color: MnesisColors.textPrimary,
          size: MnesisSpacings.iconSizeMedium,
        ),
        actionsIconTheme: const IconThemeData(
          color: MnesisColors.textPrimary,
          size: MnesisSpacings.iconSizeMedium,
        ),
      ),

      // ========================================================================
      // NAVIGATION
      // ========================================================================

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MnesisColors.surfaceDark,
        selectedItemColor: MnesisColors.primaryOrange,
        unselectedItemColor: MnesisColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: MnesisSpacings.elevation3,
        selectedLabelStyle: MnesisTextStyles.labelSmall,
        unselectedLabelStyle: MnesisTextStyles.labelSmall,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MnesisColors.surfaceDark,
        indicatorColor: MnesisColors.primaryOrange,
        elevation: MnesisSpacings.elevation3,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MnesisTextStyles.labelSmall.copyWith(
              color: MnesisColors.primaryOrange,
            );
          }
          return MnesisTextStyles.labelSmall.copyWith(
            color: MnesisColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: MnesisColors.textOnOrange,
              size: MnesisSpacings.iconSizeMedium,
            );
          }
          return const IconThemeData(
            color: MnesisColors.textSecondary,
            size: MnesisSpacings.iconSizeMedium,
          );
        }),
      ),

      // ========================================================================
      // CARDS & SURFACES
      // ========================================================================

      cardTheme: CardThemeData(
        color: MnesisColors.surfaceDark,
        elevation: MnesisSpacings.elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
        ),
        margin: const EdgeInsets.all(MnesisSpacings.md),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: MnesisColors.surfaceElevated,
        elevation: MnesisSpacings.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusLg),
        ),
        titleTextStyle: MnesisTextStyles.headlineMedium,
        contentTextStyle: MnesisTextStyles.bodyMedium,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: MnesisColors.surfaceElevated,
        elevation: MnesisSpacings.elevation4,
        modalBackgroundColor: MnesisColors.surfaceElevated,
        modalElevation: MnesisSpacings.elevation4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MnesisSpacings.radiusLg),
          ),
        ),
      ),

      // ========================================================================
      // BUTTONS
      // ========================================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return MnesisColors.orangeDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return MnesisColors.orangePressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return MnesisColors.orangeHover;
            }
            return MnesisColors.primaryOrange;
          }),
          foregroundColor: const WidgetStatePropertyAll(
            MnesisColors.textOnOrange,
          ),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return 0;
            }
            if (states.contains(WidgetState.pressed)) {
              return MnesisSpacings.elevation1;
            }
            return MnesisSpacings.elevation2;
          }),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.buttonPaddingHorizontal,
              vertical: MnesisSpacings.buttonPaddingVertical,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MnesisSpacings.radiusSm),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(MnesisTextStyles.labelLarge),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return MnesisColors.surfaceElevated;
            }
            if (states.contains(WidgetState.hovered)) {
              return MnesisColors.surfaceDark;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return MnesisColors.textDisabled;
            }
            return MnesisColors.primaryOrange;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(
                color: MnesisColors.borderSubtle,
                width: 1,
              );
            }
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(
                color: MnesisColors.primaryOrange,
                width: 2,
              );
            }
            return const BorderSide(
              color: MnesisColors.borderDefault,
              width: 1,
            );
          }),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.buttonPaddingHorizontal,
              vertical: MnesisSpacings.buttonPaddingVertical,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MnesisSpacings.radiusSm),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(MnesisTextStyles.labelLarge),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return MnesisColors.textDisabled;
            }
            return MnesisColors.primaryOrange;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return MnesisColors.surfaceElevated;
            }
            if (states.contains(WidgetState.hovered)) {
              return MnesisColors.surfaceDark;
            }
            return Colors.transparent;
          }),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.lg,
              vertical: MnesisSpacings.sm,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MnesisSpacings.radiusSm),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(MnesisTextStyles.labelLarge),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return MnesisColors.primaryOrange;
            }
            if (states.contains(WidgetState.disabled)) {
              return MnesisColors.textDisabled;
            }
            return MnesisColors.textSecondary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return MnesisColors.surfaceElevated;
            }
            if (states.contains(WidgetState.pressed)) {
              return MnesisColors.surfaceElevated;
            }
            if (states.contains(WidgetState.hovered)) {
              return MnesisColors.surfaceDark;
            }
            return Colors.transparent;
          }),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.all(MnesisSpacings.sm),
          ),
          iconSize: const WidgetStatePropertyAll(
            MnesisSpacings.iconSizeMedium,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MnesisColors.primaryOrange,
        foregroundColor: MnesisColors.textOnOrange,
        elevation: MnesisSpacings.elevation3,
        focusElevation: MnesisSpacings.elevation4,
        hoverElevation: MnesisSpacings.elevation4,
        shape: CircleBorder(),
      ),

      // ========================================================================
      // INPUT FIELDS
      // ========================================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MnesisColors.backgroundDarker,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MnesisSpacings.inputPaddingHorizontal,
          vertical: MnesisSpacings.inputPaddingVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
          borderSide: const BorderSide(
            color: MnesisColors.borderDefault,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
          borderSide: const BorderSide(
            color: MnesisColors.borderDefault,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
          borderSide: const BorderSide(
            color: MnesisColors.primaryOrange,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
          borderSide: const BorderSide(
            color: MnesisColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
          borderSide: const BorderSide(
            color: MnesisColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
          borderSide: const BorderSide(
            color: MnesisColors.borderSubtle,
            width: 1,
          ),
        ),
        labelStyle: MnesisTextStyles.bodyMedium.copyWith(
          color: MnesisColors.textSecondary,
        ),
        hintStyle: MnesisTextStyles.bodyMedium.copyWith(
          color: MnesisColors.textTertiary,
        ),
        errorStyle: MnesisTextStyles.bodySmall.copyWith(
          color: MnesisColors.textError,
        ),
        helperStyle: MnesisTextStyles.bodySmall.copyWith(
          color: MnesisColors.textSecondary,
        ),
        prefixIconColor: MnesisColors.textSecondary,
        suffixIconColor: MnesisColors.textSecondary,
      ),

      // ========================================================================
      // LIST & LIST TILES
      // ========================================================================

      listTileTheme: const ListTileThemeData(
        tileColor: MnesisColors.surfaceDark,
        selectedTileColor: MnesisColors.surfaceElevated,
        iconColor: MnesisColors.textSecondary,
        selectedColor: MnesisColors.primaryOrange,
        textColor: MnesisColors.textPrimary,
        titleTextStyle: MnesisTextStyles.bodyMedium,
        subtitleTextStyle: MnesisTextStyles.bodySmall,
        contentPadding: EdgeInsets.symmetric(
          horizontal: MnesisSpacings.listItemPaddingHorizontal,
          vertical: MnesisSpacings.listItemPaddingVertical,
        ),
        minVerticalPadding: MnesisSpacings.sm,
        minLeadingWidth: MnesisSpacings.iconSizeMedium,
      ),

      // ========================================================================
      // DIVIDERS
      // ========================================================================

      dividerTheme: const DividerThemeData(
        color: MnesisColors.divider,
        thickness: 1,
        space: MnesisSpacings.lg,
      ),

      // ========================================================================
      // CHIPS
      // ========================================================================

      chipTheme: ChipThemeData(
        backgroundColor: MnesisColors.surfaceDark,
        selectedColor: MnesisColors.primaryOrange,
        disabledColor: MnesisColors.surfaceDark,
        deleteIconColor: MnesisColors.textSecondary,
        labelStyle: MnesisTextStyles.labelMedium,
        secondaryLabelStyle: MnesisTextStyles.labelSmall,
        padding: const EdgeInsets.symmetric(
          horizontal: MnesisSpacings.md,
          vertical: MnesisSpacings.sm,
        ),
        labelPadding: const EdgeInsets.symmetric(
          horizontal: MnesisSpacings.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
          side: const BorderSide(
            color: MnesisColors.borderDefault,
            width: 1,
          ),
        ),
      ),

      // ========================================================================
      // PROGRESS INDICATORS
      // ========================================================================

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MnesisColors.primaryOrange,
        linearTrackColor: MnesisColors.surfaceDark,
        circularTrackColor: MnesisColors.surfaceDark,
        linearMinHeight: 4,
      ),

      // ========================================================================
      // TOOLTIPS
      // ========================================================================

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: MnesisColors.surfaceOverlay,
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusSm),
        ),
        textStyle: MnesisTextStyles.bodySmall.copyWith(
          color: MnesisColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MnesisSpacings.md,
          vertical: MnesisSpacings.sm,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),

      // ========================================================================
      // SNACKBARS
      // ========================================================================

      snackBarTheme: SnackBarThemeData(
        backgroundColor: MnesisColors.surfaceOverlay,
        contentTextStyle: MnesisTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisSpacings.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: MnesisSpacings.elevation3,
      ),

      // ========================================================================
      // ICONS
      // ========================================================================

      iconTheme: const IconThemeData(
        color: MnesisColors.textSecondary,
        size: MnesisSpacings.iconSizeMedium,
      ),

      primaryIconTheme: const IconThemeData(
        color: MnesisColors.primaryOrange,
        size: MnesisSpacings.iconSizeMedium,
      ),

      // ========================================================================
      // SWITCHES & CHECKBOXES
      // ========================================================================

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MnesisColors.textOnOrange;
          }
          return MnesisColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MnesisColors.primaryOrange;
          }
          return MnesisColors.surfaceDark;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(
          MnesisColors.borderDefault,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MnesisColors.primaryOrange;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(MnesisColors.textOnOrange),
        side: const BorderSide(
          color: MnesisColors.borderDefault,
          width: 2,
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MnesisColors.primaryOrange;
          }
          return MnesisColors.borderDefault;
        }),
      ),

      // ========================================================================
      // SLIDER
      // ========================================================================

      sliderTheme: const SliderThemeData(
        activeTrackColor: MnesisColors.primaryOrange,
        inactiveTrackColor: MnesisColors.surfaceDark,
        thumbColor: MnesisColors.primaryOrange,
        overlayColor: Color(0x33FF7043), // 20% orange opacity
        valueIndicatorColor: MnesisColors.surfaceOverlay,
        valueIndicatorTextStyle: MnesisTextStyles.labelSmall,
      ),
    );
  }
}
