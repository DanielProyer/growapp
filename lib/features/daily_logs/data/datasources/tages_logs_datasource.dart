import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/tages_log_model.dart';

/// Supabase Datasource für Tages-Logs
class TagesLogsDatasource {
  final SupabaseClient _client;

  TagesLogsDatasource(this._client);

  /// Select mit Join auf Durchgang → Sorte
  static const _selectQuery =
      '*, durchgaenge(id, sorte_id, status, steckling_datum, vegi_start, bluete_start, sorten(name))';

  /// Alle Logs für einen Durchgang (neueste zuerst)
  Future<List<TagesLogModel>> fuerDurchgangLaden(String durchgangId) async {
    final response = await _client
        .from(AppConstants.tabelleTagesLogs)
        .select(_selectQuery)
        .eq('durchgang_id', durchgangId)
        .order('datum', ascending: false);

    return (response as List)
        .map((json) => TagesLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Einzelnen Log laden
  Future<TagesLogModel?> laden(String id) async {
    final response = await _client
        .from(AppConstants.tabelleTagesLogs)
        .select(_selectQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return TagesLogModel.fromJson(response);
  }

  /// Neuen Log erstellen
  Future<TagesLogModel> erstellen(TagesLogModel model) async {
    final response = await _client
        .from(AppConstants.tabelleTagesLogs)
        .insert(model.toJson())
        .select(_selectQuery)
        .single();

    return TagesLogModel.fromJson(response);
  }

  /// Log aktualisieren
  Future<TagesLogModel> aktualisieren(String id, TagesLogModel model) async {
    final response = await _client
        .from(AppConstants.tabelleTagesLogs)
        .update(model.toJson())
        .eq('id', id)
        .select(_selectQuery)
        .single();

    return TagesLogModel.fromJson(response);
  }

  /// Log löschen
  Future<void> loeschen(String id) async {
    await _client
        .from(AppConstants.tabelleTagesLogs)
        .delete()
        .eq('id', id);
  }
}
