import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/mutterpflanze_model.dart';
import '../models/steckling_model.dart';

/// Supabase Datasource für Mutterpflanzen & Stecklinge
class MuetterDatasource {
  final SupabaseClient _client;

  MuetterDatasource(this._client);

  static const _mutterSelect =
      '*, sorten(name), stecklinge(datum, anzahl_unten, anzahl_oben, erfolgsrate)';

  // ── Mutterpflanzen CRUD ──

  Future<List<MutterpflanzeModel>> alleLaden() async {
    final response = await _client
        .from(AppConstants.tabelleMuetterpflanzen)
        .select(_mutterSelect)
        .order('erstellt_am', ascending: false);

    return (response as List)
        .map((json) =>
            MutterpflanzeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MutterpflanzeModel> laden(String id) async {
    final response = await _client
        .from(AppConstants.tabelleMuetterpflanzen)
        .select(_mutterSelect)
        .eq('id', id)
        .single();

    return MutterpflanzeModel.fromJson(response);
  }

  Future<MutterpflanzeModel> erstellen(MutterpflanzeModel model) async {
    final response = await _client
        .from(AppConstants.tabelleMuetterpflanzen)
        .insert(model.toJson())
        .select(_mutterSelect)
        .single();

    return MutterpflanzeModel.fromJson(response);
  }

  Future<MutterpflanzeModel> aktualisieren(
      String id, MutterpflanzeModel model) async {
    final response = await _client
        .from(AppConstants.tabelleMuetterpflanzen)
        .update(model.toJson())
        .eq('id', id)
        .select(_mutterSelect)
        .single();

    return MutterpflanzeModel.fromJson(response);
  }

  Future<void> loeschen(String id) async {
    await _client
        .from(AppConstants.tabelleMuetterpflanzen)
        .delete()
        .eq('id', id);
  }

  Future<void> entsorgen(String id, String grund) async {
    await _client.from(AppConstants.tabelleMuetterpflanzen).update({
      'status': 'entsorgt',
      'entsorgt_datum': DateTime.now().toIso8601String().split('T').first,
      'entsorgt_grund': grund,
    }).eq('id', id);
  }

  // ── Stecklinge CRUD ──

  Future<List<StecklingModel>> stecklingeFuerMutter(String mutterId) async {
    final response = await _client
        .from(AppConstants.tabelleStecklinge)
        .select()
        .eq('mutter_id', mutterId)
        .order('datum', ascending: false);

    return (response as List)
        .map((json) => StecklingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<StecklingModel> stecklingErstellen(StecklingModel model) async {
    final response = await _client
        .from(AppConstants.tabelleStecklinge)
        .insert(model.toJson())
        .select()
        .single();

    return StecklingModel.fromJson(response);
  }

  Future<StecklingModel> stecklingAktualisieren(
      String id, StecklingModel model) async {
    final response = await _client
        .from(AppConstants.tabelleStecklinge)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return StecklingModel.fromJson(response);
  }

  Future<void> stecklingLoeschen(String id) async {
    await _client
        .from(AppConstants.tabelleStecklinge)
        .delete()
        .eq('id', id);
  }
}
