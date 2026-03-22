/// KalenderEintrag Entity - Repräsentiert einen Kalender-Termin
class KalenderEintrag {
  final String id;
  final String titel;
  final String? beschreibung;
  final String typ;
  final DateTime geplantAm;
  final bool erledigt;
  final String? durchgangId;
  final String? pflanzeId;
  final int erinnerungMinuten; // 0 = keine Erinnerung
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  const KalenderEintrag({
    required this.id,
    required this.titel,
    this.beschreibung,
    this.typ = 'allgemein',
    required this.geplantAm,
    this.erledigt = false,
    this.durchgangId,
    this.pflanzeId,
    this.erinnerungMinuten = 0,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
  });

  String get typLabel {
    switch (typ) {
      case 'bewaesserung':
        return 'Bewässerung';
      case 'duengung':
        return 'Düngung';
      case 'ernte':
        return 'Ernte';
      case 'stecklinge':
        return 'Stecklinge';
      case 'umtopfen':
        return 'Umtopfen';
      case 'schaedlingskontrolle':
        return 'Schädlingskontrolle';
      case 'foto':
        return 'Foto';
      case 'allgemein':
        return 'Allgemein';
      default:
        return typ;
    }
  }

  String get erinnerungLabel {
    switch (erinnerungMinuten) {
      case 0:
        return 'Keine';
      case 15:
        return '15 Min vorher';
      case 30:
        return '30 Min vorher';
      case 60:
        return '1 Std vorher';
      case 1440:
        return '1 Tag vorher';
      default:
        return '$erinnerungMinuten Min vorher';
    }
  }

  KalenderEintrag copyWith({
    String? id,
    String? titel,
    String? beschreibung,
    String? typ,
    DateTime? geplantAm,
    bool? erledigt,
    String? durchgangId,
    String? pflanzeId,
    int? erinnerungMinuten,
    String? erstelltVon,
    DateTime? erstelltAm,
    DateTime? aktualisiertAm,
  }) {
    return KalenderEintrag(
      id: id ?? this.id,
      titel: titel ?? this.titel,
      beschreibung: beschreibung ?? this.beschreibung,
      typ: typ ?? this.typ,
      geplantAm: geplantAm ?? this.geplantAm,
      erledigt: erledigt ?? this.erledigt,
      durchgangId: durchgangId ?? this.durchgangId,
      pflanzeId: pflanzeId ?? this.pflanzeId,
      erinnerungMinuten: erinnerungMinuten ?? this.erinnerungMinuten,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      aktualisiertAm: aktualisiertAm ?? this.aktualisiertAm,
    );
  }
}
