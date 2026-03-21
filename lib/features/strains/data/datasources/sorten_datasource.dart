import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/sorte_model.dart';

/// Supabase Datasource für Sorten
class SortenDatasource {
  final SupabaseClient _client;

  SortenDatasource(this._client);

  Future<List<SorteModel>> alleLaden() async {
    final response = await _client
        .from(AppConstants.tabelleSorten)
        .select()
        .order('name');

    return (response as List)
        .map((json) => SorteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SorteModel?> laden(String id) async {
    final response = await _client
        .from(AppConstants.tabelleSorten)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return SorteModel.fromJson(response);
  }

  Future<SorteModel> erstellen(SorteModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSorten)
        .insert(model.toJson())
        .select()
        .single();

    return SorteModel.fromJson(response);
  }

  Future<SorteModel> aktualisieren(String id, SorteModel model) async {
    final response = await _client
        .from(AppConstants.tabelleSorten)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return SorteModel.fromJson(response);
  }

  Future<void> loeschen(String id) async {
    await _client
        .from(AppConstants.tabelleSorten)
        .delete()
        .eq('id', id);
  }

  Future<List<SorteModel>> nachStatusFiltern(String status) async {
    final response = await _client
        .from(AppConstants.tabelleSorten)
        .select()
        .eq('status', status)
        .order('name');

    return (response as List)
        .map((json) => SorteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SorteModel>> suchen(String suchbegriff) async {
    final response = await _client
        .from(AppConstants.tabelleSorten)
        .select()
        .or('name.ilike.%$suchbegriff%,zuechter.ilike.%$suchbegriff%')
        .order('name');

    return (response as List)
        .map((json) => SorteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
