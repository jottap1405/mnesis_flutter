// Widget test for Mnesis app.

import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/main.dart';

void main() {
  testWidgets('Mnesis app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MnesisApp());
    await tester.pumpAndSettle(); // Wait for all animations to complete

    // Verify that the chat screen loads (initial route)
    expect(find.text('Chat'), findsWidgets);

    // Verify that bottom navigation is present
    expect(find.text('Novo'), findsOneWidget);
    expect(find.text('Operação'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
