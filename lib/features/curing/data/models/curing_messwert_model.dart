import '../../domain/entities/curing_messwert.dart';

/// Curing-Messwert Model - JSON Serialisierung für Supabase
class CuringMesswertModel extends CuringMesswert {
  const CuringMesswertModel({
    required super.id,
    required super.glasId,
    required super.datum,
    super.rlfProzent,
    super.temperatur,
    super.gewichtG,
    super.gelueftet,
    super.lueftungsdauerMin,
    super.bemerkung,
    super.erstelltVon,
  });

  factory CuringMesswertModel.fromJson(Map<String, dynamic> json) {
    return CuringMesswertModel(
      id: json['id'] as String,
      glasId: json['glas_id'] as String,
      datum: DateTime.parse(json['datum'] as String),
      rlfProzent: json['rlf_prozent'] as int?,
      temperatur: _parseDouble(json['temperatur']),
      gewichtG: _parseDouble(json['gewicht_g']),
      gelueftet: json['gelueftet'] as bool? ?? false,
      lueftungsdauerMin: json['lueftungsdauer_min'] as int?,
      bemerkung: json['bemerkung'] as String?,
      erstelltVon: json['erstellt_von'] as String?,
    );
  }

  factory CuringMesswertModel.fromEntity(CuringMesswert m) {
    return CuringMesswertModel(
      id: m.id,
      glasId: m.glasId,
      datum: m.datum,
      rlfProzent: m.rlfProzent,
      temperatur: m.temperatur,
      gewichtG: m.gewichtG,
      gelueftet: m.gelueftet,
      lueftungsdauerMin: m.lueftungsdauerMin,
      bemerkung: m.bemerkung,
      erstelltVon: m.erstelltVon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'glas_id': glasId,
      'datum': datum.toIso8601String().split('T').first,
      'rlf_prozent': rlfProzent,
      'temperatur': temperatur,
      'gewicht_g': gewichtG,
      'gelueftet': gelueftet,
      'lueftungsdauer_min': lueftungsdauerMin,
      'bemerkung': bemerkung,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
