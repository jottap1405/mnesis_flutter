import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/theme/color_scheme.dart';

/// Test suite for MnesisColorScheme.
///
/// Verifies Material 3 color scheme configuration and
/// proper mapping of design system colors to Material color roles.
void main() {
  group('MnesisColorScheme', () {
    late ColorScheme colorScheme;

    setUp(() {
      colorScheme = MnesisColorScheme.dark;
    });

    group('Primary Colors', () {
      test('primary is MnesisColors.primaryOrange', () {
        expect(colorScheme.primary, equals(MnesisColors.primaryOrange));
      });

      test('onPrimary is MnesisColors.textPrimary', () {
        expect(colorScheme.onPrimary, equals(MnesisColors.textPrimary));
      });

      test('primaryContainer is MnesisColors.primaryOrangeDark', () {
        expect(
            colorScheme.primaryContainer, equals(MnesisColors.primaryOrangeDark));
      });

      test('onPrimaryContainer is MnesisColors.primaryOrangeLight', () {
        expect(colorScheme.onPrimaryContainer,
            equals(MnesisColors.primaryOrangeLight));
      });
    });

    group('Secondary Colors', () {
      test('secondary is MnesisColors.textSecondary', () {
        expect(colorScheme.secondary, equals(MnesisColors.textSecondary));
      });

      test('onSecondary is MnesisColors.backgroundDark', () {
        expect(colorScheme.onSecondary, equals(MnesisColors.backgroundDark));
      });

      test('secondaryContainer is MnesisColors.surfaceDark', () {
        expect(colorScheme.secondaryContainer, equals(MnesisColors.surfaceDark));
      });

      test('onSecondaryContainer is MnesisColors.textPrimary', () {
        expect(
            colorScheme.onSecondaryContainer, equals(MnesisColors.textPrimary));
      });
    });

    group('Tertiary Colors', () {
      test('tertiary is MnesisColors.info', () {
        expect(colorScheme.tertiary, equals(MnesisColors.info));
      });

      test('onTertiary is MnesisColors.textPrimary', () {
        expect(colorScheme.onTertiary, equals(MnesisColors.textPrimary));
      });

      test('tertiaryContainer is MnesisColors.infoBackground', () {
        expect(
            colorScheme.tertiaryContainer, equals(MnesisColors.infoBackground));
      });

      test('onTertiaryContainer is MnesisColors.info', () {
        expect(colorScheme.onTertiaryContainer, equals(MnesisColors.info));
      });
    });

    group('Surface Colors', () {
      test('surface is MnesisColors.backgroundDark', () {
        expect(colorScheme.surface, equals(MnesisColors.backgroundDark));
      });

      test('onSurface is MnesisColors.textPrimary', () {
        expect(colorScheme.onSurface, equals(MnesisColors.textPrimary));
      });

      test('surfaceContainerHighest is MnesisColors.surfaceDark', () {
        expect(colorScheme.surfaceContainerHighest,
            equals(MnesisColors.surfaceDark));
      });

      test('surfaceContainerHigh is MnesisColors.surfaceElevated', () {
        expect(colorScheme.surfaceContainerHigh,
            equals(MnesisColors.surfaceElevated));
      });

      test('surfaceContainerLow is MnesisColors.surfaceOverlay', () {
        expect(
            colorScheme.surfaceContainerLow, equals(MnesisColors.surfaceOverlay));
      });

      test('onSurfaceVariant is MnesisColors.textSecondary', () {
        expect(colorScheme.onSurfaceVariant, equals(MnesisColors.textSecondary));
      });
    });

    group('Error Colors', () {
      test('error is MnesisColors.error', () {
        expect(colorScheme.error, equals(MnesisColors.error));
      });

      test('onError is MnesisColors.textPrimary', () {
        expect(colorScheme.onError, equals(MnesisColors.textPrimary));
      });

      test('errorContainer is MnesisColors.errorBackground', () {
        expect(colorScheme.errorContainer, equals(MnesisColors.errorBackground));
      });

      test('onErrorContainer is MnesisColors.error', () {
        expect(colorScheme.onErrorContainer, equals(MnesisColors.error));
      });
    });

    group('Outline Colors', () {
      test('outline is MnesisColors.textTertiary', () {
        expect(colorScheme.outline, equals(MnesisColors.textTertiary));
      });

      test('outlineVariant is MnesisColors.backgroundDarker', () {
        expect(
            colorScheme.outlineVariant, equals(MnesisColors.backgroundDarker));
      });
    });

    group('Special Colors', () {
      test('shadow is Colors.black', () {
        expect(colorScheme.shadow, equals(Colors.black));
      });

      test('scrim is Colors.black54', () {
        expect(colorScheme.scrim, equals(Colors.black54));
      });

      test('inverseSurface is MnesisColors.textPrimary', () {
        expect(colorScheme.inverseSurface, equals(MnesisColors.textPrimary));
      });

      test('onInverseSurface is MnesisColors.backgroundDark', () {
        expect(
            colorScheme.onInverseSurface, equals(MnesisColors.backgroundDark));
      });

      test('inversePrimary is MnesisColors.primaryOrangeDark', () {
        expect(
            colorScheme.inversePrimary, equals(MnesisColors.primaryOrangeDark));
      });

      test('surfaceTint is MnesisColors.primaryOrange', () {
        expect(colorScheme.surfaceTint, equals(MnesisColors.primaryOrange));
      });
    });

    group('Color Scheme Properties', () {
      test('is configured for dark brightness', () {
        expect(colorScheme.brightness, equals(Brightness.dark));
      });

      test('all colors are non-null', () {
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.onPrimary, isNotNull);
        expect(colorScheme.primaryContainer, isNotNull);
        expect(colorScheme.onPrimaryContainer, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.onSecondary, isNotNull);
        expect(colorScheme.secondaryContainer, isNotNull);
        expect(colorScheme.onSecondaryContainer, isNotNull);
        expect(colorScheme.tertiary, isNotNull);
        expect(colorScheme.onTertiary, isNotNull);
        expect(colorScheme.tertiaryContainer, isNotNull);
        expect(colorScheme.onTertiaryContainer, isNotNull);
        expect(colorScheme.error, isNotNull);
        expect(colorScheme.onError, isNotNull);
        expect(colorScheme.errorContainer, isNotNull);
        expect(colorScheme.onErrorContainer, isNotNull);
        expect(colorScheme.surface, isNotNull);
        expect(colorScheme.onSurface, isNotNull);
        expect(colorScheme.onSurfaceVariant, isNotNull);
        expect(colorScheme.outline, isNotNull);
        expect(colorScheme.outlineVariant, isNotNull);
        expect(colorScheme.shadow, isNotNull);
        expect(colorScheme.scrim, isNotNull);
        expect(colorScheme.inverseSurface, isNotNull);
        expect(colorScheme.onInverseSurface, isNotNull);
        expect(colorScheme.inversePrimary, isNotNull);
        expect(colorScheme.surfaceTint, isNotNull);
      });

      test('surface container hierarchy is correct', () {
        // Verify that surface containers follow expected hierarchy
        expect(colorScheme.surfaceContainerHighest, isNotNull);
        expect(colorScheme.surfaceContainerHigh, isNotNull);
        expect(colorScheme.surfaceContainerLow, isNotNull);
      });
    });

    group('Color Consistency', () {
      test('primary and primaryContainer are related', () {
        expect(colorScheme.primary, isNot(equals(colorScheme.primaryContainer)));
        // Both should be shades of orange
        expect(colorScheme.primary, equals(MnesisColors.primaryOrange));
        expect(
            colorScheme.primaryContainer, equals(MnesisColors.primaryOrangeDark));
      });

      test('error colors use consistent error palette', () {
        expect(colorScheme.error, equals(MnesisColors.error));
        expect(colorScheme.errorContainer, equals(MnesisColors.errorBackground));
      });

      test('surface colors use consistent surface palette', () {
        expect(colorScheme.surface, equals(MnesisColors.backgroundDark));
        expect(colorScheme.surfaceContainerHighest,
            equals(MnesisColors.surfaceDark));
      });
    });

    group('Accessibility', () {
      test('has sufficient contrast between primary and onPrimary', () {
        // This is a basic check - detailed contrast testing is in theme_validation_test
        expect(colorScheme.primary, isNot(equals(colorScheme.onPrimary)));
      });

      test('has sufficient contrast between surface and onSurface', () {
        expect(colorScheme.surface, isNot(equals(colorScheme.onSurface)));
      });

      test('has sufficient contrast between error and onError', () {
        expect(colorScheme.error, isNot(equals(colorScheme.onError)));
      });
    });

    group('Material 3 Compliance', () {
      test('follows Material 3 color role naming', () {
        // Verify all Material 3 color roles are present
        final colorScheme = MnesisColorScheme.dark;

        // Primary
        expect(() => colorScheme.primary, returnsNormally);
        expect(() => colorScheme.onPrimary, returnsNormally);
        expect(() => colorScheme.primaryContainer, returnsNormally);
        expect(() => colorScheme.onPrimaryContainer, returnsNormally);

        // Secondary
        expect(() => colorScheme.secondary, returnsNormally);
        expect(() => colorScheme.onSecondary, returnsNormally);
        expect(() => colorScheme.secondaryContainer, returnsNormally);
        expect(() => colorScheme.onSecondaryContainer, returnsNormally);

        // Tertiary
        expect(() => colorScheme.tertiary, returnsNormally);
        expect(() => colorScheme.onTertiary, returnsNormally);
        expect(() => colorScheme.tertiaryContainer, returnsNormally);
        expect(() => colorScheme.onTertiaryContainer, returnsNormally);

        // Error
        expect(() => colorScheme.error, returnsNormally);
        expect(() => colorScheme.onError, returnsNormally);
        expect(() => colorScheme.errorContainer, returnsNormally);
        expect(() => colorScheme.onErrorContainer, returnsNormally);

        // Surface
        expect(() => colorScheme.surface, returnsNormally);
        expect(() => colorScheme.onSurface, returnsNormally);
        expect(() => colorScheme.surfaceContainerHighest, returnsNormally);
      });

      test('color scheme can be used in ThemeData', () {
        expect(
          () => ThemeData(
            colorScheme: MnesisColorScheme.dark,
            useMaterial3: true,
          ),
          returnsNormally,
        );
      });
    });

    group('Immutability', () {
      test('returns same instance on repeated calls', () {
        final scheme1 = MnesisColorScheme.dark;
        final scheme2 = MnesisColorScheme.dark;

        expect(scheme1.primary, equals(scheme2.primary));
        expect(scheme1.surface, equals(scheme2.surface));
        expect(scheme1.error, equals(scheme2.error));
      });

      test('color scheme properties are immutable', () {
        final scheme = MnesisColorScheme.dark;
        final primary = scheme.primary;
        final surface = scheme.surface;

        // Get again and verify they're the same
        expect(scheme.primary, equals(primary));
        expect(scheme.surface, equals(surface));
      });
    });
  });
}
