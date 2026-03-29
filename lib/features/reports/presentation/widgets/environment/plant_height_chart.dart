import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// B4: LineChart - Pflanzenhöhe über Zeit (mit Fläche)
class PlantHeightChart extends ConsumerWidget {
  const PlantHeightChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(environmentDataProvider);

    return dataAsync.when(
      data: (daten) {
        final mitHoehe =
            daten.where((d) => d.pflanzenHoehe != null).toList();

        if (mitHoehe.isEmpty) {
          return const ChartCard(
            titel: 'Pflanzenhöhe',
            child: EmptyChartState(
                nachricht: 'Keine Höhendaten vorhanden.'),
          );
        }

        final spots = <FlSpot>[];
        for (int i = 0; i < mitHoehe.length; i++) {
          spots.add(FlSpot(i.toDouble(), mitHoehe[i].pflanzenHoehe!));
        }

        final maxY =
            (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1)
                .ceilToDouble();

        return ChartCard(
          titel: 'Pflanzenhöhe',
          untertitel: 'Höhenwachstum in cm',
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final idx = spot.x.toInt();
                      final datum = idx < mitHoehe.length
                          ? DateFormat('dd.MM')
                              .format(mitHoehe[idx].datum)
                          : '';
                      return LineTooltipItem(
                        '$datum\n${spot.y.toStringAsFixed(1)} cm',
                        const TextStyle(
                            color: Colors.white, fontSize: 12),
                      );
                    }).toList();
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
                    interval: (mitHoehe.length / 5)
                        .ceilToDouble()
                        .clamp(1, 100),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= mitHoehe.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          DateFormat('dd.MM')
                              .format(mitHoehe[idx].datum),
                          style: const TextStyle(fontSize: 10),
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
                      return Text('${value.toInt()}cm',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: ChartColors.pflanzenHoehe,
                  barWidth: 2,
                  dotData: FlDotData(
                      show: mitHoehe.length < 20),
                  belowBarData: BarAreaData(
                    show: true,
                    color: ChartColors.pflanzenHoehe.withAlpha(40),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Pflanzenhöhe',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Pflanzenhöhe',
        child: Center(child: Text('Fehler: $e')),
      ),
    );
  }
}
