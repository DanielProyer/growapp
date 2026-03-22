import '../../domain/entities/kalender_eintrag.dart';

/// KalenderEintrag Model - JSON Serialisierung für Supabase
class KalenderEintragModel extends KalenderEintrag {
  const KalenderEintragModel({
    required super.id,
    required super.titel,
    super.beschreibung,
    super.typ,
    required super.geplantAm,
    super.erledigt,
    super.durchgangId,
    super.pflanzeId,
    super.erinnerungMinuten,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
  });

  factory KalenderEintragModel.fromJson(Map<String, dynamic> json) {
    return KalenderEintragModel(
      id: json['id'] as String,
      titel: json['titel'] as String,
      beschreibung: json['beschreibung'] as String?,
      typ: json['typ'] as String? ?? 'allgemein',
      geplantAm: DateTime.parse(json['geplant_am'] as String),
      erledigt: json['erledigt'] as bool? ?? false,
      durchgangId: json['durchgang_id'] as String?,
      pflanzeId: json['pflanze_id'] as String?,
      erinnerungMinuten: json['erinnerung_minuten'] as int? ?? 0,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
      aktualisiertAm: json['aktualisiert_am'] != null
          ? DateTime.parse(json['aktualisiert_am'] as String)
          : null,
    );
  }

  factory KalenderEintragModel.fromEntity(KalenderEintrag eintrag) {
    return KalenderEintragModel(
      id: eintrag.id,
      titel: eintrag.titel,
      beschreibung: eintrag.beschreibung,
      typ: eintrag.typ,
      geplantAm: eintrag.geplantAm,
      erledigt: eintrag.erledigt,
      durchgangId: eintrag.durchgangId,
      pflanzeId: eintrag.pflanzeId,
      erinnerungMinuten: eintrag.erinnerungMinuten,
      erstelltVon: eintrag.erstelltVon,
      erstelltAm: eintrag.erstelltAm,
      aktualisiertAm: eintrag.aktualisiertAm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titel': titel,
      'beschreibung': beschreibung,
      'typ': typ,
      'geplant_am': geplantAm.toIso8601String(),
      'erledigt': erledigt,
      'durchgang_id': durchgangId,
      'pflanze_id': pflanzeId,
      'erinnerung_minuten': erinnerungMinuten,
    };
  }
}
