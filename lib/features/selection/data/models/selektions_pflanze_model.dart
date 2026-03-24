import '../../domain/entities/selektions_pflanze.dart';

/// SelektionsPflanze Model - JSON Serialisierung für Supabase
class SelektionsPflanzeModel extends SelektionsPflanze {
  const SelektionsPflanzeModel({
    required super.id,
    required super.selektionId,
    required super.pflanzeId,
    super.keeperStatus,
    super.vorselektion,
    super.bewertungVigor,
    super.bewertungStruktur,
    super.bewertungHarz,
    super.bewertungAroma,
    super.bewertungErtrag,
    super.bewertungSchaedlingsresistenz,
    super.bewertungFestigkeit,
    super.bewertungGeschmack,
    super.bewertungWirkung,
    super.bewertungGesamt,
    super.trichomNotizen,
    super.bewertungNotizen,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
    super.pflanzenNr,
    super.sorteName,
  });

  factory SelektionsPflanzeModel.fromJson(Map<String, dynamic> json) {
    // Pflanzen-Daten aus Join
    final pflanzeData = json['pflanzen'];
    int? pflanzenNr;
    String? sorteName;

    if (pflanzeData is Map<String, dynamic>) {
      pflanzenNr = pflanzeData['pflanzen_nr'] as int?;
      final sorteData = pflanzeData['sorten'];
      if (sorteData is Map<String, dynamic>) {
        sorteName = sorteData['name'] as String?;
      }
    }

    return SelektionsPflanzeModel(
      id: json['id'] as String,
      selektionId: json['selektion_id'] as String,
      pflanzeId: json['pflanze_id'] as String,
      keeperStatus: json['keeper_status'] as String? ?? 'vielleicht',
      vorselektion: json['vorselektion'] as bool? ?? false,
      bewertungVigor: json['bewertung_vigor'] as int?,
      bewertungStruktur: json['bewertung_struktur'] as int?,
      bewertungHarz: json['bewertung_harz'] as int?,
      bewertungAroma: json['bewertung_aroma'] as int?,
      bewertungErtrag: json['bewertung_ertrag'] as int?,
      bewertungSchaedlingsresistenz:
          json['bewertung_schaedlingsresistenz'] as int?,
      bewertungFestigkeit: json['bewertung_festigkeit'] as int?,
      bewertungGeschmack: json['bewertung_geschmack'] as int?,
      bewertungWirkung: json['bewertung_wirkung'] as int?,
      bewertungGesamt: (json['bewertung_gesamt'] as num?)?.toDouble(),
      trichomNotizen:
          (json['trichom_notizen'] as Map<String, dynamic>?) ?? const {},
      bewertungNotizen:
          (json['bewertung_notizen'] as Map<String, dynamic>?) ?? const {},
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
      pflanzenNr: pflanzenNr,
      sorteName: sorteName,
    );
  }

  factory SelektionsPflanzeModel.fromEntity(SelektionsPflanze p) {
    return SelektionsPflanzeModel(
      id: p.id,
      selektionId: p.selektionId,
      pflanzeId: p.pflanzeId,
      keeperStatus: p.keeperStatus,
      vorselektion: p.vorselektion,
      bewertungVigor: p.bewertungVigor,
      bewertungStruktur: p.bewertungStruktur,
      bewertungHarz: p.bewertungHarz,
      bewertungAroma: p.bewertungAroma,
      bewertungErtrag: p.bewertungErtrag,
      bewertungSchaedlingsresistenz: p.bewertungSchaedlingsresistenz,
      bewertungFestigkeit: p.bewertungFestigkeit,
      bewertungGeschmack: p.bewertungGeschmack,
      bewertungWirkung: p.bewertungWirkung,
      bewertungGesamt: p.bewertungGesamt,
      trichomNotizen: p.trichomNotizen,
      bewertungNotizen: p.bewertungNotizen,
      bemerkung: p.bemerkung,
      erstelltVon: p.erstelltVon,
      erstelltAm: p.erstelltAm,
      aktualisiertAm: p.aktualisiertAm,
      pflanzenNr: p.pflanzenNr,
      sorteName: p.sorteName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selektion_id': selektionId,
      'pflanze_id': pflanzeId,
      'keeper_status': keeperStatus,
      'vorselektion': vorselektion,
      'bewertung_vigor': bewertungVigor,
      'bewertung_struktur': bewertungStruktur,
      'bewertung_harz': bewertungHarz,
      'bewertung_aroma': bewertungAroma,
      'bewertung_ertrag': bewertungErtrag,
      'bewertung_schaedlingsresistenz': bewertungSchaedlingsresistenz,
      'bewertung_festigkeit': bewertungFestigkeit,
      'bewertung_geschmack': bewertungGeschmack,
      'bewertung_wirkung': bewertungWirkung,
      'bewertung_gesamt': berechneteBewertung,
      'trichom_notizen': trichomNotizen,
      'bewertung_notizen': bewertungNotizen,
      'bemerkung': bemerkung,
    };
  }
}
