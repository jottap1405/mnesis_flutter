import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/di/injection.dart';
import 'package:mnesis_flutter/core/config/env_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Dependency Injection', () {
    setUp(() async {
      // Reset DI container before each test
      await getIt.reset();

      // Load test environment
      dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test.api.com
API_TIMEOUT_SECONDS=30
ENVIRONMENT=test
      ''');
    });

    tearDown(() async {
      // Clean up after each test
      await getIt.reset();
    });

    test('configureDependencies initializes DI container', () async {
      // Act
      await configureDependencies();

      // Assert
      expect(getIt.isRegistered<EnvConfig>(), isTrue,
          reason: 'EnvConfig should be registered');
    });

    test('EnvConfig is registered as lazy singleton', () async {
      // Arrange
      await configureDependencies();

      // Act
      final config1 = getIt<EnvConfig>();
      final config2 = getIt<EnvConfig>();

      // Assert
      expect(identical(config1, config2), isTrue,
          reason: 'EnvConfig should be a singleton');
    });

    test('can retrieve EnvConfig from container', () async {
      // Arrange
      await configureDependencies();

      // Act
      final config = getIt<EnvConfig>();

      // Assert
      expect(config, isNotNull);
      expect(config, isA<EnvConfig>());
    });

    test('container reset clears all registrations', () async {
      // Arrange
      await configureDependencies();
      expect(getIt.isRegistered<EnvConfig>(), isTrue);

      // Act
      await getIt.reset();

      // Assert
      expect(getIt.isRegistered<EnvConfig>(), isFalse,
          reason: 'Container should be empty after reset');
    });

    test('multiple calls to configureDependencies handle gracefully', () async {
      // First call
      await configureDependencies();
      expect(getIt.isRegistered<EnvConfig>(), isTrue);

      // Reset and call again
      await getIt.reset();
      await configureDependencies();

      // Should still work
      expect(getIt.isRegistered<EnvConfig>(), isTrue);
      final config = getIt<EnvConfig>();
      expect(config, isNotNull);
    });
  });
}