import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/selektions_datasource.dart';
import '../../data/models/selektion_model.dart';
import '../../data/models/selektions_pflanze_model.dart';
import '../../data/models/wachstums_messung_model.dart';
import '../../domain/entities/selektion.dart';
import '../../domain/entities/selektions_pflanze.dart';
import '../../domain/entities/wachstums_messung.dart';

/// Datasource Provider
final selektionsDatasourceProvider = Provider<SelektionsDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SelektionsDatasource(client);
});

/// Alle Selektionen laden
final selektionenListeProvider =
    AsyncNotifierProvider<SelektionenListeNotifier, List<Selektion>>(
  SelektionenListeNotifier.new,
);

class SelektionenListeNotifier extends AsyncNotifier<List<Selektion>> {
  @override
  Future<List<Selektion>> build() async {
    final ds = ref.watch(selektionsDatasourceProvider);
    return await ds.alleLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(selektionsDatasourceProvider);
      return await ds.alleLaden();
    });
  }

  Future<Selektion> erstellen(Selektion selektion) async {
    final ds = ref.read(selektionsDatasourceProvider);
    final model = SelektionModel.fromEntity(selektion);
    final result = await ds.erstellen(model);
    await aktualisieren();
    return result;
  }

  Future<Selektion> selektionAktualisieren(
      String id, Selektion selektion) async {
    final ds = ref.read(selektionsDatasourceProvider);
    final model = SelektionModel.fromEntity(selektion);
    final result = await ds.aktualisieren(id, model);
    await aktualisieren();
    return result;
  }

  Future<void> statusAendern(String id, String neuerStatus) async {
    final ds = ref.read(selektionsDatasourceProvider);
    await ds.statusAendern(id, neuerStatus);
    await aktualisieren();
  }

  Future<void> loeschen(String id) async {
    final ds = ref.read(selektionsDatasourceProvider);
    await ds.loeschen(id);
    await aktualisieren();
  }
}

/// Einzelne Selektion (abgeleitet aus Liste)
final selektionProvider =
    Provider.family<AsyncValue<Selektion?>, String>((ref, id) {
  return ref.watch(selektionenListeProvider).whenData((liste) {
    for (final s in liste) {
      if (s.id == id) return s;
    }
    return null;
  });
});

/// Status-Filter (null = alle)
final selektionenStatusFilterProvider =
    StateProvider<String?>((ref) => 'aktiv');

/// Gefilterte Selektionen
final gefilterteSelektionenProvider =
    Provider<AsyncValue<List<Selektion>>>((ref) {
  final filterStatus = ref.watch(selektionenStatusFilterProvider);
  final selektionenAsync = ref.watch(selektionenListeProvider);

  return selektionenAsync.whenData((selektionen) {
    if (filterStatus == null) return selektionen;
    return selektionen.where((s) => s.status == filterStatus).toList();
  });
});

/// Pflanzen für eine Selektion
final selektionsPflanzenProvider = FutureProvider.family<
    List<SelektionsPflanze>, String>((ref, selektionId) async {
  final ds = ref.watch(selektionsDatasourceProvider);
  return await ds.pflanzenFuerSelektion(selektionId);
});

/// Pflanze zur Selektion hinzufügen
Future<void> selektionsPflanzeHinzufuegen(
  WidgetRef ref, {
  required String selektionId,
  required String pflanzeId,
}) async {
  final ds = ref.read(selektionsDatasourceProvider);
  final model = SelektionsPflanzeModel(
    id: '',
    selektionId: selektionId,
    pflanzeId: pflanzeId,
  );
  await ds.pflanzeHinzufuegen(model);
  ref.invalidate(selektionsPflanzenProvider(selektionId));
  ref.invalidate(selektionenListeProvider);
}

/// Pflanze bewerten / aktualisieren
Future<void> selektionsPflanzeAktualisieren(
  WidgetRef ref, {
  required String id,
  required SelektionsPflanze pflanze,
}) async {
  final ds = ref.read(selektionsDatasourceProvider);
  final model = SelektionsPflanzeModel.fromEntity(pflanze);
  await ds.pflanzeAktualisieren(id, model);
  ref.invalidate(selektionsPflanzenProvider(pflanze.selektionId));
  ref.invalidate(selektionenListeProvider);
}

/// Pflanze aus Selektion entfernen
Future<void> selektionsPflanzeEntfernen(
  WidgetRef ref, {
  required String id,
  required String selektionId,
}) async {
  final ds = ref.read(selektionsDatasourceProvider);
  await ds.pflanzeEntfernen(id);
  ref.invalidate(selektionsPflanzenProvider(selektionId));
  ref.invalidate(selektionenListeProvider);
}

/// Wachstumsmessungen für eine Pflanze
final wachstumsMessungenProvider = FutureProvider.family<
    List<WachstumsMessung>, String>((ref, pflanzeId) async {
  final ds = ref.watch(selektionsDatasourceProvider);
  return await ds.messungenFuerPflanze(pflanzeId);
});

/// Messung erstellen
Future<void> messungErstellen(
  WidgetRef ref, {
  required WachstumsMessung messung,
}) async {
  final ds = ref.read(selektionsDatasourceProvider);
  final model = WachstumsMessungModel.fromEntity(messung);
  await ds.messungErstellen(model);
  ref.invalidate(wachstumsMessungenProvider(messung.pflanzeId));
}

/// Messung aktualisieren
Future<void> messungAktualisieren(
  WidgetRef ref, {
  required String id,
  required WachstumsMessung messung,
}) async {
  final ds = ref.read(selektionsDatasourceProvider);
  final model = WachstumsMessungModel.fromEntity(messung);
  await ds.messungAktualisieren(id, model);
  ref.invalidate(wachstumsMessungenProvider(messung.pflanzeId));
}

/// Messung löschen
Future<void> messungLoeschen(
  WidgetRef ref, {
  required WachstumsMessung messung,
}) async {
  final ds = ref.read(selektionsDatasourceProvider);
  await ds.messungLoeschen(messung.id);
  ref.invalidate(wachstumsMessungenProvider(messung.pflanzeId));
}
