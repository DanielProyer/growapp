import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/report_data.dart';
import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// C1: RadarChart - 9 Scores Vergleich
class PhenoRadarChart extends ConsumerWidget {
  const PhenoRadarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(phenoRadarProvider);

    return dataAsync.when(
      data: (daten) {
        if (daten.isEmpty) {
          return const ChartCard(
            titel: 'Pheno-Radar',
            child: EmptyChartState(
                nachricht: 'Noch keine Bewertungen vorhanden.'),
          );
        }

        return ChartCard(
          titel: 'Pheno-Radar',
          untertitel: '9 Bewertungskriterien im Vergleich',
          hoehe: 300,
          trailing: _Legende(daten: daten),
          child: RadarChart(
            RadarChartData(
              radarTouchData: RadarTouchData(enabled: true),
              dataSets: List.generate(daten.length, (i) {
                return RadarDataSet(
                  dataEntries: daten[i]
                      .werte
                      .map((w) => RadarEntry(value: w))
                      .toList(),
                  fillColor: ChartColors.seriesColor(i).withAlpha(40),
                  borderColor: ChartColors.seriesColor(i),
                  borderWidth: 2,
                  entryRadius: 3,
                );
              }),
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData:
                  const BorderSide(color: Colors.grey, width: 0.5),
              titlePositionPercentageOffset: 0.15,
              titleTextStyle: const TextStyle(
                  fontSize: 10, color: Colors.grey),
              getTitle: (index, angle) {
                return RadarChartTitle(
                  text: PhenoRadarData.kriterienNamen[index],
                );
              },
              tickCount: 5,
              ticksTextStyle: const TextStyle(
                  fontSize: 8, color: Colors.grey),
              tickBorderData:
                  const BorderSide(color: Colors.grey, width: 0.3),
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Pheno-Radar',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Pheno-Radar',
        child: Center(child: Text('Fehler: $e')),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  final List<PhenoRadarData> daten;
  const _Legende({required this.daten});

  @override
  Widget build(BuildContext context) {
    if (daten.length <= 1) return const SizedBox.shrink();

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
