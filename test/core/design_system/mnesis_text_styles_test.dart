import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_text_styles.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';

void main() {
  group('MnesisTextStyles - Typography Scale Tests', () {
    group('Font Family', () {
      test('all text styles use Inter font family', () {
        expect(MnesisTextStyles.displayLarge.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.displayMedium.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.displaySmall.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.headlineLarge.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.headlineMedium.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.headlineSmall.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.bodyLarge.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.bodyMedium.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.bodySmall.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.labelLarge.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.labelMedium.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.labelSmall.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.caption.fontFamily, equals('Inter'));
        expect(MnesisTextStyles.overline.fontFamily, equals('Inter'));
      });
    });

    group('Display Styles - Font Sizes', () {
      test('displayLarge has correct font size (36px)', () {
        expect(MnesisTextStyles.displayLarge.fontSize, equals(36.0));
      });

      test('displayMedium has correct font size (28px)', () {
        expect(MnesisTextStyles.displayMedium.fontSize, equals(28.0));
      });

      test('displaySmall has correct font size (24px)', () {
        expect(MnesisTextStyles.displaySmall.fontSize, equals(24.0));
      });

      test('display styles follow descending size hierarchy', () {
        expect(
          MnesisTextStyles.displayLarge.fontSize! >
              MnesisTextStyles.displayMedium.fontSize!,
          isTrue,
          reason: 'displayLarge should be larger than displayMedium',
        );
        expect(
          MnesisTextStyles.displayMedium.fontSize! >
              MnesisTextStyles.displaySmall.fontSize!,
          isTrue,
          reason: 'displayMedium should be larger than displaySmall',
        );
      });
    });

    group('Headline Styles - Font Sizes', () {
      test('headlineLarge has correct font size (20px)', () {
        expect(MnesisTextStyles.headlineLarge.fontSize, equals(20.0));
      });

      test('headlineMedium has correct font size (18px)', () {
        expect(MnesisTextStyles.headlineMedium.fontSize, equals(18.0));
      });

      test('headlineSmall has correct font size (16px)', () {
        expect(MnesisTextStyles.headlineSmall.fontSize, equals(16.0));
      });

      test('headline styles follow descending size hierarchy', () {
        expect(
          MnesisTextStyles.headlineLarge.fontSize! >
              MnesisTextStyles.headlineMedium.fontSize!,
          isTrue,
        );
        expect(
          MnesisTextStyles.headlineMedium.fontSize! >
              MnesisTextStyles.headlineSmall.fontSize!,
          isTrue,
        );
      });
    });

    group('Body Styles - Font Sizes', () {
      test('bodyLarge has correct font size (18px)', () {
        expect(MnesisTextStyles.bodyLarge.fontSize, equals(18.0));
      });

      test('bodyMedium has correct font size (16px)', () {
        expect(MnesisTextStyles.bodyMedium.fontSize, equals(16.0));
      });

      test('bodySmall has correct font size (14px)', () {
        expect(MnesisTextStyles.bodySmall.fontSize, equals(14.0));
      });

      test('body styles follow descending size hierarchy', () {
        expect(
          MnesisTextStyles.bodyLarge.fontSize! >
              MnesisTextStyles.bodyMedium.fontSize!,
          isTrue,
        );
        expect(
          MnesisTextStyles.bodyMedium.fontSize! >
              MnesisTextStyles.bodySmall.fontSize!,
          isTrue,
        );
      });
    });

    group('Label Styles - Font Sizes', () {
      test('labelLarge has correct font size (16px)', () {
        expect(MnesisTextStyles.labelLarge.fontSize, equals(16.0));
      });

      test('labelMedium has correct font size (14px)', () {
        expect(MnesisTextStyles.labelMedium.fontSize, equals(14.0));
      });

      test('labelSmall has correct font size (12px)', () {
        expect(MnesisTextStyles.labelSmall.fontSize, equals(12.0));
      });

      test('label styles follow descending size hierarchy', () {
        expect(
          MnesisTextStyles.labelLarge.fontSize! >
              MnesisTextStyles.labelMedium.fontSize!,
          isTrue,
        );
        expect(
          MnesisTextStyles.labelMedium.fontSize! >
              MnesisTextStyles.labelSmall.fontSize!,
          isTrue,
        );
      });
    });

    group('Caption & Overline - Font Sizes', () {
      test('caption has correct font size (12px)', () {
        expect(MnesisTextStyles.caption.fontSize, equals(12.0));
      });

      test('overline has correct font size (11px)', () {
        expect(MnesisTextStyles.overline.fontSize, equals(11.0));
      });

      test('overline is smallest text style', () {
        expect(
          MnesisTextStyles.overline.fontSize! <
              MnesisTextStyles.caption.fontSize!,
          isTrue,
        );
      });
    });

    group('Font Weights', () {
      test('displayLarge has Bold weight (700)', () {
        expect(MnesisTextStyles.displayLarge.fontWeight, equals(FontWeight.w700));
      });

      test('displayMedium has Bold weight (700)', () {
        expect(MnesisTextStyles.displayMedium.fontWeight, equals(FontWeight.w700));
      });

      test('displaySmall has SemiBold weight (600)', () {
        expect(MnesisTextStyles.displaySmall.fontWeight, equals(FontWeight.w600));
      });

      test('headlines have SemiBold weight (600)', () {
        expect(MnesisTextStyles.headlineLarge.fontWeight, equals(FontWeight.w600));
        expect(MnesisTextStyles.headlineMedium.fontWeight, equals(FontWeight.w600));
        expect(MnesisTextStyles.headlineSmall.fontWeight, equals(FontWeight.w600));
      });

      test('body styles have Regular weight (400)', () {
        expect(MnesisTextStyles.bodyLarge.fontWeight, equals(FontWeight.w400));
        expect(MnesisTextStyles.bodyMedium.fontWeight, equals(FontWeight.w400));
        expect(MnesisTextStyles.bodySmall.fontWeight, equals(FontWeight.w400));
      });

      test('labels have Medium weight (500)', () {
        expect(MnesisTextStyles.labelLarge.fontWeight, equals(FontWeight.w500));
        expect(MnesisTextStyles.labelMedium.fontWeight, equals(FontWeight.w500));
        expect(MnesisTextStyles.labelSmall.fontWeight, equals(FontWeight.w500));
      });

      test('caption has Regular weight (400)', () {
        expect(MnesisTextStyles.caption.fontWeight, equals(FontWeight.w400));
      });

      test('overline has SemiBold weight (600)', () {
        expect(MnesisTextStyles.overline.fontWeight, equals(FontWeight.w600));
      });
    });

    group('Line Heights (Height Ratio)', () {
      test('displayLarge has correct line height ratio (1.2)', () {
        expect(MnesisTextStyles.displayLarge.height, equals(1.2));
      });

      test('displayMedium has correct line height ratio (1.25)', () {
        expect(MnesisTextStyles.displayMedium.height, equals(1.25));
      });

      test('displaySmall has correct line height ratio (1.3)', () {
        expect(MnesisTextStyles.displaySmall.height, equals(1.3));
      });

      test('headlines have correct line height ratios (1.4-1.5)', () {
        expect(MnesisTextStyles.headlineLarge.height, equals(1.4));
        expect(MnesisTextStyles.headlineMedium.height, equals(1.4));
        expect(MnesisTextStyles.headlineSmall.height, equals(1.5));
      });

      test('body styles have 1.5 line height for readability', () {
        expect(MnesisTextStyles.bodyLarge.height, equals(1.5));
        expect(MnesisTextStyles.bodyMedium.height, equals(1.5));
        expect(MnesisTextStyles.bodySmall.height, equals(1.5));
      });

      test('label styles have compact line heights (1.25-1.3)', () {
        expect(MnesisTextStyles.labelLarge.height, equals(1.25));
        expect(MnesisTextStyles.labelMedium.height, equals(1.3));
        expect(MnesisTextStyles.labelSmall.height, equals(1.3));
      });

      test('caption and overline have compact line heights', () {
        expect(MnesisTextStyles.caption.height, equals(1.3));
        expect(MnesisTextStyles.overline.height, equals(1.4));
      });
    });

    group('Letter Spacing', () {
      test('displayLarge has negative letter spacing (-0.5)', () {
        expect(MnesisTextStyles.displayLarge.letterSpacing, equals(-0.5));
      });

      test('displayMedium has negative letter spacing (-0.25)', () {
        expect(MnesisTextStyles.displayMedium.letterSpacing, equals(-0.25));
      });

      test('displaySmall has zero letter spacing', () {
        expect(MnesisTextStyles.displaySmall.letterSpacing, equals(0));
      });

      test('headlines have zero letter spacing', () {
        expect(MnesisTextStyles.headlineLarge.letterSpacing, equals(0));
        expect(MnesisTextStyles.headlineMedium.letterSpacing, equals(0));
        expect(MnesisTextStyles.headlineSmall.letterSpacing, equals(0));
      });

      test('body styles have appropriate letter spacing', () {
        expect(MnesisTextStyles.bodyLarge.letterSpacing, equals(0));
        expect(MnesisTextStyles.bodyMedium.letterSpacing, equals(0.25));
        expect(MnesisTextStyles.bodySmall.letterSpacing, equals(0.25));
      });

      test('labels have positive letter spacing for buttons', () {
        expect(MnesisTextStyles.labelLarge.letterSpacing, equals(0.1));
        expect(MnesisTextStyles.labelMedium.letterSpacing, equals(0.5));
        expect(MnesisTextStyles.labelSmall.letterSpacing, equals(0.5));
      });

      test('caption has appropriate letter spacing (0.4)', () {
        expect(MnesisTextStyles.caption.letterSpacing, equals(0.4));
      });

      test('overline has wide letter spacing for uppercase (1.5)', () {
        expect(MnesisTextStyles.overline.letterSpacing, equals(1.5));
      });
    });

    group('Color Assignment', () {
      test('display and headline styles use textPrimary', () {
        expect(MnesisTextStyles.displayLarge.color, equals(MnesisColors.textPrimary));
        expect(MnesisTextStyles.displayMedium.color, equals(MnesisColors.textPrimary));
        expect(MnesisTextStyles.displaySmall.color, equals(MnesisColors.textPrimary));
        expect(MnesisTextStyles.headlineLarge.color, equals(MnesisColors.textPrimary));
        expect(MnesisTextStyles.headlineMedium.color, equals(MnesisColors.textPrimary));
        expect(MnesisTextStyles.headlineSmall.color, equals(MnesisColors.textPrimary));
      });

      test('body large and medium use textPrimary', () {
        expect(MnesisTextStyles.bodyLarge.color, equals(MnesisColors.textPrimary));
        expect(MnesisTextStyles.bodyMedium.color, equals(MnesisColors.textPrimary));
      });

      test('bodySmall uses textSecondary for de-emphasis', () {
        expect(MnesisTextStyles.bodySmall.color, equals(MnesisColors.textSecondary));
      });

      test('labels use textPrimary for buttons', () {
        expect(MnesisTextStyles.labelLarge.color, equals(MnesisColors.textPrimary));
        expect(MnesisTextStyles.labelMedium.color, equals(MnesisColors.textPrimary));
      });

      test('labelSmall uses textSecondary', () {
        expect(MnesisTextStyles.labelSmall.color, equals(MnesisColors.textSecondary));
      });

      test('caption uses textTertiary for metadata', () {
        expect(MnesisTextStyles.caption.color, equals(MnesisColors.textTertiary));
      });

      test('overline uses textSecondary', () {
        expect(MnesisTextStyles.overline.color, equals(MnesisColors.textSecondary));
      });
    });

    group('Typography Scale Validation', () {
      test('complete type scale exists without gaps', () {
        // Verify all styles are defined and non-null
        expect(MnesisTextStyles.displayLarge, isNotNull);
        expect(MnesisTextStyles.displayMedium, isNotNull);
        expect(MnesisTextStyles.displaySmall, isNotNull);
        expect(MnesisTextStyles.headlineLarge, isNotNull);
        expect(MnesisTextStyles.headlineMedium, isNotNull);
        expect(MnesisTextStyles.headlineSmall, isNotNull);
        expect(MnesisTextStyles.bodyLarge, isNotNull);
        expect(MnesisTextStyles.bodyMedium, isNotNull);
        expect(MnesisTextStyles.bodySmall, isNotNull);
        expect(MnesisTextStyles.labelLarge, isNotNull);
        expect(MnesisTextStyles.labelMedium, isNotNull);
        expect(MnesisTextStyles.labelSmall, isNotNull);
        expect(MnesisTextStyles.caption, isNotNull);
        expect(MnesisTextStyles.overline, isNotNull);
      });

      test('font sizes are all positive values', () {
        expect(MnesisTextStyles.displayLarge.fontSize!, greaterThan(0));
        expect(MnesisTextStyles.displayMedium.fontSize!, greaterThan(0));
        expect(MnesisTextStyles.displaySmall.fontSize!, greaterThan(0));
        expect(MnesisTextStyles.headlineLarge.fontSize!, greaterThan(0));
        expect(MnesisTextStyles.bodyLarge.fontSize!, greaterThan(0));
        expect(MnesisTextStyles.labelSmall.fontSize!, greaterThan(0));
        expect(MnesisTextStyles.caption.fontSize!, greaterThan(0));
        expect(MnesisTextStyles.overline.fontSize!, greaterThan(0));
      });

      test('line height ratios are reasonable (>= 1.0)', () {
        expect(MnesisTextStyles.displayLarge.height!, greaterThanOrEqualTo(1.0));
        expect(MnesisTextStyles.bodyMedium.height!, greaterThanOrEqualTo(1.0));
        expect(MnesisTextStyles.caption.height!, greaterThanOrEqualTo(1.0));
      });
    });

    group('Readability Optimization', () {
      test('body text has optimal line height for readability (1.5)', () {
        // Body text should have 1.5 line height for optimal readability
        expect(MnesisTextStyles.bodyLarge.height, equals(1.5));
        expect(MnesisTextStyles.bodyMedium.height, equals(1.5));
        expect(MnesisTextStyles.bodySmall.height, equals(1.5));
      });

      test('display text has tighter line height (1.2-1.3)', () {
        // Display text should have tighter leading for visual impact
        expect(MnesisTextStyles.displayLarge.height, lessThanOrEqualTo(1.3));
        expect(MnesisTextStyles.displayMedium.height, lessThanOrEqualTo(1.3));
        expect(MnesisTextStyles.displaySmall.height, lessThanOrEqualTo(1.3));
      });

      test('font size range is appropriate (11px - 36px)', () {
        // Smallest font (overline) should be >= 11px for readability
        expect(MnesisTextStyles.overline.fontSize, greaterThanOrEqualTo(11.0));

        // Largest font (displayLarge) should be <= 36px for practicality
        expect(MnesisTextStyles.displayLarge.fontSize, lessThanOrEqualTo(36.0));
      });
    });
  });
}
