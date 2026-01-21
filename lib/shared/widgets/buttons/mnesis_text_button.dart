import 'package:flutter/material.dart';
import '../../../core/design_system/mnesis_colors.dart';
import '../../../core/design_system/mnesis_spacings.dart';
import '../../../core/design_system/mnesis_text_styles.dart';

/// Text button component for Mnesis application.
///
/// This is a minimal button used for tertiary actions and inline links.
///
/// ## Design Specifications
/// - **Background**: Transparent
/// - **Border**: None
/// - **Height**: 48px (maintains touch target)
/// - **Text**: Orange (#FF7043), semi-bold
/// - **States**: normal, hover, pressed, disabled, loading
/// - **Ripple**: Orange with 20% opacity
///
/// ## States
/// - **Normal**: Transparent background with orange text
/// - **Hover**: Slight orange overlay (user feedback)
/// - **Pressed**: Visual feedback with ripple effect
/// - **Disabled**: 40% opacity, no interaction
/// - **Loading**: Shows circular progress indicator
///
/// ## Usage
/// ```dart
/// MnesisTextButton(
///   text: 'Pular',
///   onPressed: () {
///     // Handle button press
///   },
/// )
/// ```
///
/// With icon:
/// ```dart
/// MnesisTextButton(
///   text: 'Ver mais',
///   icon: Icons.arrow_forward,
///   onPressed: () {},
/// )
/// ```
class MnesisTextButton extends StatelessWidget {
  /// Creates a [MnesisTextButton].
  ///
  /// The [text] parameter must not be null.
  /// The [onPressed] parameter is required. Pass null to disable the button.
  const MnesisTextButton({
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
  /// If null, button will shrink to fit content.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      height: MnesisSpacings.buttonHeight,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return MnesisColors.primaryOrange.withValues(alpha: MnesisColors.opacityDisabled);
            }
            return MnesisColors.primaryOrange;
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
                    MnesisColors.primaryOrange,
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
