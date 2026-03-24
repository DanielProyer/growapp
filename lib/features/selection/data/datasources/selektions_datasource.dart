import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/selektion_model.dart';
import '../models/selektions_pflanze_model.dart';
import '../models/wachstums_messung_model.dart';

/// Supabase Datasource für Selektionen, Pflanzen-Bewertungen & Wachstumsmessungen
class SelektionsDatasource {
  final SupabaseClient _client;

  SelektionsDatasource(this._client);

  static const _selektionSelect =
      '*, sorten(name), selektions_pflanzen(keeper_status, bewertung_gesamt)';

  static const _pflanzeSelect =
      '*, pflanzen(pflanzen_nr, sorten(name))';

  // ── Selektionen CRUD ──

  Future<List<SelektionModel>> alleLaden() async {
    final response = await _client
        .from(AppConstants.tabelleSelektionen)
        .select(_selektionSelect)
        .order('erstellt_am', ascending: false);

    return (response as List)
        .map((json) =>
            SelektionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SelektionModel> laden(String id) async {
    final response = await _client
        .from(AppConstants.tabelleSelektionen)
        .select(_selektionSelect)
        .eq('id', id)
        .single();

    return SelektionModel.fromJson(response);
  }

  Future<SelektionModel> erstellen(SelektionModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSelektionen)
        .insert(model.toJson())
        .select(_selektionSelect)
        .single();

    return SelektionModel.fromJson(response);
  }

  Future<SelektionModel> aktualisieren(
      String id, SelektionModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSelektionen)
        .update(model.toJson())
        .eq('id', id)
        .select(_selektionSelect)
        .single();

    return SelektionModel.fromJson(response);
  }

  Future<void> loeschen(String id) async {
    await _client
        .from(AppConstants.tabelleSelektionen)
        .delete()
        .eq('id', id);
  }

  Future<void> statusAendern(String id, String neuerStatus) async {
    await _client
        .from(AppConstants.tabelleSelektionen)
        .update({'status': neuerStatus})
        .eq('id', id);
  }

  // ── Selektions-Pflanzen CRUD ──

  Future<List<SelektionsPflanzeModel>> pflanzenFuerSelektion(
      String selektionId) async {
    final response = await _client
        .from(AppConstants.tabelleSelektionsPflanzen)
        .select(_pflanzeSelect)
        .eq('selektion_id', selektionId)
        .order('erstellt_am', ascending: true);

    return (response as List)
        .map((json) =>
            SelektionsPflanzeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SelektionsPflanzeModel> pflanzeHinzufuegen(
      SelektionsPflanzeModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSelektionsPflanzen)
        .insert(model.toJson())
        .select(_pflanzeSelect)
        .single();

    return SelektionsPflanzeModel.fromJson(response);
  }

  Future<SelektionsPflanzeModel> pflanzeAktualisieren(
      String id, SelektionsPflanzeModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSelektionsPflanzen)
        .update(model.toJson())
        .eq('id', id)
        .select(_pflanzeSelect)
        .single();

    return SelektionsPflanzeModel.fromJson(response);
  }

  Future<void> pflanzeEntfernen(String id) async {
    await _client
        .from(AppConstants.tabelleSelektionsPflanzen)
        .delete()
        .eq('id', id);
  }

  // ── Wachstums-Messungen CRUD ──

  Future<List<WachstumsMessungModel>> messungenFuerPflanze(
      String pflanzeId) async {
    final response = await _client
        .from(AppConstants.tabelleWachstumsMessungen)
        .select()
        .eq('pflanze_id', pflanzeId)
        .order('datum', ascending: true);

    return (response as List)
        .map((json) =>
            WachstumsMessungModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<WachstumsMessungModel> messungErstellen(
      WachstumsMessungModel model) async {
    final response = await _client
        .from(AppConstants.tabelleWachstumsMessungen)
        .insert(model.toJson())
        .select()
        .single();

    return WachstumsMessungModel.fromJson(response);
  }

  Future<WachstumsMessungModel> messungAktualisieren(
      String id, WachstumsMessungModel model) async {
    final response = await _client
        .from(AppConstants.tabelleWachstumsMessungen)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return WachstumsMessungModel.fromJson(response);
  }

  Future<void> messungLoeschen(String id) async {
    await _client
        .from(AppConstants.tabelleWachstumsMessungen)
        .delete()
        .eq('id', id);
  }
}
