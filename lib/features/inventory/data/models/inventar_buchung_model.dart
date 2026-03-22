import '../../domain/entities/inventar_buchung.dart';

/// InventarBuchung Model - JSON Serialisierung für Supabase
class InventarBuchungModel extends InventarBuchung {
  const InventarBuchungModel({
    required super.id,
    required super.artikelId,
    required super.typ,
    required super.menge,
    super.stueckpreis,
    required super.datum,
    super.bemerkung,
    super.erstelltVon,
    super.erstelltAm,
  });

  factory InventarBuchungModel.fromJson(Map<String, dynamic> json) {
    return InventarBuchungModel(
      id: json['id'] as String,
      artikelId: json['artikel_id'] as String,
      typ: json['typ'] as String,
      menge: (json['menge'] as num).toDouble(),
      stueckpreis: (json['stueckpreis'] as num?)?.toDouble(),
      datum: DateTime.parse(json['datum'] as String),
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artikel_id': artikelId,
      'typ': typ,
      'menge': menge,
      'stueckpreis': stueckpreis,
      'datum': datum.toIso8601String().split('T').first,
      'bemerkung': bemerkung,
    };
  }
}
