import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../grows/presentation/providers/grows_provider.dart';
import '../../../grows/domain/entities/durchgang.dart';
import '../../../daily_logs/presentation/providers/tages_logs_provider.dart';
import '../../../selection/presentation/providers/selektions_provider.dart';
import '../../domain/entities/report_data.dart';

// ── Filter-State Provider ──

/// Gewählter Durchgang für Umgebungs-Tab
final reportSelectedGrowIdProvider = StateProvider<String?>((ref) => null);

/// Gewählte Selektion für Selektion-Tab
final reportSelectedSelektionIdProvider = StateProvider<String?>((ref) => null);

/// Gewählte Pflanzen-IDs für Radar/Kurven (Multi-Select)
final reportSelectedPflanzenIdsProvider =
    StateProvider<Set<String>>((ref) => {});

// ── Grow-Performance Provider (A) ──

/// Ertrag pro Sorte (A1) - aggregiert über alle beendeten Durchgänge
final yieldPerStrainProvider =
    Provider<AsyncValue<List<YieldPerStrainData>>>((ref) {
  return ref.watch(durchgaengeListeProvider).whenData((durchgaenge) {
    final beendet = durchgaenge
        .where((d) => d.status == 'beendet' && d.trockenErtragG != null);

    // Gruppiere nach Sorte
    final map = <String, _YieldAccumulator>{};
    for (final d in beendet) {
      final name = d.sorteName ?? 'Unbekannt';
      map.putIfAbsent(name, () => _YieldAccumulator());
      map[name]!.add(d.trockenErtragG!);
    }

    final result = map.entries
        .map((e) => YieldPerStrainData(
              sorteName: e.key,
              trockenErtragG: e.value.durchschnitt,
              anzahlDurchgaenge: e.value.anzahl,
            ))
        .toList()
      ..sort((a, b) => b.trockenErtragG.compareTo(a.trockenErtragG));

    return result;
  });
});

/// Ertrag pro Watt (A2)
final yieldPerWattProvider =
    Provider<AsyncValue<List<YieldPerWattData>>>((ref) {
  return ref.watch(durchgaengeListeProvider).whenData((durchgaenge) {
    return durchgaenge
        .where((d) => d.status == 'beendet' && d.ertragProWatt != null)
        .map((d) => YieldPerWattData(
              durchgangTitel: d.titel,
              grammProWatt: d.ertragProWatt!,
            ))
        .toList()
      ..sort((a, b) => b.grammProWatt.compareTo(a.grammProWatt));
  });
});

/// Zyklusdauer (A3)
final cycleDurationProvider =
    Provider<AsyncValue<List<CycleDurationData>>>((ref) {
  return ref.watch(durchgaengeListeProvider).whenData((durchgaenge) {
    return durchgaenge
        .where((d) =>
            d.status == 'beendet' &&
            d.vegiStart != null &&
            d.blueteStart != null)
        .map((d) {
      final vegiTage = d.blueteStart!.difference(d.vegiStart!).inDays;
      final blueteTage = d.ernteDatum != null
          ? d.ernteDatum!.difference(d.blueteStart!).inDays
          : 0;
      final curingTage = (d.ernteDatum != null && d.einglasDatum != null)
          ? d.einglasDatum!.difference(d.ernteDatum!).inDays
          : 0;

      return CycleDurationData(
        durchgangTitel: d.titel,
        vegiTage: vegiTage.clamp(0, 365),
        blueteTage: blueteTage.clamp(0, 365),
        curingTage: curingTage.clamp(0, 365),
      );
    }).toList();
  });
});

/// Pflanzen-Attrition (A4)
final plantAttritionProvider =
    Provider<AsyncValue<List<PlantAttritionData>>>((ref) {
  return ref.watch(durchgaengeListeProvider).whenData((durchgaenge) {
    return durchgaenge
        .where((d) => d.pflanzenAnzahlStart != null)
        .map((d) => PlantAttritionData(
              durchgangTitel: d.titel,
              start: d.pflanzenAnzahlStart ?? 0,
              vegi: d.pflanzenAnzahlVegi ?? d.pflanzenAnzahlStart ?? 0,
              bluete: d.pflanzenAnzahlBluete ??
                  d.pflanzenAnzahlVegi ??
                  d.pflanzenAnzahlStart ??
                  0,
            ))
        .toList();
  });
});

// ── Umgebung Provider (B) ──

