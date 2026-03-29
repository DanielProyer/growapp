import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// A3: Horizontal Stacked BarChart - Zyklusdauer (Vegi/Blüte/Curing)
class CycleDurationChart extends ConsumerWidget {
  const CycleDurationChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(cycleDurationProvider);

    return dataAsync.when(
      data: (daten) {
        if (daten.isEmpty) {
          return const ChartCard(
            titel: 'Zyklusdauer',
            child: EmptyChartState(
                nachricht: 'Keine Zyklusdaten vorhanden.'),
          );
        }

        final maxX = daten
                .map((d) => d.gesamtTage.toDouble())
                .reduce((a, b) => a > b ? a : b) *
            1.1;

        return ChartCard(
          titel: 'Zyklusdauer',
          untertitel: 'Tage pro Phase',
          hoehe: (daten.length * 50.0).clamp(150, 400),
          trailing: _Legende(),
          child: RotatedBox(
            quarterTurns: 0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxX,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final d = daten[group.x];
                      final phase = rodIndex == 0
                          ? 'Vegi: ${d.vegiTage}d'
                          : rodIndex == 1
                              ? 'Blüte: ${d.blueteTage}d'
                              : 'Curing: ${d.curingTage}d';
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
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}d',
                            style: const TextStyle(fontSize: 10));
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
                        toY: d.vegiTage.toDouble(),
                        color: ChartColors.vegiPhase,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2)),
                      ),
                      BarChartRodData(
                        toY: d.blueteTage.toDouble(),
                        color: ChartColors.bluetePhase,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2)),
                      ),
                      BarChartRodData(
                        toY: d.curingTage.toDouble(),
                        color: ChartColors.curingPhase,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Zyklusdauer',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Zyklusdauer',
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
        _LegendItem(color: ChartColors.vegiPhase, label: 'Vegi'),
        const SizedBox(width: 8),
        _LegendItem(color: ChartColors.bluetePhase, label: 'Blüte'),
        const SizedBox(width: 8),
        _LegendItem(color: ChartColors.curingPhase, label: 'Curing'),
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
