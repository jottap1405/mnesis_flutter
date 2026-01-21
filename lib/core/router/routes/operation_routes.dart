import 'package:go_router/go_router.dart';
import '../../../features/operation/presentation/operation_screen.dart';
import '../../../features/operation/presentation/operation_detail_screen.dart';

/// Operation feature route definitions.
///
/// This feature provides quick access to **general operations** and
/// overview of ongoing/completed medical procedures.
///
/// ## Philosophy
/// Operations screen shows a dashboard of current activities, pending tasks,
/// and quick access to common workflows. Detailed operations can be accessed
/// via nested routes.
///
/// ## Routes
/// - `/operation` - Operations overview/dashboard
/// - `/operation/:operationId` - Specific operation detail
///
/// Example:
/// ```dart
/// // Navigate to operations
/// context.go(OperationRoutes.root);
///
/// // Navigate to specific operation
/// context.go(OperationRoutes.detail('op-123'));
/// ```
class OperationRoutes {
  OperationRoutes._(); // Private constructor

  /// Root path for operations.
  static const String root = '/operation';

  /// Path for operation detail.
  static const String detailPath = '/operation/:operationId';

  /// Helper to build operation detail route.
  static String detail(String operationId) => '/operation/$operationId';

  /// Route definitions.
  static final List<RouteBase> routes = [
    GoRoute(
      path: root,
      name: 'operation',
      builder: (context, state) => const OperationScreen(),
      routes: [
        // Nested route: operation detail
        GoRoute(
          path: ':operationId',
          name: 'operation-detail',
          builder: (context, state) {
            final operationId = state.pathParameters['operationId']!;
            return OperationDetailScreen(operationId: operationId);
          },
        ),
      ],
    ),
  ];
}
