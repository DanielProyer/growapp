import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/anbauflaechen_datasource.dart';
import '../../data/datasources/zelte_datasource.dart';
import '../../data/models/anbauflaeche_model.dart';
import '../../data/repositories/zelte_repository_impl.dart';
import '../../domain/entities/anbauflaeche.dart';
import '../../domain/entities/zelt.dart';
import '../../domain/repositories/zelte_repository.dart';

// ── Zelte ──

final zelteDatasourceProvider = Provider<ZelteDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ZelteDatasource(client);
});

final zelteRepositoryProvider = Provider<ZelteRepository>((ref) {
  final datasource = ref.watch(zelteDatasourceProvider);
  return ZelteRepositoryImpl(datasource);
});

final zelteListeProvider =
    AsyncNotifierProvider<ZelteListeNotifier, List<Zelt>>(
  ZelteListeNotifier.new,
);

class ZelteListeNotifier extends AsyncNotifier<List<Zelt>> {
  @override
  Future<List<Zelt>> build() async {
    final repo = ref.watch(zelteRepositoryProvider);
    return await repo.alleLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(zelteRepositoryProvider);
      return await repo.alleLaden();
    });
  }

  Future<void> loeschen(String id) async {
    final repo = ref.read(zelteRepositoryProvider);
    await repo.loeschen(id);
    await aktualisieren();
  }
}

/// Einzelnes Zelt (abgeleitet von Liste, reaktiv)
final zeltProvider =
    Provider.family<AsyncValue<Zelt?>, String>((ref, id) {
  return ref.watch(zelteListeProvider).whenData((liste) {
    for (final z in liste) {
      if (z.id == id) return z;
    }
    return null;
  });
});

// ── Anbauflächen ──

final anbauflaechenDatasourceProvider = Provider<AnbauflaechenDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AnbauflaechenDatasource(client);
});

/// Anbauflächen für ein Zelt laden
final anbauflaechenProvider =
    FutureProvider.family<List<Anbauflaeche>, String>((ref, zeltId) async {
  final ds = ref.watch(anbauflaechenDatasourceProvider);
  return await ds.fuerZeltLaden(zeltId);
});

/// Anbaufläche erstellen
Future<void> anbauflaecheErstellen(AnbauflaechenDatasource ds, Anbauflaeche a) async {
  await ds.erstellen(AnbauflaecheModel.fromEntity(a));
}

/// Anbaufläche aktualisieren
Future<void> anbauflaecheAktualisieren(AnbauflaechenDatasource ds, Anbauflaeche a) async {
  await ds.aktualisieren(a.id, AnbauflaecheModel.fromEntity(a));
}
