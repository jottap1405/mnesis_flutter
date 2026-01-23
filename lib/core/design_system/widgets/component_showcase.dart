import 'package:flutter/material.dart';
import '../mnesis_colors.dart';
import '../mnesis_text_styles.dart';
import '../mnesis_spacings.dart';

/// Component showcase widget for design system testing.
///
/// Displays various UI components:
/// - Cards (basic and with image)
/// - Chips (all variations)
/// - List tiles
/// - Progress indicators
/// - Navigation bar
///
/// This widget is extracted from the main design system test screen to
/// comply with FlowForge Rule #24 (file size limit).
class ComponentShowcase extends StatefulWidget {
  /// Creates a component showcase widget.
  const ComponentShowcase({super.key});

  @override
  State<ComponentShowcase> createState() => _ComponentShowcaseState();
}

class _ComponentShowcaseState extends State<ComponentShowcase> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCards(),
        SizedBox(height: MnesisSpacings.xl),
        Text('Chips', style: MnesisTextStyles.headlineSmall),
        SizedBox(height: MnesisSpacings.md),
        _buildChips(),
        SizedBox(height: MnesisSpacings.xl),
        Text('List Items', style: MnesisTextStyles.headlineSmall),
        SizedBox(height: MnesisSpacings.md),
        _buildListItems(),
        SizedBox(height: MnesisSpacings.xl),
        Text('Progress Indicators', style: MnesisTextStyles.headlineSmall),
        SizedBox(height: MnesisSpacings.md),
        _buildProgressIndicators(),
        SizedBox(height: MnesisSpacings.xl),
        Text('Navigation', style: MnesisTextStyles.headlineSmall),
        SizedBox(height: MnesisSpacings.md),
        _buildNavigation(),
      ],
    );
  }

  /// Builds card examples.
  Widget _buildCards() {
    return Column(
      children: [
        // Basic card
        Card(
          child: Padding(
            padding: EdgeInsets.all(MnesisSpacings.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basic Card',
                  style: MnesisTextStyles.headlineSmall,
                ),
                SizedBox(height: MnesisSpacings.sm),
                Text(
                  'This is a basic card with some content inside.',
                  style: MnesisTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: MnesisSpacings.md),
        // Card with image
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                color: MnesisColors.orange20,
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: MnesisColors.primaryOrange,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MnesisSpacings.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card with Image',
                      style: MnesisTextStyles.headlineSmall,
                    ),
                    SizedBox(height: MnesisSpacings.sm),
                    Text(
                      'This card has an image placeholder at the top.',
                      style: MnesisTextStyles.bodyMedium,
                    ),
                    SizedBox(height: MnesisSpacings.md),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('ACTION 1'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('ACTION 2'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds chip variations.
  Widget _buildChips() {
    return Wrap(
      spacing: MnesisSpacings.sm,
      runSpacing: MnesisSpacings.sm,
      children: [
        Chip(
          label: const Text('Basic Chip'),
          onDeleted: () {},
        ),
        const Chip(
          label: Text('With Avatar'),
          avatar: CircleAvatar(
            backgroundColor: MnesisColors.primaryOrange,
            child: Text('A'),
          ),
        ),
        ActionChip(
          label: const Text('Action Chip'),
          onPressed: () {},
        ),
        FilterChip(
          label: const Text('Filter Chip'),
          selected: true,
          onSelected: (value) {},
        ),
        ChoiceChip(
          label: const Text('Choice Chip'),
          selected: true,
          onSelected: (value) {},
        ),
        InputChip(
          label: const Text('Input Chip'),
          onPressed: () {},
          onDeleted: () {},
        ),
      ],
    );
  }

  /// Builds list tile examples.
  Widget _buildListItems() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Basic List Tile'),
            subtitle: Text('With subtitle'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: MnesisColors.primaryOrange,
              child: Text('AB'),
            ),
            title: const Text('With Avatar'),
            subtitle: const Text('And action'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text('With Switch'),
            subtitle: const Text('Toggle option'),
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  /// Builds progress indicator examples.
  Widget _buildProgressIndicators() {
    return Column(
      children: [
        const LinearProgressIndicator(),
        SizedBox(height: MnesisSpacings.lg),
        const LinearProgressIndicator(value: 0.7),
        SizedBox(height: MnesisSpacings.lg),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(value: 0.75),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds navigation bar example.
  Widget _buildNavigation() {
    return Card(
      child: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}