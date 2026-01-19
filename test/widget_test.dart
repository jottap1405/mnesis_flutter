// Widget test for Mnesis app.

import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/main.dart';

void main() {
  testWidgets('Mnesis app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MnesisApp());
    await tester.pumpAndSettle(); // Wait for all animations to complete

    // Verify that the design system test screen loads
    expect(find.text('Mnesis Design System'), findsOneWidget);

    // Verify that key sections are present (ListView content)
    expect(find.text('Typography'), findsOneWidget);
    expect(find.text('Buttons'), findsOneWidget);
  });
}
