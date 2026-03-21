import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/tages_logs_datasource.dart';
import '../../data/models/tages_log_model.dart';
import '../../domain/entities/tages_log.dart';

final tagesLogsDatasourceProvider = Provider<TagesLogsDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TagesLogsDatasource(client);
});

/// Logs für einen bestimmten Durchgang
final tagesLogsFuerDurchgangProvider = AsyncNotifierProvider.family<
    TagesLogsFuerDurchgangNotifier, List<TagesLog>, String>(
  TagesLogsFuerDurchgangNotifier.new,
);

class TagesLogsFuerDurchgangNotifier
    extends FamilyAsyncNotifier<List<TagesLog>, String> {
  @override
  Future<List<TagesLog>> build(String arg) async {
    final ds = ref.watch(tagesLogsDatasourceProvider);
    return await ds.fuerDurchgangLaden(arg);
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(tagesLogsDatasourceProvider);
      return await ds.fuerDurchgangLaden(arg);
    });
  }

  Future<void> loeschen(String id) async {
    final ds = ref.read(tagesLogsDatasourceProvider);
    await ds.loeschen(id);
    await aktualisieren();
  }
}

/// Einzelner Log
final tagesLogProvider =
    FutureProvider.family<TagesLog?, String>((ref, id) async {
  final ds = ref.watch(tagesLogsDatasourceProvider);
  return await ds.laden(id);
});

/// Helper: Log erstellen
Future<void> tagesLogErstellen(TagesLogsDatasource ds, TagesLog log) async {
  await ds.erstellen(TagesLogModel.fromEntity(log));
}

/// Helper: Log aktualisieren
Future<void> tagesLogAktualisieren(
    TagesLogsDatasource ds, TagesLog log) async {
  await ds.aktualisieren(log.id, TagesLogModel.fromEntity(log));
}
