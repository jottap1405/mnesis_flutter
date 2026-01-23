import 'package:flutter/material.dart';
import '../mnesis_colors.dart';
import '../mnesis_text_styles.dart';
import '../mnesis_spacings.dart';

/// Color palette showcase widget for design system testing.
///
/// Displays all colors from [MnesisColors] with their hex values.
/// This widget is extracted from the main design system test screen to
/// comply with FlowForge Rule #24 (file size limit).
///
/// See also:
/// * [MnesisColors] - Color system definition
class ColorPaletteShowcase extends StatelessWidget {
  /// Creates a color palette showcase widget.
  const ColorPaletteShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildColorRow('Primary Orange', MnesisColors.primaryOrange),
        _buildColorRow('Primary Orange Light', MnesisColors.primaryOrangeLight),
        _buildColorRow('Primary Orange Dark', MnesisColors.primaryOrangeDark),
        _buildColorRow('Primary Orange Disabled', MnesisColors.orangeDisabled),
        SizedBox(height: MnesisSpacings.md),
        _buildColorRow('Background Dark', MnesisColors.backgroundDark),
        _buildColorRow('Background Darker', MnesisColors.backgroundDarker),
        _buildColorRow('Surface Dark', MnesisColors.surfaceDark),
        _buildColorRow('Surface Elevated', MnesisColors.surfaceElevated),
        _buildColorRow('Surface Overlay', MnesisColors.surfaceOverlay),
        SizedBox(height: MnesisSpacings.md),
        _buildColorRow('Text Primary', MnesisColors.textPrimary),
        _buildColorRow('Text Secondary', MnesisColors.textSecondary),
        _buildColorRow('Text Tertiary', MnesisColors.textTertiary),
        _buildColorRow('Text Disabled', MnesisColors.textDisabled),
        SizedBox(height: MnesisSpacings.md),
        _buildColorRow('Success', MnesisColors.success),
        _buildColorRow('Warning', MnesisColors.warning),
        _buildColorRow('Error', MnesisColors.error),
        _buildColorRow('Info', MnesisColors.info),
      ],
    );
  }

  /// Builds a single color display row.
  ///
  /// Shows a color swatch with its name and hex value.
  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MnesisSpacings.xs),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(MnesisSpacings.radiusSm),
              border: Border.all(color: MnesisColors.textTertiary),
            ),
          ),
          SizedBox(width: MnesisSpacings.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: MnesisTextStyles.bodyMedium),
                Text(
                  _getColorHex(color),
                  style: MnesisTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Converts a Color to its hex representation.
  ///
  /// Uses toARGB32 to avoid deprecated value getter.
  String _getColorHex(Color color) {
    final argb = color.toARGB32();
    // Extract RGB components (ignore alpha)
    final rgb = argb & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}