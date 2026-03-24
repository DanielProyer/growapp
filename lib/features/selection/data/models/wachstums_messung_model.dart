import '../../domain/entities/wachstums_messung.dart';

/// WachstumsMessung Model - JSON Serialisierung für Supabase
class WachstumsMessungModel extends WachstumsMessung {
  const WachstumsMessungModel({
    required super.id,
    required super.pflanzeId,
    required super.datum,
    super.hoeheCm,
    super.nodienAnzahl,
    super.stammdicke,
    super.getoppt,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
  });

  factory WachstumsMessungModel.fromJson(Map<String, dynamic> json) {
    return WachstumsMessungModel(
      id: json['id'] as String,
      pflanzeId: json['pflanze_id'] as String,
      datum: DateTime.parse(json['datum'] as String),
      hoeheCm: (json['hoehe_cm'] as num?)?.toDouble(),
      nodienAnzahl: json['nodien_anzahl'] as int?,
      stammdicke: (json['stammdicke'] as num?)?.toDouble(),
      getoppt: json['getoppt'] as bool? ?? false,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
    );
  }

  factory WachstumsMessungModel.fromEntity(WachstumsMessung m) {
    return WachstumsMessungModel(
      id: m.id,
      pflanzeId: m.pflanzeId,
      datum: m.datum,
      hoeheCm: m.hoeheCm,
      nodienAnzahl: m.nodienAnzahl,
      stammdicke: m.stammdicke,
      getoppt: m.getoppt,
      bemerkung: m.bemerkung,
      erstelltVon: m.erstelltVon,
      erstelltAm: m.erstelltAm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pflanze_id': pflanzeId,
      'datum': datum.toIso8601String().split('T').first,
      'hoehe_cm': hoeheCm,
      'nodien_anzahl': nodienAnzahl,
      'stammdicke': stammdicke,
      'getoppt': getoppt,
      'bemerkung': bemerkung,
    };
  }
}
