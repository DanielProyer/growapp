import '../../domain/entities/sorte.dart';

/// Sorte Model - JSON Serialisierung für Supabase
class SorteModel extends Sorte {
  const SorteModel({
    required super.id,
    required super.name,
    super.zuechter,
    super.geschlecht,
    super.kreuzung,
    super.indicaAnteil,
    super.sativaAnteil,
    super.thcGehalt,
    super.cbdGehalt,
    super.bluetezeitZuechter,
    super.bluetezeitEigen,
    super.pflanzenhoheZuechter,
    super.pflanzenhoheEigen,
    super.ertragZuechter,
    super.ertragEigen,
    super.keimquote,
    super.aroma,
    super.geschmack,
    super.terpenprofil,
    super.wirkungHigh,
    super.growTipp,
    super.samenAnzahl,
    super.status,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
  });

  /// Aus Supabase JSON erstellen
  factory SorteModel.fromJson(Map<String, dynamic> json) {
    return SorteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      zuechter: json['zuechter'] as String?,
      geschlecht: json['geschlecht'] as String? ?? 'feminisiert',
      kreuzung: json['kreuzung'] as String?,
      indicaAnteil: (json['indica_anteil'] as num?)?.toInt() ?? 0,
      sativaAnteil: (json['sativa_anteil'] as num?)?.toInt() ?? 0,
      thcGehalt: (json['thc_gehalt'] as num?)?.toDouble(),
      cbdGehalt: (json['cbd_gehalt'] as num?)?.toDouble(),
      bluetezeitZuechter: (json['bluetezeit_zuechter'] as num?)?.toInt(),
      bluetezeitEigen: (json['bluetezeit_eigen'] as num?)?.toInt(),
      pflanzenhoheZuechter: json['pflanzenhohe_zuechter'] as String?,
      pflanzenhoheEigen: json['pflanzenhohe_eigen'] as String?,
      ertragZuechter: json['ertrag_zuechter'] as String?,
      ertragEigen: json['ertrag_eigen'] as String?,
      keimquote: (json['keimquote'] as num?)?.toInt(),
      aroma: json['aroma'] as String?,
      geschmack: json['geschmack'] as String?,
      terpenprofil: json['terpenprofil'] as String?,
      wirkungHigh: json['wirkung_high'] as String?,
      growTipp: json['grow_tipp'] as String?,
      samenAnzahl: (json['samen_anzahl'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'aktiv',
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
    );
  }

  /// Aus Entity erstellen
  factory SorteModel.fromEntity(Sorte sorte) {
    return SorteModel(
      id: sorte.id,
      name: sorte.name,
      zuechter: sorte.zuechter,
      geschlecht: sorte.geschlecht,
      kreuzung: sorte.kreuzung,
      indicaAnteil: sorte.indicaAnteil,
      sativaAnteil: sorte.sativaAnteil,
      thcGehalt: sorte.thcGehalt,
      cbdGehalt: sorte.cbdGehalt,
      bluetezeitZuechter: sorte.bluetezeitZuechter,
      bluetezeitEigen: sorte.bluetezeitEigen,
      pflanzenhoheZuechter: sorte.pflanzenhoheZuechter,
      pflanzenhoheEigen: sorte.pflanzenhoheEigen,
      ertragZuechter: sorte.ertragZuechter,
      ertragEigen: sorte.ertragEigen,
      keimquote: sorte.keimquote,
      aroma: sorte.aroma,
      geschmack: sorte.geschmack,
      terpenprofil: sorte.terpenprofil,
      wirkungHigh: sorte.wirkungHigh,
      growTipp: sorte.growTipp,
      samenAnzahl: sorte.samenAnzahl,
      status: sorte.status,
      bemerkung: sorte.bemerkung,
      erstelltVon: sorte.erstelltVon,
      erstelltAm: sorte.erstelltAm,
      aktualisiertAm: sorte.aktualisiertAm,
    );
  }

  /// Zu JSON für Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'zuechter': zuechter,
      'geschlecht': geschlecht,
      'kreuzung': kreuzung,
      'indica_anteil': indicaAnteil,
      'sativa_anteil': sativaAnteil,
      'thc_gehalt': thcGehalt,
      'cbd_gehalt': cbdGehalt,
      'bluetezeit_zuechter': bluetezeitZuechter,
      'bluetezeit_eigen': bluetezeitEigen,
      'pflanzenhohe_zuechter': pflanzenhoheZuechter,
      'pflanzenhohe_eigen': pflanzenhoheEigen,
      'ertrag_zuechter': ertragZuechter,
      'ertrag_eigen': ertragEigen,
      'keimquote': keimquote,
      'aroma': aroma,
      'geschmack': geschmack,
      'terpenprofil': terpenprofil,
      'wirkung_high': wirkungHigh,
      'grow_tipp': growTipp,
      'samen_anzahl': samenAnzahl,
      'status': status,
      'bemerkung': bemerkung,
    };
  }
}
