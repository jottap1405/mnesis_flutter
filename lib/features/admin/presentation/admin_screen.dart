import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes/admin_routes.dart';

/// Admin screen showing profile and settings options.
///
/// Provides access to user profile, app settings, and configuration.
class AdminScreen extends StatelessWidget {
  /// Creates an [AdminScreen].
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _AdminOptionCard(
            icon: Icons.person,
            title: 'Perfil',
            description: 'Editar informações do perfil',
            onTap: () => context.go(AdminRoutes.profile),
          ),
          const SizedBox(height: 16),
          _AdminOptionCard(
            icon: Icons.settings,
            title: 'Configurações',
            description: 'Configurações do aplicativo',
            onTap: () => context.go(AdminRoutes.settings),
          ),
          const SizedBox(height: 16),
          _AdminOptionCard(
            icon: Icons.info,
            title: 'Sobre',
            description: 'Informações sobre o app',
            onTap: () => context.go(AdminRoutes.about),
          ),
        ],
      ),
    );
  }
}

class _AdminOptionCard extends StatelessWidget {
  const _AdminOptionCard({
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
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
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
