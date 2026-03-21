/// Durchgang Entity - Repräsentiert einen Grow-Durchgang
class Durchgang {
  final String id;
  final String? sorteId;
  final String typ; // 'samen' oder 'steckling'
  final String status;
  final int? pflanzenAnzahl;

  // Anbauflächen pro Phase (Pflanzen können umziehen)
  final String? stecklingAnbauflaecheId;
  final String? vegiAnbauflaecheId;
  final String? blueteAnbauflaecheId;

  // Termine
  final DateTime? stecklingDatum;
  final DateTime? vegiStart;
  final DateTime? blueteStart;
  final DateTime? ernteDatum;
  final DateTime? einglasDatum;

  // Ernte
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

  // Verknüpfte Daten (aus Joins geladen)
  final String? sorteName;
  final String? stecklingAnbauflaecheName;
  final String? stecklingZeltName;
  final String? vegiAnbauflaecheName;
  final String? vegiZeltName;
  final String? blueteAnbauflaecheName;
  final String? blueteZeltName;

  const Durchgang({
    required this.id,
    this.sorteId,
    this.typ = 'steckling',
    this.status = 'vorbereitung',
    this.pflanzenAnzahl,
    this.stecklingAnbauflaecheId,
    this.vegiAnbauflaecheId,
    this.blueteAnbauflaecheId,
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
    this.stecklingAnbauflaecheName,
    this.stecklingZeltName,
    this.vegiAnbauflaecheName,
    this.vegiZeltName,
    this.blueteAnbauflaecheName,
    this.blueteZeltName,
  });

  bool get istSamen => typ == 'samen';

  /// Typ-Label für die Anzeige
  String get typLabel => istSamen ? 'Samen' : 'Steckling';

  /// Status-Label für die Anzeige
  String get statusLabel {
    switch (status) {
      case 'vorbereitung':
        return 'Vorbereitung';
      case 'keimung':
        return 'Keimung';
      case 'steckling':
        return 'Steckling';
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

  /// Label für die erste Phase (abhängig vom Typ)
  String get erstePhaseLabel => istSamen ? 'Keimung' : 'Steckling';

  /// Ist der Durchgang aktiv?
  bool get istAktiv => status != 'beendet';

  /// Aktuelle Anbaufläche basierend auf Phase
  String? get aktuelleAnbauflaecheName {
    switch (status) {
      case 'bluete':
      case 'ernte':
      case 'curing':
      case 'beendet':
        return blueteAnbauflaecheName ?? vegiAnbauflaecheName ?? stecklingAnbauflaecheName;
      case 'vegetation':
        return vegiAnbauflaecheName ?? stecklingAnbauflaecheName;
      default:
        return stecklingAnbauflaecheName;
    }
  }

  /// Aktueller Zeltname basierend auf Phase
  String? get aktuellerZeltName {
    switch (status) {
      case 'bluete':
      case 'ernte':
      case 'curing':
      case 'beendet':
        return blueteZeltName ?? vegiZeltName ?? stecklingZeltName;
      case 'vegetation':
        return vegiZeltName ?? stecklingZeltName;
      default:
        return stecklingZeltName;
    }
  }

  /// Titel für die Anzeige
  String get titel {
    final sorte = sorteName ?? 'Unbekannte Sorte';
    final flaeche = aktuelleAnbauflaecheName ?? '';
    if (flaeche.isNotEmpty) return '$sorte – $flaeche';
    return sorte;
  }
}
