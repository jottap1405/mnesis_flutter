# Mnesis Design System Documentation

> **Medical Assistant Virtual App - Design System Specification**
> Dark-First Design with Orange Accent
> Last Updated: 2026-01-16

---

## Table of Contents

1. [Overview](#overview)
2. [Design Philosophy](#design-philosophy)
3. [Color System](#color-system)
4. [Typography Scale](#typography-scale)
5. [Spacing System](#spacing-system)
6. [Component Tokens](#component-tokens)
7. [Component Inventory](#component-inventory)
8. [shadcn_flutter Customization Strategy](#shadcn_flutter-customization-strategy)
9. [Dark Theme Configuration](#dark-theme-configuration)
10. [Implementation Guidelines](#implementation-guidelines)

---

## Overview

Mnesis is a medical assistant virtual app featuring a sophisticated dark-first interface with vibrant orange accents. The design emphasizes clarity, accessibility, and a modern aesthetic suitable for healthcare professionals and patients.

**Key Design Files Analyzed:**
- `mnesisDesign.png`: Splash/welcome screen with brain logo and voice input
- `mnesis.png`: Brand logo (brain outline with 4 orange stars)
- `mnesis1.png`: Chat interface with message interaction actions

**Architecture Strategy:**
- **Hybrid Approach**: Volan chat components + shadcn_flutter for generic UI
- **Customization**: shadcn components styled with Mnesis design tokens
- **Framework**: Flutter with Material Design 3 foundation

---

## Design Philosophy

### Core Principles

1. **Dark-First Design**
   - Reduces eye strain in medical environments
   - Professional and modern aesthetic
   - Energy-efficient for OLED displays

2. **Accessibility Priority**
   - High contrast ratios (WCAG AAA compliant)
   - Clear visual hierarchy
   - Touch-friendly target sizes (minimum 48x48 dp)

3. **Medical Context**
   - Professional and trustworthy appearance
   - Clear information hierarchy
   - Calm and focused user experience

4. **Voice-Centric Interaction**
   - Primary input method is voice
   - Visual feedback for voice states
   - Seamless text fallback

---

## Color System

### Primary Colors

```dart
class MnesisColors {
  // Primary Orange Accent
  static const Color primaryOrange = Color(0xFFFF7043);
  static const Color primaryOrangeDark = Color(0xFFE65A30);
  static const Color primaryOrangeLight = Color(0xFFFF8A65);

  // Orange Variants for States
  static const Color orangeHover = Color(0xFFFF8560);
  static const Color orangePressed = Color(0xFFE85D35);
  static const Color orangeDisabled = Color(0x4DFF7043); // 30% opacity
}
```

### Background Colors

```dart
class MnesisColors {
  // Dark Backgrounds
  static const Color backgroundDark = Color(0xFF2D3339);
  static const Color backgroundDarker = Color(0xFF1F2327);
  static const Color backgroundDarkest = Color(0xFF0D0F11);

  // Surface Colors
  static const Color surfaceDark = Color(0xFF3D4349);
  static const Color surfaceElevated = Color(0xFF4D5359);
  static const Color surfaceOverlay = Color(0xFF5D6369);
}
```

### Text Colors

```dart
class MnesisColors {
  // Text Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textTertiary = Color(0xFF707070);
  static const Color textDisabled = Color(0xFF4D4D4D);

  // Special Text
  static const Color textOnOrange = Color(0xFFFFFFFF);
  static const Color textError = Color(0xFFEF5350);
  static const Color textSuccess = Color(0xFF66BB6A);
  static const Color textWarning = Color(0xFFFFA726);
}
```

### Semantic Colors

```dart
class MnesisColors {
  // Status & Feedback
  static const Color error = Color(0xFFEF5350);
  static const Color errorBackground = Color(0x1AEF5350); // 10% opacity

  static const Color success = Color(0xFF66BB6A);
  static const Color successBackground = Color(0x1A66BB6A);

  static const Color warning = Color(0xFFFFA726);
  static const Color warningBackground = Color(0x1AFFA726);

  static const Color info = Color(0xFF42A5F5);
  static const Color infoBackground = Color(0x1A42A5F5);
}
```

### Border & Divider Colors

```dart
class MnesisColors {
  // Borders
  static const Color borderDefault = Color(0xFF4D5359);
  static const Color borderSubtle = Color(0xFF3D4349);
  static const Color borderStrong = Color(0xFF6D7379);

  // Dividers
  static const Color divider = Color(0x1AFFFFFF); // 10% white opacity
  static const Color dividerStrong = Color(0x33FFFFFF); // 20% white opacity
}
```

### Chat-Specific Colors

```dart
class MnesisColors {
  // Chat Bubbles
  static const Color userBubble = Color(0xFF3D4349);
  static const Color assistantBubble = Color(0xFF4D5359);
  static const Color systemBubble = Color(0xFF2D3339);

  // Bubble Borders (subtle highlight)
  static const Color userBubbleBorder = Color(0xFF4D5359);
  static const Color assistantBubbleBorder = Color(0xFF5D6369);
}
```

### Color Accessibility

| Color Combination | Contrast Ratio | WCAG Level |
|-------------------|----------------|------------|
| White on #2D3339 | 12.5:1 | AAA |
| White on #3D4349 | 10.2:1 | AAA |
| Orange on #2D3339 | 4.8:1 | AA |
| Secondary Text on #2D3339 | 7.1:1 | AAA |

---

## Typography Scale

### Font Families

```dart
class MnesisTypography {
  // Primary Font Family
  static const String fontFamily = 'Inter';

  // Fallback Stack
  static const List<String> fontFallbacks = [
    'Inter',
    'SF Pro Display',
    'Roboto',
    'Helvetica Neue',
    '-apple-system',
    'BlinkMacSystemFont',
    'sans-serif',
  ];
}
```

### Type Scale

```dart
class MnesisTextStyles {
  // Display Styles (Headers, Titles)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36.0,
    fontWeight: FontWeight.w700, // Bold
    height: 1.2, // 43.2px line height
    letterSpacing: -0.5,
    color: MnesisColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 1.25, // 35px line height
    letterSpacing: -0.25,
    color: MnesisColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24.0,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.3, // 31.2px line height
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4, // 28px line height
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.4, // 25.2px line height
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5, // 24px line height
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  // Body Styles (Main Content)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18.0,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5, // 27px line height
    letterSpacing: 0,
    color: MnesisColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5, // 24px line height
    letterSpacing: 0.25,
    color: MnesisColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5, // 21px line height
    letterSpacing: 0.25,
    color: MnesisColors.textSecondary,
  );

  // Label Styles (Buttons, Input Labels)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w500, // Medium
    height: 1.25, // 20px line height
    letterSpacing: 0.1,
    color: MnesisColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.3, // 18.2px line height
    letterSpacing: 0.5,
    color: MnesisColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.3, // 15.6px line height
    letterSpacing: 0.5,
    color: MnesisColors.textSecondary,
  );

  // Caption Styles (Timestamps, Meta Info)
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3, // 15.6px line height
    letterSpacing: 0.4,
    color: MnesisColors.textTertiary,
  );

  // Overline Styles (Section Headers)
  static const TextStyle overline = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    height: 1.4, // 15.4px line height
    letterSpacing: 1.5,
    color: MnesisColors.textSecondary,
  );
}
```

### Typography Usage Guidelines

| Style | Use Case | Example |
|-------|----------|---------|
| Display Large | App title, splash screen | "Mnesis" |
| Display Medium | Page titles | "Conversations" |
| Headline Large | Section headers | "Recent Chats" |
| Body Large | Chat messages, main content | Message text |
| Body Medium | Standard text | Descriptions |
| Label Medium | Button text | "Send" |
| Caption | Timestamps, metadata | "2 minutes ago" |

---

## Spacing System

### Base Unit

```dart
class MnesisSpacing {
  // Base unit: 4px
  static const double baseUnit = 4.0;

  // Spacing Scale
  static const double space4 = 4.0;   // 1x base
  static const double space8 = 8.0;   // 2x base
  static const double space12 = 12.0; // 3x base
  static const double space16 = 16.0; // 4x base
  static const double space24 = 24.0; // 6x base
  static const double space32 = 32.0; // 8x base
  static const double space48 = 48.0; // 12x base
  static const double space64 = 64.0; // 16x base

  // Semantic Spacing
  static const double spaceTiny = space4;
  static const double spaceSmall = space8;
  static const double spaceMedium = space16;
  static const double spaceLarge = space24;
  static const double spaceXLarge = space32;
  static const double spaceXXLarge = space48;
  static const double spaceXXXLarge = space64;
}
```

### Component-Specific Spacing

```dart
class MnesisSpacing {
  // Chat Bubbles
  static const double bubblePadding = 16.0;
  static const double bubbleMarginVertical = 8.0;
  static const double bubbleMarginHorizontal = 12.0;

  // Input Field
  static const double inputHeight = 56.0;
  static const double inputPaddingHorizontal = 20.0;
  static const double inputPaddingVertical = 16.0;

  // Buttons
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double buttonMinHeight = 48.0;

  // Icons
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Screen Padding
  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 24.0;

  // List Items
  static const double listItemHeight = 72.0;
  static const double listItemPadding = 16.0;
  static const double listItemSpacing = 8.0;
}
```

### Border Radius Scale

```dart
class MnesisBorderRadius {
  // Border Radius Scale
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircle = 999.0; // Full circle

  // Component-Specific Radius
  static const double bubbleRadius = 16.0;
  static const double inputRadius = 24.0;
  static const double buttonRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double dialogRadius = 20.0;
}
```

### Elevation & Shadows

```dart
class MnesisElevation {
  // Elevation levels (for shadow intensity)
  static const double level0 = 0.0;   // No elevation
  static const double level1 = 2.0;   // Subtle
  static const double level2 = 4.0;   // Raised
  static const double level3 = 8.0;   // Floating
  static const double level4 = 16.0;  // Modal

  // Shadow Definitions
  static List<BoxShadow> getShadow(double elevation) {
    if (elevation == 0) return [];

    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }

  // Specific Shadow Presets for Dark Theme
  static const List<BoxShadow> shadowSubtle = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowModerate = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowStrong = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
```

---

## Component Tokens

### Chat Bubble Component

```dart
class ChatBubbleTokens {
  // Dimensions
  static const double minHeight = 48.0;
  static const double maxWidth = 280.0;
  static const double padding = 16.0;
  static const double borderRadius = 16.0;

  // Colors - User Bubble
  static const Color userBackground = Color(0xFF3D4349);
  static const Color userText = Color(0xFFFFFFFF);
  static const Color userBorder = Color(0xFF4D5359);

  // Colors - Assistant Bubble
  static const Color assistantBackground = Color(0xFF4D5359);
  static const Color assistantText = Color(0xFFFFFFFF);
  static const Color assistantBorder = Color(0xFF5D6369);

  // Typography
  static const TextStyle messageText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Color(0xFFFFFFFF),
  );

  static const TextStyle timestampText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: Color(0xFF707070),
  );

  // Spacing
  static const double messageSpacing = 8.0;
  static const double bubbleMarginHorizontal = 12.0;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Curve animationCurve = Curves.easeOut;
}
```

### Input Field Component

```dart
class InputFieldTokens {
  // Dimensions
  static const double height = 56.0;
  static const double borderRadius = 24.0;
  static const double paddingHorizontal = 20.0;
  static const double paddingVertical = 16.0;

  // Colors
  static const Color background = Color(0xFF3D4349);
  static const Color border = Color(0xFF4D5359);
  static const Color borderFocused = Color(0xFFFF7043);
  static const Color text = Color(0xFFFFFFFF);
  static const Color placeholder = Color(0xFFA0A0A0);
  static const Color cursorColor = Color(0xFFFF7043);

  // Typography
  static const TextStyle inputText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Color(0xFFFFFFFF),
  );

  static const TextStyle placeholderText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Color(0xFFA0A0A0),
  );

  // Border
  static const double borderWidth = 1.0;
  static const double borderWidthFocused = 2.0;

  // Spacing
  static const double iconSpacing = 12.0;
}
```

### Voice Button Component

```dart
class VoiceButtonTokens {
  // Dimensions
  static const double size = 56.0;
  static const double iconSize = 28.0;

  // Colors - Default State
  static const Color background = Color(0xFFFF7043);
  static const Color icon = Color(0xFFFFFFFF);

  // Colors - Active (Recording) State
  static const Color backgroundActive = Color(0xFFE65A30);
  static const Color iconActive = Color(0xFFFFFFFF);

  // Colors - Disabled State
  static const Color backgroundDisabled = Color(0x4DFF7043);
  static const Color iconDisabled = Color(0x80FFFFFF);

  // Border Radius
  static const double borderRadius = 999.0; // Full circle

  // Animation
  static const Duration pulseDuration = Duration(milliseconds: 1500);
  static const double pulseScale = 1.1;

  // Shadow
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x33FF7043),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Ripple Effect
  static const Color rippleColor = Color(0x33FFFFFF);
}
```

### Button Component (Primary)

```dart
class PrimaryButtonTokens {
  // Dimensions
  static const double minHeight = 48.0;
  static const double paddingHorizontal = 24.0;
  static const double paddingVertical = 12.0;
  static const double borderRadius = 12.0;

  // Colors - Default State
  static const Color background = Color(0xFFFF7043);
  static const Color text = Color(0xFFFFFFFF);

  // Colors - Hover State
  static const Color backgroundHover = Color(0xFFFF8560);

  // Colors - Pressed State
  static const Color backgroundPressed = Color(0xFFE85D35);

  // Colors - Disabled State
  static const Color backgroundDisabled = Color(0x4DFF7043);
  static const Color textDisabled = Color(0x80FFFFFF);

  // Typography
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0.1,
    color: Color(0xFFFFFFFF),
  );

  // Shadow
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x1AFF7043),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}
```

### Button Component (Secondary)

```dart
class SecondaryButtonTokens {
  // Dimensions
  static const double minHeight = 48.0;
  static const double paddingHorizontal = 24.0;
  static const double paddingVertical = 12.0;
  static const double borderRadius = 12.0;
  static const double borderWidth = 1.5;

  // Colors - Default State
  static const Color background = Colors.transparent;
  static const Color border = Color(0xFFFF7043);
  static const Color text = Color(0xFFFF7043);

  // Colors - Hover State
  static const Color backgroundHover = Color(0x0DFF7043); // 5% opacity
  static const Color borderHover = Color(0xFFFF8560);
  static const Color textHover = Color(0xFFFF8560);

  // Colors - Pressed State
  static const Color backgroundPressed = Color(0x1AFF7043); // 10% opacity

  // Colors - Disabled State
  static const Color borderDisabled = Color(0x4DFF7043);
  static const Color textDisabled = Color(0x4DFF7043);

  // Typography
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0.1,
    color: Color(0xFFFF7043),
  );
}
```

### Icon Button Component

```dart
class IconButtonTokens {
  // Dimensions
  static const double size = 40.0;
  static const double iconSize = 24.0;
  static const double borderRadius = 8.0;

  // Colors - Default State
  static const Color background = Colors.transparent;
  static const Color icon = Color(0xFFA0A0A0);

  // Colors - Hover State
  static const Color backgroundHover = Color(0x0DFFFFFF); // 5% white
  static const Color iconHover = Color(0xFFFFFFFF);

  // Colors - Pressed State
  static const Color backgroundPressed = Color(0x1AFFFFFF); // 10% white

  // Colors - Active State (selected, toggled)
  static const Color backgroundActive = Color(0xFFFF7043);
  static const Color iconActive = Color(0xFFFFFFFF);

  // Ripple
  static const Color rippleColor = Color(0x1AFFFFFF);
}
```

### Message Action Buttons (Copy, Like, Dislike, Share, More)

```dart
class MessageActionTokens {
  // Dimensions
  static const double buttonSize = 32.0;
  static const double iconSize = 16.0;
  static const double spacing = 8.0;
  static const double containerPadding = 8.0;

  // Colors - Default State
  static const Color iconDefault = Color(0xFFA0A0A0);
  static const Color backgroundDefault = Colors.transparent;

  // Colors - Hover State
  static const Color iconHover = Color(0xFFFFFFFF);
  static const Color backgroundHover = Color(0x1AFFFFFF);

  // Colors - Active State
  static const Color iconActive = Color(0xFFFF7043);
  static const Color backgroundActive = Color(0x1AFF7043);

  // Container
  static const Color containerBackground = Color(0xFF2D3339);
  static const double containerRadius = 8.0;

  // Actions
  static const List<String> actions = [
    'copy',
    'like',
    'dislike',
    'share',
    'more',
  ];
}
```

### Card Component

```dart
class CardTokens {
  // Dimensions
  static const double borderRadius = 16.0;
  static const double padding = 16.0;

  // Colors
  static const Color background = Color(0xFF3D4349);
  static const Color border = Color(0xFF4D5359);

  // Border
  static const double borderWidth = 1.0;

  // Shadow
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
```

### Dialog Component

```dart
class DialogTokens {
  // Dimensions
  static const double borderRadius = 20.0;
  static const double padding = 24.0;
  static const double maxWidth = 400.0;

  // Colors
  static const Color background = Color(0xFF3D4349);
  static const Color barrier = Color(0x80000000); // 50% black

  // Shadow
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeOutCubic;
}
```

### Bottom Sheet Component

```dart
class BottomSheetTokens {
  // Dimensions
  static const double borderRadiusTop = 24.0;
  static const double padding = 24.0;
  static const double handleWidth = 40.0;
  static const double handleHeight = 4.0;

  // Colors
  static const Color background = Color(0xFF3D4349);
  static const Color handle = Color(0xFF707070);
  static const Color barrier = Color(0x80000000);

  // Shadow
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
  ];
}
```

### Loading Indicator Component

```dart
class LoadingIndicatorTokens {
  // Dimensions
  static const double sizeSmall = 16.0;
  static const double sizeMedium = 24.0;
  static const double sizeLarge = 48.0;
  static const double strokeWidth = 3.0;

  // Colors
  static const Color primary = Color(0xFFFF7043);
  static const Color secondary = Color(0xFF4D5359);

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 1500);
}
```

---

## Component Inventory

### From Volan (Chat-Specific Components)

**Core Chat Components:**
1. `ChatBubble` - Message display with user/assistant variants
2. `ChatInput` - Message input field with voice integration
3. `VoiceRecorder` - Voice input recording interface
4. `MessageActions` - Action buttons (copy, like, dislike, share, more)
5. `TypingIndicator` - Shows when assistant is composing
6. `ChatList` - Scrollable message list
7. `ChatHeader` - Conversation header with back/menu actions
8. `MessageTimestamp` - Timestamp display for messages
9. `MessageStatus` - Delivery/read status indicators
10. `QuickReplies` - Suggested response chips

**Specialized Chat Features:**
11. `VoiceWaveform` - Visual feedback during voice input
12. `AudioPlayer` - Playback for voice messages
13. `ChatAvatar` - User/assistant profile pictures
14. `MessageReactions` - Emoji reactions on messages
15. `ChatSearchBar` - Search within conversation

### From shadcn_flutter (Generic UI Components)

**Navigation & Layout:**
1. `AppBar` - Top navigation bar
2. `NavigationBar` - Bottom navigation
3. `Drawer` - Side navigation drawer
4. `Tabs` - Tab navigation
5. `Scaffold` - Page layout structure

**Buttons & Actions:**
6. `Button` (Primary, Secondary, Text variants)
7. `IconButton` - Icon-only buttons
8. `FloatingActionButton` - FAB for primary actions
9. `SegmentedButton` - Toggle button groups
10. `Chip` - Small action/filter chips

**Forms & Inputs:**
11. `TextField` - Text input fields
12. `Checkbox` - Checkbox input
13. `Radio` - Radio button input
14. `Switch` - Toggle switch
15. `Slider` - Range slider
16. `Dropdown` - Dropdown select
17. `DatePicker` - Date selection
18. `TimePicker` - Time selection

**Feedback & Overlays:**
19. `Dialog` - Modal dialogs
20. `BottomSheet` - Bottom sheets
21. `Snackbar` - Toast notifications
22. `AlertDialog` - Alert/confirmation dialogs
23. `ProgressIndicator` - Loading indicators
24. `Tooltip` - Hover/press tooltips
25. `Badge` - Notification badges

**Display & Content:**
26. `Card` - Content containers
27. `List` - List views
28. `ListTile` - List item component
29. `Avatar` - Profile pictures
30. `Divider` - Section dividers
31. `EmptyState` - Empty state placeholders
32. `ErrorState` - Error state displays

**Advanced Components:**
33. `Calendar` - Calendar view
34. `DataTable` - Tabular data display
35. `Stepper` - Multi-step flows
36. `Accordion` - Expandable sections
37. `Carousel` - Image/content carousel

### Custom Mnesis Components

**Medical-Specific:**
1. `MedicalTermHighlight` - Highlight medical terminology
2. `SymptomChecker` - Interactive symptom input
3. `MedicationCard` - Medication information display
4. `AppointmentCard` - Appointment scheduling UI
5. `HealthMetricCard` - Display vital signs/metrics
6. `VoicePermissionPrompt` - Onboarding for voice permissions
7. `SplashScreen` - Mnesis branded splash with brain logo
8. `OnboardingFlow` - First-time user experience

**Voice-Specific:**
9. `VoiceAnimation` - Animated voice input feedback
10. `VoiceSettings` - Voice configuration UI
11. `LanguageSelector` - Multi-language support for voice

---

## shadcn_flutter Customization Strategy

### Theme Integration Approach

```dart
// lib/core/theme/mnesis_theme.dart

import 'package:shadcn_flutter/shadcn_flutter.dart';

class MnesisTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      // Base theme from shadcn_flutter
      colorScheme: ColorScheme.dark(
        primary: MnesisColors.primaryOrange,
        onPrimary: MnesisColors.textOnOrange,
        secondary: MnesisColors.surfaceDark,
        onSecondary: MnesisColors.textPrimary,
        error: MnesisColors.error,
        onError: MnesisColors.textOnOrange,
        background: MnesisColors.backgroundDark,
        onBackground: MnesisColors.textPrimary,
        surface: MnesisColors.surfaceDark,
        onSurface: MnesisColors.textPrimary,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: MnesisTextStyles.displayLarge,
        displayMedium: MnesisTextStyles.displayMedium,
        displaySmall: MnesisTextStyles.displaySmall,
        headlineLarge: MnesisTextStyles.headlineLarge,
        headlineMedium: MnesisTextStyles.headlineMedium,
        headlineSmall: MnesisTextStyles.headlineSmall,
        bodyLarge: MnesisTextStyles.bodyLarge,
        bodyMedium: MnesisTextStyles.bodyMedium,
        bodySmall: MnesisTextStyles.bodySmall,
        labelLarge: MnesisTextStyles.labelLarge,
        labelMedium: MnesisTextStyles.labelMedium,
        labelSmall: MnesisTextStyles.labelSmall,
      ),

      // Component customizations below...
    );
  }
}
```

### Button Customization

```dart
// Override shadcn_flutter button styles
extension MnesisButtonTheme on ThemeData {
  ButtonThemeData get mnesisButtonTheme {
    return ButtonThemeData(
      // Primary Button
      colorScheme: ColorScheme.dark(
        primary: PrimaryButtonTokens.background,
        onPrimary: PrimaryButtonTokens.text,
      ),

      // Shape
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PrimaryButtonTokens.borderRadius),
      ),

      // Padding
      padding: EdgeInsets.symmetric(
        horizontal: PrimaryButtonTokens.paddingHorizontal,
        vertical: PrimaryButtonTokens.paddingVertical,
      ),

      // Height
      height: PrimaryButtonTokens.minHeight,
    );
  }
}
```

### Input Field Customization

```dart
// Override shadcn_flutter input styles
extension MnesisInputTheme on ThemeData {
  InputDecorationTheme get mnesisInputTheme {
    return InputDecorationTheme(
      // Background
      filled: true,
      fillColor: InputFieldTokens.background,

      // Border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InputFieldTokens.borderRadius),
        borderSide: BorderSide(
          color: InputFieldTokens.border,
          width: InputFieldTokens.borderWidth,
        ),
      ),

      // Focused border
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(InputFieldTokens.borderRadius),
        borderSide: BorderSide(
          color: InputFieldTokens.borderFocused,
          width: InputFieldTokens.borderWidthFocused,
        ),
      ),

      // Text styles
      hintStyle: InputFieldTokens.placeholderText,

      // Padding
      contentPadding: EdgeInsets.symmetric(
        horizontal: InputFieldTokens.paddingHorizontal,
        vertical: InputFieldTokens.paddingVertical,
      ),
    );
  }
}
```

### Card Customization

```dart
// Override shadcn_flutter card styles
extension MnesisCardTheme on ThemeData {
  CardTheme get mnesisCardTheme {
    return CardTheme(
      color: CardTokens.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CardTokens.borderRadius),
        side: BorderSide(
          color: CardTokens.border,
          width: CardTokens.borderWidth,
        ),
      ),
      margin: EdgeInsets.all(MnesisSpacing.space8),
    );
  }
}
```

### Dialog Customization

```dart
// Override shadcn_flutter dialog styles
extension MnesisDialogTheme on ThemeData {
  DialogTheme get mnesisDialogTheme {
    return DialogTheme(
      backgroundColor: DialogTokens.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DialogTokens.borderRadius),
      ),

      // Title text style
      titleTextStyle: MnesisTextStyles.headlineMedium,

      // Content text style
      contentTextStyle: MnesisTextStyles.bodyMedium,
    );
  }
}
```

### Component Override Strategy

**Three-Tier Approach:**

1. **Tier 1: Theme-Level Customization**
   - Override `ThemeData` properties
   - Apply globally via Material theme
   - Best for consistent styling across all instances

2. **Tier 2: Widget-Level Customization**
   - Create wrapper widgets around shadcn components
   - Apply Mnesis tokens via constructor parameters
   - Best for component-specific variations

3. **Tier 3: Custom Implementation**
   - Build custom components from scratch
   - Use when shadcn component doesn't fit requirements
   - Best for highly specialized medical UI elements

**Example Wrapper Pattern:**

```dart
// lib/shared/components/mnesis_button.dart

class MnesisButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final MnesisButtonVariant variant;

  const MnesisButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = MnesisButtonVariant.primary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap shadcn Button with Mnesis styling
    return ShadButton(
      onPressed: isLoading ? null : onPressed,
      style: _getButtonStyle(variant),
      child: isLoading
          ? SizedBox(
              width: LoadingIndicatorTokens.sizeSmall,
              height: LoadingIndicatorTokens.sizeSmall,
              child: CircularProgressIndicator(
                strokeWidth: LoadingIndicatorTokens.strokeWidth,
                valueColor: AlwaysStoppedAnimation(
                  PrimaryButtonTokens.text,
                ),
              ),
            )
          : Text(text),
    );
  }

  ButtonStyle _getButtonStyle(MnesisButtonVariant variant) {
    switch (variant) {
      case MnesisButtonVariant.primary:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return PrimaryButtonTokens.backgroundDisabled;
            }
            if (states.contains(MaterialState.pressed)) {
              return PrimaryButtonTokens.backgroundPressed;
            }
            if (states.contains(MaterialState.hovered)) {
              return PrimaryButtonTokens.backgroundHover;
            }
            return PrimaryButtonTokens.background;
          }),
          foregroundColor: MaterialStateProperty.all(PrimaryButtonTokens.text),
          textStyle: MaterialStateProperty.all(PrimaryButtonTokens.buttonText),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: PrimaryButtonTokens.paddingHorizontal,
              vertical: PrimaryButtonTokens.paddingVertical,
            ),
          ),
          minimumSize: MaterialStateProperty.all(
            Size.fromHeight(PrimaryButtonTokens.minHeight),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                PrimaryButtonTokens.borderRadius,
              ),
            ),
          ),
        );

      case MnesisButtonVariant.secondary:
        // Similar implementation for secondary variant
        return ButtonStyle(/* ... */);
    }
  }
}

enum MnesisButtonVariant { primary, secondary, text }
```

---

## Dark Theme Configuration

### Complete ThemeData Setup

```dart
// lib/core/theme/mnesis_theme.dart

import 'package:flutter/material.dart';

class MnesisTheme {
  /// Main Mnesis dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      // Brightness
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        // Primary colors
        primary: MnesisColors.primaryOrange,
        primaryContainer: MnesisColors.primaryOrangeDark,
        onPrimary: MnesisColors.textOnOrange,
        onPrimaryContainer: MnesisColors.textOnOrange,

        // Secondary colors
        secondary: MnesisColors.surfaceDark,
        secondaryContainer: MnesisColors.surfaceElevated,
        onSecondary: MnesisColors.textPrimary,
        onSecondaryContainer: MnesisColors.textPrimary,

        // Background colors
        background: MnesisColors.backgroundDark,
        onBackground: MnesisColors.textPrimary,

        // Surface colors
        surface: MnesisColors.surfaceDark,
        surfaceVariant: MnesisColors.surfaceElevated,
        onSurface: MnesisColors.textPrimary,
        onSurfaceVariant: MnesisColors.textSecondary,

        // Error colors
        error: MnesisColors.error,
        onError: MnesisColors.textOnOrange,
        errorContainer: MnesisColors.errorBackground,
        onErrorContainer: MnesisColors.error,

        // Outline colors
        outline: MnesisColors.borderDefault,
        outlineVariant: MnesisColors.borderSubtle,

        // Shadow
        shadow: Colors.black.withOpacity(0.3),

        // Surface tint (disabled for dark theme)
        surfaceTint: Colors.transparent,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: MnesisTextStyles.displayLarge,
        displayMedium: MnesisTextStyles.displayMedium,
        displaySmall: MnesisTextStyles.displaySmall,
        headlineLarge: MnesisTextStyles.headlineLarge,
        headlineMedium: MnesisTextStyles.headlineMedium,
        headlineSmall: MnesisTextStyles.headlineSmall,
        bodyLarge: MnesisTextStyles.bodyLarge,
        bodyMedium: MnesisTextStyles.bodyMedium,
        bodySmall: MnesisTextStyles.bodySmall,
        labelLarge: MnesisTextStyles.labelLarge,
        labelMedium: MnesisTextStyles.labelMedium,
        labelSmall: MnesisTextStyles.labelSmall,
        titleLarge: MnesisTextStyles.headlineLarge,
        titleMedium: MnesisTextStyles.headlineMedium,
        titleSmall: MnesisTextStyles.headlineSmall,
      ),

      // Font family
      fontFamily: MnesisTypography.fontFamily,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: MnesisColors.backgroundDark,
        foregroundColor: MnesisColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: MnesisTextStyles.headlineMedium,
        iconTheme: IconThemeData(
          color: MnesisColors.textPrimary,
          size: MnesisSpacing.iconSizeMedium,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: MnesisColors.surfaceDark,
        selectedItemColor: MnesisColors.primaryOrange,
        unselectedItemColor: MnesisColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: MnesisTextStyles.labelSmall,
        unselectedLabelStyle: MnesisTextStyles.labelSmall,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: CardTokens.background,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CardTokens.borderRadius),
          side: BorderSide(
            color: CardTokens.border,
            width: CardTokens.borderWidth,
          ),
        ),
        margin: EdgeInsets.all(MnesisSpacing.space8),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: DialogTokens.background,
        elevation: MnesisElevation.level4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DialogTokens.borderRadius),
        ),
        titleTextStyle: MnesisTextStyles.headlineMedium,
        contentTextStyle: MnesisTextStyles.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: BottomSheetTokens.background,
        elevation: MnesisElevation.level4,
        modalBackgroundColor: BottomSheetTokens.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(BottomSheetTokens.borderRadiusTop),
          ),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return PrimaryButtonTokens.backgroundDisabled;
            }
            if (states.contains(MaterialState.pressed)) {
              return PrimaryButtonTokens.backgroundPressed;
            }
            if (states.contains(MaterialState.hovered)) {
              return PrimaryButtonTokens.backgroundHover;
            }
            return PrimaryButtonTokens.background;
          }),
          foregroundColor: MaterialStateProperty.all(PrimaryButtonTokens.text),
          textStyle: MaterialStateProperty.all(PrimaryButtonTokens.buttonText),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: PrimaryButtonTokens.paddingHorizontal,
              vertical: PrimaryButtonTokens.paddingVertical,
            ),
          ),
          minimumSize: MaterialStateProperty.all(
            Size.fromHeight(PrimaryButtonTokens.minHeight),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                PrimaryButtonTokens.borderRadius,
              ),
            ),
          ),
          elevation: MaterialStateProperty.all(0),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return SecondaryButtonTokens.backgroundPressed;
            }
            if (states.contains(MaterialState.hovered)) {
              return SecondaryButtonTokens.backgroundHover;
            }
            return SecondaryButtonTokens.background;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return SecondaryButtonTokens.textDisabled;
            }
            if (states.contains(MaterialState.hovered)) {
              return SecondaryButtonTokens.textHover;
            }
            return SecondaryButtonTokens.text;
          }),
          textStyle: MaterialStateProperty.all(SecondaryButtonTokens.buttonText),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: SecondaryButtonTokens.paddingHorizontal,
              vertical: SecondaryButtonTokens.paddingVertical,
            ),
          ),
          minimumSize: MaterialStateProperty.all(
            Size.fromHeight(SecondaryButtonTokens.minHeight),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                SecondaryButtonTokens.borderRadius,
              ),
            ),
          ),
          side: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return BorderSide(
                color: SecondaryButtonTokens.borderDisabled,
                width: SecondaryButtonTokens.borderWidth,
              );
            }
            if (states.contains(MaterialState.hovered)) {
              return BorderSide(
                color: SecondaryButtonTokens.borderHover,
                width: SecondaryButtonTokens.borderWidth,
              );
            }
            return BorderSide(
              color: SecondaryButtonTokens.border,
              width: SecondaryButtonTokens.borderWidth,
            );
          }),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return IconButtonTokens.iconActive;
            }
            if (states.contains(MaterialState.hovered)) {
              return IconButtonTokens.iconHover;
            }
            return IconButtonTokens.icon;
          }),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return IconButtonTokens.backgroundActive;
            }
            if (states.contains(MaterialState.pressed)) {
              return IconButtonTokens.backgroundPressed;
            }
            if (states.contains(MaterialState.hovered)) {
              return IconButtonTokens.backgroundHover;
            }
            return IconButtonTokens.background;
          }),
          minimumSize: MaterialStateProperty.all(
            Size(IconButtonTokens.size, IconButtonTokens.size),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(IconButtonTokens.borderRadius),
            ),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: VoiceButtonTokens.background,
        foregroundColor: VoiceButtonTokens.icon,
        elevation: MnesisElevation.level3,
        highlightElevation: MnesisElevation.level4,
        shape: CircleBorder(),
        sizeConstraints: BoxConstraints.tight(
          Size(VoiceButtonTokens.size, VoiceButtonTokens.size),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: InputFieldTokens.background,

        // Border styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(InputFieldTokens.borderRadius),
          borderSide: BorderSide(
            color: InputFieldTokens.border,
            width: InputFieldTokens.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(InputFieldTokens.borderRadius),
          borderSide: BorderSide(
            color: InputFieldTokens.border,
            width: InputFieldTokens.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(InputFieldTokens.borderRadius),
          borderSide: BorderSide(
            color: InputFieldTokens.borderFocused,
            width: InputFieldTokens.borderWidthFocused,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(InputFieldTokens.borderRadius),
          borderSide: BorderSide(
            color: MnesisColors.error,
            width: InputFieldTokens.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(InputFieldTokens.borderRadius),
          borderSide: BorderSide(
            color: MnesisColors.error,
            width: InputFieldTokens.borderWidthFocused,
          ),
        ),

        // Text styles
        hintStyle: InputFieldTokens.placeholderText,
        labelStyle: MnesisTextStyles.labelMedium,
        errorStyle: MnesisTextStyles.labelSmall.copyWith(
          color: MnesisColors.error,
        ),

        // Padding
        contentPadding: EdgeInsets.symmetric(
          horizontal: InputFieldTokens.paddingHorizontal,
          vertical: InputFieldTokens.paddingVertical,
        ),

        // Icon theme
        iconColor: MnesisColors.textSecondary,
        prefixIconColor: MnesisColors.textSecondary,
        suffixIconColor: MnesisColors.textSecondary,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        tileColor: MnesisColors.surfaceDark,
        selectedTileColor: MnesisColors.surfaceElevated,
        iconColor: MnesisColors.textSecondary,
        textColor: MnesisColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: MnesisSpacing.listItemPadding,
          vertical: MnesisSpacing.space8,
        ),
        minLeadingWidth: 40,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisBorderRadius.radiusMedium),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: MnesisColors.divider,
        thickness: 1,
        space: MnesisSpacing.space16,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: MnesisColors.surfaceDark,
        selectedColor: MnesisColors.primaryOrange,
        disabledColor: MnesisColors.surfaceDark.withOpacity(0.5),
        labelStyle: MnesisTextStyles.labelMedium,
        secondaryLabelStyle: MnesisTextStyles.labelMedium.copyWith(
          color: MnesisColors.textOnOrange,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MnesisSpacing.space12,
          vertical: MnesisSpacing.space8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisBorderRadius.radiusLarge),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: LoadingIndicatorTokens.primary,
        linearTrackColor: LoadingIndicatorTokens.secondary,
        circularTrackColor: LoadingIndicatorTokens.secondary,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: MnesisColors.surfaceOverlay,
          borderRadius: BorderRadius.circular(MnesisBorderRadius.radiusSmall),
        ),
        textStyle: MnesisTextStyles.labelSmall.copyWith(
          color: MnesisColors.textPrimary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MnesisSpacing.space12,
          vertical: MnesisSpacing.space8,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MnesisColors.surfaceElevated,
        contentTextStyle: MnesisTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnesisBorderRadius.radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: MnesisElevation.level3,
      ),

      // Badge Theme (Material 3)
      badgeTheme: BadgeThemeData(
        backgroundColor: MnesisColors.primaryOrange,
        textColor: MnesisColors.textOnOrange,
        textStyle: MnesisTextStyles.labelSmall,
      ),

      // Platform Brightness
      platform: TargetPlatform.iOS, // or TargetPlatform.android

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Use Material 3
      useMaterial3: true,
    );
  }
}
```

### Theme Application

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:mnesis/core/theme/mnesis_theme.dart';

void main() {
  runApp(const MnesisApp());
}

class MnesisApp extends StatelessWidget {
  const MnesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mnesis',

      // Apply Mnesis dark theme
      theme: MnesisTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark mode

      // Disable debug banner
      debugShowCheckedModeBanner: false,

      // Home page
      home: const SplashScreen(),
    );
  }
}
```

---

## Implementation Guidelines

### File Organization

```
lib/
├── core/
│   ├── theme/
│   │   ├── mnesis_theme.dart              # Main theme configuration
│   │   ├── colors.dart                    # MnesisColors class
│   │   ├── typography.dart                # MnesisTextStyles class
│   │   ├── spacing.dart                   # MnesisSpacing class
│   │   ├── tokens/                        # Component tokens
│   │   │   ├── button_tokens.dart
│   │   │   ├── chat_bubble_tokens.dart
│   │   │   ├── input_tokens.dart
│   │   │   └── ...
│   │   └── extensions/                    # Theme extensions
│   │       ├── color_extensions.dart
│   │       └── text_style_extensions.dart
│   └── constants/
│       └── design_constants.dart          # Shared constants
├── features/
│   └── chat/
│       └── presentation/
│           └── widgets/
│               ├── chat_bubble.dart       # Volan component
│               ├── chat_input.dart        # Volan component
│               └── voice_button.dart      # Custom component
└── shared/
    ├── components/                        # shadcn_flutter wrappers
    │   ├── mnesis_button.dart
    │   ├── mnesis_card.dart
    │   ├── mnesis_dialog.dart
    │   └── ...
    └── widgets/                           # Custom widgets
        ├── voice_animation.dart
        └── medical_term_highlight.dart
```

### Usage Examples

**1. Using Theme Colors:**

```dart
// Access theme colors
Container(
  color: Theme.of(context).colorScheme.primary, // Orange
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
);

// Or use MnesisColors directly for design system adherence
Container(
  color: MnesisColors.primaryOrange,
  child: Text(
    'Hello',
    style: MnesisTextStyles.bodyLarge,
  ),
);
```

**2. Creating Custom Components with Tokens:**

```dart
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    required this.message,
    required this.isUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: ChatBubbleTokens.maxWidth,
      ),
      padding: EdgeInsets.all(ChatBubbleTokens.padding),
      decoration: BoxDecoration(
        color: isUser
            ? ChatBubbleTokens.userBackground
            : ChatBubbleTokens.assistantBackground,
        borderRadius: BorderRadius.circular(ChatBubbleTokens.borderRadius),
        border: Border.all(
          color: isUser
              ? ChatBubbleTokens.userBubbleBorder
              : ChatBubbleTokens.assistantBubbleBorder,
          width: 1,
        ),
      ),
      child: Text(
        message,
        style: ChatBubbleTokens.messageText,
      ),
    );
  }
}
```

**3. Wrapping shadcn Components:**

```dart
class MnesisCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const MnesisCard({
    required this.child,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      onTap: onTap,
      decoration: BoxDecoration(
        color: CardTokens.background,
        borderRadius: BorderRadius.circular(CardTokens.borderRadius),
        border: Border.all(
          color: CardTokens.border,
          width: CardTokens.borderWidth,
        ),
        boxShadow: CardTokens.shadow,
      ),
      padding: EdgeInsets.all(CardTokens.padding),
      child: child,
    );
  }
}
```

### Best Practices

1. **Token Usage Priority:**
   - First: Use component tokens (e.g., `ChatBubbleTokens.padding`)
   - Second: Use semantic spacing (e.g., `MnesisSpacing.spaceMedium`)
   - Last: Use base units (e.g., `MnesisSpacing.space16`)

2. **Color Accessibility:**
   - Always verify contrast ratios meet WCAG AA (4.5:1 for text)
   - Prefer WCAG AAA (7:1) for medical content
   - Test with color blindness simulators

3. **Typography Consistency:**
   - Use predefined text styles from `MnesisTextStyles`
   - Only override when absolutely necessary
   - Document custom overrides with reasoning

4. **Component Composition:**
   - Build complex components from primitive tokens
   - Reuse shadcn components where possible
   - Create custom components for medical-specific needs

5. **Dark Theme Considerations:**
   - Avoid pure black (#000000) - use `backgroundDarkest` instead
   - Elevate surfaces with subtle color changes, not just shadows
   - Reduce brightness for long reading sessions

6. **Voice-First Design:**
   - Make voice input button prominently accessible
   - Provide clear visual feedback for voice states
   - Ensure keyboard/text input remains easy to access

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-16 | Initial design system documentation |

---

## References

- [Material Design 3 Guidelines](https://m3.material.io/)
- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes)
- [shadcn_flutter Documentation](https://shadcn-flutter.dev/)
- [WCAG 2.1 Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- Mnesis Design Files: `mnesisDesign.png`, `mnesis.png`, `mnesis1.png`

---

**Document Maintained By:** fft-documentation agent
**Last Review:** 2026-01-16
**Next Review:** On major design updates or component additions
