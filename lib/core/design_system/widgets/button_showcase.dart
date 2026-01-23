import 'package:flutter/material.dart';
import '../mnesis_spacings.dart';

/// Button showcase widget for design system testing.
///
/// Displays all button variations including:
/// - Elevated buttons (enabled/disabled)
/// - Outlined buttons (enabled/disabled)
/// - Text buttons (enabled/disabled)
/// - Icon buttons (various styles)
/// - Full width buttons
///
/// This widget is extracted from the main design system test screen to
/// comply with FlowForge Rule #24 (file size limit).
class ButtonShowcase extends StatelessWidget {
  /// Creates a button showcase widget.
  const ButtonShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Elevated buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated'),
            ),
            ElevatedButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
          ],
        ),
        SizedBox(height: MnesisSpacings.md),
        // Outlined buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined'),
            ),
            OutlinedButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
          ],
        ),
        SizedBox(height: MnesisSpacings.md),
        // Text buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text('Text'),
            ),
            TextButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
          ],
        ),
        SizedBox(height: MnesisSpacings.md),
        // Icon buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite),
            ),
            IconButton(
              onPressed: null,
              icon: const Icon(Icons.favorite_border),
            ),
            IconButton.filled(
              onPressed: () {},
              icon: const Icon(Icons.add),
            ),
            IconButton.outlined(
              onPressed: () {},
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        SizedBox(height: MnesisSpacings.md),
        // Full width button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Full Width Button'),
          ),
        ),
      ],
    );
  }
}