import '../../domain/entities/inventar_item.dart';

/// InventarItem Model - JSON Serialisierung für Supabase
class InventarItemModel extends InventarItem {
  const InventarItemModel({
    required super.id,
    required super.name,
    super.typ,
    super.kategorie,
    super.einheit,
    super.aktuellerBestand,
    super.mindestBestand,
    super.preis,
    super.lieferant,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
    super.aktualisiertAm,
  });

  factory InventarItemModel.fromJson(Map<String, dynamic> json) {
    return InventarItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      typ: json['typ'] as String? ?? 'verbrauchsmaterial',
      kategorie: json['kategorie'] as String? ?? 'sonstige',
      einheit: json['einheit'] as String?,
      aktuellerBestand: (json['aktueller_bestand'] as num?)?.toDouble() ?? 0,
      mindestBestand: (json['mindest_bestand'] as num?)?.toDouble() ?? 0,
      preis: (json['preis'] as num?)?.toDouble(),
      lieferant: json['lieferant'] as String?,
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

  factory InventarItemModel.fromEntity(InventarItem item) {
    return InventarItemModel(
      id: item.id,
      name: item.name,
      typ: item.typ,
      kategorie: item.kategorie,
      einheit: item.einheit,
      aktuellerBestand: item.aktuellerBestand,
      mindestBestand: item.mindestBestand,
      preis: item.preis,
      lieferant: item.lieferant,
      bemerkung: item.bemerkung,
      erstelltVon: item.erstelltVon,
      erstelltAm: item.erstelltAm,
      aktualisiertAm: item.aktualisiertAm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'typ': typ,
      'kategorie': kategorie,
      'einheit': einheit,
      'aktueller_bestand': aktuellerBestand,
      'mindest_bestand': mindestBestand,
      'preis': preis,
      'lieferant': lieferant,
      'bemerkung': bemerkung,
    };
  }
}
