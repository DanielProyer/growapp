import 'package:intl/intl.dart';

/// Selektion Entity - Pheno-Hunting Durchlauf
class Selektion {
  final String id;
  final String sorteId;
  final String? durchgangId;
  final String name;
  final String status;
  final DateTime? startDatum;
  final int? samenAnzahl;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  // Join-Daten
  final String? sorteName;

  // Aggregierte Daten
  final int? pflanzenAnzahl;
  final int? keeperAnzahl;
  final double? durchschnittBewertung;

  const Selektion({
    required this.id,
    required this.sorteId,
    this.durchgangId,
    required this.name,
    this.status = 'aktiv',
    this.startDatum,
    this.samenAnzahl,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
    this.sorteName,
    this.pflanzenAnzahl,
    this.keeperAnzahl,
    this.durchschnittBewertung,
  });

  bool get istAktiv => status == 'aktiv';

  String get statusLabel => istAktiv ? 'Aktiv' : 'Abgeschlossen';

  String? get startDatumFormatiert => startDatum != null
      ? DateFormat('dd.MM.yyyy').format(startDatum!)
      : null;
}
