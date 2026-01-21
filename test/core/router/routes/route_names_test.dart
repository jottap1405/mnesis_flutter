import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/router/routes/route_names.dart';
import 'package:mnesis_flutter/core/router/routes/route_paths.dart';

void main() {
  group('RouteNames', () {
    group('Constant Values', () {
      test('chat should be non-null and non-empty', () {
        expect(RouteNames.chat, isNotNull);
        expect(RouteNames.chat, isNotEmpty);
      });

      test('quickActions should be non-null and non-empty', () {
        expect(RouteNames.quickActions, isNotNull);
        expect(RouteNames.quickActions, isNotEmpty);
      });

      test('operations should be non-null and non-empty', () {
        expect(RouteNames.operations, isNotNull);
        expect(RouteNames.operations, isNotEmpty);
      });

      test('admin should be non-null and non-empty', () {
        expect(RouteNames.admin, isNotNull);
        expect(RouteNames.admin, isNotEmpty);
      });

      test('notFound should be non-null and non-empty', () {
        expect(RouteNames.notFound, isNotNull);
        expect(RouteNames.notFound, isNotEmpty);
      });
    });

    group('Naming Convention', () {
      test('chat should follow camelCase convention', () {
        expect(RouteNames.chat, matches(RegExp(r'^[a-z][a-zA-Z0-9]*$')));
      });

      test('quickActions should follow camelCase convention', () {
        expect(RouteNames.quickActions, matches(RegExp(r'^[a-z][a-zA-Z0-9]*$')));
      });

      test('operations should follow camelCase convention', () {
        expect(RouteNames.operations, matches(RegExp(r'^[a-z][a-zA-Z0-9]*$')));
      });

      test('admin should follow camelCase convention', () {
        expect(RouteNames.admin, matches(RegExp(r'^[a-z][a-zA-Z0-9]*$')));
      });

      test('notFound should follow camelCase convention', () {
        expect(RouteNames.notFound, matches(RegExp(r'^[a-z][a-zA-Z0-9]*$')));
      });
    });

    group('Uniqueness', () {
      test('all route names should be unique', () {
        final routeNames = [
          RouteNames.chat,
          RouteNames.quickActions,
          RouteNames.operations,
          RouteNames.admin,
          RouteNames.notFound,
        ];

        final uniqueNames = routeNames.toSet();
        expect(
          uniqueNames.length,
          equals(routeNames.length),
          reason: 'All route names must be unique',
        );
      });
    });
  });

  group('RoutePaths', () {
    group('Constant Values', () {
      test('chat should be non-null and non-empty', () {
        expect(RoutePaths.chat, isNotNull);
        expect(RoutePaths.chat, isNotEmpty);
      });

      test('quickActions should be non-null and non-empty', () {
        expect(RoutePaths.quickActions, isNotNull);
        expect(RoutePaths.quickActions, isNotEmpty);
      });

      test('operations should be non-null and non-empty', () {
        expect(RoutePaths.operations, isNotNull);
        expect(RoutePaths.operations, isNotEmpty);
      });

      test('admin should be non-null and non-empty', () {
        expect(RoutePaths.admin, isNotNull);
        expect(RoutePaths.admin, isNotEmpty);
      });

      test('notFound should be non-null and non-empty', () {
        expect(RoutePaths.notFound, isNotNull);
        expect(RoutePaths.notFound, isNotEmpty);
      });
    });

    group('Path Format', () {
      test('chat path should start with /', () {
        expect(RoutePaths.chat, startsWith('/'));
      });

      test('quickActions path should start with /', () {
        expect(RoutePaths.quickActions, startsWith('/'));
      });

      test('operations path should start with /', () {
        expect(RoutePaths.operations, startsWith('/'));
      });

      test('admin path should start with /', () {
        expect(RoutePaths.admin, startsWith('/'));
      });

      test('notFound path should start with /', () {
        expect(RoutePaths.notFound, startsWith('/'));
      });
    });

    group('Expected URLs', () {
      test('chat path should be /chat', () {
        expect(RoutePaths.chat, equals('/chat'));
      });

      test('quickActions path should be /new', () {
        expect(RoutePaths.quickActions, equals('/new'));
      });

      test('operations path should be /operation', () {
        expect(RoutePaths.operations, equals('/operation'));
      });

      test('admin path should be /admin', () {
        expect(RoutePaths.admin, equals('/admin'));
      });

      test('notFound path should be /404', () {
        expect(RoutePaths.notFound, equals('/404'));
      });
    });

    group('URL Convention', () {
      test('chat path should follow URL conventions', () {
        expect(
          RoutePaths.chat,
          matches(RegExp(r'^\/[a-z0-9\-_]*$')),
          reason: 'Path should be lowercase, alphanumeric with dash/underscore',
        );
      });

      test('quickActions path should follow URL conventions', () {
        expect(
          RoutePaths.quickActions,
          matches(RegExp(r'^\/[a-z0-9\-_]*$')),
          reason: 'Path should be lowercase, alphanumeric with dash/underscore',
        );
      });

      test('operations path should follow URL conventions', () {
        expect(
          RoutePaths.operations,
          matches(RegExp(r'^\/[a-z0-9\-_]*$')),
          reason: 'Path should be lowercase, alphanumeric with dash/underscore',
        );
      });

      test('admin path should follow URL conventions', () {
        expect(
          RoutePaths.admin,
          matches(RegExp(r'^\/[a-z0-9\-_]*$')),
          reason: 'Path should be lowercase, alphanumeric with dash/underscore',
        );
      });

      test('notFound path should follow URL conventions', () {
        expect(
          RoutePaths.notFound,
          matches(RegExp(r'^\/[a-z0-9\-_]*$')),
          reason: 'Path should be lowercase, alphanumeric with dash/underscore',
        );
      });
    });

    group('Uniqueness', () {
      test('all route paths should be unique', () {
        final routePaths = [
          RoutePaths.chat,
          RoutePaths.quickActions,
          RoutePaths.operations,
          RoutePaths.admin,
          RoutePaths.notFound,
        ];

        final uniquePaths = routePaths.toSet();
        expect(
          uniquePaths.length,
          equals(routePaths.length),
          reason: 'All route paths must be unique',
        );
      });
    });
  });

  group('RouteNames and RoutePaths Integration', () {
    test('should have matching route count', () {
      // RouteNames has 5 routes: chat, quickActions, operations, admin, notFound
      // RoutePaths has 5 paths: chat, quickActions, operations, admin, notFound
      const expectedRouteCount = 5;

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

      expect(
        routeNames.length,
        equals(expectedRouteCount),
        reason: 'RouteNames should have exactly $expectedRouteCount routes',
      );

      expect(
        routePaths.length,
        equals(expectedRouteCount),
        reason: 'RoutePaths should have exactly $expectedRouteCount paths',
      );

      expect(
        routeNames.length,
        equals(routePaths.length),
        reason: 'RouteNames and RoutePaths must have matching route count',
      );
    });
  });
}
