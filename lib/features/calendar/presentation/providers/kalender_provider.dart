import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/kalender_datasource.dart';
import '../../data/models/kalender_eintrag_model.dart';
import '../../domain/entities/kalender_eintrag.dart';
import '../../services/notification_service.dart';

/// Datasource Provider
final kalenderDatasourceProvider = Provider<KalenderDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return KalenderDatasource(client);
});

/// Alle Kalender-Einträge (AsyncNotifier für Refresh)
final kalenderListeProvider =
    AsyncNotifierProvider<KalenderListeNotifier, List<KalenderEintrag>>(
  KalenderListeNotifier.new,
);

class KalenderListeNotifier extends AsyncNotifier<List<KalenderEintrag>> {
  @override
  Future<List<KalenderEintrag>> build() async {
    final ds = ref.watch(kalenderDatasourceProvider);
    return await ds.alleLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(kalenderDatasourceProvider);
      return await ds.alleLaden();
    });
  }

  Future<KalenderEintrag> erstellen(KalenderEintrag eintrag) async {
    final ds = ref.read(kalenderDatasourceProvider);
    final model = KalenderEintragModel.fromEntity(eintrag);
    final result = await ds.erstellen(model);

    // Notification planen wenn Erinnerung gesetzt
    if (eintrag.erinnerungMinuten > 0) {
      final ns = ref.read(notificationServiceProvider);
      final erinnerungsZeit = eintrag.geplantAm
          .subtract(Duration(minutes: eintrag.erinnerungMinuten));
      await ns.erinnerungPlanen(
        eintragId: result.id,
        titel: eintrag.titel,
        zeitpunkt: erinnerungsZeit,
        beschreibung: eintrag.beschreibung,
      );
    }

    await aktualisieren();
    ref.invalidate(anstehendeTermineProvider);
    return result;
  }

  Future<KalenderEintrag> eintragAktualisieren(
      String id, KalenderEintrag eintrag) async {
    final ds = ref.read(kalenderDatasourceProvider);
    final model = KalenderEintragModel.fromEntity(eintrag);
    final result = await ds.aktualisieren(id, model);

    // Notification aktualisieren
    final ns = ref.read(notificationServiceProvider);
    await ns.erinnerungAbbrechen(id);
    if (eintrag.erinnerungMinuten > 0) {
      final erinnerungsZeit = eintrag.geplantAm
          .subtract(Duration(minutes: eintrag.erinnerungMinuten));
      await ns.erinnerungPlanen(
        eintragId: id,
        titel: eintrag.titel,
        zeitpunkt: erinnerungsZeit,
        beschreibung: eintrag.beschreibung,
      );
    }

    await aktualisieren();
    ref.invalidate(anstehendeTermineProvider);
    return result;
  }

  Future<void> erledigtToggeln(String id, bool erledigt) async {
    final ds = ref.read(kalenderDatasourceProvider);
    await ds.erledigtSetzen(id, erledigt);

    // Notification abbrechen wenn erledigt
    if (erledigt) {
      final ns = ref.read(notificationServiceProvider);
      await ns.erinnerungAbbrechen(id);
    }

    await aktualisieren();
    ref.invalidate(anstehendeTermineProvider);
  }

  Future<void> loeschen(String id) async {
    final ds = ref.read(kalenderDatasourceProvider);
    final ns = ref.read(notificationServiceProvider);
    await ns.erinnerungAbbrechen(id);
    await ds.loeschen(id);
    await aktualisieren();
    ref.invalidate(anstehendeTermineProvider);
  }
}

/// Einträge für einen bestimmten Tag (abgeleitet aus der Liste)
final kalenderTagProvider =
    Provider.family<AsyncValue<List<KalenderEintrag>>, DateTime>((ref, tag) {
  return ref.watch(kalenderListeProvider).whenData((liste) {
    return liste.where((e) {
      final d = e.geplantAm.toLocal();
      return d.year == tag.year && d.month == tag.month && d.day == tag.day;
    }).toList()
      ..sort((a, b) => a.geplantAm.compareTo(b.geplantAm));
  });
});

/// Events pro Tag (für TableCalendar Marker)
final kalenderEventsProvider =
    Provider<AsyncValue<Map<DateTime, List<KalenderEintrag>>>>((ref) {
  return ref.watch(kalenderListeProvider).whenData((liste) {
    final map = <DateTime, List<KalenderEintrag>>{};
    for (final eintrag in liste) {
      final d = eintrag.geplantAm.toLocal();
      final key = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(key, () => []).add(eintrag);
    }
    return map;
  });
});

/// Anstehende Termine (für Dashboard-Widget)
final anstehendeTermineProvider =
    FutureProvider<List<KalenderEintrag>>((ref) async {
  final ds = ref.watch(kalenderDatasourceProvider);
  return await ds.anstehendeLaden(limit: 5);
});
