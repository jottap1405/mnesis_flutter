import 'package:flutter/material.dart';

/// Navigation configuration for the Mnesis app.
///
/// This class centralizes all navigation-related configuration values,
/// making it easy to tune navigation behavior and animations across
/// the entire application.
///
/// Example usage:
/// ```dart
/// // In transition pages
/// transitionDuration: NavigationConfig.transitionDuration,
///
/// // Check if animations are enabled
/// if (NavigationConfig.enableBottomNavAnimations) {
///   // Apply animation
/// }
/// ```
///
/// See also:
/// * [MnesisRouter] - The main router using these configurations
/// * [FadeTransitionPage] - Uses transition duration and curve
/// * [SlideTransitionPage] - Uses parallax and timing settings
class NavigationConfig {
  NavigationConfig._(); // Private constructor to prevent instantiation

  // ============================================================================
  // Animation Configuration
  // ============================================================================

  /// Enable/disable animations for bottom navigation tab switches.
  ///
  /// When false (default), tab switches are instant for better UX.
  /// When true, tabs will use the standard transition animation.
  ///
  /// **Default**: false (instant switching)
  /// **Recommended**: Keep false for optimal bottom nav experience
  ///
  /// Example:
  /// ```dart
  /// // In bottom navigation implementation
  /// if (NavigationConfig.enableBottomNavAnimations) {
  ///   return FadeTransitionPage(...);
  /// } else {
  ///   return CustomTransitionPage(
  ///     transitionDuration: Duration.zero,
  ///     ...
  ///   );
  /// }
  /// ```
  static const bool enableBottomNavAnimations = false;

  /// Standard transition duration for screen animations.
  ///
  /// Used by [FadeTransitionPage] and [SlideTransitionPage].
  /// Follows Material Design guidelines (200-300ms).
  ///
  /// **Default**: 300ms
  /// **Range**: 200-400ms recommended
  /// **Performance**: Shorter durations feel snappier but may lose smoothness
  ///
  /// Example:
  /// ```dart
  /// CustomTransitionPage(
  ///   transitionDuration: NavigationConfig.transitionDuration,
  ///   ...
  /// )
  /// ```
  static const Duration transitionDuration = Duration(milliseconds: 300);

  /// Fast transition duration for quick UI updates.
  ///
  /// Used for transitions that should feel instant but still animated.
  /// Ideal for modal dismissals and quick navigation changes.
  ///
  /// **Default**: 150ms
  /// **Range**: 100-200ms recommended
  /// **Use case**: Modal sheets, dialogs, quick overlays
  static const Duration fastTransitionDuration = Duration(milliseconds: 150);

  /// Slow transition duration for emphasized transitions.
  ///
  /// Used for important transitions that deserve user attention.
  /// Ideal for onboarding flows and major screen changes.
  ///
  /// **Default**: 500ms
  /// **Range**: 400-600ms recommended
  /// **Use case**: Onboarding, authentication flows, major navigation changes
  static const Duration slowTransitionDuration = Duration(milliseconds: 500);

  /// Enable/disable parallax effect in slide transitions.
  ///
  /// When true, background screen moves slightly during slide transition
  /// creating a depth effect.
  ///
  /// **Default**: true
  /// **Performance**: Minimal impact, safe to keep enabled
  /// **Platform note**: Works best on high refresh rate displays
  ///
  /// Example:
  /// ```dart
  /// if (NavigationConfig.enableParallaxEffect) {
  ///   backgroundOffset = Offset(
  ///     -animation.value * NavigationConfig.parallaxIntensity,
  ///     0,
  ///   );
  /// }
  /// ```
  static const bool enableParallaxEffect = true;

  /// Intensity of the parallax effect (0.0 - 1.0).
  ///
  /// Controls how much the background moves during slide transition.
  /// - 0.0: No parallax (same as disabled)
  /// - 0.3: Subtle effect (recommended)
  /// - 1.0: Full parallax (may be too pronounced)
  ///
  /// **Default**: 0.3
  /// **Range**: 0.0 - 1.0
  /// **Accessibility**: Consider reducing for users with motion sensitivity
  static const double parallaxIntensity = 0.3;

  /// Enable/disable hero animations globally.
  ///
  /// Hero animations create smooth transitions for shared elements
  /// between screens.
  ///
  /// **Default**: true
  /// **Performance**: Can impact performance with complex widgets
  /// **Recommendation**: Disable for low-end devices if needed
  static const bool enableHeroAnimations = true;

  // ============================================================================
  // Easing Curves
  // ============================================================================

