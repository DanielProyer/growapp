import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// B3: LineChart - pH + EC über Zeit
class PhEcChart extends ConsumerWidget {
  const PhEcChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(environmentDataProvider);

    return dataAsync.when(
      data: (daten) {
        final mitPhEc =
            daten.where((d) => d.ph != null || d.ec != null).toList();

        if (mitPhEc.isEmpty) {
          return const ChartCard(
            titel: 'pH / EC',
            child: EmptyChartState(
                nachricht: 'Keine pH/EC-Daten vorhanden.'),
          );
        }

        // pH und EC haben unterschiedliche Skalen
        // pH: ~5.0-7.0, EC: ~0.5-3.0
        // Wir normalisieren EC auf pH-Skala für gemeinsame Achse
        final phSpots = <FlSpot>[];
        final ecSpots = <FlSpot>[];
        for (int i = 0; i < mitPhEc.length; i++) {
          if (mitPhEc[i].ph != null) {
            phSpots.add(FlSpot(i.toDouble(), mitPhEc[i].ph!));
          }
          if (mitPhEc[i].ec != null) {
            ecSpots.add(FlSpot(i.toDouble(), mitPhEc[i].ec!));
          }
        }

        // Y-Achse: 0-14 für beide (pH natürlich, EC passt auch)
        final allValues = <double>[
          ...phSpots.map((s) => s.y),
          ...ecSpots.map((s) => s.y),
        ];
        final minY =
            (allValues.reduce((a, b) => a < b ? a : b) - 0.5)
                .floorToDouble()
                .clamp(0.0, 14.0);
        final maxY =
            (allValues.reduce((a, b) => a > b ? a : b) + 0.5)
                .ceilToDouble()
                .clamp(minY + 1, 14.0);

        return ChartCard(
          titel: 'pH / EC',
          untertitel: 'pH-Wert und Leitfähigkeit',
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
                      final datum = idx < mitPhEc.length
                          ? DateFormat('dd.MM')
                              .format(mitPhEc[idx].datum)
                          : '';
                      final label =
                          spot.barIndex == 0 ? 'pH' : 'EC';
                      final unit =
                          spot.barIndex == 0 ? '' : ' mS/cm';
                      return LineTooltipItem(
                        '$datum\n$label: ${spot.y.toStringAsFixed(2)}$unit',
                        TextStyle(
                          color: spot.barIndex == 0
                              ? ChartColors.ph
                              : ChartColors.ec,
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
                    interval: (mitPhEc.length / 5)
                        .ceilToDouble()
                        .clamp(1, 100),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= mitPhEc.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          DateFormat('dd.MM')
                              .format(mitPhEc[idx].datum),
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
                      return Text(value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                if (phSpots.isNotEmpty)
                  LineChartBarData(
                    spots: phSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: ChartColors.ph,
                    barWidth: 2,
                    dotData: FlDotData(
                        show: mitPhEc.length < 20),
                  ),
                if (ecSpots.isNotEmpty)
                  LineChartBarData(
                    spots: ecSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: ChartColors.ec,
                    barWidth: 2,
                    dotData: FlDotData(
                        show: mitPhEc.length < 20),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'pH / EC',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'pH / EC',
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
        _LegendItem(color: ChartColors.ph, label: 'pH'),
        const SizedBox(width: 8),
        _LegendItem(color: ChartColors.ec, label: 'EC'),
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
