import 'package:flutter/material.dart';

import '../mnesis_colors.dart';
import '../mnesis_spacings.dart';
import '../mnesis_text_styles.dart';

/// Mnesis navigation theme configurations for Material 3.
///
/// This class provides theme configurations for all navigation components:
/// - Navigation bar (Material 3)
/// - Bottom navigation bar (Material 2 legacy)
/// - Navigation rail (large screens)
///
/// ## Design Principles
/// - Consistent orange selection color
/// - Clear selected/unselected states
/// - Elevated surface background
/// - Standard navigation heights
///
/// See also:
/// * [MnesisColors] - Color palette
/// * [MnesisSpacings] - Spacing constants
/// * [MnesisTextStyles] - Typography
class MnesisNavigationThemes {
  MnesisNavigationThemes._(); // Private constructor

  /// Navigation bar theme (Material 3 navigation bar).
  ///
  /// Modern navigation bar with pill-shaped indicator.
  static NavigationBarThemeData get navigationBar {
    return NavigationBarThemeData(
      backgroundColor: MnesisColors.surfaceDark,
      indicatorColor: MnesisColors.orange20,
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
            color: MnesisColors.primaryOrange,
            size: MnesisSpacings.iconSizeMedium,
          );
        }
        return const IconThemeData(
          color: MnesisColors.textSecondary,
          size: MnesisSpacings.iconSizeMedium,
        );
      }),
      height: MnesisSpacings.navigationBarHeight,
      elevation: MnesisSpacings.elevation2,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnesisSpacings.radiusPill),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    );
  }

  /// Bottom navigation bar theme configuration.
  ///
  /// Legacy Material 2 bottom navigation for compatibility.
  static BottomNavigationBarThemeData get bottomNavigationBar {
    return BottomNavigationBarThemeData(
      backgroundColor: MnesisColors.surfaceDark,
      selectedItemColor: MnesisColors.primaryOrange,
      unselectedItemColor: MnesisColors.textSecondary,
      selectedLabelStyle: MnesisTextStyles.labelSmall,
      unselectedLabelStyle: MnesisTextStyles.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: MnesisSpacings.elevation2,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedIconTheme: const IconThemeData(
        color: MnesisColors.primaryOrange,
        size: MnesisSpacings.iconSizeMedium,
      ),
      unselectedIconTheme: const IconThemeData(
        color: MnesisColors.textSecondary,
        size: MnesisSpacings.iconSizeMedium,
      ),
    );
  }

  /// Navigation rail theme configuration.
  ///
  /// For larger screens with side navigation.
  static NavigationRailThemeData get navigationRail {
    return NavigationRailThemeData(
      backgroundColor: MnesisColors.surfaceDark,
      selectedIconTheme: const IconThemeData(
        color: MnesisColors.primaryOrange,
        size: MnesisSpacings.iconSizeMedium,
      ),
      unselectedIconTheme: const IconThemeData(
        color: MnesisColors.textSecondary,
        size: MnesisSpacings.iconSizeMedium,
      ),
      selectedLabelTextStyle: MnesisTextStyles.labelMedium.copyWith(
        color: MnesisColors.primaryOrange,
      ),
      unselectedLabelTextStyle: MnesisTextStyles.labelMedium.copyWith(
        color: MnesisColors.textSecondary,
      ),
      indicatorColor: MnesisColors.orange20,
      elevation: MnesisSpacings.elevation1,
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      minWidth: 72,
      minExtendedWidth: 256,
    );
  }
}