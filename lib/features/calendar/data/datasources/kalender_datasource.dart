import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/kalender_eintrag_model.dart';

/// Supabase Datasource für Kalender-Einträge
class KalenderDatasource {
  final SupabaseClient _client;

  KalenderDatasource(this._client);

  /// Alle Einträge laden (sortiert nach geplant_am)
  Future<List<KalenderEintragModel>> alleLaden() async {
    final response = await _client
        .from(AppConstants.tabelleKalenderEintraege)
        .select()
        .order('geplant_am');

    return (response as List)
        .map((json) =>
            KalenderEintragModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Einträge für einen bestimmten Monat laden
  Future<List<KalenderEintragModel>> fuerMonatLaden(
      int jahr, int monat) async {
    final start = DateTime(jahr, monat, 1);
    final end = DateTime(jahr, monat + 1, 1);

    final response = await _client
        .from(AppConstants.tabelleKalenderEintraege)
        .select()
        .gte('geplant_am', start.toIso8601String())
        .lt('geplant_am', end.toIso8601String())
        .order('geplant_am');

    return (response as List)
        .map((json) =>
            KalenderEintragModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Anstehende unerledigte Einträge laden (ab jetzt, limitiert)
  Future<List<KalenderEintragModel>> anstehendeLaden({int limit = 5}) async {
    final response = await _client
        .from(AppConstants.tabelleKalenderEintraege)
        .select()
        .eq('erledigt', false)
        .gte('geplant_am', DateTime.now().toIso8601String())
        .order('geplant_am')
        .limit(limit);

    return (response as List)
        .map((json) =>
            KalenderEintragModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Eintrag erstellen
  Future<KalenderEintragModel> erstellen(KalenderEintragModel model) async {
    final response = await _client
        .from(AppConstants.tabelleKalenderEintraege)
        .insert(model.toJson())
        .select()
        .single();

    return KalenderEintragModel.fromJson(response);
  }

  /// Eintrag aktualisieren
  Future<KalenderEintragModel> aktualisieren(
      String id, KalenderEintragModel model) async {
    final response = await _client
        .from(AppConstants.tabelleKalenderEintraege)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return KalenderEintragModel.fromJson(response);
  }

  /// Erledigt-Status toggeln
  Future<void> erledigtSetzen(String id, bool erledigt) async {
    await _client
        .from(AppConstants.tabelleKalenderEintraege)
        .update({'erledigt': erledigt})
        .eq('id', id);
  }

  /// Eintrag löschen
  Future<void> loeschen(String id) async {
    await _client
        .from(AppConstants.tabelleKalenderEintraege)
        .delete()
        .eq('id', id);
  }
}
