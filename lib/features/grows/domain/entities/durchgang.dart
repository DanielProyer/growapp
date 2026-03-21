/// Durchgang Entity - Repräsentiert einen Grow-Durchgang
class Durchgang {
  final String id;
  final String? anbauflaecheId;
  final String? sorteId;
  final String status;
  final int? pflanzenAnzahl;
  final DateTime? stecklingDatum;
  final DateTime? vegiStart;
  final DateTime? blueteStart;
  final DateTime? ernteDatum;
  final DateTime? einglasDatum;
  final String? ernteMethode;
  final double? trockenErtragG;
  final double? trimG;
  final double? ertragProWatt;
  final double? siebung1;
  final double? siebung2;
  final double? siebung3;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  // Verknüpfte Daten (aus Join geladen)
  final String? sorteName;
  final String? anbauflaecheName;
  final String? zeltName;

  const Durchgang({
    required this.id,
    this.anbauflaecheId,
    this.sorteId,
    this.status = 'vorbereitung',
    this.pflanzenAnzahl,
    this.stecklingDatum,
    this.vegiStart,
    this.blueteStart,
    this.ernteDatum,
    this.einglasDatum,
    this.ernteMethode,
    this.trockenErtragG,
    this.trimG,
    this.ertragProWatt,
    this.siebung1,
    this.siebung2,
    this.siebung3,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
    this.sorteName,
    this.anbauflaecheName,
    this.zeltName,
  });

  /// Status-Label für die Anzeige
  String get statusLabel {
    switch (status) {
      case 'vorbereitung':
        return 'Vorbereitung';
      case 'vegetation':
        return 'Vegetation';
      case 'bluete':
        return 'Blüte';
      case 'ernte':
        return 'Ernte';
      case 'curing':
        return 'Curing';
      case 'beendet':
        return 'Beendet';
      default:
        return status;
    }
  }

  /// Ist der Durchgang aktiv?
  bool get istAktiv =>
      status != 'beendet';

  /// Titel für die Anzeige
  String get titel {
    final sorte = sorteName ?? 'Unbekannte Sorte';
    final flaeche = anbauflaecheName ?? '';
    if (flaeche.isNotEmpty) return '$sorte – $flaeche';
    return sorte;
  }

  Durchgang copyWith({
    String? id,
    String? anbauflaecheId,
    String? sorteId,
    String? status,
    int? pflanzenAnzahl,
    DateTime? stecklingDatum,
    DateTime? vegiStart,
    DateTime? blueteStart,
    DateTime? ernteDatum,
    DateTime? einglasDatum,
    String? ernteMethode,
    double? trockenErtragG,
    double? trimG,
    double? ertragProWatt,
    double? siebung1,
    double? siebung2,
    double? siebung3,
    String? bemerkung,
    String? erstelltVon,
    DateTime? erstelltAm,
    DateTime? aktualisiertAm,
    String? sorteName,
    String? anbauflaecheName,
    String? zeltName,
  }) {
    return Durchgang(
      id: id ?? this.id,
      anbauflaecheId: anbauflaecheId ?? this.anbauflaecheId,
      sorteId: sorteId ?? this.sorteId,
      status: status ?? this.status,
      pflanzenAnzahl: pflanzenAnzahl ?? this.pflanzenAnzahl,
      stecklingDatum: stecklingDatum ?? this.stecklingDatum,
      vegiStart: vegiStart ?? this.vegiStart,
      blueteStart: blueteStart ?? this.blueteStart,
      ernteDatum: ernteDatum ?? this.ernteDatum,
      einglasDatum: einglasDatum ?? this.einglasDatum,
      ernteMethode: ernteMethode ?? this.ernteMethode,
      trockenErtragG: trockenErtragG ?? this.trockenErtragG,
      trimG: trimG ?? this.trimG,
      ertragProWatt: ertragProWatt ?? this.ertragProWatt,
      siebung1: siebung1 ?? this.siebung1,
      siebung2: siebung2 ?? this.siebung2,
      siebung3: siebung3 ?? this.siebung3,
      bemerkung: bemerkung ?? this.bemerkung,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      aktualisiertAm: aktualisiertAm ?? this.aktualisiertAm,
      sorteName: sorteName ?? this.sorteName,
      anbauflaecheName: anbauflaecheName ?? this.anbauflaecheName,
      zeltName: zeltName ?? this.zeltName,
    );
  }
}
