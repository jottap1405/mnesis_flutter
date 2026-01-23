import 'package:flutter/material.dart';
import '../mnesis_spacings.dart';

/// Input fields showcase widget for design system testing.
///
/// Displays various input field configurations:
/// - Normal text input with helper text
/// - Input with prefix icon (search)
/// - Password input with suffix icon
/// - Error state input
/// - Disabled input
///
/// This widget is extracted from the main design system test screen to
/// comply with FlowForge Rule #24 (file size limit).
class InputShowcase extends StatefulWidget {
  /// Creates an input showcase widget.
  const InputShowcase({super.key});

  @override
  State<InputShowcase> createState() => _InputShowcaseState();
}

class _InputShowcaseState extends State<InputShowcase> {
  final TextEditingController _textController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Normal input
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Normal Input',
            hintText: 'Enter text here',
            helperText: 'Helper text',
          ),
        ),
        SizedBox(height: MnesisSpacings.lg),
        // With prefix icon
        const TextField(
          decoration: InputDecoration(
            labelText: 'With Icon',
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SizedBox(height: MnesisSpacings.lg),
        // With suffix icon (password)
        TextField(
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter password',
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        SizedBox(height: MnesisSpacings.lg),
        // Error state
        const TextField(
          decoration: InputDecoration(
            labelText: 'Error State',
            errorText: 'This field has an error',
          ),
        ),
        SizedBox(height: MnesisSpacings.lg),
        // Disabled
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Disabled',
            hintText: 'Cannot edit',
          ),
        ),
      ],
    );
  }
}