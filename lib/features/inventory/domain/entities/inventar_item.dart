/// InventarItem Entity - Repräsentiert einen Inventar-Artikel
class InventarItem {
  final String id;
  final String name;
  final String typ; // 'equipment' oder 'verbrauchsmaterial'
  final String kategorie;
  final String? einheit;
  final double aktuellerBestand;
  final double mindestBestand;
  final double? preis;
  final String? lieferant;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  const InventarItem({
    required this.id,
    required this.name,
    this.typ = 'verbrauchsmaterial',
    this.kategorie = 'sonstige',
    this.einheit,
    this.aktuellerBestand = 0,
    this.mindestBestand = 0,
    this.preis,
    this.lieferant,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
  });

  bool get istEquipment => typ == 'equipment';

  bool get bestandNiedrig =>
      mindestBestand > 0 && aktuellerBestand <= mindestBestand;

  String get typLabel {
    switch (typ) {
      case 'equipment':
        return 'Equipment';
      case 'verbrauchsmaterial':
        return 'Verbrauchsmaterial';
      default:
        return typ;
    }
  }

  String get kategorieLabel {
    switch (kategorie) {
      case 'duenger':
        return 'Dünger';
      case 'schaedlingsbekaempfung':
        return 'Schädlingsbekämpfung';
      case 'medium':
        return 'Medium/Substrat';
      case 'beleuchtung':
        return 'Beleuchtung';
      case 'belueftung':
        return 'Belüftung/Klima';
      case 'bewaesserung':
        return 'Bewässerung';
      case 'messinstrumente':
        return 'Messinstrumente';
      case 'zubehoer':
        return 'Zubehör';
      case 'sonstige':
        return 'Sonstiges';
      default:
        return kategorie;
    }
  }

  InventarItem copyWith({
    String? id,
    String? name,
    String? typ,
    String? kategorie,
    String? einheit,
    double? aktuellerBestand,
    double? mindestBestand,
    double? preis,
    String? lieferant,
    String? bemerkung,
    String? erstelltVon,
    DateTime? erstelltAm,
    DateTime? aktualisiertAm,
  }) {
    return InventarItem(
      id: id ?? this.id,
      name: name ?? this.name,
      typ: typ ?? this.typ,
      kategorie: kategorie ?? this.kategorie,
      einheit: einheit ?? this.einheit,
      aktuellerBestand: aktuellerBestand ?? this.aktuellerBestand,
      mindestBestand: mindestBestand ?? this.mindestBestand,
      preis: preis ?? this.preis,
      lieferant: lieferant ?? this.lieferant,
      bemerkung: bemerkung ?? this.bemerkung,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      aktualisiertAm: aktualisiertAm ?? this.aktualisiertAm,
    );
  }
}