/// Umgebungsdaten für gewählten Durchgang
final environmentDataProvider =
    Provider<AsyncValue<List<EnvironmentDataPoint>>>((ref) {
  final growId = ref.watch(reportSelectedGrowIdProvider);
  if (growId == null) return const AsyncValue.data([]);

  return ref
      .watch(tagesLogsFuerDurchgangProvider(growId))
      .whenData((logs) {
    final sorted = [...logs]..sort((a, b) => a.datum.compareTo(b.datum));
    return sorted
        .map((log) => EnvironmentDataPoint(
              datum: log.datum,
              tempTag: log.tempTag,
              tempNacht: log.tempNacht,
              relfTag: log.relfTag,
              relfNacht: log.relfNacht,
              ph: log.ph,
              ec: log.ec,
              pflanzenHoehe: log.pflanzenHoehe,
            ))
        .toList();
  });
});

// ── Selektion Provider (C) ──

/// Radar-Daten für gewählte Pflanzen einer Selektion (C1)
final phenoRadarProvider =
    Provider<AsyncValue<List<PhenoRadarData>>>((ref) {
  final selektionId = ref.watch(reportSelectedSelektionIdProvider);
  if (selektionId == null) return const AsyncValue.data([]);

  final selectedIds = ref.watch(reportSelectedPflanzenIdsProvider);

  return ref
      .watch(selektionsPflanzenProvider(selektionId))
      .whenData((pflanzen) {
    final filtered = selectedIds.isEmpty
        ? pflanzen
        : pflanzen.where((p) => selectedIds.contains(p.id)).toList();

    return filtered
        .map((p) => PhenoRadarData(
              bezeichnung: p.bezeichnung,
              vigor: p.bewertungVigor,
              struktur: p.bewertungStruktur,
              harz: p.bewertungHarz,
              aroma: p.bewertungAroma,
              ertrag: p.bewertungErtrag,
              schaedlingsresistenz: p.bewertungSchaedlingsresistenz,
              festigkeit: p.bewertungFestigkeit,
              geschmack: p.bewertungGeschmack,
              wirkung: p.bewertungWirkung,
            ))
        .toList();
  });
});

/// Keeper-Quote (C2)
final keeperRateProvider = Provider<AsyncValue<KeeperRateData>>((ref) {
  final selektionId = ref.watch(reportSelectedSelektionIdProvider);
  if (selektionId == null) {
    return const AsyncValue.data(KeeperRateData());
  }

  return ref
      .watch(selektionsPflanzenProvider(selektionId))
      .whenData((pflanzen) {
    int keeper = 0, nein = 0, vielleicht = 0;
    for (final p in pflanzen) {
      switch (p.keeperStatus) {
        case 'ja':
          keeper++;
          break;
        case 'nein':
          nein++;
          break;
        default:
          vielleicht++;
      }
    }
    return KeeperRateData(
        keeper: keeper, nein: nein, vielleicht: vielleicht);
  });
});

/// Score-Verteilung (C4)
final scoreDistributionProvider =
    Provider<AsyncValue<List<ScoreDistributionData>>>((ref) {
  final selektionId = ref.watch(reportSelectedSelektionIdProvider);
  if (selektionId == null) return const AsyncValue.data([]);

  return ref
      .watch(selektionsPflanzenProvider(selektionId))
      .whenData((pflanzen) {
    if (pflanzen.isEmpty) return [];

    final kriterien = PhenoRadarData.kriterienNamen;
    final getters = <int? Function(dynamic)>[
      (p) => p.bewertungVigor,
      (p) => p.bewertungStruktur,
      (p) => p.bewertungHarz,
      (p) => p.bewertungAroma,
      (p) => p.bewertungErtrag,
      (p) => p.bewertungSchaedlingsresistenz,
      (p) => p.bewertungFestigkeit,
      (p) => p.bewertungGeschmack,
      (p) => p.bewertungWirkung,
    ];

    return List.generate(kriterien.length, (i) {
      final werte = pflanzen
          .map((p) => getters[i](p))
          .whereType<int>()
          .toList();
      final avg = werte.isEmpty
          ? 0.0
          : werte.reduce((a, b) => a + b) / werte.length;
      return ScoreDistributionData(
        kriterium: kriterien[i],
        durchschnitt: avg,
      );
    });
  });
});

