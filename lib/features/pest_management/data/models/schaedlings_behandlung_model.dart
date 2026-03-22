import '../../domain/entities/schaedlings_behandlung.dart';

/// SchaedlingsBehandlung Model - JSON Serialisierung für Supabase
class SchaedlingsBehandlungModel extends SchaedlingsBehandlung {
  const SchaedlingsBehandlungModel({
    required super.id,
    super.vorfallId,
    required super.zeltId,
    required super.behandlungTyp,
    required super.mittel,
    super.menge,
    required super.datum,
    super.wirksamkeit,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
    super.zeltName,
  });

  factory SchaedlingsBehandlungModel.fromJson(Map<String, dynamic> json) {
    // Zeltname aus Join
    final zeltData = json['zelte'];
    final zeltName =
        zeltData is Map<String, dynamic> ? zeltData['name'] as String? : null;

    return SchaedlingsBehandlungModel(
      id: json['id'] as String,
      vorfallId: json['vorfall_id'] as String?,
      zeltId: json['zelt_id'] as String,
      behandlungTyp: json['behandlung_typ'] as String,
      mittel: json['mittel'] as String,
      menge: json['menge'] as String?,
      datum: DateTime.parse(json['datum'] as String),
      wirksamkeit: json['wirksamkeit'] as String?,
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

  factory SchaedlingsBehandlungModel.fromEntity(SchaedlingsBehandlung b) {
    return SchaedlingsBehandlungModel(
      id: b.id,
      vorfallId: b.vorfallId,
      zeltId: b.zeltId,
      behandlungTyp: b.behandlungTyp,
      mittel: b.mittel,
      menge: b.menge,
      datum: b.datum,
      wirksamkeit: b.wirksamkeit,
      bemerkung: b.bemerkung,
      erstelltVon: b.erstelltVon,
      erstelltAm: b.erstelltAm,
      aktualisiertAm: b.aktualisiertAm,
      zeltName: b.zeltName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vorfall_id': vorfallId,
      'zelt_id': zeltId,
      'behandlung_typ': behandlungTyp,
      'mittel': mittel,
      'menge': menge,
      'datum': datum.toIso8601String().split('T').first,
      'wirksamkeit': wirksamkeit,
      'bemerkung': bemerkung,
    };
  }
}
