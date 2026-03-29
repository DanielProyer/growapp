import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// B2: LineChart - Luftfeuchtigkeit Tag/Nacht über Zeit
class HumidityChart extends ConsumerWidget {
  const HumidityChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(environmentDataProvider);

    return dataAsync.when(
      data: (daten) {
        final mitRlf = daten
            .where((d) => d.relfTag != null || d.relfNacht != null)
            .toList();

        if (mitRlf.isEmpty) {
          return const ChartCard(
            titel: 'Luftfeuchtigkeit',
            child: EmptyChartState(
                nachricht: 'Keine RLF-Daten vorhanden.'),
          );
        }

        final allRlf = <double>[
          ...mitRlf.where((d) => d.relfTag != null).map((d) => d.relfTag!),
          ...mitRlf
              .where((d) => d.relfNacht != null)
              .map((d) => d.relfNacht!),
        ];
        final minY =
            (allRlf.reduce((a, b) => a < b ? a : b) - 5).floorToDouble();
        final maxY =
            (allRlf.reduce((a, b) => a > b ? a : b) + 5).ceilToDouble();

        final tagSpots = <FlSpot>[];
        final nachtSpots = <FlSpot>[];
        for (int i = 0; i < mitRlf.length; i++) {
          if (mitRlf[i].relfTag != null) {
            tagSpots.add(FlSpot(i.toDouble(), mitRlf[i].relfTag!));
          }
          if (mitRlf[i].relfNacht != null) {
            nachtSpots.add(FlSpot(i.toDouble(), mitRlf[i].relfNacht!));
          }
        }

        return ChartCard(
          titel: 'Luftfeuchtigkeit',
          untertitel: 'Relative Luftfeuchtigkeit Tag/Nacht',
          trailing: _Legende(),
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final idx = spot.x.toInt();
                      final datum = idx < mitRlf.length
                          ? DateFormat('dd.MM').format(mitRlf[idx].datum)
                          : '';
                      final label =
                          spot.barIndex == 0 ? 'Tag' : 'Nacht';
                      return LineTooltipItem(
                        '$datum\n$label: ${spot.y.toStringAsFixed(1)}%',
                        TextStyle(
                          color: spot.barIndex == 0
                              ? ChartColors.rlfTag
                              : ChartColors.rlfNacht,
                          fontSize: 12,
                        ),
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
                    interval:
                        (mitRlf.length / 5).ceilToDouble().clamp(1, 100),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= mitRlf.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          DateFormat('dd.MM').format(mitRlf[idx].datum),
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
                      return Text('${value.toInt()}%',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                if (tagSpots.isNotEmpty)
                  LineChartBarData(
                    spots: tagSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: ChartColors.rlfTag,
                    barWidth: 2,
                    dotData: FlDotData(show: mitRlf.length < 20),
                  ),
                if (nachtSpots.isNotEmpty)
                  LineChartBarData(
                    spots: nachtSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: ChartColors.rlfNacht,
                    barWidth: 2,
                    dotData: FlDotData(show: mitRlf.length < 20),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Luftfeuchtigkeit',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Luftfeuchtigkeit',
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
        _LegendItem(color: ChartColors.rlfTag, label: 'Tag'),
        const SizedBox(width: 8),
        _LegendItem(color: ChartColors.rlfNacht, label: 'Nacht'),
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
