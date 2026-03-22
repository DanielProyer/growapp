import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/foto_model.dart';

/// Supabase Datasource für Fotos (DB + Storage)
class FotosDatasource {
  final SupabaseClient _client;

  FotosDatasource(this._client);

  static const _bucket = 'fotos';

  /// Fotos für eine Pflanze laden (chronologisch, älteste zuerst)
  Future<List<FotoModel>> fuerPflanzeLaden(String pflanzeId) async {
    final response = await _client
        .from(AppConstants.tabelleFotos)
        .select()
        .eq('pflanze_id', pflanzeId)
        .order('aufgenommen_am', ascending: true);

    final fotos = (response as List)
        .map((json) => FotoModel.fromJson(json as Map<String, dynamic>))
        .toList();

    if (fotos.isEmpty) return fotos;

    // Signed URLs im Batch generieren
    final pfade = fotos.map((f) => f.speicherPfad).toList();
    final urls = await _client.storage
        .from(_bucket)
        .createSignedUrls(pfade, 3600);

    return List.generate(fotos.length, (i) {
      final url = urls[i].signedUrl;
      return FotoModel.fromJson(
        {
          'id': fotos[i].id,
          'speicher_pfad': fotos[i].speicherPfad,
          'vorschau_pfad': fotos[i].vorschauPfad,
          'beschreibung': fotos[i].beschreibung,
          'kategorie': fotos[i].kategorie,
          'pflanze_id': fotos[i].pflanzeId,
          'durchgang_id': fotos[i].durchgangId,
          'zelt_id': fotos[i].zeltId,
          'inventar_id': fotos[i].inventarId,
          'vorfall_id': fotos[i].vorfallId,
          'aufgenommen_am': fotos[i].aufgenommenAm?.toIso8601String(),
          'erstellt_von': fotos[i].erstelltVon,
          'erstellt_am': fotos[i].erstelltAm.toIso8601String(),
        },
        bilderUrl: url,
      );
    });
  }

