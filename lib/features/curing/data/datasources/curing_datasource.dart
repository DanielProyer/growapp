import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/curing_glas_model.dart';
import '../models/curing_messwert_model.dart';

/// Supabase Datasource für Curing-Gläser & Messwerte
class CuringDatasource {
  final SupabaseClient _client;

  CuringDatasource(this._client);

  static const _glasSelect =
      '*, sorten(name), curing_messwerte(rlf_prozent)';

  // ── Gläser CRUD ──

  Future<List<CuringGlasModel>> alleGlaeserLaden() async {
    final response = await _client
        .from(AppConstants.tabelleCuringGlaeser)
        .select(_glasSelect)
        .order('erstellt_am', ascending: false);

    return (response as List)
        .map((json) =>
            CuringGlasModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CuringGlasModel> glasLaden(String id) async {
    final response = await _client
        .from(AppConstants.tabelleCuringGlaeser)
        .select(_glasSelect)
        .eq('id', id)
        .single();

    return CuringGlasModel.fromJson(response);
  }

  Future<CuringGlasModel> glasErstellen(CuringGlasModel model) async {
    final response = await _client
        .from(AppConstants.tabelleCuringGlaeser)
        .insert(model.toJson())
        .select(_glasSelect)
        .single();

    return CuringGlasModel.fromJson(response);
  }

  Future<CuringGlasModel> glasAktualisieren(
      String id, CuringGlasModel model) async {
    final response = await _client
        .from(AppConstants.tabelleCuringGlaeser)
        .update(model.toJson())
        .eq('id', id)
        .select(_glasSelect)
        .single();

    return CuringGlasModel.fromJson(response);
  }

  Future<void> glasLoeschen(String id) async {
    await _client
        .from(AppConstants.tabelleCuringGlaeser)
        .delete()
        .eq('id', id);
  }

  // ── Messwerte CRUD ──

  Future<List<CuringMesswertModel>> messwerteProGlas(String glasId) async {
    final response = await _client
        .from(AppConstants.tabelleCuringMesswerte)
        .select()
        .eq('glas_id', glasId)
        .order('datum', ascending: false);

    return (response as List)
        .map((json) =>
            CuringMesswertModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CuringMesswertModel> messwertErstellen(
      CuringMesswertModel model) async {
    final response = await _client
        .from(AppConstants.tabelleCuringMesswerte)
        .insert(model.toJson())
        .select()
        .single();

    return CuringMesswertModel.fromJson(response);
  }

  Future<CuringMesswertModel> messwertAktualisieren(
      String id, CuringMesswertModel model) async {
    final response = await _client
        .from(AppConstants.tabelleCuringMesswerte)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return CuringMesswertModel.fromJson(response);
  }

  Future<void> messwertLoeschen(String id) async {
    await _client
        .from(AppConstants.tabelleCuringMesswerte)
        .delete()
        .eq('id', id);
  }
}
