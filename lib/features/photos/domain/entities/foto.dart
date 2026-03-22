import 'package:intl/intl.dart';

/// Foto Entity - Ein Foto zu einer Pflanze
class Foto {
  final String id;
  final String speicherPfad;
  final String? vorschauPfad;
  final String? beschreibung;
  final String? kategorie;
  final String? pflanzeId;
  final String? durchgangId;
  final String? zeltId;
  final String? inventarId;
  final String? vorfallId;
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
    this.kategorie,
    this.pflanzeId,
    this.durchgangId,
    this.zeltId,
    this.inventarId,
    this.vorfallId,
    this.aufgenommenAm,
    required this.erstelltVon,
    required this.erstelltAm,
    this.bilderUrl,
  });

  String get bezeichnung {
    final parts = <String>[];
    if (kategorie != null) parts.add(kategorieLabel);
    if (beschreibung != null && beschreibung!.isNotEmpty) {
      parts.add(beschreibung!);
    }
    if (parts.isNotEmpty) return parts.join(' – ');
    final datum = aufgenommenAm ?? erstelltAm;
    return 'Foto vom ${DateFormat('dd.MM.yyyy').format(datum)}';
  }

  String get kategorieLabel {
    switch (kategorie) {
      case 'pflanze':
        return 'Pflanze';
      case 'wurzeln':
        return 'Wurzeln';
      case 'buds':
        return 'Buds';
      case 'trichome':
        return 'Trichome';
      default:
        return kategorie ?? '';
    }
  }

  static const kategorien = ['pflanze', 'wurzeln', 'buds', 'trichome'];

  static String kategorieLabelFuer(String k) {
    switch (k) {
      case 'pflanze':
        return 'Pflanze';
      case 'wurzeln':
        return 'Wurzeln';
      case 'buds':
        return 'Buds';
      case 'trichome':
        return 'Trichome';
      default:
        return k;
    }
  }
}
