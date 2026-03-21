import '../../domain/entities/sorte.dart';

/// Sorte Model - JSON Serialisierung für Supabase
class SorteModel extends Sorte {
  const SorteModel({
    required super.id,
    required super.name,
    super.zuechter,
    super.indicaAnteil,
    super.sativaAnteil,
    super.thcGehalt,
    super.cbdGehalt,
    super.bluetezeitZuechter,
    super.bluetezeitEigen,
    super.bluetezeitSicherheit,
    super.keimquote,
    super.ertragSelektion,
    super.ertragProduktion,
    super.geschmack,
    super.wirkung,
    super.toppingEmpfohlen,
    super.samenAnzahl,
    super.hatMutterpflanze,
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
      indicaAnteil: (json['indica_anteil'] as num?)?.toInt() ?? 0,
      sativaAnteil: (json['sativa_anteil'] as num?)?.toInt() ?? 0,
      thcGehalt: (json['thc_gehalt'] as num?)?.toDouble(),
      cbdGehalt: (json['cbd_gehalt'] as num?)?.toDouble(),
      bluetezeitZuechter: (json['bluetezeit_zuechter'] as num?)?.toInt(),
      bluetezeitEigen: (json['bluetezeit_eigen'] as num?)?.toInt(),
      bluetezeitSicherheit: (json['bluetezeit_sicherheit'] as num?)?.toInt(),
      keimquote: (json['keimquote'] as num?)?.toInt(),
      ertragSelektion: json['ertrag_selektion'] as String?,
      ertragProduktion: json['ertrag_produktion'] as String?,
      geschmack: json['geschmack'] as String?,
      wirkung: json['wirkung'] as String?,
      toppingEmpfohlen: json['topping_empfohlen'] as bool? ?? false,
      samenAnzahl: (json['samen_anzahl'] as num?)?.toInt() ?? 0,
      hatMutterpflanze: json['hat_mutterpflanze'] as bool? ?? false,
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
      indicaAnteil: sorte.indicaAnteil,
      sativaAnteil: sorte.sativaAnteil,
      thcGehalt: sorte.thcGehalt,
      cbdGehalt: sorte.cbdGehalt,
      bluetezeitZuechter: sorte.bluetezeitZuechter,
      bluetezeitEigen: sorte.bluetezeitEigen,
      bluetezeitSicherheit: sorte.bluetezeitSicherheit,
      keimquote: sorte.keimquote,
      ertragSelektion: sorte.ertragSelektion,
      ertragProduktion: sorte.ertragProduktion,
      geschmack: sorte.geschmack,
      wirkung: sorte.wirkung,
      toppingEmpfohlen: sorte.toppingEmpfohlen,
      samenAnzahl: sorte.samenAnzahl,
      hatMutterpflanze: sorte.hatMutterpflanze,
      status: sorte.status,
      bemerkung: sorte.bemerkung,
      erstelltVon: sorte.erstelltVon,
      erstelltAm: sorte.erstelltAm,
      aktualisiertAm: sorte.aktualisiertAm,
    );
  }

  /// Zu JSON für Supabase (ohne id, erstellt_am, aktualisiert_am)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'zuechter': zuechter,
      'indica_anteil': indicaAnteil,
      'sativa_anteil': sativaAnteil,
      'thc_gehalt': thcGehalt,
      'cbd_gehalt': cbdGehalt,
      'bluetezeit_zuechter': bluetezeitZuechter,
      'bluetezeit_eigen': bluetezeitEigen,
      'bluetezeit_sicherheit': bluetezeitSicherheit,
      'keimquote': keimquote,
      'ertrag_selektion': ertragSelektion,
      'ertrag_produktion': ertragProduktion,
      'geschmack': geschmack,
      'wirkung': wirkung,
      'topping_empfohlen': toppingEmpfohlen,
      'samen_anzahl': samenAnzahl,
      'hat_mutterpflanze': hatMutterpflanze,
      'status': status,
      'bemerkung': bemerkung,
    };
  }
}
