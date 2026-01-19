import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_spacings.dart';

void main() {
  group('MnesisSpacings - Spacing System Tests', () {
    group('Base Unit', () {
      test('base unit is 4px', () {
        expect(MnesisSpacings.baseUnit, equals(4.0));
      });
    });

    group('Spacing Scale - Base Unit Multiples', () {
      test('xs is 1x base unit (4px)', () {
        expect(MnesisSpacings.xs, equals(4.0));
        expect(MnesisSpacings.xs, equals(MnesisSpacings.baseUnit * 1));
      });

      test('sm is 2x base unit (8px)', () {
        expect(MnesisSpacings.sm, equals(8.0));
        expect(MnesisSpacings.sm, equals(MnesisSpacings.baseUnit * 2));
      });

      test('md is 3x base unit (12px)', () {
        expect(MnesisSpacings.md, equals(12.0));
        expect(MnesisSpacings.md, equals(MnesisSpacings.baseUnit * 3));
      });

      test('lg is 4x base unit (16px)', () {
        expect(MnesisSpacings.lg, equals(16.0));
        expect(MnesisSpacings.lg, equals(MnesisSpacings.baseUnit * 4));
      });

      test('xl is 6x base unit (24px)', () {
        expect(MnesisSpacings.xl, equals(24.0));
        expect(MnesisSpacings.xl, equals(MnesisSpacings.baseUnit * 6));
      });

      test('xl2 is 8x base unit (32px)', () {
        expect(MnesisSpacings.xl2, equals(32.0));
        expect(MnesisSpacings.xl2, equals(MnesisSpacings.baseUnit * 8));
      });

      test('xl3 is 12x base unit (48px)', () {
        expect(MnesisSpacings.xl3, equals(48.0));
        expect(MnesisSpacings.xl3, equals(MnesisSpacings.baseUnit * 12));
      });

      test('xl4 is 16x base unit (64px)', () {
        expect(MnesisSpacings.xl4, equals(64.0));
        expect(MnesisSpacings.xl4, equals(MnesisSpacings.baseUnit * 16));
      });

      test('all spacing values are multiples of base unit', () {
        expect(MnesisSpacings.xs % MnesisSpacings.baseUnit, equals(0));
        expect(MnesisSpacings.sm % MnesisSpacings.baseUnit, equals(0));
        expect(MnesisSpacings.md % MnesisSpacings.baseUnit, equals(0));
        expect(MnesisSpacings.lg % MnesisSpacings.baseUnit, equals(0));
        expect(MnesisSpacings.xl % MnesisSpacings.baseUnit, equals(0));
        expect(MnesisSpacings.xl2 % MnesisSpacings.baseUnit, equals(0));
        expect(MnesisSpacings.xl3 % MnesisSpacings.baseUnit, equals(0));
        expect(MnesisSpacings.xl4 % MnesisSpacings.baseUnit, equals(0));
      });

      test('spacing scale follows ascending order', () {
        expect(MnesisSpacings.xs, lessThan(MnesisSpacings.sm));
        expect(MnesisSpacings.sm, lessThan(MnesisSpacings.md));
        expect(MnesisSpacings.md, lessThan(MnesisSpacings.lg));
        expect(MnesisSpacings.lg, lessThan(MnesisSpacings.xl));
        expect(MnesisSpacings.xl, lessThan(MnesisSpacings.xl2));
        expect(MnesisSpacings.xl2, lessThan(MnesisSpacings.xl3));
        expect(MnesisSpacings.xl3, lessThan(MnesisSpacings.xl4));
      });
    });

    group('Semantic Spacing Aliases', () {
      test('tiny equals xs (4px)', () {
        expect(MnesisSpacings.tiny, equals(MnesisSpacings.xs));
        expect(MnesisSpacings.tiny, equals(4.0));
      });

      test('small equals sm (8px)', () {
        expect(MnesisSpacings.small, equals(MnesisSpacings.sm));
        expect(MnesisSpacings.small, equals(8.0));
      });

      test('medium equals lg (16px)', () {
        expect(MnesisSpacings.medium, equals(MnesisSpacings.lg));
        expect(MnesisSpacings.medium, equals(16.0));
      });

      test('large equals xl (24px)', () {
        expect(MnesisSpacings.large, equals(MnesisSpacings.xl));
        expect(MnesisSpacings.large, equals(24.0));
      });

      test('extraLarge equals xl2 (32px)', () {
        expect(MnesisSpacings.extraLarge, equals(MnesisSpacings.xl2));
        expect(MnesisSpacings.extraLarge, equals(32.0));
      });
    });

    group('Chat Bubble Spacing', () {
      test('chat bubble padding is defined', () {
        expect(MnesisSpacings.chatBubblePaddingHorizontal, equals(16.0));
        expect(MnesisSpacings.chatBubblePaddingVertical, equals(12.0));
      });

      test('chat bubble gap equals md (12px)', () {
        expect(MnesisSpacings.chatBubbleGap, equals(MnesisSpacings.md));
        expect(MnesisSpacings.chatBubbleGap, equals(12.0));
      });
    });

    group('Input Field Spacing', () {
      test('input padding horizontal equals lg (16px)', () {
        expect(MnesisSpacings.inputPaddingHorizontal, equals(MnesisSpacings.lg));
        expect(MnesisSpacings.inputPaddingHorizontal, equals(16.0));
      });

      test('input padding vertical equals md (12px)', () {
        expect(MnesisSpacings.inputPaddingVertical, equals(MnesisSpacings.md));
        expect(MnesisSpacings.inputPaddingVertical, equals(12.0));
      });
    });

    group('Button Spacing', () {
      test('button padding horizontal equals xl (24px)', () {
        expect(MnesisSpacings.buttonPaddingHorizontal, equals(MnesisSpacings.xl));
        expect(MnesisSpacings.buttonPaddingHorizontal, equals(24.0));
      });

      test('button padding vertical equals md (12px)', () {
        expect(MnesisSpacings.buttonPaddingVertical, equals(MnesisSpacings.md));
        expect(MnesisSpacings.buttonPaddingVertical, equals(12.0));
      });

      test('small button padding is smaller than regular', () {
        expect(
          MnesisSpacings.buttonSmallPaddingHorizontal,
          lessThan(MnesisSpacings.buttonPaddingHorizontal),
        );
        expect(
          MnesisSpacings.buttonSmallPaddingVertical,
          lessThan(MnesisSpacings.buttonPaddingVertical),
        );
      });

      test('small button padding values are correct', () {
        expect(MnesisSpacings.buttonSmallPaddingHorizontal, equals(16.0));
        expect(MnesisSpacings.buttonSmallPaddingVertical, equals(8.0));
      });
    });

    group('Icon Button & Touch Targets', () {
      test('icon button size meets minimum touch target (48px)', () {
        expect(
          MnesisSpacings.iconButtonSize,
          greaterThanOrEqualTo(48.0),
          reason: 'Touch targets should be at least 48dp for accessibility',
        );
      });

      test('icon button size is exactly 48px', () {
        expect(MnesisSpacings.iconButtonSize, equals(48.0));
      });
    });

    group('Icon Sizes', () {
      test('icon size small equals lg (16px)', () {
        expect(MnesisSpacings.iconSizeSmall, equals(MnesisSpacings.lg));
        expect(MnesisSpacings.iconSizeSmall, equals(16.0));
      });

      test('icon size medium equals xl (24px)', () {
        expect(MnesisSpacings.iconSizeMedium, equals(MnesisSpacings.xl));
        expect(MnesisSpacings.iconSizeMedium, equals(24.0));
      });

      test('icon size large equals xl2 (32px)', () {
        expect(MnesisSpacings.iconSizeLarge, equals(MnesisSpacings.xl2));
        expect(MnesisSpacings.iconSizeLarge, equals(32.0));
      });

      test('icon sizes follow ascending order', () {
        expect(
          MnesisSpacings.iconSizeSmall,
          lessThan(MnesisSpacings.iconSizeMedium),
        );
        expect(
          MnesisSpacings.iconSizeMedium,
          lessThan(MnesisSpacings.iconSizeLarge),
        );
      });
    });

    group('Screen Padding', () {
      test('screen padding horizontal equals xl (24px)', () {
        expect(MnesisSpacings.screenPaddingHorizontal, equals(MnesisSpacings.xl));
        expect(MnesisSpacings.screenPaddingHorizontal, equals(24.0));
      });

      test('screen padding vertical equals xl (24px)', () {
        expect(MnesisSpacings.screenPaddingVertical, equals(MnesisSpacings.xl));
        expect(MnesisSpacings.screenPaddingVertical, equals(24.0));
      });
    });

    group('Card & List Spacing', () {
      test('card padding equals lg (16px)', () {
        expect(MnesisSpacings.cardPadding, equals(MnesisSpacings.lg));
        expect(MnesisSpacings.cardPadding, equals(16.0));
      });

      test('list item height is 56px (Material Design standard)', () {
        expect(MnesisSpacings.listItemHeight, equals(56.0));
      });

      test('list item padding horizontal equals lg (16px)', () {
        expect(MnesisSpacings.listItemPaddingHorizontal, equals(MnesisSpacings.lg));
        expect(MnesisSpacings.listItemPaddingHorizontal, equals(16.0));
      });

      test('list item padding vertical equals sm (8px)', () {
        expect(MnesisSpacings.listItemPaddingVertical, equals(MnesisSpacings.sm));
        expect(MnesisSpacings.listItemPaddingVertical, equals(8.0));
      });
    });

    group('Border Radius Scale', () {
      test('radiusNone is 0px', () {
        expect(MnesisSpacings.radiusNone, equals(0.0));
      });

      test('radiusXs is 4px', () {
        expect(MnesisSpacings.radiusXs, equals(4.0));
      });

      test('radiusSm is 8px', () {
        expect(MnesisSpacings.radiusSm, equals(8.0));
      });

      test('radiusMd is 12px', () {
        expect(MnesisSpacings.radiusMd, equals(12.0));
      });

      test('radiusLg is 16px', () {
        expect(MnesisSpacings.radiusLg, equals(16.0));
      });

      test('radiusXl is 24px', () {
        expect(MnesisSpacings.radiusXl, equals(24.0));
      });

      test('radiusPill is 999px (ensures fully rounded)', () {
        expect(MnesisSpacings.radiusPill, equals(999.0));
      });

      test('radiusCircular is 9999px (for perfect circles)', () {
        expect(MnesisSpacings.radiusCircular, equals(9999.0));
      });

      test('border radius scale follows ascending order', () {
        expect(MnesisSpacings.radiusNone, lessThan(MnesisSpacings.radiusXs));
        expect(MnesisSpacings.radiusXs, lessThan(MnesisSpacings.radiusSm));
        expect(MnesisSpacings.radiusSm, lessThan(MnesisSpacings.radiusMd));
        expect(MnesisSpacings.radiusMd, lessThan(MnesisSpacings.radiusLg));
        expect(MnesisSpacings.radiusLg, lessThan(MnesisSpacings.radiusXl));
        expect(MnesisSpacings.radiusXl, lessThan(MnesisSpacings.radiusPill));
      });
    });

    group('Elevation Levels', () {
      test('elevation0 is 0px (no elevation)', () {
        expect(MnesisSpacings.elevation0, equals(0.0));
      });

      test('elevation1 is 2px (subtle)', () {
        expect(MnesisSpacings.elevation1, equals(2.0));
      });

      test('elevation2 is 4px (moderate)', () {
        expect(MnesisSpacings.elevation2, equals(4.0));
      });

      test('elevation3 is 8px (high)', () {
        expect(MnesisSpacings.elevation3, equals(8.0));
      });

      test('elevation4 is 16px (maximum)', () {
        expect(MnesisSpacings.elevation4, equals(16.0));
      });

      test('elevation levels follow ascending order', () {
        expect(MnesisSpacings.elevation0, lessThan(MnesisSpacings.elevation1));
        expect(MnesisSpacings.elevation1, lessThan(MnesisSpacings.elevation2));
        expect(MnesisSpacings.elevation2, lessThan(MnesisSpacings.elevation3));
        expect(MnesisSpacings.elevation3, lessThan(MnesisSpacings.elevation4));
      });

      test('elevation levels are powers of 2', () {
        expect(MnesisSpacings.elevation1, equals(2.0));
        expect(MnesisSpacings.elevation2, equals(4.0));
        expect(MnesisSpacings.elevation3, equals(8.0));
        expect(MnesisSpacings.elevation4, equals(16.0));
      });
    });

    group('Spacing Consistency Validation', () {
      test('all spacing values are positive', () {
        expect(MnesisSpacings.xs, greaterThan(0));
        expect(MnesisSpacings.sm, greaterThan(0));
        expect(MnesisSpacings.md, greaterThan(0));
        expect(MnesisSpacings.lg, greaterThan(0));
        expect(MnesisSpacings.xl, greaterThan(0));
      });

      test('component spacings use scale values', () {
        // Chat bubbles
        expect(MnesisSpacings.chatBubblePaddingHorizontal, equals(MnesisSpacings.lg));
        expect(MnesisSpacings.chatBubblePaddingVertical, equals(MnesisSpacings.md));

        // Inputs
        expect(MnesisSpacings.inputPaddingHorizontal, equals(MnesisSpacings.lg));
        expect(MnesisSpacings.inputPaddingVertical, equals(MnesisSpacings.md));

        // Buttons
        expect(MnesisSpacings.buttonPaddingHorizontal, equals(MnesisSpacings.xl));
        expect(MnesisSpacings.buttonPaddingVertical, equals(MnesisSpacings.md));
      });

      test('icon sizes use spacing scale', () {
        expect(MnesisSpacings.iconSizeSmall, equals(MnesisSpacings.lg));
        expect(MnesisSpacings.iconSizeMedium, equals(MnesisSpacings.xl));
        expect(MnesisSpacings.iconSizeLarge, equals(MnesisSpacings.xl2));
      });
    });

    group('Accessibility - Touch Targets', () {
      test('icon button meets 48dp minimum touch target', () {
        expect(
          MnesisSpacings.iconButtonSize,
          greaterThanOrEqualTo(48.0),
          reason: 'Material Design requires 48dp minimum for touch targets',
        );
      });

      test('list item height meets minimum touch target', () {
        expect(
          MnesisSpacings.listItemHeight,
          greaterThanOrEqualTo(48.0),
          reason: 'List items should have minimum 48dp height for accessibility',
        );
      });
    });

    group('Material Design Compliance', () {
      test('uses 4dp base unit (Material Design standard)', () {
        expect(
          MnesisSpacings.baseUnit,
          equals(4.0),
          reason: 'Material Design uses 4dp as base unit for spacing grid',
        );
      });

      test('elevation values match Material Design standards', () {
        // Material Design elevation scale: 0, 1, 2, 3, 4, 6, 8, 9, 12, 16, 24
        // Our simplified scale: 0, 2, 4, 8, 16
        expect(MnesisSpacings.elevation0, equals(0.0));
        expect(MnesisSpacings.elevation1, equals(2.0));
        expect(MnesisSpacings.elevation2, equals(4.0));
        expect(MnesisSpacings.elevation3, equals(8.0));
        expect(MnesisSpacings.elevation4, equals(16.0));
      });
    });
  });
}
