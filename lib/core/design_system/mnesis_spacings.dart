/// Mnesis spacing and sizing system based on 4px base unit.
///
/// This spacing scale ensures consistent rhythm and visual hierarchy:
/// - **Base Unit**: 4px foundation for all measurements
/// - **Predictable Scale**: Multiples of base unit (4, 8, 12, 16, 24, 32, 48, 64)
/// - **Semantic Names**: Contextual spacing (tiny, small, medium, large)
/// - **Component-Specific**: Dedicated spacing for UI elements
///
/// ## Base Unit Philosophy
/// The 4px base unit ensures:
/// - Alignment across all screen densities
/// - Easy mental math (spacing = base × multiplier)
/// - Compatibility with 8px grid systems
///
/// ## Spacing Scale
/// - **xs**: 4px - Minimal spacing (icon padding, tight gaps)
/// - **sm**: 8px - Compact spacing (chip padding, small gaps)
/// - **md**: 12px - Default spacing (input padding, list gaps)
/// - **lg**: 16px - Comfortable spacing (button padding, section gaps)
/// - **xl**: 24px - Generous spacing (card padding, major gaps)
/// - **2xl**: 32px - Large spacing (screen padding, section separation)
/// - **3xl**: 48px - Extra large spacing (hero sections, major divisions)
/// - **4xl**: 64px - Massive spacing (splash screens, dramatic separation)
///
/// ## Border Radius Scale
/// Consistent corner rounding for UI elements.
///
/// Example:
/// ```dart
/// Container(
///   padding: EdgeInsets.all(MnesisSpacings.lg),
///   margin: EdgeInsets.symmetric(
///     horizontal: MnesisSpacings.xl,
///     vertical: MnesisSpacings.md,
///   ),
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(MnesisSpacings.radiusMd),
///   ),
/// )
/// ```
///
/// See also:
/// * [MnesisColors] for color system
/// * [MnesisTextStyles] for typography
/// * Technical docs: `documentation/mnesis/MNESIS_DESIGN_SYSTEM.md`
class MnesisSpacings {
  MnesisSpacings._(); // Private constructor to prevent instantiation

  // ============================================================================
  // BASE UNIT
  // ============================================================================

  /// Base spacing unit (4px).
  ///
  /// All spacing values are multiples of this base unit to ensure
  /// consistent alignment and visual rhythm.
  static const double baseUnit = 4.0;

  // ============================================================================
  // SPACING SCALE (Multiples of Base Unit)
  // ============================================================================

  /// Extra small spacing - 4px (1 × base unit).
  ///
  /// Use for:
  /// - Icon padding
  /// - Tight gaps between related elements
  /// - Badge spacing
  ///
  /// **Size**: 4px
  static const double xs = 4.0;

  /// Small spacing - 8px (2 × base unit).
  ///
  /// Use for:
  /// - Chip padding
  /// - Small gaps in compact layouts
  /// - List item internal spacing
  ///
  /// **Size**: 8px
  static const double sm = 8.0;

  /// Medium spacing - 12px (3 × base unit).
  ///
  /// Use for:
  /// - Input field padding
  /// - Default list gaps
  /// - Small button padding
  ///
  /// **Size**: 12px
  static const double md = 12.0;

  /// Large spacing - 16px (4 × base unit).
  ///
  /// Use for:
  /// - Button padding
  /// - Card internal padding
  /// - Section gaps
  /// - Default component spacing
  ///
  /// **Size**: 16px
  static const double lg = 16.0;

  /// Extra large spacing - 24px (6 × base unit).
  ///
  /// Use for:
  /// - Card padding
  /// - Major section gaps
  /// - Screen horizontal padding
  ///
  /// **Size**: 24px
  static const double xl = 24.0;

  /// 2X extra large spacing - 32px (8 × base unit).
  ///
  /// Use for:
  /// - Screen padding (top/bottom)
  /// - Major component separation
  /// - Section divisions
  ///
  /// **Size**: 32px
  static const double xl2 = 32.0;

