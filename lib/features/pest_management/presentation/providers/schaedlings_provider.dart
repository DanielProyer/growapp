import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/schaedlings_datasource.dart';
import '../../data/models/schaedlings_vorfall_model.dart';
import '../../data/models/schaedlings_behandlung_model.dart';
import '../../domain/entities/schaedlings_vorfall.dart';
import '../../domain/entities/schaedlings_behandlung.dart';

/// Datasource Provider
final schaedlingsDatasourceProvider = Provider<SchaedlingsDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SchaedlingsDatasource(client);
});

/// Alle Vorfälle laden (AsyncNotifier für Refresh-Unterstützung)
final vorfaelleListeProvider =
    AsyncNotifierProvider<VorfaelleListeNotifier, List<SchaedlingsVorfall>>(
  VorfaelleListeNotifier.new,
);

class VorfaelleListeNotifier extends AsyncNotifier<List<SchaedlingsVorfall>> {
  @override
  Future<List<SchaedlingsVorfall>> build() async {
    final ds = ref.watch(schaedlingsDatasourceProvider);
    return await ds.vorfaelleAlleLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(schaedlingsDatasourceProvider);
      return await ds.vorfaelleAlleLaden();
    });
  }

  Future<SchaedlingsVorfall> erstellen(SchaedlingsVorfall vorfall) async {
    final ds = ref.read(schaedlingsDatasourceProvider);
    final model = SchaedlingsVorfallModel.fromEntity(vorfall);
    final result = await ds.vorfallErstellen(model);
    await aktualisieren();
    return result;
  }

  Future<SchaedlingsVorfall> vorfallAktualisieren(
      String id, SchaedlingsVorfall vorfall) async {
    final ds = ref.read(schaedlingsDatasourceProvider);
    final model = SchaedlingsVorfallModel.fromEntity(vorfall);
    final result = await ds.vorfallAktualisieren(id, model);
    await aktualisieren();
    return result;
  }

  Future<void> loeschen(String id) async {
    final ds = ref.read(schaedlingsDatasourceProvider);
    await ds.vorfallLoeschen(id);
    await aktualisieren();
  }
}

/// Einzelner Vorfall (abgeleitet aus Liste)
final vorfallProvider =
    Provider.family<AsyncValue<SchaedlingsVorfall?>, String>((ref, id) {
  return ref.watch(vorfaelleListeProvider).whenData((liste) {
    for (final v in liste) {
      if (v.id == id) return v;
    }
    return null;
  });
});

/// Zelt-Filter für Vorfälle (null = alle)
final vorfaelleZeltFilterProvider = StateProvider<String?>((ref) => null);

/// Gefilterte Vorfälle
final gefilterteVorfaelleProvider =
    Provider<AsyncValue<List<SchaedlingsVorfall>>>((ref) {
  final filterZeltId = ref.watch(vorfaelleZeltFilterProvider);
  final vorfaelleAsync = ref.watch(vorfaelleListeProvider);

  return vorfaelleAsync.whenData((vorfaelle) {
    if (filterZeltId == null) return vorfaelle;
    return vorfaelle.where((v) => v.zeltId == filterZeltId).toList();
  });
});

/// Behandlungen für einen Vorfall
final behandlungenProvider = FutureProvider.family<
    List<SchaedlingsBehandlung>, String>((ref, vorfallId) async {
  final ds = ref.watch(schaedlingsDatasourceProvider);
  return await ds.behandlungenFuerVorfall(vorfallId);
});

/// Prophylaktische Behandlungen (ohne Vorfall)
final prophylaxeListeProvider =
    AsyncNotifierProvider<ProphylaxeListeNotifier, List<SchaedlingsBehandlung>>(
  ProphylaxeListeNotifier.new,
);

class ProphylaxeListeNotifier
    extends AsyncNotifier<List<SchaedlingsBehandlung>> {
  @override
  Future<List<SchaedlingsBehandlung>> build() async {
    final ds = ref.watch(schaedlingsDatasourceProvider);
    return await ds.prophylaktischeBehandlungenLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(schaedlingsDatasourceProvider);
      return await ds.prophylaktischeBehandlungenLaden();
    });
  }
}

/// Behandlung erstellen (reaktiv oder prophylaktisch)
Future<void> behandlungErstellen(
  WidgetRef ref, {
  required SchaedlingsBehandlung behandlung,
}) async {
  final ds = ref.read(schaedlingsDatasourceProvider);
  final model = SchaedlingsBehandlungModel.fromEntity(behandlung);
  await ds.behandlungErstellen(model);

  if (behandlung.vorfallId != null) {
    ref.invalidate(behandlungenProvider(behandlung.vorfallId!));
  } else {
    ref.invalidate(prophylaxeListeProvider);
  }
}

/// Behandlung löschen
Future<void> behandlungLoeschen(
  WidgetRef ref, {
  required SchaedlingsBehandlung behandlung,
}) async {
  final ds = ref.read(schaedlingsDatasourceProvider);
  await ds.behandlungLoeschen(behandlung.id);

  if (behandlung.vorfallId != null) {
    ref.invalidate(behandlungenProvider(behandlung.vorfallId!));
  } else {
    ref.invalidate(prophylaxeListeProvider);
  }
}
