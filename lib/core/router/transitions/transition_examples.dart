import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'fade_transition_page.dart';
import 'slide_transition_page.dart';
import 'instant_transition_page.dart';

/// Examples of how to use custom page transitions in GoRouter.
///
/// This file provides reference implementations for different navigation
/// scenarios, demonstrating when and how to use each transition type
/// according to Material Design guidelines.
///
/// ## Transition Types and Use Cases
///
/// ### InstantTransitionPage (Instant switch)
/// - Bottom navigation tab switches
/// - Tab bar navigation
/// - Drawer menu selections
/// - When maintaining context is important
///
/// ### FadeTransitionPage (Opacity animation)
/// - Deep links from external sources
/// - Error and 404 pages
/// - Modal-like overlays
/// - Authentication screens
///
/// ### SlideTransitionPage (Horizontal movement)
/// - Detail views (master-detail pattern)
/// - Step-by-step flows (onboarding, wizards)
/// - Settings sub-pages
/// - Forward navigation with spatial context
///
/// See also:
/// * [Material Design Motion Guidelines](https://m3.material.io/styles/motion)
/// * [TransitionConfig] for animation constants
class TransitionExamples {
  TransitionExamples._();

  /// Example: Bottom navigation routes with no transition.
  ///
  /// Provides instant feedback when switching between main app sections.
  static final bottomNavigationExample = GoRoute(
    path: '/home',
    pageBuilder: (context, state) => InstantTransitionPage(
      key: state.pageKey,
      child: const Placeholder(), // Your screen widget
    ),
  );

  /// Example: Deep link with fade transition.
  ///
  /// Smooth entry when arriving from external source.
  static final deepLinkExample = GoRoute(
    path: '/shared/:id',
    pageBuilder: (context, state) => FadeTransitionPage(
      key: state.pageKey,
      child: Placeholder(
        // Access parameters
        color: Colors.blue,
        child: Text(state.pathParameters['id'] ?? ''),
      ),
    ),
  );

  /// Example: Detail page with slide transition.
  ///
  /// Shows spatial relationship in master-detail navigation.
  static final detailPageExample = GoRoute(
    path: '/product/:id',
    pageBuilder: (context, state) => SlideTransitionPage(
      key: state.pageKey,
      child: const Placeholder(), // Your detail screen
    ),
  );

  /// Example: Back navigation with left slide.
  ///
  /// Reverses the slide direction for back navigation.
  static final backNavigationExample = GoRoute(
    path: '/previous',
    pageBuilder: (context, state) => SlideTransitionPage.fromLeft(
      key: state.pageKey,
      child: const Placeholder(),
    ),
  );

  /// Example: Modal-like page with subtle slide.
  ///
  /// Less dramatic slide for secondary navigation.
  static final modalExample = GoRoute(
    path: '/modal',
    pageBuilder: (context, state) => SlideTransitionPage.subtle(
      key: state.pageKey,
      child: const Placeholder(),
    ),
  );

  /// Example: Error page with fast fade.
  ///
  /// Quicker transition for error states.
  static final errorPageExample = GoRoute(
    path: '/error',
    pageBuilder: (context, state) => FadeTransitionPage.fast(
      key: state.pageKey,
      child: const Placeholder(),
    ),
  );

  /// Example: Nested routes with mixed transitions.
  ///
  /// Shows how to combine different transition types in a route hierarchy.
  static final nestedRoutesExample = GoRoute(
    path: '/settings',
    pageBuilder: (context, state) => FadeTransitionPage(
      key: state.pageKey,
      child: const Placeholder(), // Settings main screen
    ),
    routes: [
      // Sub-settings with slide transition
      GoRoute(
        path: 'profile',
        pageBuilder: (context, state) => SlideTransitionPage(
          key: state.pageKey,
          child: const Placeholder(), // Profile settings
        ),
      ),
      // Another sub-setting
      GoRoute(
        path: 'privacy',
        pageBuilder: (context, state) => SlideTransitionPage(
          key: state.pageKey,
          child: const Placeholder(), // Privacy settings
        ),
      ),
    ],
  );

  /// Example: Conditional transitions based on navigation method.
  ///
  /// Shows how to choose transitions dynamically based on context.
  static GoRoute conditionalTransitionExample() {
    return GoRoute(
      path: '/dynamic',
      pageBuilder: (context, state) {
        // Check how we navigated here
        final fromDeepLink = state.uri.queryParameters['source'] == 'external';
        final fromBottomNav = state.uri.queryParameters['tab'] != null;

        if (fromBottomNav) {
          // No transition for tab switches
          return InstantTransitionPage(
            key: state.pageKey,
            child: const Placeholder(),
          );
        } else if (fromDeepLink) {
          // Fade for external links
          return FadeTransitionPage(
            key: state.pageKey,
            child: const Placeholder(),
          );
        } else {
          // Default to slide for programmatic navigation
          return SlideTransitionPage(
            key: state.pageKey,
            child: const Placeholder(),
          );
        }
      },
    );
  }

  /// Example: Custom transition combination.
  ///
  /// Shows how to extend CustomTransitionPage for unique transitions.
  static GoRoute customTransitionExample() {
    return GoRoute(
      path: '/custom',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const Placeholder(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Combine fade and scale for a zoom effect
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Extension methods for programmatic navigation with transitions.
///
/// These extensions make it easier to navigate with specific transition types.
extension NavigationTransitions on BuildContext {
  /// Navigate with a fade transition.
  ///
  /// Example:
  /// ```dart
  /// context.goWithFade('/path');
  /// ```
  void goWithFade(String location, {Object? extra}) {
    // Note: The transition is defined in the route configuration,
    // not at the call site. This is just a convenience method.
    go(location, extra: extra);
  }

  /// Navigate with a slide transition.
  ///
  /// Example:
  /// ```dart
  /// context.goWithSlide('/details/$id');
  /// ```
  void goWithSlide(String location, {Object? extra}) {
    // The actual transition is determined by the route configuration
    go(location, extra: extra);
  }

  /// Navigate with no transition (instant).
  ///
  /// Example:
  /// ```dart
  /// context.goInstant('/home');
  /// ```
  void goInstant(String location, {Object? extra}) {
    // The actual transition is determined by the route configuration
    go(location, extra: extra);
  }
}