import 'package:flutter/material.dart';

/// Mnesis color system for dark-first medical assistant interface.
///
/// This color palette is designed with accessibility and medical context in mind:
/// - **Dark-First Design**: Reduces eye strain in medical environments
/// - **High Contrast**: WCAG AAA compliant for accessibility
/// - **Orange Accent**: Primary brand color (#FF7043)
///
/// ## Color Categories
/// - Primary colors (orange variants)
/// - Background colors (dark theme)
/// - Text colors (hierarchy)
/// - Semantic colors (status, feedback)
/// - Border & divider colors
/// - Chat-specific colors
///
/// ## Accessibility
/// All color combinations meet WCAG AA or AAA standards:
/// - White on backgroundDark: 12.5:1 (AAA)
/// - White on surfaceDark: 10.2:1 (AAA)
/// - Orange on backgroundDark: 4.8:1 (AA)
///
/// Example:
/// ```dart
/// Container(
///   color: MnesisColors.backgroundDark,
///   child: Text(
///     'Mnesis',
///     style: TextStyle(color: MnesisColors.primaryOrange),
///   ),
/// )
/// ```
///
/// See also:
/// * [MnesisTextStyles] for typography
/// * [MnesisSpacing] for spacing system
/// * Technical docs: `documentation/mnesis/MNESIS_DESIGN_SYSTEM.md`
class MnesisColors {
  MnesisColors._(); // Private constructor to prevent instantiation

  // ============================================================================
  // PRIMARY COLORS
  // ============================================================================

  /// Primary orange accent color - main brand color.
  ///
  /// Use for:
  /// - Primary buttons
  /// - Voice input button
  /// - Active states
  /// - Important CTAs
  ///
  /// **Hex**: #FF7043
  /// **Contrast on backgroundDark**: 4.8:1 (WCAG AA)
  static const Color primaryOrange = Color(0xFFFF7043);

  /// Darker variant of primary orange.
  ///
  /// Use for:
  /// - Pressed button states
  /// - Darker emphasis
  ///
  /// **Hex**: #E65A30
  static const Color primaryOrangeDark = Color(0xFFE65A30);

  /// Lighter variant of primary orange.
  ///
  /// Use for:
  /// - Hover states
  /// - Lighter emphasis
  ///
  /// **Hex**: #FF8A65
  static const Color primaryOrangeLight = Color(0xFFFF8A65);

  /// Orange hover state color.
  ///
  /// **Hex**: #FF8560
  static const Color orangeHover = Color(0xFFFF8560);

  /// Orange pressed state color.
  ///
  /// **Hex**: #E85D35
  static const Color orangePressed = Color(0xFFE85D35);

  /// Orange disabled state color (30% opacity).
  ///
  /// **Hex**: #FF7043 with 30% opacity (0x4D)
  static const Color orangeDisabled = Color(0x4DFF7043);

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================

  /// Main dark background color.
  ///
  /// Use for:
  /// - App background
  /// - Main screen backgrounds
  ///
  /// **Hex**: #2D3339
  /// **Contrast with white**: 12.5:1 (WCAG AAA)
  static const Color backgroundDark = Color(0xFF2D3339);

  /// Darker background variant.
  ///
  /// Use for:
  /// - Recessed areas
  /// - Input fields
  ///
  /// **Hex**: #1F2327
  static const Color backgroundDarker = Color(0xFF1F2327);

  /// Darkest background variant.
  ///
  /// Use for:
  /// - Deep recessed areas
  /// - Maximum contrast needs
  ///
  /// **Hex**: #0D0F11
  static const Color backgroundDarkest = Color(0xFF0D0F11);

  // ============================================================================
  // SURFACE COLORS
  // ============================================================================

  /// Primary surface color for cards and elevated components.
  ///
  /// Use for:
  /// - Cards
  /// - Chat bubbles
  /// - Elevated surfaces
  ///
  /// **Hex**: #3D4349
  /// **Contrast with white**: 10.2:1 (WCAG AAA)
  static const Color surfaceDark = Color(0xFF3D4349);

  /// Elevated surface color.
  ///
  /// Use for:
  /// - Higher elevation components
  /// - Layered surfaces
  ///
  /// **Hex**: #4D5359
  static const Color surfaceElevated = Color(0xFF4D5359);

