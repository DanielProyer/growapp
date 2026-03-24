import 'package:intl/intl.dart';

/// Steckling Entity - Repräsentiert einen Stecklingsschnitt
class Steckling {
  final String id;
  final String mutterId;
  final DateTime datum;
  final int? anzahlUnten;
  final int? anzahlOben;
  final Map<String, dynamic>? naehrstoffe;
  final int? erfolgsrate;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;

  const Steckling({
    required this.id,
    required this.mutterId,
    required this.datum,
    this.anzahlUnten,
    this.anzahlOben,
    this.naehrstoffe,
    this.erfolgsrate,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
  });

  int get gesamtAnzahl => (anzahlUnten ?? 0) + (anzahlOben ?? 0);

  String get datumFormatiert => DateFormat('dd.MM.yyyy').format(datum);

  String get erfolgsrateFormatiert =>
      erfolgsrate != null ? '$erfolgsrate%' : '-';
}
