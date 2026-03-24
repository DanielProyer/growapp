import 'dart:convert';

import '../../domain/entities/curing_glas.dart';

/// Curing-Glas Model - JSON Serialisierung für Supabase
class CuringGlasModel extends CuringGlas {
  const CuringGlasModel({
    required super.id,
    required super.durchgangId,
    super.sorteId,
    required super.glasNr,
    super.trimMethode,
    super.status,
    super.schimmelErkannt,
    super.ernteDatum,
    super.einglasDatum,
    super.nassGewichtG,
    super.trockenGewichtG,
    super.endgewichtG,
    super.zielRlf,
    super.behaelterTyp,
    super.groesseMl,
    super.bovedaTyp,
    super.qualitaetNotizen,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.sorteName,
    super.messwerteAnzahl,
    super.letzteRlf,
  });

  factory CuringGlasModel.fromJson(Map<String, dynamic> json) {
    // Sortenname aus Join
    final sorteData = json['sorten'];
    final sorteName =
        sorteData is Map<String, dynamic> ? sorteData['name'] as String? : null;

    // Messwerte-Aggregation
    final messwertData = json['curing_messwerte'];
    int messwerteAnzahl = 0;
    int? letzteRlf;

    if (messwertData is List) {
      messwerteAnzahl = messwertData.length;
      // Letzter Messwert (nach Datum sortiert, letzter Eintrag)
      if (messwertData.isNotEmpty) {
        final letzter = messwertData.last;
        if (letzter is Map<String, dynamic>) {
          letzteRlf = letzter['rlf_prozent'] as int?;
        }
      }
    }

    // qualitaet_notizen als Map parsen
    Map<String, dynamic> qualitaetNotizen = {};
    final qn = json['qualitaet_notizen'];
    if (qn is Map<String, dynamic>) {
      qualitaetNotizen = qn;
    } else if (qn is String) {
      try {
        qualitaetNotizen =
            Map<String, dynamic>.from(jsonDecode(qn) as Map);
      } catch (_) {}
    }

    return CuringGlasModel(
      id: json['id'] as String,
      durchgangId: json['durchgang_id'] as String,
      sorteId: json['sorte_id'] as String?,
      glasNr: json['glas_nr'] as int,
      trimMethode: json['trim_methode'] as String?,
      status: json['status'] as String? ?? 'trocknung',
      schimmelErkannt: json['schimmel_erkannt'] as bool? ?? false,
      ernteDatum: _parseDate(json['ernte_datum']),
      einglasDatum: _parseDate(json['einglas_datum']),
      nassGewichtG: _parseDouble(json['nass_gewicht_g']),
      trockenGewichtG: _parseDouble(json['trocken_gewicht_g']),
      endgewichtG: _parseDouble(json['endgewicht_g']),
      zielRlf: json['ziel_rlf'] as int?,
      behaelterTyp: json['behaelter_typ'] as String?,
      groesseMl: json['groesse_ml'] as int?,
      bovedaTyp: json['boveda_typ'] as String?,
      qualitaetNotizen: qualitaetNotizen,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      sorteName: sorteName,
      messwerteAnzahl: messwerteAnzahl,
      letzteRlf: letzteRlf,
    );
  }

  factory CuringGlasModel.fromEntity(CuringGlas g) {
    return CuringGlasModel(
      id: g.id,
      durchgangId: g.durchgangId,
      sorteId: g.sorteId,
      glasNr: g.glasNr,
      trimMethode: g.trimMethode,
      status: g.status,
      schimmelErkannt: g.schimmelErkannt,
      ernteDatum: g.ernteDatum,
      einglasDatum: g.einglasDatum,
      nassGewichtG: g.nassGewichtG,
      trockenGewichtG: g.trockenGewichtG,
      endgewichtG: g.endgewichtG,
      zielRlf: g.zielRlf,
      behaelterTyp: g.behaelterTyp,
      groesseMl: g.groesseMl,
      bovedaTyp: g.bovedaTyp,
      qualitaetNotizen: g.qualitaetNotizen,
      bemerkung: g.bemerkung,
      erstelltVon: g.erstelltVon,
      erstelltAm: g.erstelltAm,
      sorteName: g.sorteName,
      messwerteAnzahl: g.messwerteAnzahl,
      letzteRlf: g.letzteRlf,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durchgang_id': durchgangId,
      'sorte_id': sorteId,
      'glas_nr': glasNr,
      'trim_methode': trimMethode,
      'status': status,
      'schimmel_erkannt': schimmelErkannt,
      'ernte_datum': ernteDatum?.toIso8601String().split('T').first,
      'einglas_datum': einglasDatum?.toIso8601String().split('T').first,
      'nass_gewicht_g': nassGewichtG,
      'trocken_gewicht_g': trockenGewichtG,
      'endgewicht_g': endgewichtG,
      'ziel_rlf': zielRlf,
      'behaelter_typ': behaelterTyp,
      'groesse_ml': groesseMl,
      'boveda_typ': bovedaTyp,
      'qualitaet_notizen': qualitaetNotizen,
      'bemerkung': bemerkung,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