  /// Standard easing curve for transitions.
  ///
  /// Used by all page transitions. Follows Material Design motion guidelines.
  ///
  /// **Default**: Curves.easeInOut
  /// **Alternatives**: Curves.easeOut, Curves.fastOutSlowIn
  /// **Platform consistency**: Matches platform navigation feel
  ///
  /// Example:
  /// ```dart
  /// AnimationController(
  ///   duration: NavigationConfig.transitionDuration,
  /// ).drive(CurveTween(curve: NavigationConfig.transitionCurve));
  /// ```
  static const Curve transitionCurve = Curves.easeInOut;

  /// Easing curve for fade transitions.
  ///
  /// Specific curve for opacity animations.
  /// Slightly different from slide transitions for better visual feel.
  ///
  /// **Default**: Curves.easeIn
  /// **Rationale**: Fade-ins look better with easeIn curve
  static const Curve fadeCurve = Curves.easeIn;

  /// Easing curve for slide transitions.
  ///
  /// Specific curve for position animations.
  /// Provides smooth acceleration and deceleration.
  ///
  /// **Default**: Curves.fastOutSlowIn
  /// **Rationale**: Material Design standard for movement
  static const Curve slideCurve = Curves.fastOutSlowIn;

  /// Easing curve for modal/bottom sheet animations.
  ///
  /// Used for bottom sheets, dialogs, and modal presentations.
  ///
  /// **Default**: Curves.decelerate
  /// **Rationale**: Feels natural for bottom-up animations
  static const Curve modalCurve = Curves.decelerate;

  // ============================================================================
  // Router Observer Configuration
  // ============================================================================

