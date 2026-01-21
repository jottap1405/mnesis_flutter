# Mnesis Navigation System

## Overview

The Mnesis navigation system is built on GoRouter, providing a declarative, type-safe approach to navigation throughout the application. The architecture emphasizes a chat-first model with persistent bottom navigation, ensuring users can quickly access core features while maintaining context across sessions.

**Key Design Principles:**
- **Type-safe API**: Compile-time safety eliminates runtime navigation errors
- **Chat-first architecture**: No traditional login screen; authentication happens in-context
- **Persistent bottom navigation**: Four main sections accessible at all times
- **Custom transitions**: Optimized animations for different navigation patterns
- **Deep linking support**: Full integration with Android and iOS deep linking

## Quick Links

- **[Navigation Architecture](./navigation-architecture.md)** - System components and design
- **[Navigation Usage Guide](./navigation-usage-guide.md)** - How to use navigation in your code
- **[Adding Routes Guide](./navigation-adding-routes.md)** - Step-by-step guide for new routes
- **[Navigation Testing](./navigation-testing.md)** - Testing strategies and examples
- **[Deep Linking Android](./deep-linking-android.md)** - Android deep linking setup
- **[Deep Linking iOS](./deep-linking-ios.md)** - iOS deep linking setup
- **[Navigation Troubleshooting](./navigation-troubleshooting.md)** - Common issues and solutions

## At a Glance

### Main Routes

| Route | Path | Screen | Purpose |
|-------|------|--------|---------|
| Chat | `/chat` | ChatScreen | Main AI assistant interface (home) |
| Quick Actions | `/new` | NewScreen | Quick access to common medical tasks |
| Operations | `/operation` | OperationScreen | Medical operations management |
| Admin | `/admin` | AdminScreen | Settings and configuration |
| Not Found | `/404` | NotFoundPage | Error page for invalid routes |

### Navigation Methods

```dart
// Using NavigationHelper (recommended)
context.nav.goToChat();
context.nav.goToQuickActions();
context.nav.goToOperations();
context.nav.goToAdmin();

// Back navigation
if (context.nav.canGoBack()) {
  context.nav.goBack();
}

// Replace navigation (no back stack)
context.nav.replaceWithChat();
```

### Page Transitions

| Transition | Use Case | Duration | Animation |
|------------|----------|----------|-----------|
| **InstantTransitionPage** | Bottom nav tabs | 0ms | None (instant) |
| **FadeTransitionPage** | Deep links, errors | 300ms | Fade in/out |
| **SlideTransitionPage** | Detail views | 300ms | Horizontal slide |

## Architecture Overview

### Component Hierarchy

```
MaterialApp.router
  └── AppRouter.router (GoRouter)
      ├── ShellRoute (AppShell with bottom nav)
      │   ├── /chat      → ChatScreen
      │   ├── /new       → NewScreen
      │   ├── /operation → OperationScreen
      │   └── /admin     → AdminScreen
      │
      └── Standalone Routes
          └── /404       → NotFoundPage
```

### Core Components

1. **AppRouter** (`lib/core/router/app_router_simple.dart`)
   - Singleton GoRouter configuration
   - Defines all routes and navigation logic
   - Integrates AuthGuard and error handling

2. **Route Constants**
   - **RouteNames** (`lib/core/router/routes/route_names.dart`) - Internal route identifiers
   - **RoutePaths** (`lib/core/router/routes/route_paths.dart`) - URL paths

3. **AppShell** (`lib/core/router/shell/app_shell.dart`)
   - Persistent bottom navigation wrapper
   - Automatic route-to-tab synchronization

4. **AuthGuard** (`lib/core/router/guards/auth_guard.dart`)
   - Chat-first authentication model
   - Currently allows all navigation (no login screen)

5. **NavigationHelper** (`lib/core/router/navigation/navigation_helper.dart`)
   - Type-safe navigation API
   - Error handling and fallbacks

6. **Page Transitions** (`lib/core/router/transitions/`)
   - Custom transition implementations
   - Optimized for different navigation patterns

For detailed architecture documentation, see [Navigation Architecture](./navigation-architecture.md).

## Quick Start

### Basic Navigation

```dart
import 'package:mnesis_flutter/core/router/navigation/navigation_helper.dart';

// Navigate to different screens
context.nav.goToChat();
context.nav.goToQuickActions();
context.nav.goToOperations();
context.nav.goToAdmin();
```

### Back Navigation

```dart
// Check if can go back
if (context.nav.canGoBack()) {
  context.nav.goBack();
} else {
  // Handle exit (show dialog, etc.)
}
```

### Replace Navigation

