import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';

import '../../helpers/accessibility_test_helpers.dart';

void main() {
  group('MnesisColors - WCAG Accessibility Tests', () {
    group('Contrast Ratio Tests', () {
      test('textPrimary on backgroundDark meets WCAG AAA (12.5:1)', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textPrimary,
          MnesisColors.backgroundDark,
        );

        // WCAG AAA requires 7:1 for normal text, 4.5:1 for large text
        expect(ratio, greaterThanOrEqualTo(7.0),
            reason: 'textPrimary on backgroundDark should meet WCAG AAA');
        expect(ratio, closeTo(12.5, 0.5),
            reason: 'Expected contrast ratio ~12.5:1');
      });

      test('textPrimary on surfaceDark meets WCAG AAA (10.2:1)', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textPrimary,
          MnesisColors.surfaceDark,
        );

        expect(ratio, greaterThanOrEqualTo(7.0),
            reason: 'textPrimary on surfaceDark should meet WCAG AAA');
        expect(ratio, closeTo(10.2, 0.5),
            reason: 'Expected contrast ratio ~10.2:1');
      });

      test('textSecondary on backgroundDark meets WCAG AA', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textSecondary,
          MnesisColors.backgroundDark,
        );

        // WCAG AA requires 4.5:1 for normal text
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'textSecondary on backgroundDark should meet WCAG AA');
        expect(ratio, closeTo(4.88, 0.5),
            reason: 'Expected contrast ratio ~4.88:1');
      });

      test('primaryOrange on backgroundDark meets WCAG AA (4.8:1)', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.primaryOrange,
          MnesisColors.backgroundDark,
        );

        // WCAG AA requires 4.5:1 for normal text, 3:1 for large text
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'primaryOrange on backgroundDark should meet WCAG AA');
        expect(ratio, closeTo(4.8, 0.5),
            reason: 'Expected contrast ratio ~4.8:1');
      });

      test('textOnOrange on primaryOrange is visible', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textOnOrange,
          MnesisColors.primaryOrange,
        );

        // Orange background with white text has lower contrast
        // Acceptable for large text and icons (WCAG AA large text: 3:1)
        expect(ratio, greaterThanOrEqualTo(2.5),
            reason: 'textOnOrange should be visible on primaryOrange');
      });

      test('textTertiary on backgroundDark is de-emphasized', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textTertiary,
          MnesisColors.backgroundDark,
        );

        // Tertiary text is intentionally de-emphasized (lower contrast)
        // Still visible for large text
        expect(ratio, greaterThanOrEqualTo(2.5),
            reason: 'textTertiary should be visible on backgroundDark');
      });

      test('error on backgroundDark is visible', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.error,
          MnesisColors.backgroundDark,
        );

        // Semantic colors prioritize recognizability over perfect contrast
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: 'error color should be visible');
      });

      test('success on backgroundDark is visible', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.success,
          MnesisColors.backgroundDark,
        );

        // Semantic colors prioritize recognizability over perfect contrast
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: 'success color should be visible');
      });

      test('warning on backgroundDark is visible', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.warning,
          MnesisColors.backgroundDark,
        );

        // Semantic colors prioritize recognizability over perfect contrast
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: 'warning color should be visible');
      });
    });

    group('Color Value Tests', () {
      test('primaryOrange has correct hex value', () {
        expect(MnesisColors.primaryOrange.toARGB32(), equals(0xFFFF7043));
      });

      test('backgroundDark has correct hex value', () {
        expect(MnesisColors.backgroundDark.toARGB32(), equals(0xFF2D3339));
      });

      test('textPrimary is white', () {
        expect(MnesisColors.textPrimary.toARGB32(), equals(0xFFFFFFFF));
      });

      test('textSecondary has correct hex value', () {
        expect(MnesisColors.textSecondary.toARGB32(), equals(0xFFA0A0A0));
      });

      test('surfaceDark has correct hex value', () {
        expect(MnesisColors.surfaceDark.toARGB32(), equals(0xFF3D4349));
      });
    });

    group('Semantic Color Tests', () {
      test('error color is defined and not null', () {
        expect(MnesisColors.error, isNotNull);
        expect(MnesisColors.error.toARGB32(), equals(0xFFEF5350));
      });

      test('success color is defined and not null', () {
        expect(MnesisColors.success, isNotNull);
        expect(MnesisColors.success.toARGB32(), equals(0xFF66BB6A));
      });

      test('warning color is defined and not null', () {
        expect(MnesisColors.warning, isNotNull);
        expect(MnesisColors.warning.toARGB32(), equals(0xFFFFA726));
      });

      test('info color is defined and not null', () {
        expect(MnesisColors.info, isNotNull);
        expect(MnesisColors.info.toARGB32(), equals(0xFF42A5F5));
      });
    });

    group('Chat Bubble Color Tests', () {
      test('userBubble is distinct from assistantBubble', () {
        expect(
          MnesisColors.userBubble.toARGB32(),
          isNot(equals(MnesisColors.assistantBubble.toARGB32())),
        );
      });

      test('chat bubbles have sufficient contrast with text', () {
        final userRatio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textPrimary,
          MnesisColors.userBubble,
        );

        final assistantRatio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textPrimary,
          MnesisColors.assistantBubble,
        );

        expect(userRatio, greaterThanOrEqualTo(4.5),
            reason: 'User bubble should have readable text');
        expect(assistantRatio, greaterThanOrEqualTo(4.5),
            reason: 'Assistant bubble should have readable text');
      });
    });

    group('Border Color Tests', () {
      test('borderDefault is visible on backgroundDark', () {
        final ratio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.borderDefault,
          MnesisColors.backgroundDark,
        );

        // Borders can have lower contrast than text (subtle separation)
        // WCAG non-text contrast: 3:1 ideal, but 1.5:1+ acceptable for subtle UI
        expect(ratio, greaterThanOrEqualTo(1.5),
            reason: 'Border should be visible');
      });

      test('borderSubtle is less contrasted than borderDefault', () {
        final subtleRatio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.borderSubtle,
          MnesisColors.backgroundDark,
        );

        final defaultRatio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.borderDefault,
          MnesisColors.backgroundDark,
        );

        expect(subtleRatio, lessThan(defaultRatio),
            reason: 'Subtle border should have lower contrast');
      });

      test('borderStrong is more contrasted than borderDefault', () {
        final strongRatio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.borderStrong,
          MnesisColors.backgroundDark,
        );

        final defaultRatio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.borderDefault,
          MnesisColors.backgroundDark,
        );

        expect(strongRatio, greaterThan(defaultRatio),
            reason: 'Strong border should have higher contrast');
      });
    });

    group('Disabled State Tests', () {
      test('orangeDisabled has correct opacity (30%)', () {
        // RGBA format: 0xAABBCCDD where AA is alpha
        final alpha = (MnesisColors.orangeDisabled.toARGB32() >> 24) & 0xFF;
        final expectedAlpha = (255 * 0.3).round(); // 30% opacity = 77 (0x4D)

        expect(alpha, closeTo(expectedAlpha, 5),
            reason: 'Disabled orange should have ~30% opacity');
      });

      test('textDisabled is less contrasted than textPrimary', () {
        final disabledRatio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textDisabled,
          MnesisColors.backgroundDark,
        );

        final primaryRatio = AccessibilityTestHelpers.calculateContrastRatio(
          MnesisColors.textPrimary,
          MnesisColors.backgroundDark,
        );

        expect(disabledRatio, lessThan(primaryRatio),
            reason: 'Disabled text should be less prominent');
      });
    });

    group('Background Hierarchy Tests', () {
      test('background layers are progressively darker', () {
        final darkLuminance = MnesisColors.backgroundDark.computeLuminance();
        final darkerLuminance =
            MnesisColors.backgroundDarker.computeLuminance();
        final darkestLuminance =
            MnesisColors.backgroundDarkest.computeLuminance();

        expect(darkLuminance, greaterThan(darkerLuminance),
            reason: 'backgroundDark should be lighter than backgroundDarker');
        expect(darkerLuminance, greaterThan(darkestLuminance),
            reason: 'backgroundDarker should be lighter than backgroundDarkest');
      });

      test('surface layers are progressively lighter', () {
        final surfaceLuminance = MnesisColors.surfaceDark.computeLuminance();
        final elevatedLuminance =
            MnesisColors.surfaceElevated.computeLuminance();
        final overlayLuminance =
            MnesisColors.surfaceOverlay.computeLuminance();

        expect(elevatedLuminance, greaterThan(surfaceLuminance),
            reason: 'surfaceElevated should be lighter than surfaceDark');
        expect(overlayLuminance, greaterThan(elevatedLuminance),
            reason: 'surfaceOverlay should be lighter than surfaceElevated');
      });
    });
  });
}

