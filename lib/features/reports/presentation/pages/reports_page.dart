import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../grows/presentation/providers/grows_provider.dart';
import '../../../selection/presentation/providers/selektions_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/grow_performance/yield_per_strain_chart.dart';
import '../widgets/grow_performance/yield_per_watt_chart.dart';
import '../widgets/grow_performance/cycle_duration_chart.dart';
import '../widgets/grow_performance/plant_attrition_chart.dart';
import '../widgets/environment/temperature_chart.dart';
import '../widgets/environment/humidity_chart.dart';
import '../widgets/environment/ph_ec_chart.dart';
import '../widgets/environment/plant_height_chart.dart';
import '../widgets/selection/pheno_radar_chart.dart';
import '../widgets/selection/keeper_rate_chart.dart';
import '../widgets/selection/growth_curves_chart.dart';
import '../widgets/selection/score_distribution_chart.dart';
import '../widgets/common/empty_chart_state.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Berichte'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.emoji_events_outlined),
                text: 'Grow-Performance',
              ),
              Tab(
                icon: Icon(Icons.thermostat_outlined),
                text: 'Umgebung',
              ),
              Tab(
                icon: Icon(Icons.science_outlined),
                text: 'Selektion',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GrowPerformanceTab(),
            _EnvironmentTab(),
            _SelectionTab(),
          ],
        ),
      ),
    );
  }
}

// ── Tab A: Grow-Performance ──

class _GrowPerformanceTab extends ConsumerWidget {
  const _GrowPerformanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yieldAsync = ref.watch(yieldPerStrainProvider);
    final hatDaten = yieldAsync.valueOrNull?.isNotEmpty ?? false;

    if (!hatDaten) {
      return const EmptyChartState(
        nachricht:
            'Noch keine Erntedaten vorhanden.\nSchliesse einen Grow ab um Berichte zu sehen.',
        icon: Icons.emoji_events_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        YieldPerStrainChart(),
        SizedBox(height: 16),
        YieldPerWattChart(),
        SizedBox(height: 16),
        CycleDurationChart(),
        SizedBox(height: 16),
        PlantAttritionChart(),
      ],
    );
  }
}

// ── Tab B: Umgebung ──

class _EnvironmentTab extends ConsumerWidget {
  const _EnvironmentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGrowId = ref.watch(reportSelectedGrowIdProvider);
    final durchgaengeAsync = ref.watch(durchgaengeListeProvider);

    return Column(
      children: [
        // Durchgang-Auswahl
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: durchgaengeAsync.when(
            data: (durchgaenge) {
              if (durchgaenge.isEmpty) {
                return const SizedBox.shrink();
              }
              return DropdownButtonFormField<String>(
                initialValue: selectedGrowId,
                decoration: const InputDecoration(
                  labelText: 'Durchgang wählen',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: durchgaenge
                    .map((d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(d.titel,
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (value) {
                  ref.read(reportSelectedGrowIdProvider.notifier).state =
                      value;
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Fehler: $e'),
          ),
        ),

        // Charts
        Expanded(
          child: selectedGrowId == null
              ? const EmptyChartState(
                  nachricht: 'Wähle einen Durchgang aus.',
                  icon: Icons.thermostat_outlined,
                )
              : _EnvironmentCharts(growId: selectedGrowId),
        ),
      ],
    );
  }
}

class _EnvironmentCharts extends ConsumerWidget {
  final String growId;
  const _EnvironmentCharts({required this.growId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(environmentDataProvider);

    return dataAsync.when(
      data: (daten) {
        if (daten.isEmpty) {
          return const EmptyChartState(
            nachricht: 'Keine Tages-Logs für diesen Durchgang.',
            icon: Icons.edit_note_outlined,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            TemperatureChart(),
            SizedBox(height: 16),
            HumidityChart(),
            SizedBox(height: 16),
            PhEcChart(),
            SizedBox(height: 16),
            PlantHeightChart(),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
    );
  }
}

// ── Tab C: Selektion ──

class _SelectionTab extends ConsumerWidget {
  const _SelectionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSelektionId =
        ref.watch(reportSelectedSelektionIdProvider);
    final selektionenAsync = ref.watch(selektionenListeProvider);

    return Column(
      children: [
        // Selektion-Auswahl
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: selektionenAsync.when(
            data: (selektionen) {
              if (selektionen.isEmpty) {
                return const SizedBox.shrink();
              }
              return DropdownButtonFormField<String>(
                initialValue: selectedSelektionId,
                decoration: const InputDecoration(
                  labelText: 'Selektion wählen',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: selektionen
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name,
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (value) {
                  ref
                      .read(reportSelectedSelektionIdProvider.notifier)
                      .state = value;
                  // Reset Pflanzen-Auswahl bei Selektion-Wechsel
                  ref
                      .read(reportSelectedPflanzenIdsProvider.notifier)
                      .state = {};
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Fehler: $e'),
          ),
        ),

        // Pflanzen-Multiselect
        if (selectedSelektionId != null)
          _PflanzenMultiSelect(selektionId: selectedSelektionId),

        // Charts
        Expanded(
          child: selectedSelektionId == null
              ? const EmptyChartState(
                  nachricht: 'Wähle eine Selektion aus.',
                  icon: Icons.science_outlined,
                )
              : _SelectionCharts(selektionId: selectedSelektionId),
        ),
      ],
    );
  }
}

class _PflanzenMultiSelect extends ConsumerWidget {
  final String selektionId;
  const _PflanzenMultiSelect({required this.selektionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pflanzenAsync =
        ref.watch(selektionsPflanzenProvider(selektionId));
    final selectedIds = ref.watch(reportSelectedPflanzenIdsProvider);

    return pflanzenAsync.when(
      data: (pflanzen) {
        if (pflanzen.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              FilterChip(
                label: const Text('Alle'),
                selected: selectedIds.isEmpty,
                onSelected: (_) {
                  ref
                      .read(reportSelectedPflanzenIdsProvider.notifier)
                      .state = {};
                },
              ),
              ...pflanzen.map((p) => FilterChip(
                    label: Text(p.bezeichnung),
                    selected: selectedIds.contains(p.id),
                    onSelected: (selected) {
                      final current = {...selectedIds};
                      if (selected) {
                        current.add(p.id);
                      } else {
                        current.remove(p.id);
                      }
                      ref
                          .read(
                              reportSelectedPflanzenIdsProvider.notifier)
                          .state = current;
                    },
                  )),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _SelectionCharts extends ConsumerWidget {
  final String selektionId;
  const _SelectionCharts({required this.selektionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pflanzenAsync =
        ref.watch(selektionsPflanzenProvider(selektionId));

    return pflanzenAsync.when(
      data: (pflanzen) {
        if (pflanzen.isEmpty) {
          return const EmptyChartState(
            nachricht: 'Noch keine Pflanzen in dieser Selektion.',
            icon: Icons.science_outlined,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            PhenoRadarChart(),
            SizedBox(height: 16),
            KeeperRateChart(),
            SizedBox(height: 16),
            ScoreDistributionChart(),
            SizedBox(height: 16),
            GrowthCurvesChart(),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
    );
  }
}
