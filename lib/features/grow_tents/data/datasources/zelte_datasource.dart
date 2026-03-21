import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/zelt_model.dart';

/// Supabase Datasource für Zelte
class ZelteDatasource {
  final SupabaseClient _client;

  ZelteDatasource(this._client);

  Future<List<ZeltModel>> alleLaden() async {
    final response = await _client
        .from(AppConstants.tabelleZelte)
        .select()
        .order('name');

    return (response as List)
        .map((json) => ZeltModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ZeltModel?> laden(String id) async {
    final response = await _client
        .from(AppConstants.tabelleZelte)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ZeltModel.fromJson(response);
  }

  Future<ZeltModel> erstellen(ZeltModel model) async {
    final response = await _client
        .from(AppConstants.tabelleZelte)
        .insert(model.toJson())
        .select()
        .single();

    return ZeltModel.fromJson(response);
  }

  Future<ZeltModel> aktualisieren(String id, ZeltModel model) async {
    final response = await _client
        .from(AppConstants.tabelleZelte)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return ZeltModel.fromJson(response);
  }

  Future<void> loeschen(String id) async {
    await _client
        .from(AppConstants.tabelleZelte)
        .delete()
        .eq('id', id);
  }
}
