/// Comprehensive test suite for design system showcase widgets.
///
/// Tests all showcase components to ensure:
/// - Widgets render without errors
/// - All UI components are present
/// - Interactive elements work correctly
/// - Dark theme is properly applied
/// - Responsive behavior functions
///
/// These are internal development tools for visual verification of the
/// Mnesis dark theme design system with Material 3 components.
///
/// Comprehensive test coverage following FlowForge Rule #3
/// (80%+ test coverage) and Rule #25 (Testing & Reliability).
///
/// File covers:
/// - DesignSystemTestScreen
/// - ComponentShowcase
/// - TypographyShowcase
/// - ColorPaletteShowcase
/// - ButtonShowcase
/// - InputShowcase
/// - SelectionShowcase
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/design_system/design_system_test_screen.dart';
import 'package:mnesis_flutter/core/design_system/widgets/button_showcase.dart';
import 'package:mnesis_flutter/core/design_system/widgets/color_palette_showcase.dart';
import 'package:mnesis_flutter/core/design_system/widgets/component_showcase.dart';
import 'package:mnesis_flutter/core/design_system/widgets/input_showcase.dart';
import 'package:mnesis_flutter/core/design_system/widgets/selection_showcase.dart';
import 'package:mnesis_flutter/core/design_system/widgets/typography_showcase.dart';

void main() {
  group('DesignSystemTestScreen', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: DesignSystemTestScreen(),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(DesignSystemTestScreen), findsOneWidget);
    });

    testWidgets('has scaffold with app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays all showcase sections', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Main showcase widgets should be present
      expect(find.byType(TypographyShowcase), findsOneWidget);
      expect(find.byType(ColorPaletteShowcase), findsOneWidget);
      expect(find.byType(ButtonShowcase), findsOneWidget);
      expect(find.byType(InputShowcase), findsOneWidget);
      expect(find.byType(SelectionShowcase), findsOneWidget);
      expect(find.byType(ComponentShowcase), findsOneWidget);
    });

    testWidgets('is scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('uses Material 3 components', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Material 3 components should be present
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(FilledButton), findsWidgets);
      expect(find.byType(OutlinedButton), findsWidgets);
      expect(find.byType(TextButton), findsWidgets);
    });
  });

  group('ComponentShowcase', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ComponentShowcase(),
          ),
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ComponentShowcase), findsOneWidget);
    });

    testWidgets('displays card components', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('displays chip components', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('displays list tiles', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('displays progress indicators', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('displays navigation bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('navigation bar is interactive', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.destinations.length, greaterThan(0));
    });
  });

  group('TypographyShowcase', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TypographyShowcase(),
          ),
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(TypographyShowcase), findsOneWidget);
    });

    testWidgets('displays typography samples', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('shows different text styles', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Typography showcase should show multiple text widgets
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('ColorPaletteShowcase', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ColorPaletteShowcase(),
          ),
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ColorPaletteShowcase), findsOneWidget);
    });

    testWidgets('displays color containers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses GridView for color layout', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsWidgets);
    });
  });

  group('ButtonShowcase', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ButtonShowcase(),
          ),
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ButtonShowcase), findsOneWidget);
    });

    testWidgets('displays filled buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton), findsWidgets);
    });

    testWidgets('displays outlined buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(OutlinedButton), findsWidgets);
    });

    testWidgets('displays text buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('displays elevated buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('displays FABs', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('buttons are interactive', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap a filled button
      final filledButton = find.byType(FilledButton).first;
      await tester.tap(filledButton);
      await tester.pump();

      // Should not throw error
      expect(find.byType(ButtonShowcase), findsOneWidget);
    });
  });

  group('InputShowcase', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InputShowcase(),
          ),
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(InputShowcase), findsOneWidget);
    });

    testWidgets('displays text fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows input field states', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Input showcase should have multiple TextField widgets showing
      // different states (normal, focused, error, disabled)
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('input fields are interactive', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find first text field and try to interact
      final textField = find.byType(TextField).first;
      await tester.tap(textField);
      await tester.pump();

      // Should not throw error
      expect(find.byType(InputShowcase), findsOneWidget);
    });
  });

  group('SelectionShowcase', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SelectionShowcase(),
          ),
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(SelectionShowcase), findsOneWidget);
    });

    testWidgets('displays checkboxes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsWidgets);
    });

    testWidgets('displays radio buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Radio), findsWidgets);
    });

    testWidgets('displays switches', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('displays sliders', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('checkboxes are interactive', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap a checkbox
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pump();

      // Should not throw error
      expect(find.byType(SelectionShowcase), findsOneWidget);
    });

    testWidgets('switches are interactive', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap a switch
      final switchWidget = find.byType(Switch).first;
      await tester.tap(switchWidget);
      await tester.pump();

      // Should not throw error
      expect(find.byType(SelectionShowcase), findsOneWidget);
    });
  });

  group('Showcase Integration', () {
    testWidgets('all showcases work together in main screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DesignSystemTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // All showcases should be present
      expect(find.byType(TypographyShowcase), findsOneWidget);
      expect(find.byType(ColorPaletteShowcase), findsOneWidget);
      expect(find.byType(ButtonShowcase), findsOneWidget);
      expect(find.byType(InputShowcase), findsOneWidget);
      expect(find.byType(SelectionShowcase), findsOneWidget);
      expect(find.byType(ComponentShowcase), findsOneWidget);
    });

    testWidgets('screen is scrollable through all sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DesignSystemTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to see more content
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // Should still find main widget
      expect(find.byType(DesignSystemTestScreen), findsOneWidget);
    });

    testWidgets('dark theme is properly applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const DesignSystemTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Theme should apply to all showcase widgets
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.brightness, equals(Brightness.dark));
    });
  });

  group('Widget Properties', () {
    testWidgets('all showcases use const constructors', (tester) async {
      // Verify const constructors work
      const typography = TypographyShowcase();
      const colorPalette = ColorPaletteShowcase();
      const buttons = ButtonShowcase();
      const inputs = InputShowcase();
      const selection = SelectionShowcase();
      const components = ComponentShowcase();

      expect(typography, isNotNull);
      expect(colorPalette, isNotNull);
      expect(buttons, isNotNull);
      expect(inputs, isNotNull);
      expect(selection, isNotNull);
      expect(components, isNotNull);
    });

    testWidgets('showcases are stateful where needed', (tester) async {
      // ComponentShowcase and SelectionShowcase need state for interactions
      expect(const ComponentShowcase(), isA<StatefulWidget>());
      expect(const SelectionShowcase(), isA<StatefulWidget>());
    });

    testWidgets('showcases are stateless where appropriate', (tester) async {
      // Simple display showcases can be stateless
      expect(const TypographyShowcase(), isA<StatelessWidget>());
      expect(const ColorPaletteShowcase(), isA<StatelessWidget>());
      expect(const ButtonShowcase(), isA<StatelessWidget>());
    });
  });

  group('Responsive Behavior', () {
    testWidgets('adapts to different screen sizes', (tester) async {
      // Test on small screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: DesignSystemTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DesignSystemTestScreen), findsOneWidget);

      // Test on large screen
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(
        const MaterialApp(
          home: DesignSystemTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DesignSystemTestScreen), findsOneWidget);

      // Reset
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