  /// Enable/disable navigation logging in router observer.
  ///
  /// When true, all navigation events are logged to console/logger.
  /// Useful for debugging but should be disabled in production.
  ///
  /// **Default**: true in debug, false in release
  /// **Production**: Automatically disabled in release builds
  ///
  /// Example:
  /// ```dart
  /// if (NavigationConfig.enableNavigationLogging) {
  ///   logger.i('Navigated to: ${route.name}');
  /// }
  /// ```
  static const bool enableNavigationLogging = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  ) ? false : true;

  /// Enable/disable navigation analytics tracking.
  ///
  /// When true, navigation events are sent to analytics service.
  /// Should be enabled in production for user behavior tracking.
  ///
  /// **Default**: true
  /// **Privacy**: Ensure compliance with privacy policies
  static const bool enableNavigationAnalytics = true;

  /// Enable/disable navigation breadcrumbs for error reporting.
  ///
  /// When true, navigation history is attached to error reports.
  /// Helpful for debugging navigation-related crashes.
  ///
  /// **Default**: true
  /// **Privacy**: May contain sensitive route information
  static const bool enableNavigationBreadcrumbs = true;

  // ============================================================================
  // Deep Linking Configuration
  // ============================================================================

  /// Custom URL scheme for the app.
  ///
  /// Used for custom scheme deep links (e.g., mnesis://chat).
  /// Must match the scheme configured in platform files.
  ///
  /// **Default**: 'mnesis'
  /// **iOS**: Configure in Info.plist
  /// **Android**: Configure in AndroidManifest.xml
  ///
  /// Example:
  /// ```dart
  /// // Deep link: mnesis://chat/123
  /// if (uri.scheme == NavigationConfig.customScheme) {
  ///   handleCustomScheme(uri);
  /// }
  /// ```
  static const String customScheme = 'mnesis';

  /// App domain for Universal Links / App Links.
  ///
  /// Used for HTTPS deep links (e.g., https://mnesis.app/chat).
  /// Must match the domain configured in platform files.
  ///
  /// **Default**: 'mnesis.app'
  /// **iOS**: Configure in Associated Domains
  /// **Android**: Configure in assetlinks.json
  ///
  /// Example:
  /// ```dart
  /// // Deep link: https://mnesis.app/chat/123
  /// if (uri.host == NavigationConfig.appDomain) {
  ///   handleUniversalLink(uri);
  /// }
  /// ```
  static const String appDomain = 'mnesis.app';

  /// Enable/disable deep link validation.
  ///
  /// When true, incoming deep links are validated before navigation.
  /// Prevents navigation to invalid or malicious routes.
  ///
  /// **Default**: true
  /// **Security**: Always keep enabled in production
  static const bool validateDeepLinks = true;

  /// Maximum deep link processing time.
  ///
  /// Timeout for processing deep links to prevent hanging.
  ///
  /// **Default**: 3 seconds
  /// **Range**: 2-5 seconds recommended
  static const Duration deepLinkTimeout = Duration(seconds: 3);

  // ============================================================================
  // Error Handling Configuration
  // ============================================================================

  /// Enable/disable automatic fallback to home on navigation errors.
  ///
  /// When true, navigation errors automatically redirect to /chat.
  /// When false, navigation errors are logged but no automatic redirect.
  ///
  /// **Default**: true
  /// **Recommended**: Keep true for better UX
  /// **Alternative**: Show error screen instead of redirect
  ///
  /// Example:
  /// ```dart
  /// onError: (context, state) {
  ///   if (NavigationConfig.autoFallbackToHome) {
  ///     context.go(NavigationConfig.fallbackRoute);
  ///   } else {
  ///     showErrorDialog(context, state.error);
  ///   }
  /// }
  /// ```
  static const bool autoFallbackToHome = true;

  /// Route to use as fallback destination on errors.
  ///
  /// **Default**: '/chat'
  /// **Alternative**: Could be '/error' for dedicated error page
  static const String fallbackRoute = '/chat';

  /// Show error dialog on navigation failure.
  ///
  /// When true, shows user-friendly error dialog on navigation errors.
  /// When false, silently handles errors (logged only).
  ///
  /// **Default**: false
  /// **Production**: Consider enabling for transparency
  static const bool showNavigationErrors = false;

  /// Maximum retry attempts for failed navigations.
  ///
  /// Number of times to retry navigation before giving up.
  ///
  /// **Default**: 3
  /// **Range**: 1-5 recommended
  static const int maxNavigationRetries = 3;

  // ============================================================================
  // Performance Configuration
  // ============================================================================

  /// Enable/disable route preloading.
  ///
  /// When true, adjacent routes are preloaded for faster navigation.
  /// Improves perceived performance at the cost of memory.
  ///
  /// **Default**: true
  /// **Memory impact**: ~2-5MB per preloaded route
  /// **Recommendation**: Disable on low-memory devices
  static const bool enableRoutePreloading = true;

  /// Maximum number of routes to keep in memory.
  ///
  /// Controls the route cache size for back navigation.
  /// Higher values improve back navigation speed but use more memory.
  ///
  /// **Default**: 10
  /// **Range**: 5-20 recommended
  /// **Memory impact**: ~1-2MB per cached route
  static const int maxCachedRoutes = 10;

  /// Enable/disable lazy loading for routes.
  ///
  /// When true, route widgets are built only when needed.
  /// Improves app startup time but may cause slight delay on first navigation.
  ///
  /// **Default**: true
  /// **Recommendation**: Keep enabled for better startup performance
  static const bool enableLazyLoading = true;

  // ============================================================================
  // Platform-Specific Configuration
  // ============================================================================

  /// Enable/disable iOS-style swipe back gesture.
  ///
  /// When true, users can swipe from left edge to go back (iOS only).
  /// On Android, this is controlled by system back gesture.
  ///
  /// **Default**: true
  /// **Platform**: iOS only
  /// **Android**: Uses system back gesture
  static const bool enableIOSSwipeBack = true;

  /// Enable/disable Android predictive back gesture.
  ///
  /// When true, supports Android 14+ predictive back animations.
  /// Shows preview of destination during back gesture.
  ///
  /// **Default**: true
  /// **Platform**: Android 14+ only
  /// **Requirement**: Android API 34+
  static const bool enableAndroidPredictiveBack = true;

  /// Enable/disable web browser history integration.
  ///
  /// When true, navigation integrates with browser back/forward buttons.
  /// Only relevant for Flutter web applications.
  ///
  /// **Default**: true
  /// **Platform**: Web only
  static const bool enableWebBrowserHistory = true;

  // ============================================================================
  // Accessibility Configuration
  // ============================================================================

  /// Enable/disable reduced motion mode.
  ///
  /// When true, respects system accessibility settings for reduced motion.
  /// Disables or simplifies animations for users with motion sensitivity.
  ///
  /// **Default**: true
  /// **Accessibility**: Required for WCAG 2.1 compliance
  static const bool respectReducedMotion = true;

  /// Enable/disable screen reader announcements for navigation.
  ///
  /// When true, navigation changes are announced to screen readers.
  /// Improves accessibility for visually impaired users.
  ///
  /// **Default**: true
  /// **Accessibility**: Required for accessibility compliance
  static const bool enableScreenReaderAnnouncements = true;

  /// Minimum touch target size for navigation elements.
  ///
  /// Ensures all tappable navigation elements meet accessibility guidelines.
  ///
  /// **Default**: 48.0 (Material Design guideline)
  /// **iOS**: 44.0 minimum
  /// **Android**: 48.0 minimum
  /// **Accessibility**: WCAG 2.1 requires 44x44 minimum
  static const double minTouchTargetSize = 48.0;
}