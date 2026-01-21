import 'package:go_router/go_router.dart';
import '../../../features/new/presentation/new_screen.dart';
import '../../../features/new/presentation/new_appointment_screen.dart';
import '../../../features/new/presentation/new_patient_screen.dart';
import '../../../features/new/presentation/new_schedule_screen.dart';

/// New/Quick action feature route definitions.
///
/// This feature provides **quick shortcuts** for common actions:
/// - New appointment
/// - New patient registration
/// - New schedule entry
///
/// ## Philosophy
/// While these actions can be performed via chat (chat-first), this screen
/// provides visual shortcuts for faster access to frequently used features.
///
/// ## Routes
/// - `/new` - Quick actions overview
/// - `/new/appointment` - New appointment form
/// - `/new/patient` - New patient registration form
/// - `/new/schedule` - New schedule entry form
///
/// Example:
/// ```dart
/// // Navigate to quick actions
/// context.go(NewRoutes.root);
///
/// // Navigate to specific action
/// context.go(NewRoutes.appointment);
/// ```
class NewRoutes {
  NewRoutes._(); // Private constructor

  /// Root path for new/quick actions.
  static const String root = '/new';

  /// Path for new appointment.
  static const String appointment = '/new/appointment';

  /// Path for new patient.
  static const String patient = '/new/patient';

  /// Path for new schedule.
  static const String schedule = '/new/schedule';

  /// Route definitions.
  static final List<RouteBase> routes = [
    GoRoute(
      path: root,
      name: 'new',
      builder: (context, state) => const NewScreen(),
      routes: [
        // Nested route: new appointment
        GoRoute(
          path: 'appointment',
          name: 'new-appointment',
          builder: (context, state) => const NewAppointmentScreen(),
        ),

        // Nested route: new patient
        GoRoute(
          path: 'patient',
          name: 'new-patient',
          builder: (context, state) => const NewPatientScreen(),
        ),

        // Nested route: new schedule
        GoRoute(
          path: 'schedule',
          name: 'new-schedule',
          builder: (context, state) => const NewScheduleScreen(),
        ),
      ],
    ),
  ];
}
