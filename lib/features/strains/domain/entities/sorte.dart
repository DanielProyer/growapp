/// Sorte Entity - Repräsentiert eine Cannabis-Sorte
class Sorte {
  final String id;
  final String name;
  final String? zuechter;
  final String geschlecht;
  final String? kreuzung; // z.B. "Jelly Donutz #117 × Purple Cartel"
  final int indicaAnteil;
  final int sativaAnteil;
  final double? thcGehalt;
  final double? cbdGehalt;
  final int? bluetezeitZuechter;
  final int? bluetezeitEigen;
  final String? pflanzenhoheZuechter;
  final String? pflanzenhoheEigen;
  final String? ertragZuechter;
  final String? ertragEigen;
  final int? keimquote;
  final String? aroma;
  final String? geschmack;
  final String? terpenprofil;
  final String? wirkungHigh;
  final String? growTipp;
  final int samenAnzahl;
  final String status;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  const Sorte({
    required this.id,
    required this.name,
    this.zuechter,
    this.geschlecht = 'feminisiert',
    this.kreuzung,
    this.indicaAnteil = 0,
    this.sativaAnteil = 0,
    this.thcGehalt,
    this.cbdGehalt,
    this.bluetezeitZuechter,
    this.bluetezeitEigen,
    this.pflanzenhoheZuechter,
    this.pflanzenhoheEigen,
    this.ertragZuechter,
    this.ertragEigen,
    this.keimquote,
    this.aroma,
    this.geschmack,
    this.terpenprofil,
    this.wirkungHigh,
    this.growTipp,
    this.samenAnzahl = 0,
    this.status = 'aktiv',
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
  });

  /// Status-Label für die Anzeige
  String get statusLabel {
    switch (status) {
      case 'geplant':
        return 'Geplant';
      case 'aktiv':
        return 'Aktiv';
      case 'selektion':
        return 'Selektion';
      case 'beendet':
        return 'Beendet';
      case 'stash':
        return 'Stash';
      default:
        return status;
    }
  }

  /// Geschlecht-Label für die Anzeige
  String get geschlechtLabel {
    switch (geschlecht) {
      case 'feminisiert':
        return 'Feminisiert';
      case 'regulaer':
        return 'Regulär';
      case 'automatik':
        return 'Automatik';
      default:
        return geschlecht;
    }
  }

  /// Genetik-String (z.B. "70% Indica / 30% Sativa")
  String get genetik {
    if (indicaAnteil == 0 && sativaAnteil == 0) return 'Unbekannt';
    return '$indicaAnteil% Indica / $sativaAnteil% Sativa';
  }

  Sorte copyWith({
    String? id,
    String? name,
    String? zuechter,
    String? geschlecht,
    String? kreuzung,
    int? indicaAnteil,
    int? sativaAnteil,
    double? thcGehalt,
    double? cbdGehalt,
    int? bluetezeitZuechter,
    int? bluetezeitEigen,
    String? pflanzenhoheZuechter,
    String? pflanzenhoheEigen,
    String? ertragZuechter,
    String? ertragEigen,
    int? keimquote,
    String? aroma,
    String? geschmack,
    String? terpenprofil,
    String? wirkungHigh,
    String? growTipp,
    int? samenAnzahl,
    String? status,
    String? bemerkung,
    String? erstelltVon,
    DateTime? erstelltAm,
    DateTime? aktualisiertAm,
  }) {
    return Sorte(
      id: id ?? this.id,
      name: name ?? this.name,
      zuechter: zuechter ?? this.zuechter,
      geschlecht: geschlecht ?? this.geschlecht,
      kreuzung: kreuzung ?? this.kreuzung,
      indicaAnteil: indicaAnteil ?? this.indicaAnteil,
      sativaAnteil: sativaAnteil ?? this.sativaAnteil,
      thcGehalt: thcGehalt ?? this.thcGehalt,
      cbdGehalt: cbdGehalt ?? this.cbdGehalt,
      bluetezeitZuechter: bluetezeitZuechter ?? this.bluetezeitZuechter,
      bluetezeitEigen: bluetezeitEigen ?? this.bluetezeitEigen,
      pflanzenhoheZuechter: pflanzenhoheZuechter ?? this.pflanzenhoheZuechter,
      pflanzenhoheEigen: pflanzenhoheEigen ?? this.pflanzenhoheEigen,
      ertragZuechter: ertragZuechter ?? this.ertragZuechter,
      ertragEigen: ertragEigen ?? this.ertragEigen,
      keimquote: keimquote ?? this.keimquote,
      aroma: aroma ?? this.aroma,
      geschmack: geschmack ?? this.geschmack,
      terpenprofil: terpenprofil ?? this.terpenprofil,
      wirkungHigh: wirkungHigh ?? this.wirkungHigh,
      growTipp: growTipp ?? this.growTipp,
      samenAnzahl: samenAnzahl ?? this.samenAnzahl,
      status: status ?? this.status,
      bemerkung: bemerkung ?? this.bemerkung,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      aktualisiertAm: aktualisiertAm ?? this.aktualisiertAm,
    );
  }
}