```dart
// Remove current route from back stack
context.nav.replaceWithChat();
```

For complete usage examples, see [Navigation Usage Guide](./navigation-usage-guide.md).

## Adding New Routes

Follow these steps to add a new route:

1. Add route name to `RouteNames`
2. Add route path to `RoutePaths`
3. Create screen widget
4. Add route to `AppRouter`
5. Add NavigationHelper methods (optional)
6. Add tests
7. Update documentation

For detailed instructions with examples, see [Adding Routes Guide](./navigation-adding-routes.md).

## Deep Linking

Mnesis supports deep linking on both platforms:

- **Custom scheme**: `mnesis://` (e.g., `mnesis://chat`)
- **HTTPS links**: `https://mnesis.app` (e.g., `https://mnesis.app/operation`)

**Quick Test:**
```bash
# Android
adb shell am start -W -a android.intent.action.VIEW \
  -d "mnesis://chat" com.example.mnesis_flutter

# iOS
xcrun simctl openurl booted "mnesis://chat"
```

For complete deep linking setup:
- [Deep Linking Android](./deep-linking-android.md)
- [Deep Linking iOS](./deep-linking-ios.md)

## Testing

### Unit Tests

```dart
test('goToChat navigates to chat route', () {
  final mockRouter = MockGoRouter();
  final helper = NavigationHelper(context, router: mockRouter);

  helper.goToChat();

  verify(() => mockRouter.go(RoutePaths.chat)).called(1);
});
```

### Widget Tests

```dart
testWidgets('bottom nav switches tabs', (tester) async {
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: AppRouter.router,
  ));

  await tester.tap(find.text('Operations'));
  await tester.pumpAndSettle();

  expect(find.text('Operations Screen'), findsOneWidget);
});
```

For comprehensive testing guide, see [Navigation Testing](./navigation-testing.md).

## Troubleshooting

### Common Issues

| Issue | Quick Fix |
|-------|-----------|
| Route not found | Verify route exists in AppRouter |
| Deep link not working | Check AndroidManifest.xml / Info.plist |
| State lost on tab switch | Use `AutomaticKeepAliveClientMixin` |
| Back button not working | Check `canGoBack()` before calling `goBack()` |

For detailed troubleshooting, see [Navigation Troubleshooting](./navigation-troubleshooting.md).

## Best Practices

### Do's ✅

- Use `NavigationHelper` for type-safe navigation
- Use route constants (`RoutePaths`, `RouteNames`)
- Handle navigation errors gracefully
- Test all navigation flows
- Document new routes
- Preserve state with `AutomaticKeepAliveClientMixin`

### Don'ts ❌

- Don't hardcode route strings
- Don't skip navigation tests
- Don't ignore navigation errors
- Don't mix Navigator and GoRouter
- Don't forget deep link testing

## API Reference

### NavigationHelper Methods

```dart
// Basic navigation
void goToChat()
void goToQuickActions()
void goToOperations()
void goToAdmin()
void goToNotFound()

// Named navigation
void goToNamed(String routeName)

// Back navigation
void goBack()
bool canGoBack()

// Replace navigation
void replaceWithChat()
void replaceWithQuickActions()
void replaceWithOperations()
void replaceWithAdmin()
```

### Route Constants

```dart
// RouteNames
RouteNames.chat
RouteNames.quickActions
RouteNames.operations
RouteNames.admin
RouteNames.notFound

// RoutePaths
RoutePaths.chat         // '/chat'
RoutePaths.quickActions // '/new'
RoutePaths.operations   // '/operation'
RoutePaths.admin        // '/admin'
RoutePaths.notFound     // '/404'
```

## Related Documentation

- [Navigation Architecture](./navigation-architecture.md) - Detailed system design
- [Navigation Usage Guide](./navigation-usage-guide.md) - Complete usage examples
- [Adding Routes Guide](./navigation-adding-routes.md) - Adding new routes
- [Navigation Testing](./navigation-testing.md) - Testing strategies
- [Deep Linking Android](./deep-linking-android.md) - Android setup
- [Deep Linking iOS](./deep-linking-ios.md) - iOS setup
- [Navigation Troubleshooting](./navigation-troubleshooting.md) - Problem solving
- [Router Transitions README](../lib/core/router/transitions/README.md) - Transition details

## Support

For questions or issues:
1. Check [Navigation Troubleshooting](./navigation-troubleshooting.md)
2. Review related documentation above
3. Check existing navigation tests for examples
4. Open an issue with detailed description

---

**Documentation maintained by**: Mnesis Development Team
**Last updated**: 2025-01-21
**Version**: 1.0.0
