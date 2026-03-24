import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/curing_datasource.dart';
import '../../data/models/curing_glas_model.dart';
import '../../data/models/curing_messwert_model.dart';
import '../../domain/entities/curing_glas.dart';
import '../../domain/entities/curing_messwert.dart';

/// Datasource Provider
final curingDatasourceProvider = Provider<CuringDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CuringDatasource(client);
});

/// Alle Curing-Gläser laden
final curingGlaeserListeProvider =
    AsyncNotifierProvider<CuringGlaeserNotifier, List<CuringGlas>>(
  CuringGlaeserNotifier.new,
);

class CuringGlaeserNotifier extends AsyncNotifier<List<CuringGlas>> {
  @override
  Future<List<CuringGlas>> build() async {
    final ds = ref.watch(curingDatasourceProvider);
    return await ds.alleGlaeserLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(curingDatasourceProvider);
      return await ds.alleGlaeserLaden();
    });
  }

  Future<CuringGlas> erstellen(CuringGlas glas) async {
    final ds = ref.read(curingDatasourceProvider);
    final model = CuringGlasModel.fromEntity(glas);
    final result = await ds.glasErstellen(model);
    await aktualisieren();
    return result;
  }

  Future<CuringGlas> glasAktualisieren(String id, CuringGlas glas) async {
    final ds = ref.read(curingDatasourceProvider);
    final model = CuringGlasModel.fromEntity(glas);
    final result = await ds.glasAktualisieren(id, model);
    await aktualisieren();
    return result;
  }

  Future<void> loeschen(String id) async {
    final ds = ref.read(curingDatasourceProvider);
    await ds.glasLoeschen(id);
    await aktualisieren();
  }
}

/// Einzelnes Glas (abgeleitet aus Liste)
final curingGlasProvider =
    Provider.family<AsyncValue<CuringGlas?>, String>((ref, id) {
  return ref.watch(curingGlaeserListeProvider).whenData((liste) {
    for (final g in liste) {
      if (g.id == id) return g;
    }
    return null;
  });
});

/// Status-Filter (null = alle)
final curingStatusFilterProvider = StateProvider<String?>((ref) => null);

/// Durchgang-Filter (null = alle)
final curingDurchgangFilterProvider = StateProvider<String?>((ref) => null);

/// Gefilterte Gläser-Liste
final curingGlaeserGefiltertProvider =
    Provider<AsyncValue<List<CuringGlas>>>((ref) {
  final filterStatus = ref.watch(curingStatusFilterProvider);
  final filterDurchgang = ref.watch(curingDurchgangFilterProvider);
  final glaeserAsync = ref.watch(curingGlaeserListeProvider);

  return glaeserAsync.whenData((glaeser) {
    var result = glaeser;
    if (filterStatus != null) {
      result = result.where((g) => g.status == filterStatus).toList();
    }
    if (filterDurchgang != null) {
      result =
          result.where((g) => g.durchgangId == filterDurchgang).toList();
    }
    return result;
  });
});

/// Messwerte pro Glas
final curingMesswerteProvider =
    FutureProvider.family<List<CuringMesswert>, String>((ref, glasId) async {
  final ds = ref.watch(curingDatasourceProvider);
  return await ds.messwerteProGlas(glasId);
});

/// Helper: Messwert erstellen
Future<void> curingMesswertErstellen(
  WidgetRef ref, {
  required CuringMesswert messwert,
}) async {
  final ds = ref.read(curingDatasourceProvider);
  final model = CuringMesswertModel.fromEntity(messwert);
  await ds.messwertErstellen(model);
  ref.invalidate(curingMesswerteProvider(messwert.glasId));
  ref.invalidate(curingGlaeserListeProvider);
}

/// Helper: Messwert aktualisieren
Future<void> curingMesswertAktualisieren(
  WidgetRef ref, {
  required String id,
  required CuringMesswert messwert,
}) async {
  final ds = ref.read(curingDatasourceProvider);
  final model = CuringMesswertModel.fromEntity(messwert);
  await ds.messwertAktualisieren(id, model);
  ref.invalidate(curingMesswerteProvider(messwert.glasId));
  ref.invalidate(curingGlaeserListeProvider);
}

/// Helper: Messwert löschen
Future<void> curingMesswertLoeschen(
  WidgetRef ref, {
  required CuringMesswert messwert,
}) async {
  final ds = ref.read(curingDatasourceProvider);
  await ds.messwertLoeschen(messwert.id);
  ref.invalidate(curingMesswerteProvider(messwert.glasId));
  ref.invalidate(curingGlaeserListeProvider);
}
