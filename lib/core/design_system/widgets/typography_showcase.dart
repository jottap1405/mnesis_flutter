import 'package:flutter/material.dart';
import '../mnesis_text_styles.dart';
import '../mnesis_spacings.dart';

/// Typography showcase widget for design system testing.
///
/// Displays all text styles from [MnesisTextStyles] for visual verification.
/// This widget is extracted from the main design system test screen to
/// comply with FlowForge Rule #24 (file size limit).
///
/// See also:
/// * [MnesisTextStyles] - Typography system definition
class TypographyShowcase extends StatelessWidget {
  /// Creates a typography showcase widget.
  const TypographyShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Large', style: MnesisTextStyles.displayLarge),
        SizedBox(height: MnesisSpacings.sm),
        Text('Display Medium', style: MnesisTextStyles.displayMedium),
        SizedBox(height: MnesisSpacings.sm),
        Text('Display Small', style: MnesisTextStyles.displaySmall),
        SizedBox(height: MnesisSpacings.md),
        Text('Headline Large', style: MnesisTextStyles.headlineLarge),
        SizedBox(height: MnesisSpacings.sm),
        Text('Headline Medium', style: MnesisTextStyles.headlineMedium),
        SizedBox(height: MnesisSpacings.sm),
        Text('Headline Small', style: MnesisTextStyles.headlineSmall),
        SizedBox(height: MnesisSpacings.md),
        Text('Body Large', style: MnesisTextStyles.bodyLarge),
        SizedBox(height: MnesisSpacings.sm),
        Text('Body Medium', style: MnesisTextStyles.bodyMedium),
        SizedBox(height: MnesisSpacings.sm),
        Text('Body Small', style: MnesisTextStyles.bodySmall),
        SizedBox(height: MnesisSpacings.md),
        Text('Label Large', style: MnesisTextStyles.labelLarge),
        SizedBox(height: MnesisSpacings.sm),
        Text('Label Medium', style: MnesisTextStyles.labelMedium),
        SizedBox(height: MnesisSpacings.sm),
        Text('Label Small', style: MnesisTextStyles.labelSmall),
        SizedBox(height: MnesisSpacings.md),
        Text('Button Text', style: MnesisTextStyles.button),
        SizedBox(height: MnesisSpacings.sm),
        Text('Caption Text', style: MnesisTextStyles.caption),
        SizedBox(height: MnesisSpacings.sm),
        Text('Overline Text', style: MnesisTextStyles.overline),
      ],
    );
  }
}