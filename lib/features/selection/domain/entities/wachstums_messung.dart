import 'package:intl/intl.dart';

/// WachstumsMessung Entity - Wachstumsdaten einer Pflanze
class WachstumsMessung {
  final String id;
  final String pflanzeId;
  final DateTime datum;
  final double? hoeheCm;
  final int? nodienAnzahl;
  final double? stammdicke;
  final bool getoppt;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;

  const WachstumsMessung({
    required this.id,
    required this.pflanzeId,
    required this.datum,
    this.hoeheCm,
    this.nodienAnzahl,
    this.stammdicke,
    this.getoppt = false,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
  });

  String get datumFormatiert => DateFormat('dd.MM.yyyy').format(datum);
}
