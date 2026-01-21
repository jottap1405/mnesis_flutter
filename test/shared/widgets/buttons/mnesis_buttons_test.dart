import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/shared/widgets/buttons/buttons.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_spacings.dart';

void main() {
  group('MnesisPrimaryButton Tests', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisPrimaryButton(
              text: 'Continuar',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisPrimaryButton(
              text: 'Test',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MnesisPrimaryButton));
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MnesisPrimaryButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisPrimaryButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisPrimaryButton(
              text: 'With Icon',
              icon: Icons.arrow_forward,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('has correct height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisPrimaryButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.height, equals(MnesisSpacings.buttonHeight));
    });

    testWidgets('has correct background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisPrimaryButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final backgroundColor =
          button.style?.backgroundColor?.resolve({WidgetState.selected});
      expect(backgroundColor, equals(MnesisColors.primaryOrange));
    });

    testWidgets('is disabled while loading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisPrimaryButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MnesisPrimaryButton));
      expect(pressed, isFalse);
    });
  });

  group('MnesisSecondaryButton Tests', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisSecondaryButton(
              text: 'Cancelar',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisSecondaryButton(
              text: 'Test',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MnesisSecondaryButton));
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MnesisSecondaryButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisSecondaryButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisSecondaryButton(
              text: 'With Icon',
              icon: Icons.close,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('has correct height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisSecondaryButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(OutlinedButton),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.height, equals(MnesisSpacings.buttonHeight));
    });

    testWidgets('has transparent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisSecondaryButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );

      final backgroundColor =
          button.style?.backgroundColor?.resolve({WidgetState.selected});
      expect(backgroundColor, equals(Colors.transparent));
    });
  });

  group('MnesisTextButton Tests', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisTextButton(
              text: 'Pular',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pular'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisTextButton(
              text: 'Test',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MnesisTextButton));
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MnesisTextButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<TextButton>(
        find.byType(TextButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisTextButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisTextButton(
              text: 'Ver mais',
              icon: Icons.arrow_forward,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('Ver mais'), findsOneWidget);
    });

    testWidgets('has correct height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisTextButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(TextButton),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.height, equals(MnesisSpacings.buttonHeight));
    });

    testWidgets('has orange text color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisTextButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<TextButton>(
        find.byType(TextButton),
      );

      final foregroundColor =
          button.style?.foregroundColor?.resolve({WidgetState.selected});
      expect(foregroundColor, equals(MnesisColors.primaryOrange));
    });

    testWidgets('has transparent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MnesisTextButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<TextButton>(
        find.byType(TextButton),
      );

      final backgroundColor =
          button.style?.backgroundColor?.resolve({WidgetState.selected});
      expect(backgroundColor, equals(Colors.transparent));
    });
  });

  group('Button States and Interactions', () {
    testWidgets('all buttons support custom width', (tester) async {
      const customWidth = 200.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MnesisPrimaryButton(
                  text: 'Primary',
                  width: customWidth,
                  onPressed: () {},
                ),
                MnesisSecondaryButton(
                  text: 'Secondary',
                  width: customWidth,
                  onPressed: () {},
                ),
                MnesisTextButton(
                  text: 'Text',
                  width: customWidth,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      final primaryBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );

      final secondaryBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(OutlinedButton),
          matching: find.byType(SizedBox),
        ),
      );

      final textBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(TextButton),
          matching: find.byType(SizedBox),
        ),
      );

      expect(primaryBox.width, equals(customWidth));
      expect(secondaryBox.width, equals(customWidth));
      expect(textBox.width, equals(customWidth));
    });

    testWidgets('loading state disables all button types', (tester) async {
      var primaryPressed = false;
      var secondaryPressed = false;
      var textPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MnesisPrimaryButton(
                  text: 'Primary',
                  isLoading: true,
                  onPressed: () => primaryPressed = true,
                ),
                MnesisSecondaryButton(
                  text: 'Secondary',
                  isLoading: true,
                  onPressed: () => secondaryPressed = true,
                ),
                MnesisTextButton(
                  text: 'Text',
                  isLoading: true,
                  onPressed: () => textPressed = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MnesisPrimaryButton));
      await tester.tap(find.byType(MnesisSecondaryButton));
      await tester.tap(find.byType(MnesisTextButton));

      expect(primaryPressed, isFalse);
      expect(secondaryPressed, isFalse);
      expect(textPressed, isFalse);
    });
  });
}
