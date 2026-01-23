import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnesis_flutter/core/providers/provider_logger.dart';

void main() {
  group('ProviderLogger', () {
    late ProviderLogger logger;
    late ProviderContainer container;

    setUp(() {
      logger = ProviderLogger();
      container = ProviderContainer(observers: [logger]);
    });

    tearDown(() {
      container.dispose();
    });

    test('creates ProviderLogger instance', () {
      expect(logger, isNotNull);
      expect(logger, isA<ProviderLogger>());
    });

    test('logs provider addition without crashing', () {
      // Create a simple provider
      final provider = StateProvider<int>((ref) => 0, name: 'testProvider');

      // Reading the provider should trigger didAddProvider
      expect(() => container.read(provider), returnsNormally);

      // Verify the provider was added
      expect(container.read(provider), equals(0));
    });

    test('logs provider update without crashing', () {
      // Create a provider
      final provider = StateProvider<int>((ref) => 0, name: 'testProvider');

      // Read to initialize
      container.read(provider);

      // Update should trigger didUpdateProvider
      expect(
        () => container.read(provider.notifier).state = 1,
        returnsNormally,
      );

      // Verify the update
      expect(container.read(provider), equals(1));
    });

    test('logs provider disposal without crashing', () {
      // Create a provider
      final provider = StateProvider<int>((ref) => 0, name: 'testProvider');

      // Read to initialize
      container.read(provider);

      // Disposal should trigger didDisposeProvider
      expect(() => container.dispose(), returnsNormally);
    });

    test('handles multiple providers simultaneously', () {
      // Create multiple providers
      final intProvider = StateProvider<int>((ref) => 42, name: 'intProvider');
      final stringProvider =
          StateProvider<String>((ref) => 'test', name: 'stringProvider');
      final boolProvider =
          StateProvider<bool>((ref) => true, name: 'boolProvider');

      // Read all providers
      expect(() {
        container.read(intProvider);
        container.read(stringProvider);
        container.read(boolProvider);
      }, returnsNormally);

      // Update all providers
      expect(() {
        container.read(intProvider.notifier).state = 100;
        container.read(stringProvider.notifier).state = 'updated';
        container.read(boolProvider.notifier).state = false;
      }, returnsNormally);

      // Verify updates
      expect(container.read(intProvider), equals(100));
      expect(container.read(stringProvider), equals('updated'));
      expect(container.read(boolProvider), isFalse);
    });

    test('handles provider without name', () {
      // Provider without explicit name
      final provider = StateProvider<double>((ref) => 3.14);

      expect(() => container.read(provider), returnsNormally);
      expect(container.read(provider), equals(3.14));
    });

    test('handles complex provider types', () {
      // Provider with complex type
      final listProvider = StateProvider<List<String>>(
        (ref) => ['item1', 'item2'],
        name: 'listProvider',
      );

      expect(() => container.read(listProvider), returnsNormally);

      // Update with new list
      expect(
        () => container.read(listProvider.notifier).state = ['updated'],
        returnsNormally,
      );

      expect(container.read(listProvider), equals(['updated']));
    });

    test('handles provider error gracefully', () {
      // Provider that throws an error
      final errorProvider = Provider<String>((ref) {
        throw Exception('Test error');
      }, name: 'errorProvider');

      // Should handle error without crashing the logger
      expect(
        () => container.read(errorProvider),
        throwsException,
      );
    });

    test('logger works with nested provider containers', () {
      // Create child container
      final childContainer = ProviderContainer(
        parent: container,
        observers: [logger],
      );

      final provider = StateProvider<int>((ref) => 5, name: 'nestedProvider');

      // Operations on child container
      expect(() => childContainer.read(provider), returnsNormally);
      expect(childContainer.read(provider), equals(5));

      childContainer.dispose();
    });

    test('logger handles rapid state changes', () {
      final provider = StateProvider<int>((ref) => 0, name: 'rapidProvider');

      container.read(provider);

      // Rapid updates
      expect(() {
        for (int i = 0; i < 100; i++) {
          container.read(provider.notifier).state = i;
        }
      }, returnsNormally);

      expect(container.read(provider), equals(99));
    });
  });

  group('Performance Benchmarks', () {
    test('ProviderLogger performance is acceptable', () async {
      final logger = ProviderLogger();
      final container = ProviderContainer(observers: [logger]);
      final provider = StateProvider<int>((ref) => 0, name: 'perfProvider');

      // Initialize provider
      container.read(provider);

      final stopwatch = Stopwatch()..start();

      // Simulate 1000 provider updates
      for (var i = 0; i < 1000; i++) {
        container.read(provider.notifier).state = i;
      }

      stopwatch.stop();

      // Logging 1000 updates should take < 500ms (relaxed for test environment)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Provider logging should not significantly impact performance. '
            'Took: ${stopwatch.elapsedMilliseconds}ms for 1000 updates',
      );

      container.dispose();
    });

    test('ProviderLogger add/dispose operations are fast', () async {
      final logger = ProviderLogger();

      final stopwatch = Stopwatch()..start();

      // Simulate 100 provider lifecycle events
      for (var i = 0; i < 100; i++) {
        final container = ProviderContainer(observers: [logger]);
        final provider = StateProvider<int>((ref) => i, name: 'lifecycleProvider$i');

        // Add provider
        container.read(provider);

        // Dispose container
        container.dispose();
      }

      stopwatch.stop();

      // 100 add/dispose cycles should take < 200ms (relaxed for test environment)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
        reason: 'Provider lifecycle logging should be fast. '
            'Took: ${stopwatch.elapsedMilliseconds}ms for 100 cycles',
      );
    });

    test('ProviderLogger handles concurrent operations efficiently', () async {
      final logger = ProviderLogger();
      final container = ProviderContainer(observers: [logger]);

      // Create multiple providers
      final providers = List.generate(
        10,
        (index) => StateProvider<int>((ref) => index, name: 'provider$index'),
      );

      // Initialize all providers
      for (final provider in providers) {
        container.read(provider);
      }

      final stopwatch = Stopwatch()..start();

      // Simulate concurrent updates
      for (var iteration = 0; iteration < 100; iteration++) {
        for (var i = 0; i < providers.length; i++) {
          container.read(providers[i].notifier).state = iteration * i;
        }
      }

      stopwatch.stop();

      // 1000 total updates (100 iterations * 10 providers) should be fast
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Concurrent provider logging should be efficient. '
            'Took: ${stopwatch.elapsedMilliseconds}ms for 1000 concurrent updates',
      );

      container.dispose();
    });
  });
}