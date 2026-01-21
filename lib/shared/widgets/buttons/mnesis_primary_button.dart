import 'package:flutter/material.dart';
import '../../../core/design_system/mnesis_colors.dart';
import '../../../core/design_system/mnesis_spacings.dart';
import '../../../core/design_system/mnesis_text_styles.dart';

/// Primary button component for Mnesis application.
///
/// This is the main call-to-action button used throughout the app.
///
/// ## Design Specifications
/// - **Background**: Orange (#FF7043)
/// - **Height**: 48px
/// - **Border Radius**: 24px (pill shape)
/// - **Text**: White, semi-bold
/// - **States**: normal, hover, pressed, disabled, loading
/// - **Ripple**: Orange with 20% opacity
///
/// ## States
/// - **Normal**: Full orange background
/// - **Hover**: Slightly darker orange (user feedback)
/// - **Pressed**: Visual feedback with ripple effect
/// - **Disabled**: 40% opacity, no interaction
/// - **Loading**: Shows circular progress indicator
///
/// ## Usage
/// ```dart
/// MnesisPrimaryButton(
///   text: 'Continuar',
///   onPressed: () {
///     // Handle button press
///   },
/// )
/// ```
///
/// With loading state:
/// ```dart
/// MnesisPrimaryButton(
///   text: 'Salvando...',
///   isLoading: true,
///   onPressed: () {}, // Will be disabled while loading
/// )
/// ```
class MnesisPrimaryButton extends StatelessWidget {
  /// Creates a [MnesisPrimaryButton].
  ///
  /// The [text] parameter must not be null.
  /// The [onPressed] parameter is required. Pass null to disable the button.
  const MnesisPrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    super.key,
  });

  /// The text to display on the button.
  final String text;

  /// Callback when button is pressed.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Whether to show loading indicator.
  ///
  /// When true, the button shows a circular progress indicator
  /// and becomes disabled.
  final bool isLoading;

  /// Optional icon to display before the text.
  final IconData? icon;

  /// Optional custom width.
  ///
  /// If null, button will expand to fill available width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: MnesisSpacings.buttonHeight,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return MnesisColors.primaryOrange.withValues(alpha: MnesisColors.opacityDisabled);
            }
            return MnesisColors.primaryOrange;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return MnesisColors.textOnOrange.withValues(alpha: MnesisColors.opacityDisabled);
            }
            return MnesisColors.textOnOrange;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return MnesisColors.orange20;
            }
            if (states.contains(WidgetState.hovered)) {
              return MnesisColors.orange20.withValues(alpha: MnesisColors.opacityHover);
            }
            return null;
          }),
          elevation: WidgetStateProperty.all<double>(0),
          shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MnesisSpacings.borderRadiusLg),
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              horizontal: MnesisSpacings.lg,
              vertical: MnesisSpacings.md,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: MnesisSpacings.progressIndicatorSize,
                height: MnesisSpacings.progressIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: MnesisSpacings.progressIndicatorStroke,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    MnesisColors.textOnOrange,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: MnesisSpacings.iconSizeButton),
                    SizedBox(width: MnesisSpacings.xs),
                  ],
                  Text(
                    text,
                    style: MnesisTextStyles.button,
                  ),
                ],
              ),
      ),
    );
  }
}
