import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/reports_provider.dart';
import '../common/chart_colors.dart';

/// Kompakter LineChart für Dashboard (Temp letzte 7 Tage)
class DashboardEnvironmentMini extends ConsumerWidget {
  const DashboardEnvironmentMini({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardEnvironmentProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.withAlpha(40)),
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
                  const Icon(Icons.thermostat_outlined,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Umgebung',
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
                    final mitTemp = daten
                        .where(
                            (d) => d.tempTag != null || d.tempNacht != null)
                        .toList();

                    if (mitTemp.isEmpty) {
                      return Center(
                        child: Text('Keine Daten',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      );
                    }

                    final tagSpots = <FlSpot>[];
                    final nachtSpots = <FlSpot>[];
                    for (int i = 0; i < mitTemp.length; i++) {
                      if (mitTemp[i].tempTag != null) {
                        tagSpots.add(
                            FlSpot(i.toDouble(), mitTemp[i].tempTag!));
                      }
                      if (mitTemp[i].tempNacht != null) {
                        nachtSpots.add(
                            FlSpot(i.toDouble(), mitTemp[i].tempNacht!));
                      }
                    }

                    final allTemps = <double>[
                      ...tagSpots.map((s) => s.y),
                      ...nachtSpots.map((s) => s.y),
                    ];
                    if (allTemps.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final minY =
                        (allTemps.reduce((a, b) => a < b ? a : b) - 2)
                            .floorToDouble();
                    final maxY =
                        (allTemps.reduce((a, b) => a > b ? a : b) + 2)
                            .ceilToDouble();

                    return LineChart(
                      LineChartData(
                        minY: minY,
                        maxY: maxY,
                        lineTouchData:
                            const LineTouchData(enabled: false),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          if (tagSpots.isNotEmpty)
                            LineChartBarData(
                              spots: tagSpots,
                              isCurved: true,
                              preventCurveOverShooting: true,
                              color: ChartColors.tempTag,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          if (nachtSpots.isNotEmpty)
                            LineChartBarData(
                              spots: nachtSpots,
                              isCurved: true,
                              preventCurveOverShooting: true,
                              color: ChartColors.tempNacht,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                        ],
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