  /// 3X extra large spacing - 48px (12 × base unit).
  ///
  /// Use for:
  /// - Hero section spacing
  /// - Major page divisions
  /// - Large feature spacing
  ///
  /// **Size**: 48px
  static const double xl3 = 48.0;

  /// 4X extra large spacing - 64px (16 × base unit).
  ///
  /// Use for:
  /// - Splash screen spacing
  /// - Dramatic visual separation
  /// - Hero components
  ///
  /// **Size**: 64px
  static const double xl4 = 64.0;

  // ============================================================================
  // SEMANTIC SPACING (Contextual Names)
  // ============================================================================

  /// Minimal spacing for very tight layouts.
  ///
  /// **Size**: 4px (xs)
  static const double tiny = xs;

  /// Small spacing for compact layouts.
  ///
  /// **Size**: 8px (sm)
  static const double small = sm;

  /// Default spacing for most use cases.
  ///
  /// **Size**: 16px (lg)
  static const double medium = lg;

  /// Large spacing for generous layouts.
  ///
  /// **Size**: 24px (xl)
  static const double large = xl;

  /// Extra large spacing for major sections.
  ///
  /// **Size**: 32px (xl2)
  static const double extraLarge = xl2;

  // ============================================================================
  // COMPONENT-SPECIFIC SPACING
  // ============================================================================

  /// Chat bubble padding.
  ///
  /// **Horizontal**: 16px
  /// **Vertical**: 12px
  static const double chatBubblePaddingHorizontal = lg;
  static const double chatBubblePaddingVertical = md;

  /// Gap between chat bubbles.
  ///
  /// **Size**: 12px
  static const double chatBubbleGap = md;

  /// Input field padding.
  ///
  /// **Horizontal**: 16px
  /// **Vertical**: 12px
  static const double inputPaddingHorizontal = lg;
  static const double inputPaddingVertical = md;

  /// Button padding.
  ///
  /// **Horizontal**: 24px (large buttons)
  /// **Vertical**: 12px (large buttons)
  static const double buttonPaddingHorizontal = xl;
  static const double buttonPaddingVertical = md;

  /// Button padding for small buttons.
  ///
  /// **Horizontal**: 16px
  /// **Vertical**: 8px
  static const double buttonSmallPaddingHorizontal = lg;
  static const double buttonSmallPaddingVertical = sm;

  /// Standard button height.
  ///
  /// Use for:
  /// - Primary buttons
  /// - Secondary buttons
  /// - Text buttons
  ///
  /// **Size**: 48px (Material Design minimum touch target)
  static const double buttonHeight = 48.0;

  /// Icon button padding/size.
  ///
  /// **Size**: 48px (minimum tap target)
  static const double iconButtonSize = 48.0;

  /// Icon size for various contexts.
  ///
  /// **Small**: 16px
  /// **Medium**: 24px
  /// **Large**: 32px
  static const double iconSizeSmall = lg;
  static const double iconSizeMedium = xl;
  static const double iconSizeLarge = xl2;

  /// Icon size for buttons.
  ///
  /// Use for:
  /// - Button icons
  ///
  /// **Size**: 20px
  static const double iconSizeButton = 20.0;

  /// Loading indicator size for buttons.
  ///
  /// Use for:
  /// - Button loading states (CircularProgressIndicator)
  ///
  /// **Size**: 20px
  static const double progressIndicatorSize = 20.0;

  /// Loading indicator stroke width.
  ///
  /// Use for:
  /// - CircularProgressIndicator strokeWidth
  ///
  /// **Size**: 2px
  static const double progressIndicatorStroke = 2.0;

  /// Border width for outlined buttons.
  ///
  /// Use for:
  /// - Secondary button borders
  /// - Outlined components
  ///
  /// **Size**: 1.5px
  static const double borderWidthButton = 1.5;

  /// Screen edge padding.
  ///
  /// **Horizontal**: 24px
  /// **Vertical**: 24px
  static const double screenPaddingHorizontal = xl;
  static const double screenPaddingVertical = xl;

  /// Card padding.
  ///
  /// **All sides**: 16px
  static const double cardPadding = lg;

