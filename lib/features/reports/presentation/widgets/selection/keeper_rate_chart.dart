import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/report_data.dart';
import '../../providers/reports_provider.dart';
import '../common/chart_card.dart';
import '../common/chart_colors.dart';
import '../common/empty_chart_state.dart';

/// C2: PieChart - Keeper/Nein/Vielleicht Quote
class KeeperRateChart extends ConsumerWidget {
  const KeeperRateChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(keeperRateProvider);

    return dataAsync.when(
      data: (daten) {
        if (daten.gesamt == 0) {
          return const ChartCard(
            titel: 'Keeper-Quote',
            child: EmptyChartState(
                nachricht: 'Noch keine Pflanzen bewertet.'),
          );
        }

        final sections = <PieChartSectionData>[];
        if (daten.keeper > 0) {
          sections.add(PieChartSectionData(
            value: daten.keeper.toDouble(),
            color: ChartColors.keeper,
            title:
                'Keeper\n${(daten.keeper / daten.gesamt * 100).toStringAsFixed(0)}%',
            titleStyle:
                const TextStyle(fontSize: 11, color: Colors.white),
            radius: 80,
          ));
        }
        if (daten.vielleicht > 0) {
          sections.add(PieChartSectionData(
            value: daten.vielleicht.toDouble(),
            color: ChartColors.vielleicht,
            title:
                'Vllt.\n${(daten.vielleicht / daten.gesamt * 100).toStringAsFixed(0)}%',
            titleStyle:
                const TextStyle(fontSize: 11, color: Colors.white),
            radius: 80,
          ));
        }
        if (daten.nein > 0) {
          sections.add(PieChartSectionData(
            value: daten.nein.toDouble(),
            color: ChartColors.nichtKeeper,
            title:
                'Nein\n${(daten.nein / daten.gesamt * 100).toStringAsFixed(0)}%',
            titleStyle:
                const TextStyle(fontSize: 11, color: Colors.white),
            radius: 80,
          ));
        }

        return ChartCard(
          titel: 'Keeper-Quote',
          untertitel: '${daten.gesamt} Pflanzen bewertet',
          hoehe: 200,
          trailing: _Legende(daten: daten),
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(enabled: true),
            ),
          ),
        );
      },
      loading: () => const ChartCard(
        titel: 'Keeper-Quote',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ChartCard(
        titel: 'Keeper-Quote',
        child: Center(child: Text('Fehler: $e')),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  final KeeperRateData daten;
  const _Legende({required this.daten});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(
            color: ChartColors.keeper, label: '${daten.keeper} Keeper'),
        const SizedBox(width: 8),
        _LegendItem(
            color: ChartColors.vielleicht,
            label: '${daten.vielleicht} Vllt.'),
        const SizedBox(width: 8),
        _LegendItem(
            color: ChartColors.nichtKeeper,
            label: '${daten.nein} Nein'),
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
