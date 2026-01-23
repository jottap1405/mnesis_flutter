import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mnesis_flutter/core/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    late EnvConfig envConfig;

    setUp(() {
      // Initialize dotenv with test values
      dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test-api.example.com
API_TIMEOUT_SECONDS=60
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=false
ENVIRONMENT=development
SUPABASE_URL=https://test.supabase.co
SUPABASE_ANON_KEY=test_anon_key_12345
      ''');
      envConfig = EnvConfig();
    });

    group('API Configuration', () {
      test('apiBaseUrl returns correct value from env', () {
        expect(envConfig.apiBaseUrl, equals('https://test-api.example.com'));
      });

      test('apiTimeoutSeconds returns correct integer value', () {
        expect(envConfig.apiTimeoutSeconds, equals(60));
        expect(envConfig.apiTimeoutSeconds, isA<int>());
      });

      test('apiBaseUrl uses fallback when not set', () {
        dotenv.testLoad(fileInput: '');
        envConfig = EnvConfig();
        expect(envConfig.apiBaseUrl, equals('https://api.mnesis.example.com'));
      });

      test('apiTimeoutSeconds uses fallback when not set', () {
        dotenv.testLoad(fileInput: '');
        envConfig = EnvConfig();
        expect(envConfig.apiTimeoutSeconds, equals(30));
      });
    });

    group('Supabase Configuration', () {
      test('supabaseUrl returns value when set', () {
        expect(envConfig.supabaseUrl, equals('https://test.supabase.co'));
      });

      test('supabaseAnonKey returns value when set', () {
        expect(envConfig.supabaseAnonKey, equals('test_anon_key_12345'));
      });

      test('supabase config returns null when not set', () {
        dotenv.testLoad(fileInput: '');
        envConfig = EnvConfig();
        expect(envConfig.supabaseUrl, isNull);
        expect(envConfig.supabaseAnonKey, isNull);
      });
    });

    group('Feature Flags', () {
      test('analyticsEnabled returns true when set to true', () {
        expect(envConfig.analyticsEnabled, isTrue);
      });

      test('crashReportingEnabled returns false when set to false', () {
        expect(envConfig.crashReportingEnabled, isFalse);
      });

      test('analyticsEnabled handles case insensitive values', () {
        dotenv.testLoad(fileInput: 'ENABLE_ANALYTICS=TRUE');
        envConfig = EnvConfig();
        expect(envConfig.analyticsEnabled, isTrue);

        dotenv.testLoad(fileInput: 'ENABLE_ANALYTICS=True');
        envConfig = EnvConfig();
        expect(envConfig.analyticsEnabled, isTrue);
      });

      test('feature flags default to false when not set', () {
        dotenv.testLoad(fileInput: '');
        envConfig = EnvConfig();
        expect(envConfig.analyticsEnabled, isFalse);
        expect(envConfig.crashReportingEnabled, isFalse);
      });
    });

    group('Environment Detection', () {
      test('environment returns development', () {
        expect(envConfig.environment, equals('development'));
      });

      test('isDevelopment returns true for development env', () {
        expect(envConfig.isDevelopment, isTrue);
        expect(envConfig.isProduction, isFalse);
        expect(envConfig.isStaging, isFalse);
      });

      test('isProduction returns true for production env', () {
        dotenv.testLoad(fileInput: 'ENVIRONMENT=production');
        envConfig = EnvConfig();
        expect(envConfig.isProduction, isTrue);
        expect(envConfig.isDevelopment, isFalse);
        expect(envConfig.isStaging, isFalse);
      });

      test('isStaging returns true for staging env', () {
        dotenv.testLoad(fileInput: 'ENVIRONMENT=staging');
        envConfig = EnvConfig();
        expect(envConfig.isStaging, isTrue);
        expect(envConfig.isDevelopment, isFalse);
        expect(envConfig.isProduction, isFalse);
      });

      test('environment defaults to development when not set', () {
        dotenv.testLoad(fileInput: '');
        envConfig = EnvConfig();
        expect(envConfig.environment, equals('development'));
        expect(envConfig.isDevelopment, isTrue);
      });
    });

    group('Utility Methods', () {
      test('validateRequired returns empty list when all required present', () {
        final missing = envConfig.validateRequired();
        expect(missing, isEmpty);
      });

      test('getRaw returns raw environment variable value', () {
        expect(envConfig.getRaw('API_BASE_URL'),
            equals('https://test-api.example.com'));
        expect(envConfig.getRaw('ENVIRONMENT'), equals('development'));
      });

      test('getRaw returns null for non-existent variable', () {
        expect(envConfig.getRaw('NON_EXISTENT_VAR'), isNull);
      });
    });

    group('Edge Cases', () {
      test('handles empty environment file gracefully', () {
        dotenv.testLoad(fileInput: '');
        envConfig = EnvConfig();

        // Should use all fallback values
        expect(envConfig.apiBaseUrl, isNotEmpty);
        expect(envConfig.apiTimeoutSeconds, greaterThan(0));
        expect(envConfig.environment, equals('development'));
        expect(envConfig.analyticsEnabled, isFalse);
      });

      test('handles malformed timeout value gracefully', () {
        dotenv.testLoad(fileInput: 'API_TIMEOUT_SECONDS=not_a_number');
        envConfig = EnvConfig();

        // Should throw FormatException
        expect(() => envConfig.apiTimeoutSeconds, throwsFormatException);
      });

      test('handles whitespace in boolean values', () {
        dotenv.testLoad(fileInput: 'ENABLE_ANALYTICS= true ');
        envConfig = EnvConfig();
        expect(envConfig.analyticsEnabled, isTrue);
      });
    });
  });
}