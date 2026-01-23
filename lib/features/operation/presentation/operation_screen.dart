import 'package:flutter/material.dart';

/// Operations overview screen.
///
/// Shows a dashboard of current activities, pending tasks, and quick access
/// to common medical workflows.
///
/// ## Features
/// - Current operations dashboard
/// - Pending tasks overview
/// - Quick access to workflows
/// - Recent activity feed
class OperationScreen extends StatelessWidget {
  /// Creates an [OperationScreen].
  const OperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operações'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Operações',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Dashboard de operações médicas, tarefas pendentes '
                'e atividades recentes.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
