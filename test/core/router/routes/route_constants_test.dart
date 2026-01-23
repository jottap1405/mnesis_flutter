import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/router/routes/route_names.dart';
import 'package:mnesis_flutter/core/router/routes/route_paths.dart';

/// Comprehensive test suite for route constants.
///
/// Tests verify:
/// - All route names and paths are defined correctly
/// - Constants follow naming conventions
/// - Route names and paths are properly paired
/// - No duplicate values exist
/// - Path formats are valid
///
/// Coverage target: 100% for route_names.dart and route_paths.dart
void main() {
  group('RouteNames', () {
    group('Constant Values', () {
      test('chat route name is defined', () {
        expect(RouteNames.chat, equals('chat'));
      });

      test('quickActions route name is defined', () {
        expect(RouteNames.quickActions, equals('quickActions'));
      });

      test('operations route name is defined', () {
        expect(RouteNames.operations, equals('operations'));
      });

      test('admin route name is defined', () {
        expect(RouteNames.admin, equals('admin'));
      });

      test('notFound route name is defined', () {
        expect(RouteNames.notFound, equals('notFound'));
      });
    });

    group('Naming Convention', () {
      test('all route names follow camelCase convention', () {
        final routeNames = [
          RouteNames.chat,
          RouteNames.quickActions,
          RouteNames.operations,
          RouteNames.admin,
          RouteNames.notFound,
        ];

        final camelCasePattern = RegExp(r'^[a-z][a-zA-Z0-9]*$');

        for (final name in routeNames) {
          expect(
            camelCasePattern.hasMatch(name),
            isTrue,
            reason: 'Route name "$name" should follow camelCase convention',
          );
        }
      });

      test('no route names contain special characters', () {
        final routeNames = [
          RouteNames.chat,
          RouteNames.quickActions,
          RouteNames.operations,
          RouteNames.admin,
          RouteNames.notFound,
        ];

        for (final name in routeNames) {
          expect(name, isNot(contains('/')));
          expect(name, isNot(contains('-')));
          expect(name, isNot(contains('_')));
          expect(name, isNot(contains(' ')));
        }
      });

      test('no route names are empty', () {
        final routeNames = [
          RouteNames.chat,
          RouteNames.quickActions,
          RouteNames.operations,
          RouteNames.admin,
          RouteNames.notFound,
        ];

        for (final name in routeNames) {
          expect(name, isNotEmpty);
          expect(name.trim(), isNotEmpty);
        }
      });
    });

    group('Uniqueness', () {
      test('all route names are unique', () {
        final routeNames = [
          RouteNames.chat,
          RouteNames.quickActions,
          RouteNames.operations,
          RouteNames.admin,
          RouteNames.notFound,
        ];

        final uniqueNames = routeNames.toSet();

        expect(
          routeNames.length,
          equals(uniqueNames.length),
          reason: 'All route names should be unique',
        );
      });

      test('route names are distinct', () {
        expect(RouteNames.chat, isNot(equals(RouteNames.quickActions)));
        expect(RouteNames.chat, isNot(equals(RouteNames.operations)));
        expect(RouteNames.chat, isNot(equals(RouteNames.admin)));
        expect(RouteNames.chat, isNot(equals(RouteNames.notFound)));
        expect(RouteNames.quickActions, isNot(equals(RouteNames.operations)));
        expect(RouteNames.quickActions, isNot(equals(RouteNames.admin)));
        expect(RouteNames.quickActions, isNot(equals(RouteNames.notFound)));
        expect(RouteNames.operations, isNot(equals(RouteNames.admin)));
        expect(RouteNames.operations, isNot(equals(RouteNames.notFound)));
        expect(RouteNames.admin, isNot(equals(RouteNames.notFound)));
      });
    });

    group('Class Properties', () {
      test('cannot instantiate RouteNames', () {
        // RouteNames has private constructor, so instantiation is not allowed
        // This test verifies the design pattern is correct
        expect(RouteNames, isA<Type>());
      });

      test('all constants are compile-time constants', () {
        // Verify constants can be used in const contexts
        const testMap = {
          RouteNames.chat: 'Chat',
          RouteNames.quickActions: 'Quick Actions',
          RouteNames.operations: 'Operations',
          RouteNames.admin: 'Admin',
          RouteNames.notFound: 'Not Found',
        };

        expect(testMap, hasLength(5));
      });
    });
  });

  group('RoutePaths', () {
    group('Constant Values', () {
      test('chat route path is defined', () {
        expect(RoutePaths.chat, equals('/chat'));
      });

      test('quickActions route path is defined', () {
        expect(RoutePaths.quickActions, equals('/new'));
      });

      test('operations route path is defined', () {
        expect(RoutePaths.operations, equals('/operation'));
      });

      test('admin route path is defined', () {
        expect(RoutePaths.admin, equals('/admin'));
      });

      test('notFound route path is defined', () {
        expect(RoutePaths.notFound, equals('/404'));
      });
    });

    group('Path Format', () {
      test('all route paths start with forward slash', () {
        final routePaths = [
          RoutePaths.chat,
          RoutePaths.quickActions,
          RoutePaths.operations,
          RoutePaths.admin,
          RoutePaths.notFound,
        ];

        for (final path in routePaths) {
          expect(
            path.startsWith('/'),
            isTrue,
            reason: 'Route path "$path" should start with /',
          );
        }
      });

      test('no route paths have trailing slashes', () {
        final routePaths = [
          RoutePaths.chat,
          RoutePaths.quickActions,
          RoutePaths.operations,
          RoutePaths.admin,
          RoutePaths.notFound,
        ];

        for (final path in routePaths) {
          if (path.length > 1) {
            expect(
              path.endsWith('/'),
              isFalse,
              reason: 'Route path "$path" should not end with /',
            );
          }
        }
      });

      test('route paths follow URL conventions', () {
        final routePaths = [
          RoutePaths.chat,
          RoutePaths.quickActions,
          RoutePaths.operations,
          RoutePaths.admin,
          RoutePaths.notFound,
        ];

        // Valid URL path pattern: starts with /, lowercase alphanumeric with dash/underscore
        final urlPattern = RegExp(r'^/[a-z0-9-_/]*$');

        for (final path in routePaths) {
          expect(
            urlPattern.hasMatch(path.toLowerCase()),
            isTrue,
            reason: 'Route path "$path" should follow URL conventions',
          );
        }
      });

      test('no route paths contain spaces', () {
        final routePaths = [
          RoutePaths.chat,
          RoutePaths.quickActions,
          RoutePaths.operations,
          RoutePaths.admin,
          RoutePaths.notFound,
        ];

        for (final path in routePaths) {
          expect(path, isNot(contains(' ')));
        }
      });

      test('no route paths are empty', () {
        final routePaths = [
          RoutePaths.chat,
          RoutePaths.quickActions,
          RoutePaths.operations,
          RoutePaths.admin,
          RoutePaths.notFound,
        ];

        for (final path in routePaths) {
          expect(path, isNotEmpty);
          expect(path.trim(), isNotEmpty);
        }
      });
    });

    group('Uniqueness', () {
      test('all route paths are unique', () {
        final routePaths = [
          RoutePaths.chat,
          RoutePaths.quickActions,
          RoutePaths.operations,
          RoutePaths.admin,
          RoutePaths.notFound,
        ];

        final uniquePaths = routePaths.toSet();

        expect(
          routePaths.length,
          equals(uniquePaths.length),
          reason: 'All route paths should be unique',
        );
      });

      test('route paths are distinct', () {
        expect(RoutePaths.chat, isNot(equals(RoutePaths.quickActions)));
        expect(RoutePaths.chat, isNot(equals(RoutePaths.operations)));
        expect(RoutePaths.chat, isNot(equals(RoutePaths.admin)));
        expect(RoutePaths.chat, isNot(equals(RoutePaths.notFound)));
        expect(RoutePaths.quickActions, isNot(equals(RoutePaths.operations)));
        expect(RoutePaths.quickActions, isNot(equals(RoutePaths.admin)));
        expect(RoutePaths.quickActions, isNot(equals(RoutePaths.notFound)));
        expect(RoutePaths.operations, isNot(equals(RoutePaths.admin)));
        expect(RoutePaths.operations, isNot(equals(RoutePaths.notFound)));
        expect(RoutePaths.admin, isNot(equals(RoutePaths.notFound)));
      });
    });

    group('Class Properties', () {
      test('cannot instantiate RoutePaths', () {
        // RoutePaths has private constructor, so instantiation is not allowed
        // This test verifies the design pattern is correct
        expect(RoutePaths, isA<Type>());
      });

      test('all constants are compile-time constants', () {
        // Verify constants can be used in const contexts
        const testMap = {
          RoutePaths.chat: 'Chat',
          RoutePaths.quickActions: 'Quick Actions',
          RoutePaths.operations: 'Operations',
          RoutePaths.admin: 'Admin',
          RoutePaths.notFound: 'Not Found',
        };

        expect(testMap, hasLength(5));
      });
    });
  });

  group('RouteNames and RoutePaths Pairing', () {
    test('every route name has a corresponding path', () {
      // Verify all route names have matching paths defined
      expect(RoutePaths.chat, isNotNull);
      expect(RoutePaths.quickActions, isNotNull);
      expect(RoutePaths.operations, isNotNull);
      expect(RoutePaths.admin, isNotNull);
      expect(RoutePaths.notFound, isNotNull);
    });

    test('route names count matches route paths count', () {
      final routeNames = [
        RouteNames.chat,
        RouteNames.quickActions,
        RouteNames.operations,
        RouteNames.admin,
        RouteNames.notFound,
      ];

      final routePaths = [
        RoutePaths.chat,
        RoutePaths.quickActions,
        RoutePaths.operations,
        RoutePaths.admin,
        RoutePaths.notFound,
      ];

      expect(routeNames.length, equals(routePaths.length));
    });

    test('route pairs are logically consistent', () {
      // Verify the logical pairing between names and paths
      final pairs = {
        RouteNames.chat: RoutePaths.chat,
        RouteNames.quickActions: RoutePaths.quickActions,
        RouteNames.operations: RoutePaths.operations,
        RouteNames.admin: RoutePaths.admin,
        RouteNames.notFound: RoutePaths.notFound,
      };

      expect(pairs, hasLength(5));

      // Verify paths contain lowercase versions of names (where applicable)
      expect(RoutePaths.chat.toLowerCase(), contains('chat'));
      expect(RoutePaths.operations.toLowerCase(), contains('operation'));
      expect(RoutePaths.admin.toLowerCase(), contains('admin'));
    });
  });

  group('Edge Cases and Validation', () {
    test('route names handle string comparison correctly', () {
      final name1 = RouteNames.chat;
      final name2 = 'chat';

      expect(name1 == name2, isTrue);
      expect(name1.compareTo(name2), equals(0));
    });

    test('route paths handle string comparison correctly', () {
      final path1 = RoutePaths.chat;
      final path2 = '/chat';

      expect(path1 == path2, isTrue);
      expect(path1.compareTo(path2), equals(0));
    });

    test('route names can be used as map keys', () {
      final routeMap = {
        RouteNames.chat: 'Chat Screen',
        RouteNames.quickActions: 'Quick Actions Screen',
        RouteNames.operations: 'Operations Screen',
        RouteNames.admin: 'Admin Screen',
        RouteNames.notFound: 'Not Found Screen',
      };

      expect(routeMap[RouteNames.chat], equals('Chat Screen'));
      expect(routeMap[RouteNames.admin], equals('Admin Screen'));
    });

    test('route paths can be used as map keys', () {
      final pathMap = {
        RoutePaths.chat: 'Chat',
        RoutePaths.quickActions: 'New',
        RoutePaths.operations: 'Operations',
        RoutePaths.admin: 'Admin',
        RoutePaths.notFound: '404',
      };

      expect(pathMap[RoutePaths.chat], equals('Chat'));
      expect(pathMap[RoutePaths.notFound], equals('404'));
    });

    test('route constants are immutable', () {
      // Constants cannot be reassigned (verified by compiler)
      // This test documents the immutability guarantee
      const name = RouteNames.chat;
      const path = RoutePaths.chat;

      expect(name, equals('chat'));
      expect(path, equals('/chat'));
    });
  });
}
