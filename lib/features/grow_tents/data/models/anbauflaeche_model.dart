import '../../domain/entities/anbauflaeche.dart';

/// Anbaufläche Model - JSON Serialisierung für Supabase
class AnbauflaecheModel extends Anbauflaeche {
  const AnbauflaecheModel({
    required super.id,
    required super.zeltId,
    required super.name,
    super.lichtTyp,
    super.lichtWatt,
    super.lueftung,
    super.bewaesserung,
    super.etage,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
  });

  factory AnbauflaecheModel.fromJson(Map<String, dynamic> json) {
    return AnbauflaecheModel(
      id: json['id'] as String,
      zeltId: json['zelt_id'] as String,
      name: json['name'] as String,
      lichtTyp: json['licht_typ'] as String?,
      lichtWatt: (json['licht_watt'] as num?)?.toInt(),
      lueftung: json['lueftung'] as String?,
      bewaesserung: json['bewaesserung'] as String?,
      etage: (json['etage'] as num?)?.toInt(),
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

  factory AnbauflaecheModel.fromEntity(Anbauflaeche a) {
    return AnbauflaecheModel(
      id: a.id,
      zeltId: a.zeltId,
      name: a.name,
      lichtTyp: a.lichtTyp,
      lichtWatt: a.lichtWatt,
      lueftung: a.lueftung,
      bewaesserung: a.bewaesserung,
      etage: a.etage,
      bemerkung: a.bemerkung,
      erstelltVon: a.erstelltVon,
      erstelltAm: a.erstelltAm,
      aktualisiertAm: a.aktualisiertAm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zelt_id': zeltId,
      'name': name,
      'licht_typ': lichtTyp,
      'licht_watt': lichtWatt,
      'lueftung': lueftung,
      'bewaesserung': bewaesserung,
      'etage': etage,
      'bemerkung': bemerkung,
    };
  }
}
