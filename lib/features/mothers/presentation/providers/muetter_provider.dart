import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/muetter_datasource.dart';
import '../../data/models/mutterpflanze_model.dart';
import '../../data/models/steckling_model.dart';
import '../../domain/entities/mutterpflanze.dart';
import '../../domain/entities/steckling.dart';

/// Datasource Provider
final muetterDatasourceProvider = Provider<MuetterDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MuetterDatasource(client);
});

/// Alle Mutterpflanzen laden
final muetterListeProvider =
    AsyncNotifierProvider<MuetterListeNotifier, List<Mutterpflanze>>(
  MuetterListeNotifier.new,
);

class MuetterListeNotifier extends AsyncNotifier<List<Mutterpflanze>> {
  @override
  Future<List<Mutterpflanze>> build() async {
    final ds = ref.watch(muetterDatasourceProvider);
    return await ds.alleLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(muetterDatasourceProvider);
      return await ds.alleLaden();
    });
  }

  Future<Mutterpflanze> erstellen(Mutterpflanze mutter) async {
    final ds = ref.read(muetterDatasourceProvider);
    final model = MutterpflanzeModel.fromEntity(mutter);
    final result = await ds.erstellen(model);
    await aktualisieren();
    return result;
  }

  Future<Mutterpflanze> mutterAktualisieren(
      String id, Mutterpflanze mutter) async {
    final ds = ref.read(muetterDatasourceProvider);
    final model = MutterpflanzeModel.fromEntity(mutter);
    final result = await ds.aktualisieren(id, model);
    await aktualisieren();
    return result;
  }

  Future<void> entsorgen(String id, String grund) async {
    final ds = ref.read(muetterDatasourceProvider);
    await ds.entsorgen(id, grund);
    await aktualisieren();
  }

  Future<void> loeschen(String id) async {
    final ds = ref.read(muetterDatasourceProvider);
    await ds.loeschen(id);
    await aktualisieren();
  }
}

/// Einzelne Mutterpflanze (abgeleitet aus Liste)
final mutterProvider =
    Provider.family<AsyncValue<Mutterpflanze?>, String>((ref, id) {
  return ref.watch(muetterListeProvider).whenData((liste) {
    for (final m in liste) {
      if (m.id == id) return m;
    }
    return null;
  });
});

/// Status-Filter (null = alle, 'aktiv', 'entsorgt')
final muetterStatusFilterProvider = StateProvider<String?>((ref) => 'aktiv');

/// Gefilterte Mutterpflanzen
final gefilterteMuetterProvider =
    Provider<AsyncValue<List<Mutterpflanze>>>((ref) {
  final filterStatus = ref.watch(muetterStatusFilterProvider);
  final muetterAsync = ref.watch(muetterListeProvider);

  return muetterAsync.whenData((muetter) {
    if (filterStatus == null) return muetter;
    return muetter.where((m) => m.status == filterStatus).toList();
  });
});

/// Stecklinge für eine Mutterpflanze
final stecklingeProvider =
    FutureProvider.family<List<Steckling>, String>((ref, mutterId) async {
  final ds = ref.watch(muetterDatasourceProvider);
  return await ds.stecklingeFuerMutter(mutterId);
});

/// Steckling erstellen
Future<void> stecklingErstellen(
  WidgetRef ref, {
  required Steckling steckling,
}) async {
  final ds = ref.read(muetterDatasourceProvider);
  final model = StecklingModel.fromEntity(steckling);
  await ds.stecklingErstellen(model);
  ref.invalidate(stecklingeProvider(steckling.mutterId));
  ref.invalidate(muetterListeProvider);
}

/// Steckling aktualisieren
Future<void> stecklingAktualisieren(
  WidgetRef ref, {
  required String id,
  required Steckling steckling,
}) async {
  final ds = ref.read(muetterDatasourceProvider);
  final model = StecklingModel.fromEntity(steckling);
  await ds.stecklingAktualisieren(id, model);
  ref.invalidate(stecklingeProvider(steckling.mutterId));
  ref.invalidate(muetterListeProvider);
}

/// Steckling löschen
Future<void> stecklingLoeschen(
  WidgetRef ref, {
  required Steckling steckling,
}) async {
  final ds = ref.read(muetterDatasourceProvider);
  await ds.stecklingLoeschen(steckling.id);
  ref.invalidate(stecklingeProvider(steckling.mutterId));
  ref.invalidate(muetterListeProvider);
}