/// Wachstumskurven (C3) - für gewählte Pflanzen
final growthCurvesProvider =
    Provider<AsyncValue<List<GrowthCurveData>>>((ref) {
  final selektionId = ref.watch(reportSelectedSelektionIdProvider);
  if (selektionId == null) return const AsyncValue.data([]);

  final selectedIds = ref.watch(reportSelectedPflanzenIdsProvider);

  final pflanzenAsync = ref.watch(selektionsPflanzenProvider(selektionId));

  return pflanzenAsync.whenData((pflanzen) {
    final filtered = selectedIds.isEmpty
        ? pflanzen
        : pflanzen.where((p) => selectedIds.contains(p.id)).toList();

    // Für jede Pflanze die Wachstumsmessungen laden
    final curves = <GrowthCurveData>[];
    for (final pflanze in filtered) {
      final messungenAsync =
          ref.watch(wachstumsMessungenProvider(pflanze.pflanzeId));
      final messungen = messungenAsync.valueOrNull ?? [];
      if (messungen.isNotEmpty) {
        final sorted = [...messungen]
          ..sort((a, b) => a.datum.compareTo(b.datum));
        curves.add(GrowthCurveData(
          bezeichnung: pflanze.bezeichnung,
          pflanzeId: pflanze.pflanzeId,
          punkte: sorted
              .map((m) => GrowthCurvePoint(
                    datum: m.datum,
                    hoeheCm: m.hoeheCm,
                    nodienAnzahl: m.nodienAnzahl,
                    stammdicke: m.stammdicke,
                  ))
              .toList(),
        ));
      }
    }
    return curves;
  });
});

// ── Dashboard Provider ──

/// Quick Stats für Dashboard
final growQuickStatsProvider = Provider<AsyncValue<GrowQuickStats>>((ref) {
  return ref.watch(durchgaengeListeProvider).whenData((durchgaenge) {
    final beendet =
        durchgaenge.where((d) => d.status == 'beendet').toList();

    if (beendet.isEmpty) return const GrowQuickStats();

    // Bester Ertrag
    Durchgang? bester;
    for (final d in beendet) {
      if (d.trockenErtragG != null) {
        if (bester == null ||
            d.trockenErtragG! > (bester.trockenErtragG ?? 0)) {
          bester = d;
        }
      }
    }

    // Durchschnitt g/W
    final mitWatt = beendet
        .where((d) => d.ertragProWatt != null)
        .map((d) => d.ertragProWatt!)
        .toList();
    final avgGpW = mitWatt.isEmpty
        ? null
        : mitWatt.reduce((a, b) => a + b) / mitWatt.length;

    return GrowQuickStats(
      besterErtragG: bester?.trockenErtragG,
      besterErtragSorte: bester?.sorteName,
      durchschnittGProWatt: avgGpW,
      abgeschlosseneDurchgaenge: beendet.length,
    );
  });
});

/// Letzte 5 Durchgänge mit Ertrag (für Dashboard Mini-Chart)
final dashboardYieldProvider =
    Provider<AsyncValue<List<YieldPerWattData>>>((ref) {
  return ref.watch(durchgaengeListeProvider).whenData((durchgaenge) {
    final mitErtrag = durchgaenge
        .where(
            (d) => d.status == 'beendet' && d.trockenErtragG != null)
        .toList()
      ..sort((a, b) =>
          (b.ernteDatum ?? DateTime(2000))
              .compareTo(a.ernteDatum ?? DateTime(2000)));

    return mitErtrag
        .take(5)
        .map((d) => YieldPerWattData(
              durchgangTitel: d.sorteName ?? 'Unbekannt',
              grammProWatt: d.trockenErtragG!,
            ))
        .toList()
        .reversed
        .toList();
  });
});

/// Umgebungsdaten des ersten aktiven Durchgangs (für Dashboard Mini-Chart)
final dashboardEnvironmentProvider =
    Provider<AsyncValue<List<EnvironmentDataPoint>>>((ref) {
  final aktiveAsync = ref.watch(aktiveDurchgaengeProvider);

  return aktiveAsync.whenData((aktive) {
    if (aktive.isEmpty) return <EnvironmentDataPoint>[];

    final growId = aktive.first.id;
    final logsAsync = ref.watch(tagesLogsFuerDurchgangProvider(growId));
    final logs = logsAsync.valueOrNull ?? [];

    final sorted = [...logs]..sort((a, b) => a.datum.compareTo(b.datum));
    // Letzte 7 Tage
    final letzte7 = sorted.length > 7
        ? sorted.sublist(sorted.length - 7)
        : sorted;

    return letzte7
        .map((log) => EnvironmentDataPoint(
              datum: log.datum,
              tempTag: log.tempTag,
              tempNacht: log.tempNacht,
              relfTag: log.relfTag,
              relfNacht: log.relfNacht,
            ))
        .toList();
  });
});

// ── Helper ──

class _YieldAccumulator {
  double _summe = 0;
  int _anzahl = 0;

  void add(double wert) {
    _summe += wert;
    _anzahl++;
  }

  double get durchschnitt => _anzahl == 0 ? 0 : _summe / _anzahl;
  int get anzahl => _anzahl;
}
