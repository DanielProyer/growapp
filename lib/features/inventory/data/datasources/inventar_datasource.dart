import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/inventar_item_model.dart';
import '../models/inventar_buchung_model.dart';

/// Supabase Datasource für Inventar
class InventarDatasource {
  final SupabaseClient _client;

  InventarDatasource(this._client);

  // ── Artikel CRUD ──

  Future<List<InventarItemModel>> alleLaden() async {
    final response = await _client
        .from(AppConstants.tabelleInventar)
        .select()
        .order('typ')
        .order('name');

    return (response as List)
        .map((json) =>
            InventarItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InventarItemModel> erstellen(InventarItemModel model) async {
    final response = await _client
        .from(AppConstants.tabelleInventar)
        .insert(model.toJson())
        .select()
        .single();

    return InventarItemModel.fromJson(response);
  }

  Future<InventarItemModel> aktualisieren(
      String id, InventarItemModel model) async {
    final response = await _client
        .from(AppConstants.tabelleInventar)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return InventarItemModel.fromJson(response);
  }

  Future<void> loeschen(String id) async {
    await _client.from(AppConstants.tabelleInventar).delete().eq('id', id);
  }

  // ── Buchungen ──

  Future<List<InventarBuchungModel>> buchungenLaden(String artikelId) async {
    final response = await _client
        .from(AppConstants.tabelleInventarBuchungen)
        .select()
        .eq('artikel_id', artikelId)
        .order('datum', ascending: false)
        .order('erstellt_am', ascending: false);

    return (response as List)
        .map((json) =>
            InventarBuchungModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InventarBuchungModel> buchungErstellen(
      InventarBuchungModel model) async {
    // Buchung anlegen
    final response = await _client
        .from(AppConstants.tabelleInventarBuchungen)
        .insert(model.toJson())
        .select()
        .single();

    // Bestand aktualisieren
    final bestandAenderung =
        model.typ == 'eingang' ? model.menge : -model.menge;

    await _client.rpc('inventar_bestand_aendern', params: {
      'p_artikel_id': model.artikelId,
      'p_aenderung': bestandAenderung,
    }).onError((error, stackTrace) async {
      // Fallback: manuell aktualisieren wenn RPC nicht existiert
      final artikel = await _client
          .from(AppConstants.tabelleInventar)
          .select('aktueller_bestand')
          .eq('id', model.artikelId)
          .single();
      final neuerBestand =
          ((artikel['aktueller_bestand'] as num?)?.toDouble() ?? 0) +
              bestandAenderung;
      await _client
          .from(AppConstants.tabelleInventar)
          .update({'aktueller_bestand': neuerBestand < 0 ? 0 : neuerBestand})
          .eq('id', model.artikelId);
      return null;
    });

    return InventarBuchungModel.fromJson(response);
  }

  Future<void> buchungLoeschen(InventarBuchungModel buchung) async {
    // Bestand rückgängig machen
    final bestandAenderung =
        buchung.typ == 'eingang' ? -buchung.menge : buchung.menge;

    final artikel = await _client
        .from(AppConstants.tabelleInventar)
        .select('aktueller_bestand')
        .eq('id', buchung.artikelId)
        .single();
    final neuerBestand =
        ((artikel['aktueller_bestand'] as num?)?.toDouble() ?? 0) +
            bestandAenderung;
    await _client
        .from(AppConstants.tabelleInventar)
        .update({'aktueller_bestand': neuerBestand < 0 ? 0 : neuerBestand})
        .eq('id', buchung.artikelId);

    // Buchung löschen
    await _client
        .from(AppConstants.tabelleInventarBuchungen)
        .delete()
        .eq('id', buchung.id);
  }

  /// Preis am Artikel aktualisieren
  Future<void> preisAktualisieren(String artikelId, double preis) async {
    await _client
        .from(AppConstants.tabelleInventar)
        .update({'preis': preis})
        .eq('id', artikelId);
  }
}
