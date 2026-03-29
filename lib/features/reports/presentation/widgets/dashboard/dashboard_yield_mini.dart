import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_colors.dart';

/// Kompakter BarChart für Dashboard (letzte 5 Grows mit Ertrag)
class DashboardYieldMini extends ConsumerWidget {
  const DashboardYieldMini({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardYieldProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.withAlpha(40)),
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
                  const Icon(Icons.emoji_events_outlined,
                      size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    'Ertrag',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: dataAsync.when(
                  data: (daten) {
                    if (daten.isEmpty) {
                      return Center(
                        child: Text('Keine Daten',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      );
                    }

                    final maxY = daten
                            .map((d) => d.grammProWatt)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2;

                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem:
                                (group, groupIndex, rod, rodIndex) {
                              final d = daten[group.x];
                              return BarTooltipItem(
                                '${d.durchgangTitel}\n${d.grammProWatt.toStringAsFixed(0)}g',
                                const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= daten.length) {
                                  return const SizedBox.shrink();
                                }
                                final name =
                                    daten[idx].durchgangTitel;
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    name.length > 5
                                        ? '${name.substring(0, 5)}…'
                                        : name,
                                    style:
                                        const TextStyle(fontSize: 8),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups:
                            List.generate(daten.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: daten[i].grammProWatt,
                                color: ChartColors.seriesColor(i),
                                width: 14,
                                borderRadius:
                                    const BorderRadius.vertical(
                                        top: Radius.circular(3)),
                              ),
                            ],
                          );
                        }),
                      ),
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
