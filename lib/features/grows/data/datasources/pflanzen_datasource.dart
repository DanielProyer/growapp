import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/pflanze_model.dart';

/// Supabase Datasource für Pflanzen
class PflanzenDatasource {
  final SupabaseClient _client;

  PflanzenDatasource(this._client);

  static const _selectQuery = '*, sorten(name)';

  Future<List<PflanzeModel>> fuerDurchgangLaden(String durchgangId) async {
    final response = await _client
        .from(AppConstants.tabellePflanzen)
        .select(_selectQuery)
        .eq('durchgang_id', durchgangId)
        .order('pflanzen_nr');

    return (response as List)
        .map((json) =>
            PflanzeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PflanzeModel?> laden(String id) async {
    final response = await _client
        .from(AppConstants.tabellePflanzen)
        .select(_selectQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return PflanzeModel.fromJson(response);
  }

  Future<PflanzeModel> erstellen(PflanzeModel model) async {
    final response = await _client
        .from(AppConstants.tabellePflanzen)
        .insert(model.toJson())
        .select(_selectQuery)
        .single();

    return PflanzeModel.fromJson(response);
  }

  Future<PflanzeModel> aktualisieren(String id, PflanzeModel model) async {
    final response = await _client
        .from(AppConstants.tabellePflanzen)
        .update(model.toJson())
        .eq('id', id)
        .select(_selectQuery)
        .single();

    return PflanzeModel.fromJson(response);
  }

  Future<void> loeschen(String id) async {
    await _client
        .from(AppConstants.tabellePflanzen)
        .delete()
        .eq('id', id);
  }
}
