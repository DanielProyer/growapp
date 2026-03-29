import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// B1: LineChart - Temperatur Tag/Nacht über Zeit
class TemperatureChart extends ConsumerWidget {
  const TemperatureChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(environmentDataProvider);

    return dataAsync.when(
      data: (daten) {
        final mitTemp =
            daten.where((d) => d.tempTag != null || d.tempNacht != null).toList();

        if (mitTemp.isEmpty) {
          return const ChartCard(
            titel: 'Temperatur',
            child: EmptyChartState(
                nachricht: 'Keine Temperaturdaten vorhanden.'),
          );
        }

        final allTemps = <double>[
          ...mitTemp.where((d) => d.tempTag != null).map((d) => d.tempTag!),
          ...mitTemp.where((d) => d.tempNacht != null).map((d) => d.tempNacht!),
        ];
        final minY = (allTemps.reduce((a, b) => a < b ? a : b) - 2)
            .floorToDouble();
        final maxY = (allTemps.reduce((a, b) => a > b ? a : b) + 2)
            .ceilToDouble();

        final tagSpots = <FlSpot>[];
        final nachtSpots = <FlSpot>[];
        for (int i = 0; i < mitTemp.length; i++) {
          if (mitTemp[i].tempTag != null) {
            tagSpots.add(FlSpot(i.toDouble(), mitTemp[i].tempTag!));
          }
          if (mitTemp[i].tempNacht != null) {
            nachtSpots.add(FlSpot(i.toDouble(), mitTemp[i].tempNacht!));
          }
        }

        return ChartCard(
          titel: 'Temperatur',
          untertitel: 'Tag/Nacht Temperaturverlauf',
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
                      final datum = idx < mitTemp.length
                          ? DateFormat('dd.MM').format(mitTemp[idx].datum)
                          : '';
                      final label =
                          spot.barIndex == 0 ? 'Tag' : 'Nacht';
                      return LineTooltipItem(
                        '$datum\n$label: ${spot.y.toStringAsFixed(1)}°C',
                        TextStyle(
                          color: spot.barIndex == 0
                              ? ChartColors.tempTag
                              : ChartColors.tempNacht,
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
                    interval: (mitTemp.length / 5).ceilToDouble().clamp(1, 100),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= mitTemp.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          DateFormat('dd.MM')
                              .format(mitTemp[idx].datum),
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
                      return Text('${value.toInt()}°',
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
                    color: ChartColors.tempTag,
                    barWidth: 2,
                    dotData: FlDotData(
                        show: mitTemp.length < 20),
                  ),
                if (nachtSpots.isNotEmpty)
                  LineChartBarData(
                    spots: nachtSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: ChartColors.tempNacht,
                    barWidth: 2,
                    dotData: FlDotData(
                        show: mitTemp.length < 20),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Temperatur',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Temperatur',
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
        _LegendItem(color: ChartColors.tempTag, label: 'Tag'),
        const SizedBox(width: 8),
        _LegendItem(color: ChartColors.tempNacht, label: 'Nacht'),
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
