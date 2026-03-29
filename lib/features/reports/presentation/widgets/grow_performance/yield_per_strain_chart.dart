import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// A1: BarChart - Durchschnittlicher Trockenertrag pro Sorte
class YieldPerStrainChart extends ConsumerWidget {
  const YieldPerStrainChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(yieldPerStrainProvider);

    return dataAsync.when(
      data: (daten) {
        if (daten.isEmpty) {
          return const ChartCard(
            titel: 'Ertrag pro Sorte',
            child: EmptyChartState(
                nachricht: 'Noch keine Erntedaten vorhanden.'),
          );
        }

        final maxY = daten
                .map((d) => d.trockenErtragG)
                .reduce((a, b) => a > b ? a : b) *
            1.2;

        return ChartCard(
          titel: 'Ertrag pro Sorte',
          untertitel: 'Durchschnittlicher Trockenertrag in Gramm',
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final d = daten[group.x];
                    return BarTooltipItem(
                      '${d.sorteName}\n${d.trockenErtragG.toStringAsFixed(1)}g'
                      '${d.anzahlDurchgaenge > 1 ? ' (${d.anzahlDurchgaenge}x)' : ''}',
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
                      final name = daten[idx].sorteName;
                      return SideTitleWidget(
                        meta: meta,
                        child: SizedBox(
                          width: 60,
                          child: Text(
                            name.length > 8
                                ? '${name.substring(0, 8)}…'
                                : name,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}g',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: maxY / 5,
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(daten.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: daten[i].trockenErtragG,
                      color: ChartColors.seriesColor(i),
                      width: 20,
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
        titel: 'Ertrag pro Sorte',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Ertrag pro Sorte',
        child: Center(child: Text('Fehler: $e')),
      ),
    );
  }
}
