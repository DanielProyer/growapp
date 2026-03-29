import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/reports_provider.dart';

/// Quick Stats Karte für Dashboard
class DashboardStatsCard extends ConsumerWidget {
  const DashboardStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(growQuickStatsProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withAlpha(40)),
      ),
      child: InkWell(
        onTap: () => context.go('/berichte'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_outlined,
                      size: 16, color: Colors.purple),
                  const SizedBox(width: 6),
                  Text(
                    'Quick Stats',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: statsAsync.when(
                  data: (stats) {
                    if (stats.abgeschlosseneDurchgaenge == 0) {
                      return Center(
                        child: Text('Keine Daten',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatRow(
                          label: 'Bester Ertrag',
                          value: stats.besterErtragG != null
                              ? '${stats.besterErtragG!.toStringAsFixed(0)}g'
                              : '–',
                          detail: stats.besterErtragSorte,
                        ),
                        _StatRow(
                          label: 'Ø g/W',
                          value: stats.durchschnittGProWatt != null
                              ? stats.durchschnittGProWatt!
                                  .toStringAsFixed(2)
                              : '–',
                        ),
                        _StatRow(
                          label: 'Abgeschlossen',
                          value: '${stats.abgeschlosseneDurchgaenge}',
                          detail: 'Durchgänge',
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, _) => Center(
                    child: Text('Fehler',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[400])),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;

  const _StatRow({
    required this.label,
    required this.value,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
        if (detail != null) ...[
          const SizedBox(width: 4),
          Text(detail!,
              style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ],
    );
  }
}
