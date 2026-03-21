import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/durchgang_model.dart';

/// Supabase Datasource für Durchgänge
class DurchgaengeDatasource {
  final SupabaseClient _client;

  DurchgaengeDatasource(this._client);

  /// Select mit Joins auf Sorte und Anbaufläche→Zelt
  static const _selectQuery =
      '*, sorten(name), anbauflaechen(name, zelte(name))';

  Future<List<DurchgangModel>> alleLaden() async {
    final response = await _client
        .from(AppConstants.tabelleDurchgaenge)
        .select(_selectQuery)
        .order('erstellt_am', ascending: false);

    return (response as List)
        .map((json) => DurchgangModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DurchgangModel>> aktiveLaden() async {
    final response = await _client
        .from(AppConstants.tabelleDurchgaenge)
        .select(_selectQuery)
        .neq('status', 'beendet')
        .order('erstellt_am', ascending: false);

    return (response as List)
        .map((json) => DurchgangModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<DurchgangModel?> laden(String id) async {
    final response = await _client
        .from(AppConstants.tabelleDurchgaenge)
        .select(_selectQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return DurchgangModel.fromJson(response);
  }

  Future<DurchgangModel> erstellen(DurchgangModel model) async {
    final response = await _client
        .from(AppConstants.tabelleDurchgaenge)
        .insert(model.toJson())
        .select(_selectQuery)
        .single();

    return DurchgangModel.fromJson(response);
  }

  Future<DurchgangModel> aktualisieren(String id, DurchgangModel model) async {
    final response = await _client
        .from(AppConstants.tabelleDurchgaenge)
        .update(model.toJson())
        .eq('id', id)
        .select(_selectQuery)
        .single();

    return DurchgangModel.fromJson(response);
  }

  Future<void> loeschen(String id) async {
    await _client
        .from(AppConstants.tabelleDurchgaenge)
        .delete()
        .eq('id', id);
  }
}
