import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/zelte_datasource.dart';
import '../../data/repositories/zelte_repository_impl.dart';
import '../../domain/entities/zelt.dart';
import '../../domain/repositories/zelte_repository.dart';

/// Datasource Provider
final zelteDatasourceProvider = Provider<ZelteDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ZelteDatasource(client);
});

/// Repository Provider
final zelteRepositoryProvider = Provider<ZelteRepository>((ref) {
  final datasource = ref.watch(zelteDatasourceProvider);
  return ZelteRepositoryImpl(datasource);
});

/// Alle Zelte laden
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

/// Einzelnes Zelt laden
final zeltProvider =
    FutureProvider.family<Zelt?, String>((ref, id) async {
  final repo = ref.watch(zelteRepositoryProvider);
  return await repo.laden(id);
});
