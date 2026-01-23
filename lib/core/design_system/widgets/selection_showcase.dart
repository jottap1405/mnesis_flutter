import 'package:flutter/material.dart';
import '../mnesis_text_styles.dart';
import '../mnesis_spacings.dart';

/// Selection controls showcase widget for design system testing.
///
/// Displays interactive selection controls:
/// - Switch with list tile
/// - Checkbox with list tile
/// - Radio buttons (grouped)
/// - Slider with value display
///
/// This widget is extracted from the main design system test screen to
/// comply with FlowForge Rule #24 (file size limit).
class SelectionShowcase extends StatefulWidget {
  /// Creates a selection showcase widget.
  const SelectionShowcase({super.key});

  @override
  State<SelectionShowcase> createState() => _SelectionShowcaseState();
}

class _SelectionShowcaseState extends State<SelectionShowcase> {
  bool _switchValue = false;
  bool _checkboxValue = false;
  int _radioValue = 0;
  double _sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Switch
        SwitchListTile(
          title: const Text('Switch'),
          subtitle: const Text('Toggle this switch'),
          value: _switchValue,
          onChanged: (value) {
            setState(() {
              _switchValue = value;
            });
          },
        ),
        // Checkbox
        CheckboxListTile(
          title: const Text('Checkbox'),
          subtitle: const Text('Check this box'),
          value: _checkboxValue,
          onChanged: (value) {
            setState(() {
              _checkboxValue = value ?? false;
            });
          },
        ),
        // Radio buttons - Using column layout to avoid deprecated API
        Column(
          children: [
            ListTile(
              title: const Text('Option 1'),
              // ignore: deprecated_member_use
              leading: Radio<int>(
                value: 0,
                // ignore: deprecated_member_use
                groupValue: _radioValue,
                // ignore: deprecated_member_use
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _radioValue = value;
                    });
                  }
                },
              ),
              onTap: () {
                setState(() {
                  _radioValue = 0;
                });
              },
            ),
            ListTile(
              title: const Text('Option 2'),
              // ignore: deprecated_member_use
              leading: Radio<int>(
                value: 1,
                // ignore: deprecated_member_use
                groupValue: _radioValue,
                // ignore: deprecated_member_use
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _radioValue = value;
                    });
                  }
                },
              ),
              onTap: () {
                setState(() {
                  _radioValue = 1;
                });
              },
            ),
          ],
        ),
        // Slider
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MnesisSpacings.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Slider: ${_sliderValue.round()}',
                style: MnesisTextStyles.bodyMedium,
              ),
              Slider(
                value: _sliderValue,
                min: 0,
                max: 100,
                divisions: 10,
                label: _sliderValue.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}