import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/report_data.dart';
import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// C3: LineChart - Wachstumskurven (Höhe über Zeit)
class GrowthCurvesChart extends ConsumerWidget {
  const GrowthCurvesChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(growthCurvesProvider);

    return dataAsync.when(
      data: (daten) {
        if (daten.isEmpty) {
          return const ChartCard(
            titel: 'Wachstumskurven',
            child: EmptyChartState(
                nachricht: 'Keine Wachstumsmessungen vorhanden.'),
          );
        }

        // Alle Punkte sammeln für Achsen-Berechnung
        final allePunkte = daten.expand((c) => c.punkte).toList();
        final hoehen = allePunkte
            .where((p) => p.hoeheCm != null)
            .map((p) => p.hoeheCm!)
            .toList();

        if (hoehen.isEmpty) {
          return const ChartCard(
            titel: 'Wachstumskurven',
            child: EmptyChartState(
                nachricht: 'Keine Höhendaten vorhanden.'),
          );
        }

        final maxY =
            (hoehen.reduce((a, b) => a > b ? a : b) * 1.1)
                .ceilToDouble();

        // Gemeinsame X-Achse basierend auf Datum
        final allDates = allePunkte.map((p) => p.datum).toList()
          ..sort();
        final minDate = allDates.first;
        final maxDate = allDates.last;
        final dateRange = maxDate.difference(minDate).inDays;

        double dateToX(DateTime date) {
          if (dateRange == 0) return 0;
          return date.difference(minDate).inDays.toDouble();
        }

        return ChartCard(
          titel: 'Wachstumskurven',
          untertitel: 'Pflanzenhöhe über Zeit (cm)',
          hoehe: 280,
          trailing: _Legende(daten: daten),
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              minX: 0,
              maxX: dateRange.toDouble().clamp(1, 365),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final date = minDate
                          .add(Duration(days: spot.x.round()));
                      return LineTooltipItem(
                        '${DateFormat('dd.MM').format(date)}\n${spot.y.toStringAsFixed(1)} cm',
                        TextStyle(
                          color: ChartColors.seriesColor(spot.barIndex),
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
                    interval: (dateRange / 5)
                        .ceilToDouble()
                        .clamp(1, 100),
                    getTitlesWidget: (value, meta) {
                      final date = minDate
                          .add(Duration(days: value.round()));
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          DateFormat('dd.MM').format(date),
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
                      return Text('${value.toInt()}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              lineBarsData: List.generate(daten.length, (i) {
                final kurve = daten[i];
                final spots = kurve.punkte
                    .where((p) => p.hoeheCm != null)
                    .map((p) =>
                        FlSpot(dateToX(p.datum), p.hoeheCm!))
                    .toList();

                return LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: ChartColors.seriesColor(i),
                  barWidth: 2,
                  dotData: FlDotData(
                      show: spots.length < 15),
                );
              }),
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Wachstumskurven',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Wachstumskurven',
        child: Center(child: Text('Fehler: $e')),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  final List<GrowthCurveData> daten;
  const _Legende({required this.daten});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: List.generate(daten.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ChartColors.seriesColor(i),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(daten[i].bezeichnung,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        );
      }),
    );
  }
}
