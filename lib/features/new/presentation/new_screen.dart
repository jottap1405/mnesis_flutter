import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes/new_routes.dart';

/// Quick actions screen for starting new workflows.
///
/// Provides shortcuts for common actions that can also be performed via chat.
///
/// ## Features
/// - New appointment
/// - New patient registration
/// - New schedule entry
///
/// ## Philosophy
/// While all these actions can be done via chat (chat-first), this screen
/// provides visual shortcuts for faster access to frequently used features.
class NewScreen extends StatelessWidget {
  /// Creates a [NewScreen].
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _QuickActionCard(
            icon: Icons.event,
            title: 'Novo Atendimento',
            description: 'Iniciar um novo atendimento médico',
            onTap: () => context.go(NewRoutes.appointment),
          ),
          const SizedBox(height: 16),
          _QuickActionCard(
            icon: Icons.person_add,
            title: 'Novo Paciente',
            description: 'Cadastrar um novo paciente',
            onTap: () => context.go(NewRoutes.patient),
          ),
          const SizedBox(height: 16),
          _QuickActionCard(
            icon: Icons.calendar_today,
            title: 'Novo Agendamento',
            description: 'Criar uma nova entrada na agenda',
            onTap: () => context.go(NewRoutes.schedule),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
