import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Import test modules
import 'migrations/migration_v1_to_v2_validation_test.dart';
import 'migrations/migration_v1_to_v2_schema_test.dart';
import 'migrations/migration_v1_to_v2_constraints_test.dart';

/// Comprehensive test suite for database migration from v1 to v2.
///
/// **Test Coverage:**
/// - Migration Validation (8 tests): Table creation, data preservation
/// - Schema Validation (6 tests): Column definitions, index verification
/// - Constraints & Behavior (6 tests): Foreign keys, soft deletes, defaults
///
/// **Total Tests:** 20+
/// **Target Coverage:** 80%+
/// **Compliance:** Rule #3 (test location), Rule #24 (<700 lines per file)
///
/// **Test Structure:**
/// Tests are modularized across multiple files to comply with Rule #24:
/// - `migrations/migration_v1_to_v2_validation_test.dart` (~180 lines)
/// - `migrations/migration_v1_to_v2_schema_test.dart` (~240 lines)
/// - `migrations/migration_v1_to_v2_constraints_test.dart` (~240 lines)
///
/// **Usage:**
/// ```bash
/// flutter test test/core/database/database_migration_test.dart
/// ```
void main() {
  // Setup FFI for desktop testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Migration v1→v2', () {
    // Run all migration test modules
    runMigrationValidationTests();
    runMigrationSchemaTests();
    runMigrationConstraintsTests();
  });
}
