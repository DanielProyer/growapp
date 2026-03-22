/// InventarBuchung Entity - Ein-/Ausgang eines Inventar-Artikels
class InventarBuchung {
  final String id;
  final String artikelId;
  final String typ; // 'eingang' oder 'verbrauch'
  final double menge;
  final double? stueckpreis;
  final DateTime datum;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;

  const InventarBuchung({
    required this.id,
    required this.artikelId,
    required this.typ,
    required this.menge,
    this.stueckpreis,
    required this.datum,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
  });

  bool get istEingang => typ == 'eingang';

  String get typLabel => istEingang ? 'Eingang' : 'Verbrauch';
}
