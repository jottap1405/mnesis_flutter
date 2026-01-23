# Mnesis Design System

<div align="center">

![Tipo](https://img.shields.io/badge/Tipo-DESIGN_SYSTEM-teal?style=for-the-badge)
![Versão](https://img.shields.io/badge/Versão-1.0-blue?style=for-the-badge)
![Material](https://img.shields.io/badge/Material-3-purple?style=for-the-badge)

</div>

## 📋 Overview

Mnesis uses a dark-first Material 3 design system optimized for medical environments with reduced eye strain and high accessibility standards.

## 🎨 Color Palette

### Primary Colors
- **Primary Orange**: `#FF7043` (brand color)
- **Contrast Ratio**: 4.8:1 on dark background (WCAG AA ✅)

**Opacity Variants:**
- `orange80`: 80% opacity
- `orange60`: 60% opacity
- `orange40`: 40% opacity
- `orange20`: 20% opacity
- `orange10`: 10% opacity

### Background Colors
- **Background Dark**: `#2D3339` (main background)
- **Surface Dark**: `#3D4349` (cards, elevated surfaces)

### Text Colors
- **Text Primary**: `#FFFFFF` (12.5:1 contrast - WCAG AAA ✅)
- **Text Secondary**: `#A0A0A0` (4.88:1 contrast - WCAG AA ✅)
- **Text Disabled**: `#666666`

### Semantic Colors
- **Success**: `#66BB6A` (green)
- **Warning**: `#FFA726` (amber)
- **Error**: `#EF5350` (red)
- **Info**: `#42A5F5` (blue)

**Implementation**: See `lib/core/design_system/mnesis_colors.dart`

## 📝 Typography

Based on **Inter** font family with 8 semantic styles following Material 3 guidelines.

### Display Styles
- **Display Large**: 57px, Light (300), 1.12 height
- **Display Medium**: 45px, Regular (400), 1.16 height
- **Display Small**: 36px, Regular (400), 1.22 height

### Headline Styles
- **Headline 1**: 32px, Bold (700), 1.25 height - Page titles
- **Headline 2**: 24px, SemiBold (600), 1.33 height - Section headers
- **Headline 3**: 20px, SemiBold (600), 1.2 height - Subsection headers

### Body Styles
- **Body 1**: 16px, Regular (400), 1.5 height - Main body text
- **Body 2**: 14px, Regular (400), 1.43 height - Secondary text
- **Body 3**: 12px, Regular (400), 1.33 height - Tertiary text

### Special Styles
- **Label Large**: 14px, Medium (500), 1.43 height
- **Label Medium**: 12px, Medium (500), 1.33 height
- **Label Small**: 11px, Medium (500), 1.45 height
- **Button**: 14px, Medium (500), 1.43 height - Button text

**Implementation**: See `lib/core/design_system/mnesis_text_styles.dart`

## 📐 Spacing System

4px base unit grid system ensuring visual consistency.

### Spacing Scale
- `xs`: 4px
- `sm`: 8px
- `md`: 12px
- `lg`: 16px
- `xl`: 24px
- `xl2`: 32px
- `xl3`: 48px
- `xl4`: 64px

### Component-Specific Spacing
- **Chat Bubble**: 16px horizontal, 12px vertical
- **Button**: 24px horizontal, 12px vertical
- **Input**: 16px horizontal, 12px vertical
- **Screen**: 24px padding
- **Card**: 16px padding

### Border Radius
- **Pill**: 999px (fully rounded)
- **Large**: 16px
- **Medium**: 12px
- **Small**: 8px

### Touch Targets
- **Minimum**: 48x48px (Material Design standard)
- **Navigation Bar Height**: 80px
- **Color Swatch Size**: 48px
- **Icon Button Size**: 48px

**Implementation**: See `lib/core/design_system/mnesis_spacings.dart`

## 🏗️ Material 3 Theme

Complete theme configuration with 22+ component themes.

### Configured Components
- **Buttons**: Elevated, Outlined, Text, Icon, FAB
- **Inputs**: TextField (pill-shaped, 24px radius)
- **Navigation**: AppBar, BottomNavigationBar, NavigationBar
- **Surfaces**: Card, Dialog, BottomSheet, SnackBar, Tooltip
- **Selection**: Chip, Switch, Checkbox, Radio, Slider
- **Other**: ListTile, Divider, Icon, ProgressIndicator

**Implementation**: See `lib/core/design_system/mnesis_theme.dart`

## ♿ Accessibility

All color combinations meet WCAG AA or AAA standards.

### Contrast Ratios
- **Text Primary on Background**: 12.5:1 (WCAG AAA ✅)
- **Text Secondary on Background**: 4.88:1 (WCAG AA ✅)
- **Primary Orange on Background**: 4.8:1 (WCAG AA ✅)
- **Error on Background**: 3.8:1 (WCAG AA for large text ✅)
- **Success on Background**: 4.9:1 (WCAG AA ✅)
- **Warning on Background**: 7.8:1 (WCAG AAA ✅)

### Testing
- **138+ automated accessibility tests**
- Contrast ratio validation using `AccessibilityTestHelpers`
- Touch target size verification
- Runtime theme validation in debug mode

## 🚀 Usage

### Import Theme
```dart
import 'package:mnesis_flutter/core/design_system/mnesis_theme.dart';

MaterialApp(
  theme: MnesisTheme.darkTheme,
  themeMode: ThemeMode.dark,
  // ...
);
```

### Use Colors
```dart
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';

Container(
  color: MnesisColors.primaryOrange,
  child: Text(
    'Hello',
    style: TextStyle(color: MnesisColors.textPrimary),
  ),
);
```

### Use Typography
```dart
import 'package:mnesis_flutter/core/design_system/mnesis_text_styles.dart';

Text(
  'Page Title',
  style: MnesisTextStyles.heading1,
);
```

### Use Spacing
```dart
import 'package:mnesis_flutter/core/design_system/mnesis_spacings.dart';

Padding(
  padding: EdgeInsets.all(MnesisSpacings.lg),
  child: child,
);
```

## 🧪 Visual Testing

### Design System Test Screen
Run the visual test screen to preview all components:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const DesignSystemTestScreen(),
  ),
);
```

Or access via route: `/admin/design-system`

### Runtime Theme Validation
Theme is automatically validated in debug mode during app startup:

```dart
// In main.dart
assert(() {
  MnesisTheme.validateTheme();
  return true;
}());
```

This validates:
- Contrast ratio compliance
- Component theme configuration completeness
- Material 3 enablement

## 🛠️ Development Tools

### Accessibility Test Helpers
Use the centralized test helpers for WCAG validation:

```dart
import 'test/helpers/accessibility_test_helpers.dart';

// Calculate contrast ratio
final ratio = AccessibilityTestHelpers.calculateContrastRatio(
  foregroundColor,
  backgroundColor,
);

// Assert WCAG compliance
AccessibilityTestHelpers.expectWCAGAA(foreground, background);
AccessibilityTestHelpers.expectWCAGAAA(foreground, background);
AccessibilityTestHelpers.expectWCAGAALargeText(foreground, background);
```

## 📚 References

- [Material Design 3](https://m3.material.io/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes)
- [Inter Font](https://rsms.me/inter/)

---

*📅 Created*: 2026-01-22
*📋 Version*: 1.1
*👥 Maintainer*: Mnesis Development Team
*🏷️ Tags*: [design-system, material-3, accessibility, wcag, dark-theme]