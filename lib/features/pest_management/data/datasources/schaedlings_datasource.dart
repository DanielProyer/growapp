import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/schaedlings_vorfall_model.dart';
import '../models/schaedlings_behandlung_model.dart';

/// Supabase Datasource für Schädlingsverwaltung
class SchaedlingsDatasource {
  final SupabaseClient _client;

  SchaedlingsDatasource(this._client);

  static const _vorfallSelect = '*, zelte(name)';
  static const _behandlungSelect = '*, zelte(name)';

  // ── Vorfälle CRUD ──

  Future<List<SchaedlingsVorfallModel>> vorfaelleAlleLaden() async {
    final response = await _client
        .from(AppConstants.tabelleSchaedlingsVorfaelle)
        .select(_vorfallSelect)
        .order('erkannt_datum', ascending: false);

    return (response as List)
        .map((json) =>
            SchaedlingsVorfallModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SchaedlingsVorfallModel> vorfallLaden(String id) async {
    final response = await _client
        .from(AppConstants.tabelleSchaedlingsVorfaelle)
        .select(_vorfallSelect)
        .eq('id', id)
        .single();

    return SchaedlingsVorfallModel.fromJson(response);
  }

  Future<SchaedlingsVorfallModel> vorfallErstellen(
      SchaedlingsVorfallModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSchaedlingsVorfaelle)
        .insert(model.toJson())
        .select(_vorfallSelect)
        .single();

    return SchaedlingsVorfallModel.fromJson(response);
  }

  Future<SchaedlingsVorfallModel> vorfallAktualisieren(
      String id, SchaedlingsVorfallModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSchaedlingsVorfaelle)
        .update(model.toJson())
        .eq('id', id)
        .select(_vorfallSelect)
        .single();

    return SchaedlingsVorfallModel.fromJson(response);
  }

  Future<void> vorfallLoeschen(String id) async {
    await _client
        .from(AppConstants.tabelleSchaedlingsVorfaelle)
        .delete()
        .eq('id', id);
  }

  // ── Behandlungen CRUD ──

  Future<List<SchaedlingsBehandlungModel>> behandlungenFuerVorfall(
      String vorfallId) async {
    final response = await _client
        .from(AppConstants.tabelleSchaedlingsBehandlungen)
        .select(_behandlungSelect)
        .eq('vorfall_id', vorfallId)
        .order('datum', ascending: false);

    return (response as List)
        .map((json) =>
            SchaedlingsBehandlungModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SchaedlingsBehandlungModel>>
      prophylaktischeBehandlungenLaden() async {
    final response = await _client
        .from(AppConstants.tabelleSchaedlingsBehandlungen)
        .select(_behandlungSelect)
        .isFilter('vorfall_id', null)
        .order('datum', ascending: false);

    return (response as List)
        .map((json) =>
            SchaedlingsBehandlungModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SchaedlingsBehandlungModel> behandlungErstellen(
      SchaedlingsBehandlungModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSchaedlingsBehandlungen)
        .insert(model.toJson())
        .select(_behandlungSelect)
        .single();

    return SchaedlingsBehandlungModel.fromJson(response);
  }

  Future<void> behandlungLoeschen(String id) async {
    await _client
        .from(AppConstants.tabelleSchaedlingsBehandlungen)
        .delete()
        .eq('id', id);
  }
}
