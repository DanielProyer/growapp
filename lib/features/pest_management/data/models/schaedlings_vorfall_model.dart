import '../../domain/entities/schaedlings_vorfall.dart';

/// SchaedlingsVorfall Model - JSON Serialisierung für Supabase
class SchaedlingsVorfallModel extends SchaedlingsVorfall {
  const SchaedlingsVorfallModel({
    required super.id,
    super.zeltId,
    super.durchgangId,
    required super.schaedlingTyp,
    super.schweregrad,
    required super.erkanntDatum,
    super.behobenDatum,
    super.behandlung,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
    super.zeltName,
  });

  factory SchaedlingsVorfallModel.fromJson(Map<String, dynamic> json) {
    // Zeltname aus Join
    final zeltData = json['zelte'];
    final zeltName =
        zeltData is Map<String, dynamic> ? zeltData['name'] as String? : null;

    return SchaedlingsVorfallModel(
      id: json['id'] as String,
      zeltId: json['zelt_id'] as String?,
      durchgangId: json['durchgang_id'] as String?,
      schaedlingTyp: json['schaedling_typ'] as String,
      schweregrad: json['schweregrad'] as String? ?? 'niedrig',
      erkanntDatum: DateTime.parse(json['erkannt_datum'] as String),
      behobenDatum: _parseDate(json['behoben_datum']),
      behandlung: json['behandlung'] as String?,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
      zeltName: zeltName,
    );
  }

  factory SchaedlingsVorfallModel.fromEntity(SchaedlingsVorfall v) {
    return SchaedlingsVorfallModel(
      id: v.id,
      zeltId: v.zeltId,
      durchgangId: v.durchgangId,
      schaedlingTyp: v.schaedlingTyp,
      schweregrad: v.schweregrad,
      erkanntDatum: v.erkanntDatum,
      behobenDatum: v.behobenDatum,
      behandlung: v.behandlung,
      bemerkung: v.bemerkung,
      erstelltVon: v.erstelltVon,
      erstelltAm: v.erstelltAm,
      aktualisiertAm: v.aktualisiertAm,
      zeltName: v.zeltName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zelt_id': zeltId,
      'durchgang_id': durchgangId,
      'schaedling_typ': schaedlingTyp,
      'schweregrad': schweregrad,
      'erkannt_datum': erkanntDatum.toIso8601String().split('T').first,
      'behoben_datum': behobenDatum?.toIso8601String().split('T').first,
      'behandlung': behandlung,
      'bemerkung': bemerkung,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
