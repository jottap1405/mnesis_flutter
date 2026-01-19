import 'package:flutter/material.dart';
import 'core/design_system/mnesis_theme.dart';

void main() {
  runApp(const MnesisApp());
}

/// Mnesis application root widget.
class MnesisApp extends StatelessWidget {
  const MnesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mnesis',
      debugShowCheckedModeBanner: false,

      // Apply Mnesis dark theme
      theme: MnesisTheme.darkTheme,

      // Design system test screen
      home: const DesignSystemTestScreen(),
    );
  }
}

/// Design system test screen to visually verify theme configuration.
///
/// This screen displays all major component types with the Mnesis theme applied,
/// allowing visual verification of:
/// - Colors (primary, surface, background, semantic)
/// - Typography (display, headline, body, label, caption)
/// - Component styling (buttons, inputs, cards, etc.)
/// - Spacing and border radius
/// - Interactive states (hover, pressed, disabled, focused)
class DesignSystemTestScreen extends StatefulWidget {
  const DesignSystemTestScreen({super.key});

  @override
  State<DesignSystemTestScreen> createState() =>
      _DesignSystemTestScreenState();
}

class _DesignSystemTestScreenState extends State<DesignSystemTestScreen> {
  bool _switchValue = true;
  bool _checkboxValue = true;
  int _radioValue = 1;
  double _sliderValue = 0.5;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mnesis Design System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Typography Section
          _buildSection(
            'Typography',
            [
              Text('Display Large', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Body Large - Main content text for chat messages and important descriptions.', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Body Medium - Standard body text for general content.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Caption - Timestamps and metadata', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),

          const SizedBox(height: 32),

          // Buttons Section
          _buildSection(
            'Buttons',
            [
              Row(
                spacing: 12,
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
              const SizedBox(height: 12),
              Row(
                spacing: 12,
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
              const SizedBox(height: 12),
              Row(
                spacing: 12,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Text Button'),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite),
                    isSelected: true,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Input Fields Section
          _buildSection(
            'Input Fields',
            [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'Placeholder text',
                  helperText: 'Helper text',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Error State',
                  errorText: 'Error message',
                  prefixIcon: Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Disabled',
                  hintText: 'Disabled input',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Cards Section
          _buildSection(
            'Cards',
            [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Title',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Card content with body text. Cards are used for grouping related information.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Switches & Checkboxes Section
          _buildSection(
            'Selection Controls',
            [
              SwitchListTile(
                title: const Text('Switch'),
                value: _switchValue,
                onChanged: (value) => setState(() => _switchValue = value),
              ),
              CheckboxListTile(
                title: const Text('Checkbox'),
                value: _checkboxValue,
                onChanged: (value) =>
                    setState(() => _checkboxValue = value ?? false),
              ),
              RadioListTile<int>(
                title: const Text('Radio Option 1'),
                value: 1,
                groupValue: _radioValue,
                onChanged: (value) => setState(() => _radioValue = value ?? 1),
              ),
              RadioListTile<int>(
                title: const Text('Radio Option 2'),
                value: 2,
                groupValue: _radioValue,
                onChanged: (value) => setState(() => _radioValue = value ?? 1),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Slider Section
          _buildSection(
            'Slider',
            [
              Slider(
                value: _sliderValue,
                onChanged: (value) => setState(() => _sliderValue = value),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Chips Section
          _buildSection(
            'Chips',
            [
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: const Text('Chip'),
                    onDeleted: () {},
                  ),
                  const Chip(
                    label: Text('Chip Selected'),
                    backgroundColor: Color(0xFFFF7043),
                  ),
                  ActionChip(
                    label: const Text('Action Chip'),
                    onPressed: () {},
                    avatar: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Progress Indicators Section
          _buildSection(
            'Progress Indicators',
            [
              const LinearProgressIndicator(value: 0.7),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircularProgressIndicator(),
                  CircularProgressIndicator(value: 0.7),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Divider Section
          _buildSection(
            'Divider',
            [
              const Divider(),
            ],
          ),

          const SizedBox(height: 32),

          // Snackbar Demo Section
          _buildSection(
            'Snackbar',
            [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('This is a snackbar message'),
                      action: SnackBarAction(
                        label: 'ACTION',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                child: const Text('Show Snackbar'),
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.mic),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
