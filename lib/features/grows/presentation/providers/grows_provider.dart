import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/durchgaenge_datasource.dart';
import '../../data/models/durchgang_model.dart';
import '../../domain/entities/durchgang.dart';

final durchgaengeDatasourceProvider = Provider<DurchgaengeDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DurchgaengeDatasource(client);
});

/// Alle Durchgänge
final durchgaengeListeProvider =
    AsyncNotifierProvider<DurchgaengeListeNotifier, List<Durchgang>>(
  DurchgaengeListeNotifier.new,
);

class DurchgaengeListeNotifier extends AsyncNotifier<List<Durchgang>> {
  @override
  Future<List<Durchgang>> build() async {
    final ds = ref.watch(durchgaengeDatasourceProvider);
    return await ds.alleLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(durchgaengeDatasourceProvider);
      return await ds.alleLaden();
    });
  }

  Future<void> loeschen(String id) async {
    final ds = ref.read(durchgaengeDatasourceProvider);
    await ds.loeschen(id);
    await aktualisieren();
  }
}

/// Einzelner Durchgang (abgeleitet von Liste, reaktiv)
final durchgangProvider =
    Provider.family<AsyncValue<Durchgang?>, String>((ref, id) {
  return ref.watch(durchgaengeListeProvider).whenData((liste) {
    for (final d in liste) {
      if (d.id == id) return d;
    }
    return null;
  });
});

/// Aktive Durchgänge (für Dashboard)
final aktiveDurchgaengeProvider = FutureProvider<List<Durchgang>>((ref) async {
  final ds = ref.watch(durchgaengeDatasourceProvider);
  return await ds.aktiveLaden();
});

/// Helper: Durchgang erstellen
Future<void> durchgangErstellen(DurchgaengeDatasource ds, Durchgang d) async {
  await ds.erstellen(DurchgangModel.fromEntity(d));
}

/// Helper: Durchgang aktualisieren
Future<void> durchgangAktualisieren(DurchgaengeDatasource ds, Durchgang d) async {
  await ds.aktualisieren(d.id, DurchgangModel.fromEntity(d));
}