  /// Foto hochladen (Storage + DB-Eintrag)
  Future<FotoModel> hochladen({
    required Uint8List bytes,
    required String dateiName,
    required String pflanzeId,
    String? kategorie,
    String? beschreibung,
    DateTime? aufgenommenAm,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final pfad = '$userId/$pflanzeId/$dateiName';

    // In Storage hochladen
    await _client.storage.from(_bucket).uploadBinary(
      pfad,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );

    // DB-Eintrag erstellen
    final response = await _client
        .from(AppConstants.tabelleFotos)
        .insert({
          'speicher_pfad': pfad,
          'pflanze_id': pflanzeId,
          'kategorie': kategorie,
          'beschreibung': beschreibung,
          'aufgenommen_am': (aufgenommenAm ?? DateTime.now()).toIso8601String(),
        })
        .select()
        .single();

    // Signed URL für sofortige Anzeige
    final signedUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(pfad, 3600);

    return FotoModel.fromJson(response, bilderUrl: signedUrl);
  }

  /// Fotos für ein Inventar-Item laden (chronologisch, älteste zuerst)
  Future<List<FotoModel>> fuerInventarItemLaden(String inventarId) async {
    final response = await _client
        .from(AppConstants.tabelleFotos)
        .select()
        .eq('inventar_id', inventarId)
        .order('aufgenommen_am', ascending: true);

    final fotos = (response as List)
        .map((json) => FotoModel.fromJson(json as Map<String, dynamic>))
        .toList();

    if (fotos.isEmpty) return fotos;

    final pfade = fotos.map((f) => f.speicherPfad).toList();
    final urls = await _client.storage
        .from(_bucket)
        .createSignedUrls(pfade, 3600);

    return List.generate(fotos.length, (i) {
      final url = urls[i].signedUrl;
      return FotoModel.fromJson(
        {
          'id': fotos[i].id,
          'speicher_pfad': fotos[i].speicherPfad,
          'vorschau_pfad': fotos[i].vorschauPfad,
          'beschreibung': fotos[i].beschreibung,
          'kategorie': fotos[i].kategorie,
          'pflanze_id': fotos[i].pflanzeId,
          'durchgang_id': fotos[i].durchgangId,
          'zelt_id': fotos[i].zeltId,
          'inventar_id': fotos[i].inventarId,
          'vorfall_id': fotos[i].vorfallId,
          'aufgenommen_am': fotos[i].aufgenommenAm?.toIso8601String(),
          'erstellt_von': fotos[i].erstelltVon,
          'erstellt_am': fotos[i].erstelltAm.toIso8601String(),
        },
        bilderUrl: url,
      );
    });
  }

  /// Foto hochladen für Inventar-Artikel (Storage + DB-Eintrag)
  Future<FotoModel> hochladenFuerInventar({
    required Uint8List bytes,
    required String dateiName,
    required String inventarId,
    String? beschreibung,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final pfad = '$userId/inventar/$inventarId/$dateiName';

    await _client.storage.from(_bucket).uploadBinary(
      pfad,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );

    final response = await _client
        .from(AppConstants.tabelleFotos)
        .insert({
          'speicher_pfad': pfad,
          'inventar_id': inventarId,
          'beschreibung': beschreibung,
          'aufgenommen_am': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final signedUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(pfad, 3600);

    return FotoModel.fromJson(response, bilderUrl: signedUrl);
  }

  /// Fotos für einen Schädlingsvorfall laden (chronologisch, älteste zuerst)
  Future<List<FotoModel>> fuerVorfallLaden(String vorfallId) async {
    final response = await _client
        .from(AppConstants.tabelleFotos)
        .select()
        .eq('vorfall_id', vorfallId)
        .order('aufgenommen_am', ascending: true);

    final fotos = (response as List)
        .map((json) => FotoModel.fromJson(json as Map<String, dynamic>))
        .toList();

    if (fotos.isEmpty) return fotos;

    final pfade = fotos.map((f) => f.speicherPfad).toList();
    final urls = await _client.storage
        .from(_bucket)
        .createSignedUrls(pfade, 3600);

    return List.generate(fotos.length, (i) {
      final url = urls[i].signedUrl;
      return FotoModel.fromJson(
        {
          'id': fotos[i].id,
          'speicher_pfad': fotos[i].speicherPfad,
          'vorschau_pfad': fotos[i].vorschauPfad,
          'beschreibung': fotos[i].beschreibung,
          'kategorie': fotos[i].kategorie,
          'pflanze_id': fotos[i].pflanzeId,
          'durchgang_id': fotos[i].durchgangId,
          'zelt_id': fotos[i].zeltId,
          'inventar_id': fotos[i].inventarId,
          'vorfall_id': fotos[i].vorfallId,
          'aufgenommen_am': fotos[i].aufgenommenAm?.toIso8601String(),
          'erstellt_von': fotos[i].erstelltVon,
          'erstellt_am': fotos[i].erstelltAm.toIso8601String(),
        },
        bilderUrl: url,
      );
    });
  }

  /// Foto hochladen für Schädlingsvorfall (Storage + DB-Eintrag)
  Future<FotoModel> hochladenFuerVorfall({
    required Uint8List bytes,
    required String dateiName,
    required String vorfallId,
    String? beschreibung,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final pfad = '$userId/schaedlinge/$vorfallId/$dateiName';

    await _client.storage.from(_bucket).uploadBinary(
      pfad,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );

    final response = await _client
        .from(AppConstants.tabelleFotos)
        .insert({
          'speicher_pfad': pfad,
          'vorfall_id': vorfallId,
          'beschreibung': beschreibung,
          'aufgenommen_am': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final signedUrl = await _client.storage
        .from(_bucket)
        .createSignedUrl(pfad, 3600);

    return FotoModel.fromJson(response, bilderUrl: signedUrl);
  }

  /// Foto löschen (Storage + DB)
  Future<void> loeschen(String id, String speicherPfad) async {
    // Erst aus Storage löschen
    await _client.storage.from(_bucket).remove([speicherPfad]);

    // Dann DB-Eintrag löschen
    await _client
        .from(AppConstants.tabelleFotos)
        .delete()
        .eq('id', id);
  }
}
