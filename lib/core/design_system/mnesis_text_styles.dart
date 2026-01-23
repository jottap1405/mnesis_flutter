import 'package:flutter/material.dart';
import 'mnesis_colors.dart';

/// Mnesis typography system with Inter font family.
///
/// This typography scale is designed for medical assistant interface with:
/// - **Clear Hierarchy**: Display > Headline > Body > Label > Caption
/// - **Readability**: Optimized line heights and letter spacing
/// - **Accessibility**: High contrast ratios with background colors
///
/// ## Font Family
/// Primary: **Inter** (system fallback: SF Pro Display / Roboto)
///
/// ## Type Scale
/// - **Display**: Large titles and splash screens (36-24px)
/// - **Headline**: Section headers (20-16px)
/// - **Body**: Main content and chat messages (18-14px)
/// - **Label**: Buttons and form labels (16-12px)
/// - **Caption**: Timestamps and metadata (12px)
/// - **Overline**: Section tags (11px)
///
/// Example:
/// ```dart
/// Text(
///   'Mnesis',
///   style: MnesisTextStyles.displayLarge,
/// )
/// ```
///
/// See also:
/// * [MnesisColors] for color system
/// * [MnesisSpacing] for spacing system
/// * Technical docs: `documentation/mnesis/MNESIS_DESIGN_SYSTEM.md`
class MnesisTextStyles {
  MnesisTextStyles._(); // Private constructor to prevent instantiation

  /// Primary font family for the app.
  ///
  /// Falls back to system fonts (SF Pro Display on iOS, Roboto on Android).
  static const String fontFamily = 'Inter';

  // ============================================================================
  // DISPLAY STYLES (Headers, Titles)
  // ============================================================================

  /// Display large style - app title and splash screen.
  ///
  /// Use for:
  /// - App logo text
  /// - Splash screen title
  /// - Hero headings
  ///
  /// **Size**: 36px
  /// **Weight**: Bold (700)
  /// **Line Height**: 1.2 (43.2px)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: MnesisColors.textPrimary,
  );

  /// Display medium style - main page titles.
  ///
  /// Use for:
  /// - Page titles
  /// - Screen headers
  ///
  /// **Size**: 28px
  /// **Weight**: Bold (700)
  /// **Line Height**: 1.25 (35px)
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.25,
    color: MnesisColors.textPrimary,
  );

  /// Display small style - card headers.
  ///
  /// Use for:
  /// - Card titles
  /// - Dialog headers
  ///
  /// **Size**: 24px
  /// **Weight**: SemiBold (600)
  /// **Line Height**: 1.3 (31.2px)
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  // ============================================================================
  // HEADLINE STYLES
  // ============================================================================

  /// Headline large style - section headers.
  ///
  /// Use for:
  /// - Section headers
  /// - List group titles
  ///
  /// **Size**: 20px
  /// **Weight**: SemiBold (600)
  /// **Line Height**: 1.4 (28px)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  /// Headline medium style - subsection headers.
  ///
  /// Use for:
  /// - Subsection headers
  /// - Form section titles
  ///
  /// **Size**: 18px
  /// **Weight**: SemiBold (600)
  /// **Line Height**: 1.4 (25.2px)
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  /// Headline small style - minor headers.
  ///
  /// Use for:
  /// - Minor section headers
  /// - Emphasized labels
  ///
  /// **Size**: 16px
  /// **Weight**: SemiBold (600)
  /// **Line Height**: 1.5 (24px)
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  // ============================================================================
  // BODY STYLES (Main Content)
  // ============================================================================

  /// Body large style - main chat messages.
  ///
  /// Use for:
  /// - Chat message text
  /// - Main content areas
  /// - Important descriptions
  ///
  /// **Size**: 18px
  /// **Weight**: Regular (400)
  /// **Line Height**: 1.5 (27px)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  /// Body medium style - standard body text.
  ///
  /// Use for:
  /// - Standard body text
  /// - List item text
  /// - Form descriptions
  ///
  /// **Size**: 16px
  /// **Weight**: Regular (400)
  /// **Line Height**: 1.5 (24px)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: MnesisColors.textPrimary,
  );

  /// Body small style - secondary body text.
  ///
  /// Use for:
  /// - Supporting text
  /// - Small paragraphs
  /// - Help text
  ///
  /// **Size**: 14px
  /// **Weight**: Regular (400)
  /// **Line Height**: 1.5 (21px)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: MnesisColors.textSecondary,
  );

  // ============================================================================
  // LABEL STYLES (Buttons, Input Labels)
  // ============================================================================

  /// Button text style.
  ///
  /// Use for all button labels.
  ///
  /// **Size**: 16px
  /// **Weight**: Semi-bold (600)
  /// **Letter Spacing**: 0.5px
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Label large style - primary button text.
  ///
  /// Use for:
  /// - Primary button labels
  /// - Tab labels
  /// - Large input labels
  ///
  /// **Size**: 16px
  /// **Weight**: Medium (500)
  /// **Line Height**: 1.25 (20px)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0.1,
    color: MnesisColors.textPrimary,
  );

  /// Label medium style - standard button text.
  ///
  /// Use for:
  /// - Standard button labels
  /// - Form field labels
  /// - Menu items
  ///
  /// **Size**: 14px
  /// **Weight**: Medium (500)
  /// **Line Height**: 1.3 (18.2px)
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: MnesisColors.textPrimary,
  );

  /// Label small style - small button and chip text.
  ///
  /// Use for:
  /// - Small buttons
  /// - Chips
  /// - Badges
  ///
  /// **Size**: 12px
  /// **Weight**: Medium (500)
  /// **Line Height**: 1.3 (15.6px)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: MnesisColors.textSecondary,
  );

  // ============================================================================
  // CAPTION & OVERLINE STYLES
  // ============================================================================

  /// Caption style - timestamps and metadata.
  ///
  /// Use for:
  /// - Chat timestamps
  /// - Metadata text
  /// - Help hints
  /// - Footer text
  ///
  /// **Size**: 12px
  /// **Weight**: Regular (400)
  /// **Line Height**: 1.3 (15.6px)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
    color: MnesisColors.textTertiary,
  );

  /// Overline style - section tags and labels.
  ///
  /// Use for:
  /// - Section tags
  /// - Category labels
  /// - Uppercase labels
  ///
  /// **Size**: 11px
  /// **Weight**: SemiBold (600)
  /// **Line Height**: 1.4 (15.4px)
  /// **Note**: Typically used with uppercase text
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 1.5,
    color: MnesisColors.textSecondary,
  );
}
