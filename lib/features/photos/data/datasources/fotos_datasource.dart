import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/constants/app_constants.dart';
import '../models/foto_model.dart';

/// Supabase Datasource für Fotos (DB + Storage)
class FotosDatasource {
  final SupabaseClient _client;

  FotosDatasource(this._client);

  static const _bucket = 'fotos';

  /// Fotos für einen Durchgang laden (inkl. Signed URLs)
  Future<List<FotoModel>> fuerDurchgangLaden(String durchgangId) async {
    final response = await _client
        .from(AppConstants.tabelleFotos)
        .select()
        .eq('durchgang_id', durchgangId)
        .order('aufgenommen_am', ascending: false);

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
          'pflanze_id': fotos[i].pflanzeId,
          'durchgang_id': fotos[i].durchgangId,
          'zelt_id': fotos[i].zeltId,
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
    required String durchgangId,
    String? beschreibung,
    DateTime? aufgenommenAm,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final pfad = '$userId/$durchgangId/$dateiName';

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
          'durchgang_id': durchgangId,
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
