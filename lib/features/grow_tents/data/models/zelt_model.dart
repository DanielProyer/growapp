import '../../domain/entities/zelt.dart';

/// Zelt Model - JSON Serialisierung für Supabase
class ZeltModel extends Zelt {
  const ZeltModel({
    required super.id,
    required super.name,
    super.breiteCm,
    super.tiefeCm,
    super.hoeheCm,
    super.standort,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
  });

  factory ZeltModel.fromJson(Map<String, dynamic> json) {
    return ZeltModel(
      id: json['id'] as String,
      name: json['name'] as String,
      breiteCm: (json['breite_cm'] as num?)?.toDouble(),
      tiefeCm: (json['tiefe_cm'] as num?)?.toDouble(),
      hoeheCm: (json['hoehe_cm'] as num?)?.toDouble(),
      standort: json['standort'] as String?,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
    );
  }

  factory ZeltModel.fromEntity(Zelt zelt) {
    return ZeltModel(
      id: zelt.id,
      name: zelt.name,
      breiteCm: zelt.breiteCm,
      tiefeCm: zelt.tiefeCm,
      hoeheCm: zelt.hoeheCm,
      standort: zelt.standort,
      bemerkung: zelt.bemerkung,
      erstelltVon: zelt.erstelltVon,
      erstelltAm: zelt.erstelltAm,
      aktualisiertAm: zelt.aktualisiertAm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'breite_cm': breiteCm,
      'tiefe_cm': tiefeCm,
      'hoehe_cm': hoeheCm,
      'standort': standort,
      'bemerkung': bemerkung,
    };
  }
}
