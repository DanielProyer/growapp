import '../../domain/entities/foto.dart';

/// Foto Model - JSON Serialisierung für Supabase
class FotoModel extends Foto {
  const FotoModel({
    required super.id,
    required super.speicherPfad,
    super.vorschauPfad,
    super.beschreibung,
    super.kategorie,
    super.pflanzeId,
    super.durchgangId,
    super.zeltId,
    super.inventarId,
    super.aufgenommenAm,
    required super.erstelltVon,
    required super.erstelltAm,
    super.bilderUrl,
  });

  factory FotoModel.fromJson(Map<String, dynamic> json, {String? bilderUrl}) {
    return FotoModel(
      id: json['id'] as String,
      speicherPfad: json['speicher_pfad'] as String,
      vorschauPfad: json['vorschau_pfad'] as String?,
      beschreibung: json['beschreibung'] as String?,
      kategorie: json['kategorie'] as String?,
      pflanzeId: json['pflanze_id'] as String?,
      durchgangId: json['durchgang_id'] as String?,
      zeltId: json['zelt_id'] as String?,
      inventarId: json['inventar_id'] as String?,
      aufgenommenAm: _parseDateTime(json['aufgenommen_am']),
      erstelltVon: json['erstellt_von'] as String,
      erstelltAm: DateTime.parse(json['erstellt_am'] as String),
      bilderUrl: bilderUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speicher_pfad': speicherPfad,
      'vorschau_pfad': vorschauPfad,
      'beschreibung': beschreibung,
      'kategorie': kategorie,
      'pflanze_id': pflanzeId,
      'durchgang_id': durchgangId,
      'zelt_id': zeltId,
      'inventar_id': inventarId,
      'aufgenommen_am': aufgenommenAm?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
