/// SelektionsPflanze Entity - Einzelne Pflanze in einer Selektion mit Bewertungen
class SelektionsPflanze {
  final String id;
  final String selektionId;
  final String pflanzeId;
  final String keeperStatus;
  final bool vorselektion;

  // Bewertungen 1-10
  final int? bewertungVigor;
  final int? bewertungStruktur;
  final int? bewertungHarz;
  final int? bewertungAroma;
  final int? bewertungErtrag;
  final int? bewertungSchaedlingsresistenz;
  final int? bewertungFestigkeit;
  final int? bewertungGeschmack;
  final int? bewertungWirkung;

  final double? bewertungGesamt;
  final Map<String, dynamic> trichomNotizen;
  final Map<String, dynamic> bewertungNotizen;
  final String? bemerkung;

  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  // Join-Daten
  final int? pflanzenNr;
  final String? sorteName;

  const SelektionsPflanze({
    required this.id,
    required this.selektionId,
    required this.pflanzeId,
    this.keeperStatus = 'vielleicht',
    this.vorselektion = false,
    this.bewertungVigor,
    this.bewertungStruktur,
    this.bewertungHarz,
    this.bewertungAroma,
    this.bewertungErtrag,
    this.bewertungSchaedlingsresistenz,
    this.bewertungFestigkeit,
    this.bewertungGeschmack,
    this.bewertungWirkung,
    this.bewertungGesamt,
    this.trichomNotizen = const {},
    this.bewertungNotizen = const {},
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
    this.pflanzenNr,
    this.sorteName,
  });

  String get keeperLabel {
    switch (keeperStatus) {
      case 'ja':
        return 'Keeper';
      case 'nein':
        return 'Nein';
      case 'vielleicht':
        return 'Vielleicht';
      default:
        return keeperStatus;
    }
  }

  String get bezeichnung => 'Pflanze #${pflanzenNr ?? '?'}';

  /// Berechnet die Gesamtbewertung als Durchschnitt aller gesetzten Scores
  double? get berechneteBewertung {
    final scores = <int>[
      if (bewertungVigor != null) bewertungVigor!,
      if (bewertungStruktur != null) bewertungStruktur!,
      if (bewertungHarz != null) bewertungHarz!,
      if (bewertungAroma != null) bewertungAroma!,
      if (bewertungErtrag != null) bewertungErtrag!,
      if (bewertungSchaedlingsresistenz != null) bewertungSchaedlingsresistenz!,
      if (bewertungFestigkeit != null) bewertungFestigkeit!,
      if (bewertungGeschmack != null) bewertungGeschmack!,
      if (bewertungWirkung != null) bewertungWirkung!,
    ];
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Alle 9 Bewertungen als Liste für Mini-Balkengrafik
  List<int?> get alleBewertungen => [
        bewertungVigor,
        bewertungStruktur,
        bewertungHarz,
        bewertungAroma,
        bewertungErtrag,
        bewertungSchaedlingsresistenz,
        bewertungFestigkeit,
        bewertungGeschmack,
        bewertungWirkung,
      ];
}
