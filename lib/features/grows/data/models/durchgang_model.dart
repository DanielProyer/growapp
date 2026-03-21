import '../../domain/entities/durchgang.dart';

/// Durchgang Model - JSON Serialisierung für Supabase
class DurchgangModel extends Durchgang {
  const DurchgangModel({
    required super.id,
    super.anbauflaecheId,
    super.sorteId,
    super.status,
    super.pflanzenAnzahl,
    super.stecklingDatum,
    super.vegiStart,
    super.blueteStart,
    super.ernteDatum,
    super.einglasDatum,
    super.ernteMethode,
    super.trockenErtragG,
    super.trimG,
    super.ertragProWatt,
    super.siebung1,
    super.siebung2,
    super.siebung3,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
    super.sorteName,
    super.anbauflaecheName,
    super.zeltName,
  });

  factory DurchgangModel.fromJson(Map<String, dynamic> json) {
    // Verknüpfte Daten aus Join
    final sorteData = json['sorten'] as Map<String, dynamic>?;
    final flaecheData = json['anbauflaechen'] as Map<String, dynamic>?;
    final zeltData = flaecheData?['zelte'] as Map<String, dynamic>?;

    return DurchgangModel(
      id: json['id'] as String,
      anbauflaecheId: json['anbauflaeche_id'] as String?,
      sorteId: json['sorte_id'] as String?,
      status: json['status'] as String? ?? 'vorbereitung',
      pflanzenAnzahl: (json['pflanzen_anzahl'] as num?)?.toInt(),
      stecklingDatum: _parseDate(json['steckling_datum']),
      vegiStart: _parseDate(json['vegi_start']),
      blueteStart: _parseDate(json['bluete_start']),
      ernteDatum: _parseDate(json['ernte_datum']),
      einglasDatum: _parseDate(json['einglas_datum']),
      ernteMethode: json['ernte_methode'] as String?,
      trockenErtragG: (json['trocken_ertrag_g'] as num?)?.toDouble(),
      trimG: (json['trim_g'] as num?)?.toDouble(),
      ertragProWatt: (json['ertrag_pro_watt'] as num?)?.toDouble(),
      siebung1: (json['siebung_1'] as num?)?.toDouble(),
      siebung2: (json['siebung_2'] as num?)?.toDouble(),
      siebung3: (json['siebung_3'] as num?)?.toDouble(),
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
      sorteName: sorteData?['name'] as String?,
      anbauflaecheName: flaecheData?['name'] as String?,
      zeltName: zeltData?['name'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  factory DurchgangModel.fromEntity(Durchgang d) {
    return DurchgangModel(
      id: d.id,
      anbauflaecheId: d.anbauflaecheId,
      sorteId: d.sorteId,
      status: d.status,
      pflanzenAnzahl: d.pflanzenAnzahl,
      stecklingDatum: d.stecklingDatum,
      vegiStart: d.vegiStart,
      blueteStart: d.blueteStart,
      ernteDatum: d.ernteDatum,
      einglasDatum: d.einglasDatum,
      ernteMethode: d.ernteMethode,
      trockenErtragG: d.trockenErtragG,
      trimG: d.trimG,
      ertragProWatt: d.ertragProWatt,
      siebung1: d.siebung1,
      siebung2: d.siebung2,
      siebung3: d.siebung3,
      bemerkung: d.bemerkung,
      erstelltVon: d.erstelltVon,
      erstelltAm: d.erstelltAm,
      aktualisiertAm: d.aktualisiertAm,
      sorteName: d.sorteName,
      anbauflaecheName: d.anbauflaecheName,
      zeltName: d.zeltName,
    );
  }

  static String? _dateToString(DateTime? d) => d?.toIso8601String().split('T').first;

  Map<String, dynamic> toJson() {
    return {
      'anbauflaeche_id': anbauflaecheId,
      'sorte_id': sorteId,
      'status': status,
      'pflanzen_anzahl': pflanzenAnzahl,
      'steckling_datum': _dateToString(stecklingDatum),
      'vegi_start': _dateToString(vegiStart),
      'bluete_start': _dateToString(blueteStart),
      'ernte_datum': _dateToString(ernteDatum),
      'einglas_datum': _dateToString(einglasDatum),
      'ernte_methode': ernteMethode,
      'trocken_ertrag_g': trockenErtragG,
      'trim_g': trimG,
      'ertrag_pro_watt': ertragProWatt,
      'siebung_1': siebung1,
      'siebung_2': siebung2,
      'siebung_3': siebung3,
      'bemerkung': bemerkung,
    };
  }
}
