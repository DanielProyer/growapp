import '../../domain/entities/tages_log.dart';

/// TagesLog Model - JSON Serialisierung für Supabase
class TagesLogModel extends TagesLog {
  const TagesLogModel({
    required super.id,
    required super.durchgangId,
    required super.datum,
    super.vegiTag,
    super.blueteTag,
    super.tempTag,
    super.tempNacht,
    super.relfTag,
    super.relfNacht,
    super.lichtWatt,
    super.lampenHoehe,
    super.pflanzenHoehe,
    super.wasserMl,
    super.ph,
    super.ec,
    super.tankFuellstand,
    super.tankTemp,
    super.naehrstoffe,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
    super.durchgangTitel,
    super.sorteName,
  });

  factory TagesLogModel.fromJson(Map<String, dynamic> json) {
    // Verknüpfte Daten aus Join
    final durchgangData = json['durchgaenge'] as Map<String, dynamic>?;
    final sorteData = durchgangData?['sorten'] as Map<String, dynamic>?;

    // Nährstoffe JSONB parsen
    Map<String, double>? naehrstoffe;
    if (json['naehrstoffe'] != null) {
      final raw = json['naehrstoffe'] as Map<String, dynamic>;
      naehrstoffe = raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    return TagesLogModel(
      id: json['id'] as String,
      durchgangId: json['durchgang_id'] as String,
      datum: DateTime.parse(json['datum'] as String),
      vegiTag: (json['vegi_tag'] as num?)?.toInt(),
      blueteTag: (json['bluete_tag'] as num?)?.toInt(),
      tempTag: (json['temp_tag'] as num?)?.toDouble(),
      tempNacht: (json['temp_nacht'] as num?)?.toDouble(),
      relfTag: (json['relf_tag'] as num?)?.toDouble(),
      relfNacht: (json['relf_nacht'] as num?)?.toDouble(),
      lichtWatt: (json['licht_watt'] as num?)?.toInt(),
      lampenHoehe: (json['lampen_hoehe'] as num?)?.toInt(),
      pflanzenHoehe: (json['pflanzen_hoehe'] as num?)?.toDouble(),
      wasserMl: (json['wasser_ml'] as num?)?.toInt(),
      ph: (json['ph'] as num?)?.toDouble(),
      ec: (json['ec'] as num?)?.toDouble(),
      tankFuellstand: (json['tank_fuellstand'] as num?)?.toInt(),
      tankTemp: (json['tank_temp'] as num?)?.toDouble(),
      naehrstoffe: naehrstoffe,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
      durchgangTitel: durchgangData != null
          ? '${sorteData?['name'] ?? 'Unbekannt'}'
          : null,
      sorteName: sorteData?['name'] as String?,
    );
  }

  factory TagesLogModel.fromEntity(TagesLog log) {
    return TagesLogModel(
      id: log.id,
      durchgangId: log.durchgangId,
      datum: log.datum,
      vegiTag: log.vegiTag,
      blueteTag: log.blueteTag,
      tempTag: log.tempTag,
      tempNacht: log.tempNacht,
      relfTag: log.relfTag,
      relfNacht: log.relfNacht,
      lichtWatt: log.lichtWatt,
      lampenHoehe: log.lampenHoehe,
      pflanzenHoehe: log.pflanzenHoehe,
      wasserMl: log.wasserMl,
      ph: log.ph,
      ec: log.ec,
      tankFuellstand: log.tankFuellstand,
      tankTemp: log.tankTemp,
      naehrstoffe: log.naehrstoffe,
      bemerkung: log.bemerkung,
      erstelltVon: log.erstelltVon,
      erstelltAm: log.erstelltAm,
      aktualisiertAm: log.aktualisiertAm,
      durchgangTitel: log.durchgangTitel,
      sorteName: log.sorteName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durchgang_id': durchgangId,
      'datum': datum.toIso8601String().split('T').first,
      'vegi_tag': vegiTag,
      'bluete_tag': blueteTag,
      'temp_tag': tempTag,
      'temp_nacht': tempNacht,
      'relf_tag': relfTag,
      'relf_nacht': relfNacht,
      'licht_watt': lichtWatt,
      'lampen_hoehe': lampenHoehe,
      'pflanzen_hoehe': pflanzenHoehe,
      'wasser_ml': wasserMl,
      'ph': ph,
      'ec': ec,
      'tank_fuellstand': tankFuellstand,
      'tank_temp': tankTemp,
      'naehrstoffe': naehrstoffe,
      'bemerkung': bemerkung,
    };
  }
}
