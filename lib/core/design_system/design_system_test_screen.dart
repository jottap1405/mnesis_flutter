import 'package:flutter/material.dart';
import 'mnesis_colors.dart';
import 'mnesis_text_styles.dart';
import 'mnesis_spacings.dart';
import 'widgets/typography_showcase.dart';
import 'widgets/color_palette_showcase.dart';
import 'widgets/button_showcase.dart';
import 'widgets/input_showcase.dart';
import 'widgets/selection_showcase.dart';
import 'widgets/component_showcase.dart';

/// Visual verification screen for Mnesis design system.
///
/// This screen provides a comprehensive showcase of all Material 3 components
/// configured in [MnesisTheme], allowing visual verification of:
/// - Typography scale
/// - Color palette
/// - All button variations
/// - Input fields (all states)
/// - Cards and surfaces
/// - Navigation components
/// - Selection controls
/// - Dialogs and sheets
///
/// ## Usage
/// Navigate to this screen from the admin menu or directly via:
/// ```dart
/// context.go('/admin/design-system');
/// ```
///
/// ## Implementation Note
/// Component showcases are extracted into separate widgets in the `widgets/`
/// directory to comply with FlowForge Rule #24 (700 line file limit).
///
/// See also:
/// * [MnesisTheme] - Theme configuration
/// * [MnesisColors] - Color system
/// * [MnesisTextStyles] - Typography
/// * [MnesisSpacings] - Spacing constants
class DesignSystemTestScreen extends StatelessWidget {
  /// Creates a design system test screen.
  const DesignSystemTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showBottomSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(MnesisSpacings.lg),
        children: [
          _buildSection(
            title: 'Typography',
            children: const [TypographyShowcase()],
          ),
          _buildSection(
            title: 'Colors',
            children: const [ColorPaletteShowcase()],
          ),
          _buildSection(
            title: 'Buttons',
            children: const [ButtonShowcase()],
          ),
          _buildSection(
            title: 'Input Fields',
            children: const [InputShowcase()],
          ),
          _buildSection(
            title: 'Selection Controls',
            children: const [SelectionShowcase()],
          ),
          _buildSection(
            title: 'Components',
            children: const [ComponentShowcase()],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSnackbar(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds a section with title and content.
  ///
  /// Creates a consistent layout for each design system section
  /// with proper spacing and typography.
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MnesisTextStyles.headlineMedium,
        ),
        SizedBox(height: MnesisSpacings.md),
        ...children,
        SizedBox(height: MnesisSpacings.xl),
      ],
    );
  }

  /// Shows a dialog for testing dialog theme.
  ///
  /// Demonstrates the Material 3 dialog with custom Mnesis theme.
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dialog Title'),
          content: const Text('This is a dialog with some content to display.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a bottom sheet for testing bottom sheet theme.
  ///
  /// Demonstrates the Material 3 modal bottom sheet with custom styling.
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(MnesisSpacings.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: MnesisSpacings.lg),
                decoration: BoxDecoration(
                  color: MnesisColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Bottom Sheet',
                style: MnesisTextStyles.headlineMedium,
              ),
              SizedBox(height: MnesisSpacings.md),
              Text(
                'This is a modal bottom sheet with some content.',
                style: MnesisTextStyles.bodyMedium,
              ),
              SizedBox(height: MnesisSpacings.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a snackbar for testing snackbar theme.
  ///
  /// Demonstrates the Material 3 snackbar with floating behavior.
  void _showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('This is a snackbar message'),
        action: SnackBarAction(
          label: 'ACTION',
          onPressed: () {},
        ),
      ),
    );
  }
}