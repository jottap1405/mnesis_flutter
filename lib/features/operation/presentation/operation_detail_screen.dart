import 'package:flutter/material.dart';

/// Operation detail screen showing specific operation information.
///
/// Displays detailed information about a specific medical operation,
/// including timeline, participants, and status.
class OperationDetailScreen extends StatelessWidget {
  /// Creates an [OperationDetailScreen].
  const OperationDetailScreen({
    required this.operationId,
    super.key,
  });

  /// The ID of the operation to display.
  final String operationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operação $operationId'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Operação: $operationId',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Detalhes da operação médica, timeline e participantes.',
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
