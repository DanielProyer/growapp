/// Sorte Entity - Repräsentiert eine Cannabis-Sorte
class Sorte {
  final String id;
  final String name;
  final String? zuechter;
  final int indicaAnteil;
  final int sativaAnteil;
  final double? thcGehalt;
  final double? cbdGehalt;
  final int? bluetezeitZuechter;
  final int? bluetezeitEigen;
  final int? bluetezeitSicherheit;
  final int? keimquote;
  final String? ertragSelektion;
  final String? ertragProduktion;
  final String? geschmack;
  final String? wirkung;
  final bool toppingEmpfohlen;
  final int samenAnzahl;
  final bool hatMutterpflanze;
  final String status;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  const Sorte({
    required this.id,
    required this.name,
    this.zuechter,
    this.indicaAnteil = 0,
    this.sativaAnteil = 0,
    this.thcGehalt,
    this.cbdGehalt,
    this.bluetezeitZuechter,
    this.bluetezeitEigen,
    this.bluetezeitSicherheit,
    this.keimquote,
    this.ertragSelektion,
    this.ertragProduktion,
    this.geschmack,
    this.wirkung,
    this.toppingEmpfohlen = false,
    this.samenAnzahl = 0,
    this.hatMutterpflanze = false,
    this.status = 'aktiv',
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
  });

  /// Status-Label für die Anzeige
  String get statusLabel {
    switch (status) {
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

  /// Genetik-String (z.B. "70% Indica / 30% Sativa")
  String get genetik {
    if (indicaAnteil == 0 && sativaAnteil == 0) return 'Unbekannt';
    return '$indicaAnteil% Indica / $sativaAnteil% Sativa';
  }

  Sorte copyWith({
    String? id,
    String? name,
    String? zuechter,
    int? indicaAnteil,
    int? sativaAnteil,
    double? thcGehalt,
    double? cbdGehalt,
    int? bluetezeitZuechter,
    int? bluetezeitEigen,
    int? bluetezeitSicherheit,
    int? keimquote,
    String? ertragSelektion,
    String? ertragProduktion,
    String? geschmack,
    String? wirkung,
    bool? toppingEmpfohlen,
    int? samenAnzahl,
    bool? hatMutterpflanze,
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
      indicaAnteil: indicaAnteil ?? this.indicaAnteil,
      sativaAnteil: sativaAnteil ?? this.sativaAnteil,
      thcGehalt: thcGehalt ?? this.thcGehalt,
      cbdGehalt: cbdGehalt ?? this.cbdGehalt,
      bluetezeitZuechter: bluetezeitZuechter ?? this.bluetezeitZuechter,
      bluetezeitEigen: bluetezeitEigen ?? this.bluetezeitEigen,
      bluetezeitSicherheit: bluetezeitSicherheit ?? this.bluetezeitSicherheit,
      keimquote: keimquote ?? this.keimquote,
      ertragSelektion: ertragSelektion ?? this.ertragSelektion,
      ertragProduktion: ertragProduktion ?? this.ertragProduktion,
      geschmack: geschmack ?? this.geschmack,
      wirkung: wirkung ?? this.wirkung,
      toppingEmpfohlen: toppingEmpfohlen ?? this.toppingEmpfohlen,
      samenAnzahl: samenAnzahl ?? this.samenAnzahl,
      hatMutterpflanze: hatMutterpflanze ?? this.hatMutterpflanze,
      status: status ?? this.status,
      bemerkung: bemerkung ?? this.bemerkung,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      aktualisiertAm: aktualisiertAm ?? this.aktualisiertAm,
    );
  }
}
