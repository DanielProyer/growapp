import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// A4: Grouped BarChart - Pflanzen-Attrition (Start→Vegi→Blüte)
class PlantAttritionChart extends ConsumerWidget {
  const PlantAttritionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(plantAttritionProvider);

    return dataAsync.when(
      data: (daten) {
        if (daten.isEmpty) {
          return const ChartCard(
            titel: 'Pflanzen-Verlauf',
            child: EmptyChartState(
                nachricht: 'Keine Pflanzenanzahl-Daten vorhanden.'),
          );
        }

        final maxY = daten
                .map((d) => [d.start, d.vegi, d.bluete]
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble())
                .reduce((a, b) => a > b ? a : b) *
            1.2;

        return ChartCard(
          titel: 'Pflanzen-Verlauf',
          untertitel: 'Pflanzenanzahl pro Phase',
          trailing: _Legende(),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final d = daten[group.x];
                    final phase = rodIndex == 0
                        ? 'Start: ${d.start}'
                        : rodIndex == 1
                            ? 'Vegi: ${d.vegi}'
                            : 'Blüte: ${d.bluete}';
                    return BarTooltipItem(
                      '${d.durchgangTitel}\n$phase',
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
                          width: 70,
                          child: Text(
                            name.length > 10
                                ? '${name.substring(0, 10)}…'
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
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == value.roundToDouble()) {
                        return Text('${value.toInt()}',
                            style: const TextStyle(fontSize: 10));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(daten.length, (i) {
                final d = daten[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: d.start.toDouble(),
                      color: ChartColors.series[0],
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2)),
                    ),
                    BarChartRodData(
                      toY: d.vegi.toDouble(),
                      color: ChartColors.series[1],
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2)),
                    ),
                    BarChartRodData(
                      toY: d.bluete.toDouble(),
                      color: ChartColors.series[2],
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2)),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Pflanzen-Verlauf',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Pflanzen-Verlauf',
        child: Center(child: Text('Fehler: $e')),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(color: ChartColors.series[0], label: 'Start'),
        const SizedBox(width: 8),
        _LegendItem(color: ChartColors.series[1], label: 'Vegi'),
        const SizedBox(width: 8),
        _LegendItem(color: ChartColors.series[2], label: 'Blüte'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
