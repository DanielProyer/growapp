import 'package:intl/intl.dart';

/// Foto Entity - Ein Foto zu einem Durchgang
class Foto {
  final String id;
  final String speicherPfad;
  final String? vorschauPfad;
  final String? beschreibung;
  final String? pflanzeId;
  final String? durchgangId;
  final String? zeltId;
  final DateTime? aufgenommenAm;
  final String erstelltVon;
  final DateTime erstelltAm;

  /// Signed URL zum Anzeigen (nicht in DB gespeichert)
  final String? bilderUrl;

  const Foto({
    required this.id,
    required this.speicherPfad,
    this.vorschauPfad,
    this.beschreibung,
    this.pflanzeId,
    this.durchgangId,
    this.zeltId,
    this.aufgenommenAm,
    required this.erstelltVon,
    required this.erstelltAm,
    this.bilderUrl,
  });

  String get bezeichnung {
    if (beschreibung != null && beschreibung!.isNotEmpty) return beschreibung!;
    final datum = aufgenommenAm ?? erstelltAm;
    return 'Foto vom ${DateFormat('dd.MM.yyyy').format(datum)}';
  }
}
