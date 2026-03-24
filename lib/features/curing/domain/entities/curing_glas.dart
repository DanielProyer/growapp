import 'package:intl/intl.dart';

/// Curing-Glas Entity - Ein Behälter zum Curing eines Durchgangs
class CuringGlas {
  final String id;
  final String durchgangId;
  final String? sorteId;
  final int glasNr;
  final String? trimMethode;
  final String status; // trocknung/curing/fertig
  final bool schimmelErkannt;
  final DateTime? ernteDatum;
  final DateTime? einglasDatum;
  final double? nassGewichtG;
  final double? trockenGewichtG;
  final double? endgewichtG;
  final int? zielRlf;
  final String? behaelterTyp;
  final int? groesseMl;
  final String? bovedaTyp;
  final Map<String, dynamic> qualitaetNotizen;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;

  // Join-Daten
  final String? sorteName;

  // Aggregierte Daten
  final int messwerteAnzahl;
  final int? letzteRlf;

  const CuringGlas({
    required this.id,
    required this.durchgangId,
    this.sorteId,
    required this.glasNr,
    this.trimMethode,
    this.status = 'trocknung',
    this.schimmelErkannt = false,
    this.ernteDatum,
    this.einglasDatum,
    this.nassGewichtG,
    this.trockenGewichtG,
    this.endgewichtG,
    this.zielRlf,
    this.behaelterTyp,
    this.groesseMl,
    this.bovedaTyp,
    this.qualitaetNotizen = const {},
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.sorteName,
    this.messwerteAnzahl = 0,
    this.letzteRlf,
  });

  /// Curing-Tage seit Einglasen
  int get curingTage {
    if (einglasDatum == null) return 0;
    return DateTime.now().difference(einglasDatum!).inDays;
  }

  /// Trocknungsverlust in Prozent (nass → trocken)
  double? get trocknungsVerlustProzent {
    if (nassGewichtG == null || trockenGewichtG == null || nassGewichtG == 0) {
      return null;
    }
    return (nassGewichtG! - trockenGewichtG!) / nassGewichtG! * 100;
  }

  /// Curing-Verlust in Prozent (trocken → end)
  double? get curingVerlustProzent {
    if (trockenGewichtG == null || endgewichtG == null || trockenGewichtG == 0) {
      return null;
    }
    return (trockenGewichtG! - endgewichtG!) / trockenGewichtG! * 100;
  }

  /// Gesamtverlust in Prozent (nass → end)
  double? get gesamtVerlustProzent {
    if (nassGewichtG == null || endgewichtG == null || nassGewichtG == 0) {
      return null;
    }
    return (nassGewichtG! - endgewichtG!) / nassGewichtG! * 100;
  }

  /// Meilenstein basierend auf Curing-Tagen
  String get meilenstein {
    final tage = curingTage;
    if (tage >= 56) return 'Optimal';
    if (tage >= 28) return 'Gut';
    if (tage >= 14) return 'Rauchbar';
    return 'Frisch';
  }

  /// Status-Label für die Anzeige
  String get statusLabel {
    switch (status) {
      case 'trocknung':
        return 'Trocknung';
      case 'curing':
        return 'Curing';
      case 'fertig':
        return 'Fertig';
      default:
        return status;
    }
  }

  /// Behältertyp-Label für die Anzeige
  String get behaelterTypLabel {
    switch (behaelterTyp) {
      case 'glas':
        return 'Glas';
      case 'grove_bag':
        return 'Grove Bag';
      case 'cvault':
        return 'CVault';
      case 'eimer':
        return 'Eimer';
      case 'sonstig':
        return 'Sonstig';
      default:
        return 'Glas';
    }
  }

  /// Trim-Methode-Label
  String? get trimMethodeLabel {
    switch (trimMethode) {
      case 'nassschnitt':
        return 'Nassschnitt';
      case 'trimbag':
        return 'Trimbag';
      case 'handschnitt':
        return 'Handschnitt';
      default:
        return null;
    }
  }

  String? get ernteDatumFormatiert => ernteDatum != null
      ? DateFormat('dd.MM.yyyy').format(ernteDatum!)
      : null;

  String? get einglasDatumFormatiert => einglasDatum != null
      ? DateFormat('dd.MM.yyyy').format(einglasDatum!)
      : null;
}