  /// List item height.
  ///
  /// **Minimum**: 56px (Material Design standard)
  static const double listItemHeight = 56.0;

  /// List item padding.
  ///
  /// **Horizontal**: 16px
  /// **Vertical**: 8px
  static const double listItemPaddingHorizontal = lg;
  static const double listItemPaddingVertical = sm;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  /// No border radius (sharp corners).
  ///
  /// **Size**: 0px
  static const double radiusNone = 0.0;

  /// Extra small border radius.
  ///
  /// Use for:
  /// - Badges
  /// - Small chips
  ///
  /// **Size**: 4px
  static const double radiusXs = 4.0;

  /// Small border radius.
  ///
  /// Use for:
  /// - Buttons
  /// - Input fields
  /// - Small cards
  ///
  /// **Size**: 8px
  static const double radiusSm = 8.0;

  /// Medium border radius (default).
  ///
  /// Use for:
  /// - Cards
  /// - Chat bubbles
  /// - Containers
  ///
  /// **Size**: 12px
  static const double radiusMd = 12.0;

  /// Large border radius.
  ///
  /// Use for:
  /// - Large cards
  /// - Modals
  /// - Bottom sheets
  ///
  /// **Size**: 16px
  static const double radiusLg = 16.0;

  /// Extra large border radius.
  ///
  /// Use for:
  /// - Hero cards
  /// - Special containers
  ///
  /// **Size**: 24px
  static const double radiusXl = 24.0;

  /// Pill/circular border radius.
  ///
  /// Use for:
  /// - Pill buttons
  /// - Pills/tags
  /// - FAB buttons
  ///
  /// **Size**: 999px (ensures fully rounded regardless of size)
  static const double radiusPill = 999.0;

  /// Alias for large border radius (pill-shaped buttons).
  ///
  /// Use for:
  /// - Button components
  /// - Pill-shaped elements
  ///
  /// **Size**: 24px (same as radiusXl)
  static const double borderRadiusLg = radiusXl;

  /// Circular border radius (50% of size).
  ///
  /// Use for:
  /// - Avatar images
  /// - Icon backgrounds
  /// - Circular buttons
  ///
  /// **Note**: Use with `borderRadius: BorderRadius.circular(size / 2)`
  static const double radiusCircular = 9999.0;

  // ============================================================================
  // ELEVATION/SHADOW DISTANCES
  // ============================================================================

  /// Elevation level 0 (no elevation).
  ///
  /// **Size**: 0px
  static const double elevation0 = 0.0;

  /// Elevation level 1 (subtle elevation).
  ///
  /// Use for:
  /// - Cards on background
  /// - Raised buttons
  ///
  /// **Size**: 2px
  static const double elevation1 = 2.0;

  /// Elevation level 2 (moderate elevation).
  ///
  /// Use for:
  /// - Floating elements
  /// - Dropdowns
  ///
  /// **Size**: 4px
  static const double elevation2 = 4.0;

  /// Elevation level 3 (high elevation).
  ///
  /// Use for:
  /// - Modals
  /// - Dialogs
  ///
  /// **Size**: 8px
  static const double elevation3 = 8.0;

  /// Elevation level 4 (maximum elevation).
  ///
  /// Use for:
  /// - Navigation drawers
  /// - Full-screen overlays
  ///
  /// **Size**: 16px
  static const double elevation4 = 16.0;

  // ============================================================================
  // UI COMPONENT SIZES
  // ============================================================================

  /// Navigation bar height (Material Design recommendation).
  ///
  /// Use for:
  /// - Bottom navigation bar
  /// - Custom navigation components
  ///
  /// **Size**: 80px
  static const double navigationBarHeight = 80.0;

  /// Color swatch preview size for design system showcase.
  ///
  /// Use for:
  /// - Color palette displays
  /// - Design system previews
  ///
  /// **Size**: 48px
  static const double colorSwatchSize = 48.0;

  /// Minimum touch target size for accessibility (Material Design recommendation).
  ///
  /// Use for:
  /// - Clickable areas
  /// - Interactive components
  ///
  /// **Size**: 48px
  static const double minTouchTarget = 48.0;
}
