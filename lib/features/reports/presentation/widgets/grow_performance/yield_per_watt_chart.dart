import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// A2: BarChart - Gramm pro Watt pro Durchgang
class YieldPerWattChart extends ConsumerWidget {
  const YieldPerWattChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(yieldPerWattProvider);

    return dataAsync.when(
      data: (daten) {
        if (daten.isEmpty) {
          return const ChartCard(
            titel: 'Ertrag pro Watt',
            child: EmptyChartState(
                nachricht: 'Keine g/W Daten vorhanden.'),
          );
        }

        final maxY = daten
                .map((d) => d.grammProWatt)
                .reduce((a, b) => a > b ? a : b) *
            1.2;

        return ChartCard(
          titel: 'Ertrag pro Watt',
          untertitel: 'g/W pro abgeschlossenem Durchgang',
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final d = daten[group.x];
                    return BarTooltipItem(
                      '${d.durchgangTitel}\n${d.grammProWatt.toStringAsFixed(2)} g/W',
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
                      final name = daten[idx].durchgangTitel;
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
                      return Text(value.toStringAsFixed(1),
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
                      toY: daten[i].grammProWatt,
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
        titel: 'Ertrag pro Watt',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Ertrag pro Watt',
        child: Center(child: Text('Fehler: $e')),
      ),
    );
  }
}
