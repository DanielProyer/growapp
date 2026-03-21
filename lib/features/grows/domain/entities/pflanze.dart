/// Pflanze Entity - Einzelne Pflanze innerhalb eines Durchgangs
class Pflanze {
  final String id;
  final String durchgangId;
  final String? sorteId;
  final int pflanzenNr;
  final String status;

  // Termine
  final DateTime? aussaatDatum;
  final DateTime? keimDatum;
  final DateTime? topf1lDatum;
  final DateTime? blueteStart;
  final DateTime? ernteDatum;

  // Messungen
  final double? hoeheBlueteStart;
  final double? hoeheErnte;
  final double? stammdickeBluete;
  final double? stammdickeErnte;
  final double? nassGewichtG;
  final double? trockenGewichtG;

  final String? bemerkung;

  // Join-Felder
  final String? sorteName;

  const Pflanze({
    required this.id,
    required this.durchgangId,
    this.sorteId,
    required this.pflanzenNr,
    this.status = 'keimung',
    this.aussaatDatum,
    this.keimDatum,
    this.topf1lDatum,
    this.blueteStart,
    this.ernteDatum,
    this.hoeheBlueteStart,
    this.hoeheErnte,
    this.stammdickeBluete,
    this.stammdickeErnte,
    this.nassGewichtG,
    this.trockenGewichtG,
    this.bemerkung,
    this.sorteName,
  });

  String get bezeichnung => 'Pflanze #$pflanzenNr';

  bool get istAktiv => !['beendet', 'entsorgt'].contains(status);

  String get statusLabel {
    switch (status) {
      case 'keimung':
        return 'Keimung';
      case 'vegetation':
        return 'Vegetation';
      case 'bluete':
        return 'Blüte';
      case 'ernte':
        return 'Ernte';
      case 'beendet':
        return 'Beendet';
      case 'entsorgt':
        return 'Entsorgt';
      default:
        return status;
    }
  }

  bool get hatMessungen =>
      hoeheBlueteStart != null ||
      hoeheErnte != null ||
      stammdickeBluete != null ||
      stammdickeErnte != null ||
      nassGewichtG != null ||
      trockenGewichtG != null;
}
