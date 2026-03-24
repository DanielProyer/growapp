import '../../domain/entities/steckling.dart';

/// Steckling Model - JSON Serialisierung für Supabase
class StecklingModel extends Steckling {
  const StecklingModel({
    required super.id,
    required super.mutterId,
    required super.datum,
    super.anzahlUnten,
    super.anzahlOben,
    super.naehrstoffe,
    super.erfolgsrate,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
  });

  factory StecklingModel.fromJson(Map<String, dynamic> json) {
    return StecklingModel(
      id: json['id'] as String,
      mutterId: json['mutter_id'] as String,
      datum: DateTime.parse(json['datum'] as String),
      anzahlUnten: json['anzahl_unten'] as int?,
      anzahlOben: json['anzahl_oben'] as int?,
      naehrstoffe: json['naehrstoffe'] as Map<String, dynamic>?,
      erfolgsrate: json['erfolgsrate'] as int?,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
    );
  }

  factory StecklingModel.fromEntity(Steckling s) {
    return StecklingModel(
      id: s.id,
      mutterId: s.mutterId,
      datum: s.datum,
      anzahlUnten: s.anzahlUnten,
      anzahlOben: s.anzahlOben,
      naehrstoffe: s.naehrstoffe,
      erfolgsrate: s.erfolgsrate,
      bemerkung: s.bemerkung,
      erstelltVon: s.erstelltVon,
      erstelltAm: s.erstelltAm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mutter_id': mutterId,
      'datum': datum.toIso8601String().split('T').first,
      'anzahl_unten': anzahlUnten,
      'anzahl_oben': anzahlOben,
      'naehrstoffe': naehrstoffe,
      'erfolgsrate': erfolgsrate,
      'bemerkung': bemerkung,
    };
  }
}
