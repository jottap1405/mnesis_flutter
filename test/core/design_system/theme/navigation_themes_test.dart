import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_spacings.dart';
import 'package:mnesis_flutter/core/design_system/theme/navigation_themes.dart';

/// Test suite for MnesisNavigationThemes.
///
/// Verifies navigation theme configurations for:
/// Navigation Bar, Bottom Navigation Bar, and Navigation Rail.
void main() {
  group('MnesisNavigationThemes', () {
    group('Navigation Bar Theme', () {
      late NavigationBarThemeData theme;

      setUp(() {
        theme = MnesisNavigationThemes.navigationBar;
      });

      test('has proper background color', () {
        expect(theme.backgroundColor, equals(MnesisColors.surfaceDark));
      });

      test('has proper indicator color', () {
        expect(theme.indicatorColor, equals(MnesisColors.orange20));
      });

      test('has proper height', () {
        expect(theme.height, equals(MnesisSpacings.navigationBarHeight));
      });

      test('has proper elevation', () {
        expect(theme.elevation, equals(MnesisSpacings.elevation2));
      });

      test('has pill-shaped indicator', () {
        expect(theme.indicatorShape, isA<RoundedRectangleBorder>());
        final shape = theme.indicatorShape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(BorderRadius.circular(MnesisSpacings.radiusPill)),
        );
      });

      test('shows labels always', () {
        expect(
          theme.labelBehavior,
          equals(NavigationDestinationLabelBehavior.alwaysShow),
        );
      });

      test('selected label has orange color', () {
        final selectedStyle = theme.labelTextStyle
            ?.resolve(<WidgetState>{WidgetState.selected});
        expect(selectedStyle?.color, equals(MnesisColors.primaryOrange));
      });

      test('unselected label has secondary color', () {
        final unselectedStyle =
            theme.labelTextStyle?.resolve(<WidgetState>{});
        expect(unselectedStyle?.color, equals(MnesisColors.textSecondary));
      });

      test('selected icon has orange color and proper size', () {
        final selectedIcon =
            theme.iconTheme?.resolve(<WidgetState>{WidgetState.selected});
        expect(selectedIcon?.color, equals(MnesisColors.primaryOrange));
        expect(selectedIcon?.size, equals(MnesisSpacings.iconSizeMedium));
      });

      test('unselected icon has secondary color and proper size', () {
        final unselectedIcon = theme.iconTheme?.resolve(<WidgetState>{});
        expect(unselectedIcon?.color, equals(MnesisColors.textSecondary));
        expect(unselectedIcon?.size, equals(MnesisSpacings.iconSizeMedium));
      });
    });

    group('Bottom Navigation Bar Theme', () {
      late BottomNavigationBarThemeData theme;

      setUp(() {
        theme = MnesisNavigationThemes.bottomNavigationBar;
      });

      test('has proper background color', () {
        expect(theme.backgroundColor, equals(MnesisColors.surfaceDark));
      });

      test('has proper selected item color', () {
        expect(theme.selectedItemColor, equals(MnesisColors.primaryOrange));
      });

      test('has proper unselected item color', () {
        expect(theme.unselectedItemColor, equals(MnesisColors.textSecondary));
      });

      test('has proper elevation', () {
        expect(theme.elevation, equals(MnesisSpacings.elevation2));
      });

      test('uses fixed type', () {
        expect(theme.type, equals(BottomNavigationBarType.fixed));
      });

      test('shows selected labels', () {
        expect(theme.showSelectedLabels, isTrue);
      });

      test('shows unselected labels', () {
        expect(theme.showUnselectedLabels, isTrue);
      });

      test('selected icon theme is configured', () {
        expect(theme.selectedIconTheme, isNotNull);
        expect(
          theme.selectedIconTheme?.color,
          equals(MnesisColors.primaryOrange),
        );
        expect(
          theme.selectedIconTheme?.size,
          equals(MnesisSpacings.iconSizeMedium),
        );
      });

      test('unselected icon theme is configured', () {
        expect(theme.unselectedIconTheme, isNotNull);
        expect(
          theme.unselectedIconTheme?.color,
          equals(MnesisColors.textSecondary),
        );
        expect(
          theme.unselectedIconTheme?.size,
          equals(MnesisSpacings.iconSizeMedium),
        );
      });

      test('label styles are configured', () {
        expect(theme.selectedLabelStyle, isNotNull);
        expect(theme.unselectedLabelStyle, isNotNull);
      });
    });

    group('Navigation Rail Theme', () {
      late NavigationRailThemeData theme;

      setUp(() {
        theme = MnesisNavigationThemes.navigationRail;
      });

      test('has proper background color', () {
        expect(theme.backgroundColor, equals(MnesisColors.surfaceDark));
      });

      test('has proper indicator color', () {
        expect(theme.indicatorColor, equals(MnesisColors.orange20));
      });

      test('has proper elevation', () {
        expect(theme.elevation, equals(MnesisSpacings.elevation1));
      });

      test('shows all labels', () {
        expect(theme.labelType, equals(NavigationRailLabelType.all));
      });

      test('uses indicator', () {
        expect(theme.useIndicator, isTrue);
      });

      test('has proper minimum width', () {
        expect(theme.minWidth, equals(72));
      });

      test('has proper minimum extended width', () {
        expect(theme.minExtendedWidth, equals(256));
      });

      test('selected icon theme is configured', () {
        expect(theme.selectedIconTheme, isNotNull);
        expect(
          theme.selectedIconTheme?.color,
          equals(MnesisColors.primaryOrange),
        );
        expect(
          theme.selectedIconTheme?.size,
          equals(MnesisSpacings.iconSizeMedium),
        );
      });

      test('unselected icon theme is configured', () {
        expect(theme.unselectedIconTheme, isNotNull);
        expect(
          theme.unselectedIconTheme?.color,
          equals(MnesisColors.textSecondary),
        );
        expect(
          theme.unselectedIconTheme?.size,
          equals(MnesisSpacings.iconSizeMedium),
        );
      });

      test('selected label has orange color', () {
        expect(theme.selectedLabelTextStyle, isNotNull);
        expect(
          theme.selectedLabelTextStyle?.color,
          equals(MnesisColors.primaryOrange),
        );
      });

      test('unselected label has secondary color', () {
        expect(theme.unselectedLabelTextStyle, isNotNull);
        expect(
          theme.unselectedLabelTextStyle?.color,
          equals(MnesisColors.textSecondary),
        );
      });
    });

    group('Navigation Theme Consistency', () {
      test('all navigation types use same background color', () {
        final navBar = MnesisNavigationThemes.navigationBar;
        final bottomNav = MnesisNavigationThemes.bottomNavigationBar;
        final navRail = MnesisNavigationThemes.navigationRail;

        expect(navBar.backgroundColor, equals(MnesisColors.surfaceDark));
        expect(bottomNav.backgroundColor, equals(MnesisColors.surfaceDark));
        expect(navRail.backgroundColor, equals(MnesisColors.surfaceDark));
      });

      test('all navigation types use same selected color', () {
        final navBar = MnesisNavigationThemes.navigationBar;
        final bottomNav = MnesisNavigationThemes.bottomNavigationBar;
        final navRail = MnesisNavigationThemes.navigationRail;

        final navBarSelected = navBar.iconTheme
            ?.resolve(<WidgetState>{WidgetState.selected})?.color;
        final bottomNavSelected = bottomNav.selectedItemColor;
        final navRailSelected = navRail.selectedIconTheme?.color;

        expect(navBarSelected, equals(MnesisColors.primaryOrange));
        expect(bottomNavSelected, equals(MnesisColors.primaryOrange));
        expect(navRailSelected, equals(MnesisColors.primaryOrange));
      });

      test('all navigation types use same unselected color', () {
        final navBar = MnesisNavigationThemes.navigationBar;
        final bottomNav = MnesisNavigationThemes.bottomNavigationBar;
        final navRail = MnesisNavigationThemes.navigationRail;

        final navBarUnselected =
            navBar.iconTheme?.resolve(<WidgetState>{})?.color;
        final bottomNavUnselected = bottomNav.unselectedItemColor;
        final navRailUnselected = navRail.unselectedIconTheme?.color;

        expect(navBarUnselected, equals(MnesisColors.textSecondary));
        expect(bottomNavUnselected, equals(MnesisColors.textSecondary));
        expect(navRailUnselected, equals(MnesisColors.textSecondary));
      });

      test('all navigation types use same icon size', () {
        final navBar = MnesisNavigationThemes.navigationBar;
        final bottomNav = MnesisNavigationThemes.bottomNavigationBar;
        final navRail = MnesisNavigationThemes.navigationRail;

        final navBarSize =
            navBar.iconTheme?.resolve(<WidgetState>{})?.size;
        final bottomNavSize = bottomNav.unselectedIconTheme?.size;
        final navRailSize = navRail.unselectedIconTheme?.size;

        expect(navBarSize, equals(MnesisSpacings.iconSizeMedium));
        expect(bottomNavSize, equals(MnesisSpacings.iconSizeMedium));
        expect(navRailSize, equals(MnesisSpacings.iconSizeMedium));
      });

      test('nav bar and nav rail use same indicator color', () {
        final navBar = MnesisNavigationThemes.navigationBar;
        final navRail = MnesisNavigationThemes.navigationRail;

        expect(navBar.indicatorColor, equals(MnesisColors.orange20));
        expect(navRail.indicatorColor, equals(MnesisColors.orange20));
      });
    });

    group('Accessibility', () {
      test('selected state is visually distinct in nav bar', () {
        final theme = MnesisNavigationThemes.navigationBar;
        final selectedIcon =
            theme.iconTheme?.resolve(<WidgetState>{WidgetState.selected});
        final unselectedIcon = theme.iconTheme?.resolve(<WidgetState>{});

        expect(selectedIcon?.color, equals(MnesisColors.primaryOrange));
        expect(unselectedIcon?.color, equals(MnesisColors.textSecondary));
        expect(
          selectedIcon?.color,
          isNot(equals(unselectedIcon?.color)),
        );
      });

      test('selected state is visually distinct in bottom nav', () {
        final theme = MnesisNavigationThemes.bottomNavigationBar;

        expect(theme.selectedItemColor, equals(MnesisColors.primaryOrange));
        expect(theme.unselectedItemColor, equals(MnesisColors.textSecondary));
        expect(
          theme.selectedItemColor,
          isNot(equals(theme.unselectedItemColor)),
        );
      });

      test('selected state is visually distinct in nav rail', () {
        final theme = MnesisNavigationThemes.navigationRail;

        expect(
          theme.selectedIconTheme?.color,
          equals(MnesisColors.primaryOrange),
        );
        expect(
          theme.unselectedIconTheme?.color,
          equals(MnesisColors.textSecondary),
        );
        expect(
          theme.selectedIconTheme?.color,
          isNot(equals(theme.unselectedIconTheme?.color)),
        );
      });

      test('labels are always shown for better accessibility', () {
        final navBar = MnesisNavigationThemes.navigationBar;
        final bottomNav = MnesisNavigationThemes.bottomNavigationBar;
        final navRail = MnesisNavigationThemes.navigationRail;

        expect(
          navBar.labelBehavior,
          equals(NavigationDestinationLabelBehavior.alwaysShow),
        );
        expect(bottomNav.showSelectedLabels, isTrue);
        expect(bottomNav.showUnselectedLabels, isTrue);
        expect(navRail.labelType, equals(NavigationRailLabelType.all));
      });
    });

    group('Immutability', () {
      test('returns consistent navigation bar instance', () {
        final theme1 = MnesisNavigationThemes.navigationBar;
        final theme2 = MnesisNavigationThemes.navigationBar;

        expect(theme1.backgroundColor, equals(theme2.backgroundColor));
        expect(theme1.indicatorColor, equals(theme2.indicatorColor));
        expect(theme1.height, equals(theme2.height));
      });

      test('returns consistent bottom nav instance', () {
        final theme1 = MnesisNavigationThemes.bottomNavigationBar;
        final theme2 = MnesisNavigationThemes.bottomNavigationBar;

        expect(theme1.backgroundColor, equals(theme2.backgroundColor));
        expect(theme1.selectedItemColor, equals(theme2.selectedItemColor));
        expect(theme1.elevation, equals(theme2.elevation));
      });

      test('returns consistent nav rail instance', () {
        final theme1 = MnesisNavigationThemes.navigationRail;
        final theme2 = MnesisNavigationThemes.navigationRail;

        expect(theme1.backgroundColor, equals(theme2.backgroundColor));
        expect(theme1.indicatorColor, equals(theme2.indicatorColor));
        expect(theme1.minWidth, equals(theme2.minWidth));
      });

      test('all theme getters return non-null', () {
        expect(MnesisNavigationThemes.navigationBar, isNotNull);
        expect(MnesisNavigationThemes.bottomNavigationBar, isNotNull);
        expect(MnesisNavigationThemes.navigationRail, isNotNull);
      });
    });

    group('Material 3 Compatibility', () {
      test('navigation bar can be used in Material 3 theme', () {
        expect(
          () => ThemeData(
            navigationBarTheme: MnesisNavigationThemes.navigationBar,
            useMaterial3: true,
          ),
          returnsNormally,
        );
      });

      test('bottom navigation bar can be used in Material 3 theme', () {
        expect(
          () => ThemeData(
            bottomNavigationBarTheme:
                MnesisNavigationThemes.bottomNavigationBar,
            useMaterial3: true,
          ),
          returnsNormally,
        );
      });

      test('navigation rail can be used in Material 3 theme', () {
        expect(
          () => ThemeData(
            navigationRailTheme: MnesisNavigationThemes.navigationRail,
            useMaterial3: true,
          ),
          returnsNormally,
        );
      });
    });
  });
}
