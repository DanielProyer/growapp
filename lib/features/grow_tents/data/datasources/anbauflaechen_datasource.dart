import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/anbauflaeche_model.dart';

/// Supabase Datasource für Anbauflächen
class AnbauflaechenDatasource {
  final SupabaseClient _client;
  static const _tabelle = 'anbauflaechen';

  AnbauflaechenDatasource(this._client);

  Future<List<AnbauflaecheModel>> fuerZeltLaden(String zeltId) async {
    final response = await _client
        .from(_tabelle)
        .select()
        .eq('zelt_id', zeltId)
        .order('etage', nullsFirst: false)
        .order('name');

    return (response as List)
        .map((json) => AnbauflaecheModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AnbauflaecheModel?> laden(String id) async {
    final response = await _client
        .from(_tabelle)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return AnbauflaecheModel.fromJson(response);
  }

  Future<AnbauflaecheModel> erstellen(AnbauflaecheModel model) async {
    final response = await _client
        .from(_tabelle)
        .insert(model.toJson())
        .select()
        .single();

    return AnbauflaecheModel.fromJson(response);
  }

  Future<AnbauflaecheModel> aktualisieren(String id, AnbauflaecheModel model) async {
    final response = await _client
        .from(_tabelle)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return AnbauflaecheModel.fromJson(response);
  }

  Future<void> loeschen(String id) async {
    await _client
        .from(_tabelle)
        .delete()
        .eq('id', id);
  }
}
