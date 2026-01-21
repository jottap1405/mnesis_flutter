import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mnesis_flutter/core/router/routes/route_paths.dart';

/// Simple 404 Not Found page widget.
///
/// Displays when users navigate to a route that doesn't exist.
/// Provides a way to navigate back to the home screen.
///
/// This widget follows the Mnesis design system and provides:
/// - Clear error message
/// - Visual indication of error state
/// - Action to return to home
///
/// Example:
/// ```dart
/// GoRoute(
///   path: '/404',
///   builder: (context, state) => const NotFoundPage(),
/// )
/// ```
class NotFoundPage extends StatelessWidget {
  /// Creates a [NotFoundPage].
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),

              // Error title
              Text(
                '404',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Error message
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // Error description
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Navigate home button
              ElevatedButton.icon(
                onPressed: () => context.go(RoutePaths.chat),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}