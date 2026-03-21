import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../strains/presentation/providers/sorten_provider.dart';
import '../../../grow_tents/presentation/providers/zelte_provider.dart';
import '../../../grows/presentation/providers/grows_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortenAsync = ref.watch(sortenListeProvider);
    final zelteAsync = ref.watch(zelteListeProvider);

    final aktiveGrowsAsync = ref.watch(aktiveDurchgaengeProvider);

    final sortenAnzahl = sortenAsync.valueOrNull?.length ?? 0;
    final zelteAnzahl = zelteAsync.valueOrNull?.length ?? 0;
    final aktiveGrows = aktiveGrowsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Benachrichtigungen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Willkommen bei GrowApp',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Quick Stats
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800
                    ? 4
                    : constraints.maxWidth > 500
                        ? 2
                        : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _StatCard(
                      title: 'Aktive Grows',
                      value: '$aktiveGrows',
                      icon: Icons.eco,
                      color: Colors.green,
                      onTap: () => context.go('/grows'),
                    ),
                    _StatCard(
                      title: 'Zelte',
                      value: '$zelteAnzahl',
                      icon: Icons.house_outlined,
                      color: Colors.teal,
                      onTap: () => context.go('/zelte'),
                    ),
                    _StatCard(
                      title: 'Sorten',
                      value: '$sortenAnzahl',
                      icon: Icons.category,
                      color: Colors.orange,
                      onTap: () => context.go('/sorten'),
                    ),
                    _StatCard(
                      title: 'Pflanzen',
                      value: '0',
                      icon: Icons.local_florist,
                      color: Colors.brown,
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Aktive Grows Übersicht
            Text(
              'Aktive Grows',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withAlpha(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Noch keine aktiven Grows',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Erstelle zuerst Sorten und Zelte, dann starte einen Grow.',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(40)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
