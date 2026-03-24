import 'package:intl/intl.dart';

/// Mutterpflanze Entity
class Mutterpflanze {
  final String id;
  final String sorteId;
  final String? herkunftPflanzeId;
  final int? klonNummer;
  final String status;
  final DateTime? stecklingDatum;
  final DateTime? topf1lDatum;
  final DateTime? topf35lDatum;
  final DateTime? entsorgtDatum;
  final String? entsorgtGrund;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  // Join-Daten
  final String? sorteName;

  // Aggregierte Daten
  final int? gesamtStecklinge;
  final int? anzahlSchnitte;
  final DateTime? letzterSchnitt;
  final double? durchschnittErfolgsrate;

  const Mutterpflanze({
    required this.id,
    required this.sorteId,
    this.herkunftPflanzeId,
    this.klonNummer,
    this.status = 'aktiv',
    this.stecklingDatum,
    this.topf1lDatum,
    this.topf35lDatum,
    this.entsorgtDatum,
    this.entsorgtGrund,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
    this.sorteName,
    this.gesamtStecklinge,
    this.anzahlSchnitte,
    this.letzterSchnitt,
    this.durchschnittErfolgsrate,
  });

  bool get istAktiv => status == 'aktiv';

  String get statusLabel => istAktiv ? 'Aktiv' : 'Entsorgt';

  String get anzeigeName {
    final name = sorteName ?? 'Unbekannt';
    if (klonNummer != null) return '$name #$klonNummer';
    return name;
  }

  String? get stecklingDatumFormatiert => stecklingDatum != null
      ? DateFormat('dd.MM.yyyy').format(stecklingDatum!)
      : null;

  String? get topf1lDatumFormatiert => topf1lDatum != null
      ? DateFormat('dd.MM.yyyy').format(topf1lDatum!)
      : null;

  String? get topf35lDatumFormatiert => topf35lDatum != null
      ? DateFormat('dd.MM.yyyy').format(topf35lDatum!)
      : null;

  String? get entsorgtDatumFormatiert => entsorgtDatum != null
      ? DateFormat('dd.MM.yyyy').format(entsorgtDatum!)
      : null;

  String? get letzterSchnittFormatiert => letzterSchnitt != null
      ? DateFormat('dd.MM.yyyy').format(letzterSchnitt!)
      : null;
}
