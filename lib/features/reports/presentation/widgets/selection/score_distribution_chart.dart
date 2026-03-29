import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// C4: BarChart - Durchschnittliche Bewertung pro Kriterium
class ScoreDistributionChart extends ConsumerWidget {
  const ScoreDistributionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(scoreDistributionProvider);

    return dataAsync.when(
      data: (daten) {
        final hatWerte = daten.any((d) => d.durchschnitt > 0);
        if (daten.isEmpty || !hatWerte) {
          return const ChartCard(
            titel: 'Score-Verteilung',
            child: EmptyChartState(
                nachricht: 'Noch keine Bewertungen vorhanden.'),
          );
        }

        return ChartCard(
          titel: 'Score-Verteilung',
          untertitel: 'Durchschnitt pro Kriterium (1-10)',
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final d = daten[group.x];
                    return BarTooltipItem(
                      '${d.kriterium}\n${d.durchschnitt.toStringAsFixed(1)}',
                      const TextStyle(
                          color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= daten.length) {
                        return const SizedBox.shrink();
                      }
                      final name = daten[idx].kriterium;
                      return SideTitleWidget(
                        meta: meta,
                        angle: -0.5,
                        child: Text(
                          name.length > 7
                              ? '${name.substring(0, 7)}…'
                              : name,
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 2,
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(daten.length, (i) {
                final avg = daten[i].durchschnitt;
                Color color;
                if (avg >= 7) {
                  color = ChartColors.keeper;
                } else if (avg >= 4) {
                  color = ChartColors.vielleicht;
                } else {
                  color = ChartColors.nichtKeeper;
                }

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: avg,
                      color: color,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Score-Verteilung',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Score-Verteilung',
        child: Center(child: Text('Fehler: $e')),
      ),
    );
  }
}
