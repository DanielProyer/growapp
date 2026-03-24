import '../../domain/entities/mutterpflanze.dart';

/// Mutterpflanze Model - JSON Serialisierung für Supabase
class MutterpflanzeModel extends Mutterpflanze {
  const MutterpflanzeModel({
    required super.id,
    required super.sorteId,
    super.herkunftPflanzeId,
    super.klonNummer,
    super.status,
    super.stecklingDatum,
    super.topf1lDatum,
    super.topf35lDatum,
    super.entsorgtDatum,
    super.entsorgtGrund,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
    super.sorteName,
    super.gesamtStecklinge,
    super.anzahlSchnitte,
    super.letzterSchnitt,
    super.durchschnittErfolgsrate,
  });

  factory MutterpflanzeModel.fromJson(Map<String, dynamic> json) {
    // Sortenname aus Join
    final sorteData = json['sorten'];
    final sorteName =
        sorteData is Map<String, dynamic> ? sorteData['name'] as String? : null;

    // Stecklings-Aggregation
    final stecklingeData = json['stecklinge'];
    int? gesamtStecklinge;
    int? anzahlSchnitte;
    DateTime? letzterSchnitt;
    double? durchschnittErfolgsrate;

    if (stecklingeData is List && stecklingeData.isNotEmpty) {
      anzahlSchnitte = stecklingeData.length;
      int summe = 0;
      int erfolgsrateCount = 0;
      double erfolgsrateSumme = 0;
      DateTime? maxDatum;

      for (final s in stecklingeData) {
        if (s is Map<String, dynamic>) {
          summe += (s['anzahl_unten'] as int? ?? 0) +
              (s['anzahl_oben'] as int? ?? 0);
          if (s['erfolgsrate'] != null) {
            erfolgsrateSumme += (s['erfolgsrate'] as num).toDouble();
            erfolgsrateCount++;
          }
          if (s['datum'] != null) {
            final d = DateTime.parse(s['datum'] as String);
            if (maxDatum == null || d.isAfter(maxDatum)) maxDatum = d;
          }
        }
      }

      gesamtStecklinge = summe;
      letzterSchnitt = maxDatum;
      if (erfolgsrateCount > 0) {
        durchschnittErfolgsrate = erfolgsrateSumme / erfolgsrateCount;
      }
    } else {
      anzahlSchnitte = 0;
      gesamtStecklinge = 0;
    }

    return MutterpflanzeModel(
      id: json['id'] as String,
      sorteId: json['sorte_id'] as String,
      herkunftPflanzeId: json['herkunft_pflanze_id'] as String?,
      klonNummer: json['klon_nummer'] as int?,
      status: json['status'] as String? ?? 'aktiv',
      stecklingDatum: _parseDate(json['steckling_datum']),
      topf1lDatum: _parseDate(json['topf_1l_datum']),
      topf35lDatum: _parseDate(json['topf_3_5l_datum']),
      entsorgtDatum: _parseDate(json['entsorgt_datum']),
      entsorgtGrund: json['entsorgt_grund'] as String?,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
      sorteName: sorteName,
      gesamtStecklinge: gesamtStecklinge,
      anzahlSchnitte: anzahlSchnitte,
      letzterSchnitt: letzterSchnitt,
      durchschnittErfolgsrate: durchschnittErfolgsrate,
    );
  }

  factory MutterpflanzeModel.fromEntity(Mutterpflanze m) {
    return MutterpflanzeModel(
      id: m.id,
      sorteId: m.sorteId,
      herkunftPflanzeId: m.herkunftPflanzeId,
      klonNummer: m.klonNummer,
      status: m.status,
      stecklingDatum: m.stecklingDatum,
      topf1lDatum: m.topf1lDatum,
      topf35lDatum: m.topf35lDatum,
      entsorgtDatum: m.entsorgtDatum,
      entsorgtGrund: m.entsorgtGrund,
      bemerkung: m.bemerkung,
      erstelltVon: m.erstelltVon,
      erstelltAm: m.erstelltAm,
      aktualisiertAm: m.aktualisiertAm,
      sorteName: m.sorteName,
      gesamtStecklinge: m.gesamtStecklinge,
      anzahlSchnitte: m.anzahlSchnitte,
      letzterSchnitt: m.letzterSchnitt,
      durchschnittErfolgsrate: m.durchschnittErfolgsrate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sorte_id': sorteId,
      'herkunft_pflanze_id': herkunftPflanzeId,
      'klon_nummer': klonNummer,
      'status': status,
      'steckling_datum': stecklingDatum?.toIso8601String().split('T').first,
      'topf_1l_datum': topf1lDatum?.toIso8601String().split('T').first,
      'topf_3_5l_datum': topf35lDatum?.toIso8601String().split('T').first,
      'entsorgt_datum': entsorgtDatum?.toIso8601String().split('T').first,
      'entsorgt_grund': entsorgtGrund,
      'bemerkung': bemerkung,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