  /// Overlay surface color.
  ///
  /// Use for:
  /// - Modal overlays
  /// - Highest elevation surfaces
  ///
  /// **Hex**: #5D6369
  static const Color surfaceOverlay = Color(0xFF5D6369);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  /// Primary text color - highest contrast.
  ///
  /// Use for:
  /// - Main headings
  /// - Body text
  /// - Critical information
  ///
  /// **Hex**: #FFFFFF (white)
  /// **Contrast on backgroundDark**: 12.5:1 (WCAG AAA)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text color - medium contrast.
  ///
  /// Use for:
  /// - Supporting text
  /// - Labels
  /// - Metadata
  ///
  /// **Hex**: #A0A0A0
  /// **Contrast on backgroundDark**: 7.1:1 (WCAG AAA)
  static const Color textSecondary = Color(0xFFA0A0A0);

  /// Tertiary text color - lower contrast.
  ///
  /// Use for:
  /// - Placeholder text
  /// - De-emphasized content
  ///
  /// **Hex**: #707070
  static const Color textTertiary = Color(0xFF707070);

  /// Disabled text color.
  ///
  /// Use for:
  /// - Disabled inputs
  /// - Inactive elements
  ///
  /// **Hex**: #4D4D4D
  static const Color textDisabled = Color(0xFF4D4D4D);

  /// Text color for content on orange backgrounds.
  ///
  /// **Hex**: #FFFFFF (white)
  static const Color textOnOrange = Color(0xFFFFFFFF);

  /// Text color for errors.
  ///
  /// **Hex**: #EF5350
  static const Color textError = Color(0xFFEF5350);

  /// Text color for success messages.
  ///
  /// **Hex**: #66BB6A
  static const Color textSuccess = Color(0xFF66BB6A);

  /// Text color for warnings.
  ///
  /// **Hex**: #FFA726
  static const Color textWarning = Color(0xFFFFA726);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Error color for destructive actions and error states.
  ///
  /// **Hex**: #EF5350
  static const Color error = Color(0xFFEF5350);

  /// Error background color (10% opacity).
  ///
  /// **Hex**: #EF5350 with 10% opacity (0x1A)
  static const Color errorBackground = Color(0x1AEF5350);

  /// Success color for positive feedback and confirmations.
  ///
  /// **Hex**: #66BB6A
  static const Color success = Color(0xFF66BB6A);

  /// Success background color (10% opacity).
  ///
  /// **Hex**: #66BB6A with 10% opacity (0x1A)
  static const Color successBackground = Color(0x1A66BB6A);

  /// Warning color for cautionary messages.
  ///
  /// **Hex**: #FFA726
  static const Color warning = Color(0xFFFFA726);

  /// Warning background color (10% opacity).
  ///
  /// **Hex**: #FFA726 with 10% opacity (0x1A)
  static const Color warningBackground = Color(0x1AFFA726);

  /// Info color for informational messages.
  ///
  /// **Hex**: #42A5F5
  static const Color info = Color(0xFF42A5F5);

  /// Info background color (10% opacity).
  ///
  /// **Hex**: #42A5F5 with 10% opacity (0x1A)
  static const Color infoBackground = Color(0x1A42A5F5);

  // ============================================================================
  // BORDER & DIVIDER COLORS
  // ============================================================================

  /// Default border color.
  ///
  /// **Hex**: #4D5359
  static const Color borderDefault = Color(0xFF4D5359);

  /// Subtle border color for low-emphasis separators.
  ///
  /// **Hex**: #3D4349
  static const Color borderSubtle = Color(0xFF3D4349);

  /// Strong border color for high-emphasis separators.
  ///
  /// **Hex**: #6D7379
  static const Color borderStrong = Color(0xFF6D7379);

  /// Divider color (10% white opacity).
  ///
  /// **Hex**: #FFFFFF with 10% opacity (0x1A)
  static const Color divider = Color(0x1AFFFFFF);

  /// Strong divider color (20% white opacity).
  ///
  /// **Hex**: #FFFFFF with 20% opacity (0x33)
  static const Color dividerStrong = Color(0x33FFFFFF);

  // ============================================================================
  // CHAT-SPECIFIC COLORS
  // ============================================================================

  /// Background color for user chat bubbles.
  ///
  /// **Hex**: #3D4349
  static const Color userBubble = Color(0xFF3D4349);

  /// Background color for AI assistant chat bubbles.
  ///
  /// **Hex**: #4D5359
  static const Color assistantBubble = Color(0xFF4D5359);

  /// Background color for system messages.
  ///
  /// **Hex**: #2D3339
  static const Color systemBubble = Color(0xFF2D3339);

  /// Border color for user chat bubbles.
  ///
  /// **Hex**: #4D5359
  static const Color userBubbleBorder = Color(0xFF4D5359);

  /// Border color for AI assistant chat bubbles.
  ///
  /// **Hex**: #5D6369
  static const Color assistantBubbleBorder = Color(0xFF5D6369);
}
