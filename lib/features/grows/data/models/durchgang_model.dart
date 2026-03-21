import '../../domain/entities/durchgang.dart';

/// Durchgang Model - JSON Serialisierung für Supabase
class DurchgangModel extends Durchgang {
  const DurchgangModel({
    required super.id,
    super.sorteId,
    super.status,
    super.pflanzenAnzahl,
    super.stecklingAnbauflaecheId,
    super.vegiAnbauflaecheId,
    super.blueteAnbauflaecheId,
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
    super.stecklingAnbauflaecheName,
    super.stecklingZeltName,
    super.vegiAnbauflaecheName,
    super.vegiZeltName,
    super.blueteAnbauflaecheName,
    super.blueteZeltName,
  });

  factory DurchgangModel.fromJson(Map<String, dynamic> json) {
    // Verknüpfte Daten aus Joins
    final sorteData = json['sorten'] as Map<String, dynamic>?;

    // Drei separate Anbauflächen-Joins (mit Alias)
    final stecklingAf = json['steckling_af'] as Map<String, dynamic>?;
    final stecklingZelt = stecklingAf?['zelte'] as Map<String, dynamic>?;

    final vegiAf = json['vegi_af'] as Map<String, dynamic>?;
    final vegiZelt = vegiAf?['zelte'] as Map<String, dynamic>?;

    final blueteAf = json['bluete_af'] as Map<String, dynamic>?;
    final blueteZelt = blueteAf?['zelte'] as Map<String, dynamic>?;

    return DurchgangModel(
      id: json['id'] as String,
      sorteId: json['sorte_id'] as String?,
      status: json['status'] as String? ?? 'vorbereitung',
      pflanzenAnzahl: (json['pflanzen_anzahl'] as num?)?.toInt(),
      stecklingAnbauflaecheId: json['steckling_anbauflaeche_id'] as String?,
      vegiAnbauflaecheId: json['vegi_anbauflaeche_id'] as String?,
      blueteAnbauflaecheId: json['bluete_anbauflaeche_id'] as String?,
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
      stecklingAnbauflaecheName: stecklingAf?['name'] as String?,
      stecklingZeltName: stecklingZelt?['name'] as String?,
      vegiAnbauflaecheName: vegiAf?['name'] as String?,
      vegiZeltName: vegiZelt?['name'] as String?,
      blueteAnbauflaecheName: blueteAf?['name'] as String?,
      blueteZeltName: blueteZelt?['name'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  factory DurchgangModel.fromEntity(Durchgang d) {
    return DurchgangModel(
      id: d.id,
      sorteId: d.sorteId,
      status: d.status,
      pflanzenAnzahl: d.pflanzenAnzahl,
      stecklingAnbauflaecheId: d.stecklingAnbauflaecheId,
      vegiAnbauflaecheId: d.vegiAnbauflaecheId,
      blueteAnbauflaecheId: d.blueteAnbauflaecheId,
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
      stecklingAnbauflaecheName: d.stecklingAnbauflaecheName,
      stecklingZeltName: d.stecklingZeltName,
      vegiAnbauflaecheName: d.vegiAnbauflaecheName,
      vegiZeltName: d.vegiZeltName,
      blueteAnbauflaecheName: d.blueteAnbauflaecheName,
      blueteZeltName: d.blueteZeltName,
    );
  }

  static String? _dateToString(DateTime? d) =>
      d?.toIso8601String().split('T').first;

  Map<String, dynamic> toJson() {
    return {
      'sorte_id': sorteId,
      'status': status,
      'pflanzen_anzahl': pflanzenAnzahl,
      'steckling_anbauflaeche_id': stecklingAnbauflaecheId,
      'vegi_anbauflaeche_id': vegiAnbauflaecheId,
      'bluete_anbauflaeche_id': blueteAnbauflaecheId,
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
