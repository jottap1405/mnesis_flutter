# Route Transition Animations

This directory contains custom page transition animations for the Mnesis Flutter application navigation system, following Material Design motion guidelines.

## Overview

We provide three types of custom transitions, each optimized for specific navigation patterns to ensure the best user experience and performance.

## Transition Types

### 1. InstantTransitionPage (No Animation)
- **Duration**: 0ms (instant)
- **Use Cases**:
  - Bottom navigation tab switches ✅
  - Tab bar navigation
  - Drawer menu selections
  - When maintaining context is important
- **Performance**: Best performance, zero animation overhead
- **Why**: According to Material Design guidelines, bottom navigation should provide instant feedback to maintain user context

### 2. FadeTransitionPage (Opacity Animation)
- **Duration**: 300ms (standard) or 200ms (fast)
- **Curve**: easeInOut
- **Use Cases**:
  - Deep links from external sources
  - Error and 404 pages ✅
  - Modal-like overlays
  - Authentication screens
- **Why**: Gentle transition for non-directional navigation

### 3. SlideTransitionPage (Horizontal Movement)
- **Duration**: 300ms
- **Curve**: easeInOut
- **Variants**:
  - Standard (from right)
  - From left (for back navigation)
  - Subtle (30% offset for modals)
- **Use Cases**:
  - Detail views (master-detail pattern)
  - Step-by-step flows
  - Settings sub-pages
  - Forward navigation with spatial context
- **Why**: Shows spatial relationship between screens

## Current Implementation

### Bottom Navigation Routes (InstantTransitionPage)
```dart
GoRoute(
  path: '/chat',
  pageBuilder: (context, state) => InstantTransitionPage(
    key: state.pageKey,
    child: const ChatScreen(),
  ),
)
```

### Error Page (FadeTransitionPage)
```dart
GoRoute(
  path: '/404',
  pageBuilder: (context, state) => FadeTransitionPage(
    key: state.pageKey,
    child: const NotFoundPage(),
  ),
)
```

## Animation Parameters

All transitions follow Material Design motion guidelines:
- **Standard Duration**: 300ms (smooth but responsive)
- **Fast Duration**: 200ms (for simpler transitions)
- **Standard Curve**: Curves.easeInOut (natural acceleration/deceleration)
- **Entering Curve**: Curves.easeOut (gentle landing)
- **Exiting Curve**: Curves.easeIn (quick exit)

## Performance

### 60 FPS Guaranteed
- All transitions are optimized for 60 FPS performance
- InstantTransitionPage has zero overhead
- Fade and Slide transitions use hardware acceleration
- Tested on lower-end devices

### Best Practices
1. **Bottom Navigation**: Always use InstantTransitionPage
2. **Deep Links**: Use FadeTransitionPage for smooth entry
3. **Detail Views**: Use SlideTransitionPage to show relationship
4. **Error Pages**: Use FadeTransitionPage for gentle display

## Files

- `transition_config.dart` - Configuration constants
- `instant_transition_page.dart` - No animation transition
- `fade_transition_page.dart` - Fade in/out transition
- `slide_transition_page.dart` - Horizontal slide transition
- `transition_examples.dart` - Usage examples and patterns

## Testing

Visual testing is recommended to ensure smooth animations:

```bash
# Run the app and manually test transitions
flutter run

# Profile mode for performance testing
flutter run --profile
```

## Future Extensions

When adding new routes, follow these guidelines:

1. **Modal Routes**: Use `SlideTransitionPage.subtle()` or `FadeTransitionPage`
2. **Nested Navigation**: Use `SlideTransitionPage` for sub-pages
3. **Authentication Flows**: Use `FadeTransitionPage` for auth screens
4. **Onboarding**: Use `SlideTransitionPage` for step-by-step flows

## Material Design References

- [Motion System](https://m3.material.io/styles/motion/overview)
- [Transition Patterns](https://m3.material.io/styles/motion/transitions/transition-patterns)
- [Duration and Easing](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs)