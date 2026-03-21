import '../../domain/entities/pflanze.dart';

/// Pflanze Model - JSON Serialisierung für Supabase
class PflanzeModel extends Pflanze {
  const PflanzeModel({
    required super.id,
    required super.durchgangId,
    super.sorteId,
    required super.pflanzenNr,
    super.status,
    super.aussaatDatum,
    super.keimDatum,
    super.topf1lDatum,
    super.blueteStart,
    super.ernteDatum,
    super.hoeheBlueteStart,
    super.hoeheErnte,
    super.stammdickeBluete,
    super.stammdickeErnte,
    super.nassGewichtG,
    super.trockenGewichtG,
    super.bemerkung,
    super.sorteName,
  });

  factory PflanzeModel.fromJson(Map<String, dynamic> json) {
    final sorteData = json['sorten'] as Map<String, dynamic>?;

    return PflanzeModel(
      id: json['id'] as String,
      durchgangId: json['durchgang_id'] as String,
      sorteId: json['sorte_id'] as String?,
      pflanzenNr: (json['pflanzen_nr'] as num).toInt(),
      status: json['status'] as String? ?? 'keimung',
      aussaatDatum: _parseDate(json['aussaat_datum']),
      keimDatum: _parseDate(json['keim_datum']),
      topf1lDatum: _parseDate(json['topf_1l_datum']),
      blueteStart: _parseDate(json['bluete_start']),
      ernteDatum: _parseDate(json['ernte_datum']),
      hoeheBlueteStart: (json['hoehe_bluete_start'] as num?)?.toDouble(),
      hoeheErnte: (json['hoehe_ernte'] as num?)?.toDouble(),
      stammdickeBluete: (json['stammdicke_bluete'] as num?)?.toDouble(),
      stammdickeErnte: (json['stammdicke_ernte'] as num?)?.toDouble(),
      nassGewichtG: (json['nass_gewicht_g'] as num?)?.toDouble(),
      trockenGewichtG: (json['trocken_gewicht_g'] as num?)?.toDouble(),
      bemerkung: json['bemerkung'] as String?,
      sorteName: sorteData?['name'] as String?,
    );
  }

  factory PflanzeModel.fromEntity(Pflanze p) {
    return PflanzeModel(
      id: p.id,
      durchgangId: p.durchgangId,
      sorteId: p.sorteId,
      pflanzenNr: p.pflanzenNr,
      status: p.status,
      aussaatDatum: p.aussaatDatum,
      keimDatum: p.keimDatum,
      topf1lDatum: p.topf1lDatum,
      blueteStart: p.blueteStart,
      ernteDatum: p.ernteDatum,
      hoeheBlueteStart: p.hoeheBlueteStart,
      hoeheErnte: p.hoeheErnte,
      stammdickeBluete: p.stammdickeBluete,
      stammdickeErnte: p.stammdickeErnte,
      nassGewichtG: p.nassGewichtG,
      trockenGewichtG: p.trockenGewichtG,
      bemerkung: p.bemerkung,
      sorteName: p.sorteName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durchgang_id': durchgangId,
      'sorte_id': sorteId,
      'pflanzen_nr': pflanzenNr,
      'status': status,
      'aussaat_datum': _dateToString(aussaatDatum),
      'keim_datum': _dateToString(keimDatum),
      'topf_1l_datum': _dateToString(topf1lDatum),
      'bluete_start': _dateToString(blueteStart),
      'ernte_datum': _dateToString(ernteDatum),
      'hoehe_bluete_start': hoeheBlueteStart,
      'hoehe_ernte': hoeheErnte,
      'stammdicke_bluete': stammdickeBluete,
      'stammdicke_ernte': stammdickeErnte,
      'nass_gewicht_g': nassGewichtG,
      'trocken_gewicht_g': trockenGewichtG,
      'bemerkung': bemerkung,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  static String? _dateToString(DateTime? d) =>
      d?.toIso8601String().split('T').first;
}
