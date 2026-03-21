import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/sorten_datasource.dart';
import '../../data/repositories/sorten_repository_impl.dart';
import '../../domain/entities/sorte.dart';
import '../../domain/repositories/sorten_repository.dart';

/// Datasource Provider
final sortenDatasourceProvider = Provider<SortenDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SortenDatasource(client);
});

/// Repository Provider
final sortenRepositoryProvider = Provider<SortenRepository>((ref) {
  final datasource = ref.watch(sortenDatasourceProvider);
  return SortenRepositoryImpl(datasource);
});

/// Alle Sorten laden (AsyncNotifier für Refresh-Unterstützung)
final sortenListeProvider =
    AsyncNotifierProvider<SortenListeNotifier, List<Sorte>>(
  SortenListeNotifier.new,
);

class SortenListeNotifier extends AsyncNotifier<List<Sorte>> {
  @override
  Future<List<Sorte>> build() async {
    final repo = ref.watch(sortenRepositoryProvider);
    return await repo.alleLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(sortenRepositoryProvider);
      return await repo.alleLaden();
    });
  }

  Future<void> loeschen(String id) async {
    final repo = ref.read(sortenRepositoryProvider);
    await repo.loeschen(id);
    await aktualisieren();
  }
}

/// Einzelne Sorte laden
final sorteProvider =
    FutureProvider.family<Sorte?, String>((ref, id) async {
  final repo = ref.watch(sortenRepositoryProvider);
  return await repo.laden(id);
});

/// Suchbegriff State
final sortenSuchbegriffProvider = StateProvider<String>((ref) => '');

/// Gefilterte Sorten (nach Suchbegriff)
final gefilterteSortenProvider = Provider<AsyncValue<List<Sorte>>>((ref) {
  final suchbegriff = ref.watch(sortenSuchbegriffProvider).toLowerCase();
  final sortenAsync = ref.watch(sortenListeProvider);

  return sortenAsync.whenData((sorten) {
    if (suchbegriff.isEmpty) return sorten;
    return sorten.where((s) {
      return s.name.toLowerCase().contains(suchbegriff) ||
          (s.zuechter?.toLowerCase().contains(suchbegriff) ?? false);
    }).toList();
  });
});
