import '../../domain/entities/selektion.dart';

/// Selektion Model - JSON Serialisierung für Supabase
class SelektionModel extends Selektion {
  const SelektionModel({
    required super.id,
    required super.sorteId,
    super.durchgangId,
    required super.name,
    super.status,
    super.startDatum,
    super.samenAnzahl,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
    super.sorteName,
    super.pflanzenAnzahl,
    super.keeperAnzahl,
    super.durchschnittBewertung,
  });

  factory SelektionModel.fromJson(Map<String, dynamic> json) {
    // Sortenname aus Join
    final sorteData = json['sorten'];
    final sorteName =
        sorteData is Map<String, dynamic> ? sorteData['name'] as String? : null;

    // Pflanzen-Aggregation
    final pflanzenData = json['selektions_pflanzen'];
    int? pflanzenAnzahl;
    int? keeperAnzahl;
    double? durchschnittBewertung;

    if (pflanzenData is List) {
      pflanzenAnzahl = pflanzenData.length;
      keeperAnzahl = 0;
      double summe = 0;
      int bewertungsCount = 0;

      for (final p in pflanzenData) {
        if (p is Map<String, dynamic>) {
          if (p['keeper_status'] == 'ja') keeperAnzahl = keeperAnzahl! + 1;
          final gesamt = p['bewertung_gesamt'];
          if (gesamt != null) {
            summe += (gesamt as num).toDouble();
            bewertungsCount++;
          }
        }
      }

      if (bewertungsCount > 0) {
        durchschnittBewertung = summe / bewertungsCount;
      }
    } else {
      pflanzenAnzahl = 0;
      keeperAnzahl = 0;
    }

    return SelektionModel(
      id: json['id'] as String,
      sorteId: json['sorte_id'] as String,
      durchgangId: json['durchgang_id'] as String?,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'aktiv',
      startDatum: _parseDate(json['start_datum']),
      samenAnzahl: json['samen_anzahl'] as int?,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
      sorteName: sorteName,
      pflanzenAnzahl: pflanzenAnzahl,
      keeperAnzahl: keeperAnzahl,
      durchschnittBewertung: durchschnittBewertung,
    );
  }

  factory SelektionModel.fromEntity(Selektion s) {
    return SelektionModel(
      id: s.id,
      sorteId: s.sorteId,
      durchgangId: s.durchgangId,
      name: s.name,
      status: s.status,
      startDatum: s.startDatum,
      samenAnzahl: s.samenAnzahl,
      bemerkung: s.bemerkung,
      erstelltVon: s.erstelltVon,
      erstelltAm: s.erstelltAm,
      aktualisiertAm: s.aktualisiertAm,
      sorteName: s.sorteName,
      pflanzenAnzahl: s.pflanzenAnzahl,
      keeperAnzahl: s.keeperAnzahl,
      durchschnittBewertung: s.durchschnittBewertung,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sorte_id': sorteId,
      'durchgang_id': durchgangId,
      'name': name,
      'status': status,
      'start_datum': startDatum?.toIso8601String().split('T').first,
      'samen_anzahl': samenAnzahl,
      'bemerkung': bemerkung,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
