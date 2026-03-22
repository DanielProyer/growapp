import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../data/datasources/inventar_datasource.dart';
import '../../data/models/inventar_item_model.dart';
import '../../data/models/inventar_buchung_model.dart';
import '../../domain/entities/inventar_item.dart';
import '../../domain/entities/inventar_buchung.dart';

/// Datasource Provider
final inventarDatasourceProvider = Provider<InventarDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InventarDatasource(client);
});

/// Alle Inventar-Artikel laden (AsyncNotifier für Refresh-Unterstützung)
final inventarListeProvider =
    AsyncNotifierProvider<InventarListeNotifier, List<InventarItem>>(
  InventarListeNotifier.new,
);

class InventarListeNotifier extends AsyncNotifier<List<InventarItem>> {
  @override
  Future<List<InventarItem>> build() async {
    final ds = ref.watch(inventarDatasourceProvider);
    return await ds.alleLaden();
  }

  Future<void> aktualisieren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(inventarDatasourceProvider);
      return await ds.alleLaden();
    });
  }

  Future<void> loeschen(String id) async {
    final ds = ref.read(inventarDatasourceProvider);
    await ds.loeschen(id);
    await aktualisieren();
  }

  Future<InventarItem> erstellen(InventarItem item) async {
    final ds = ref.read(inventarDatasourceProvider);
    final model = InventarItemModel.fromEntity(item);
    final result = await ds.erstellen(model);
    await aktualisieren();
    return result;
  }

  Future<InventarItem> artikelAktualisieren(
      String id, InventarItem item) async {
    final ds = ref.read(inventarDatasourceProvider);
    final model = InventarItemModel.fromEntity(item);
    final result = await ds.aktualisieren(id, model);
    await aktualisieren();
    return result;
  }
}

/// Einzelner Artikel (abgeleitet aus der Liste)
final inventarItemProvider =
    Provider.family<AsyncValue<InventarItem?>, String>((ref, id) {
  return ref.watch(inventarListeProvider).whenData((liste) {
    for (final item in liste) {
      if (item.id == id) return item;
    }
    return null;
  });
});

/// Suchbegriff State
final inventarSuchbegriffProvider = StateProvider<String>((ref) => '');

/// Typ-Filter State (null=alle, 'equipment', 'verbrauchsmaterial')
final inventarFilterTypProvider = StateProvider<String?>((ref) => null);

/// Gefiltertes Inventar (kombiniert Suche + Typ-Filter)
final gefiltertesInventarProvider =
    Provider<AsyncValue<List<InventarItem>>>((ref) {
  final suchbegriff = ref.watch(inventarSuchbegriffProvider).toLowerCase();
  final filterTyp = ref.watch(inventarFilterTypProvider);
  final inventarAsync = ref.watch(inventarListeProvider);

  return inventarAsync.whenData((items) {
    var gefiltert = items.toList();

    // Typ-Filter
    if (filterTyp != null) {
      gefiltert = gefiltert.where((i) => i.typ == filterTyp).toList();
    }

    // Suchbegriff
    if (suchbegriff.isNotEmpty) {
      gefiltert = gefiltert.where((i) {
        return i.name.toLowerCase().contains(suchbegriff) ||
            i.kategorieLabel.toLowerCase().contains(suchbegriff) ||
            (i.lieferant?.toLowerCase().contains(suchbegriff) ?? false);
      }).toList();
    }

    return gefiltert;
  });
});

/// Buchungen für einen Artikel
final buchungenProvider =
    FutureProvider.family<List<InventarBuchung>, String>((ref, artikelId) async {
  final ds = ref.watch(inventarDatasourceProvider);
  return await ds.buchungenLaden(artikelId);
});

/// Buchung erstellen + optional Preis aktualisieren
Future<void> buchungErstellen(
  WidgetRef ref, {
  required String artikelId,
  required String typ,
  required double menge,
  double? stueckpreis,
  required DateTime datum,
  String? bemerkung,
  bool preisAktualisieren = false,
}) async {
  final ds = ref.read(inventarDatasourceProvider);

  final model = InventarBuchungModel(
    id: '',
    artikelId: artikelId,
    typ: typ,
    menge: menge,
    stueckpreis: stueckpreis,
    datum: datum,
    bemerkung: bemerkung,
  );

  await ds.buchungErstellen(model);

  // Optional: Artikelpreis aktualisieren
  if (preisAktualisieren && stueckpreis != null) {
    await ds.preisAktualisieren(artikelId, stueckpreis);
  }

  // Providers invalidieren
  ref.invalidate(inventarListeProvider);
  ref.invalidate(buchungenProvider(artikelId));
}

/// Buchung löschen
Future<void> buchungLoeschen(
  WidgetRef ref, {
  required InventarBuchung buchung,
}) async {
  final ds = ref.read(inventarDatasourceProvider);

  final model = InventarBuchungModel(
    id: buchung.id,
    artikelId: buchung.artikelId,
    typ: buchung.typ,
    menge: buchung.menge,
    stueckpreis: buchung.stueckpreis,
    datum: buchung.datum,
    bemerkung: buchung.bemerkung,
  );

  await ds.buchungLoeschen(model);

  ref.invalidate(inventarListeProvider);
  ref.invalidate(buchungenProvider(buchung.artikelId));
}
