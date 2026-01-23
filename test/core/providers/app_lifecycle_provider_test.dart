import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnesis_flutter/core/providers/app_lifecycle_provider.dart';

void main() {
  group('AppLifecycleProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is resumed', () {
      final state = container.read(appLifecycleProvider);
      expect(state, equals(MnesisLifecycleState.resumed));
    });

    test('can update lifecycle state', () {
      // Initial state
      expect(container.read(appLifecycleProvider), MnesisLifecycleState.resumed);

      // Update to paused
      container.read(appLifecycleProvider.notifier).state =
          MnesisLifecycleState.paused;
      expect(container.read(appLifecycleProvider), MnesisLifecycleState.paused);

      // Update to inactive
      container.read(appLifecycleProvider.notifier).state =
          MnesisLifecycleState.inactive;
      expect(container.read(appLifecycleProvider), MnesisLifecycleState.inactive);

      // Update to detached
      container.read(appLifecycleProvider.notifier).state =
          MnesisLifecycleState.detached;
      expect(container.read(appLifecycleProvider), MnesisLifecycleState.detached);

      // Back to resumed
      container.read(appLifecycleProvider.notifier).state =
          MnesisLifecycleState.resumed;
      expect(container.read(appLifecycleProvider), MnesisLifecycleState.resumed);
    });

    test('provider has correct name', () {
      expect(appLifecycleProvider.name, equals('appLifecycleProvider'));
    });

    test('notifier updates trigger rebuild in listeners', () {
      var rebuilds = 0;

      container.listen<MnesisLifecycleState>(
        appLifecycleProvider,
        (previous, next) {
          rebuilds++;
        },
      );

      // Trigger state changes
      container.read(appLifecycleProvider.notifier).state =
          MnesisLifecycleState.paused;
      expect(rebuilds, equals(1));

      container.read(appLifecycleProvider.notifier).state =
          MnesisLifecycleState.resumed;
      expect(rebuilds, equals(2));
    });

    test('multiple listeners receive updates', () {
      var listener1Count = 0;
      var listener2Count = 0;

      container.listen<MnesisLifecycleState>(
        appLifecycleProvider,
        (previous, next) => listener1Count++,
      );

      container.listen<MnesisLifecycleState>(
        appLifecycleProvider,
        (previous, next) => listener2Count++,
      );

      // Update state
      container.read(appLifecycleProvider.notifier).state =
          MnesisLifecycleState.inactive;

      expect(listener1Count, equals(1));
      expect(listener2Count, equals(1));
    });
  });

  group('AppLifecycleObserver Widget', () {
    testWidgets('wraps child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AppLifecycleObserver(
            child: MaterialApp(
              home: Text('Test App'),
            ),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
      expect(find.byType(AppLifecycleObserver), findsOneWidget);
    });

    testWidgets('initializes with WidgetsBindingObserver',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AppLifecycleObserver(
            child: MaterialApp(
              home: Scaffold(body: Text('Test')),
            ),
          ),
        ),
      );

      // Widget should be present and properly initialized
      expect(find.byType(AppLifecycleObserver), findsOneWidget);

      // Get the state to verify it's a WidgetsBindingObserver
      final state = tester.state<ConsumerState>(
        find.byType(AppLifecycleObserver),
      );
      expect(state, isA<WidgetsBindingObserver>());
    });

    testWidgets('updates provider on lifecycle change simulation',
        (WidgetTester tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              capturedRef = ref;
              return AppLifecycleObserver(
                child: MaterialApp(
                  home: Scaffold(
                    body: Text(
                      'State: ${ref.watch(appLifecycleProvider).name}',
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initial state should be resumed
      expect(find.text('State: resumed'), findsOneWidget);

      // Simulate lifecycle change
      capturedRef.read(appLifecycleProvider.notifier).state =
          MnesisLifecycleState.paused;
      await tester.pump();

      expect(find.text('State: paused'), findsOneWidget);
    });

    testWidgets('disposes properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: AppLifecycleObserver(
            child: MaterialApp(
              home: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(AppLifecycleObserver), findsOneWidget);

      // Replace with empty container to trigger disposal
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SizedBox(),
          ),
        ),
      );

      expect(find.byType(AppLifecycleObserver), findsNothing);
    });

    testWidgets('handles multiple instances correctly',
        (WidgetTester tester) async {
      // This tests that multiple AppLifecycleObserver widgets
      // can coexist without conflicts (though typically only one is needed)
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Column(
              children: [
                const AppLifecycleObserver(
                  child: Text('Observer 1'),
                ),
                const AppLifecycleObserver(
                  child: Text('Observer 2'),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(appLifecycleProvider);
                    return Text('State: ${state.name}');
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Observer 1'), findsOneWidget);
      expect(find.text('Observer 2'), findsOneWidget);
      expect(find.text('State: resumed'), findsOneWidget);
    });
  });

  group('MnesisLifecycleState enum', () {
    test('has all expected values', () {
      expect(MnesisLifecycleState.values.length, equals(4));
      expect(MnesisLifecycleState.values,
          contains(MnesisLifecycleState.resumed));
      expect(MnesisLifecycleState.values,
          contains(MnesisLifecycleState.inactive));
      expect(MnesisLifecycleState.values,
          contains(MnesisLifecycleState.paused));
      expect(MnesisLifecycleState.values,
          contains(MnesisLifecycleState.detached));
    });

    test('enum values have correct names', () {
      expect(MnesisLifecycleState.resumed.name, equals('resumed'));
      expect(MnesisLifecycleState.inactive.name, equals('inactive'));
      expect(MnesisLifecycleState.paused.name, equals('paused'));
      expect(MnesisLifecycleState.detached.name, equals('detached'));
    });
  });
}