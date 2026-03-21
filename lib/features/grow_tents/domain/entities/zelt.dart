/// Zelt Entity - Repräsentiert ein Grow-Zelt (physische Hülle, gemeinsames Klima)
class Zelt {
  final String id;
  final String name;
  final double? breiteCm;
  final double? tiefeCm;
  final double? hoeheCm;
  final String? standort;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  const Zelt({
    required this.id,
    required this.name,
    this.breiteCm,
    this.tiefeCm,
    this.hoeheCm,
    this.standort,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
  });

  /// Dimensionen als String (z.B. "120 × 120 × 220 cm")
  String get dimensionen {
    if (breiteCm == null && tiefeCm == null && hoeheCm == null) return 'Unbekannt';
    final b = breiteCm?.toStringAsFixed(0) ?? '?';
    final t = tiefeCm?.toStringAsFixed(0) ?? '?';
    final h = hoeheCm?.toStringAsFixed(0) ?? '?';
    return '$b × $t × $h cm';
  }

  /// Grundfläche in m²
  double? get grundflaecheM2 {
    if (breiteCm == null || tiefeCm == null) return null;
    return (breiteCm! * tiefeCm!) / 10000;
  }

  Zelt copyWith({
    String? id,
    String? name,
    double? breiteCm,
    double? tiefeCm,
    double? hoeheCm,
    String? standort,
    String? bemerkung,
    String? erstelltVon,
    DateTime? erstelltAm,
    DateTime? aktualisiertAm,
  }) {
    return Zelt(
      id: id ?? this.id,
      name: name ?? this.name,
      breiteCm: breiteCm ?? this.breiteCm,
      tiefeCm: tiefeCm ?? this.tiefeCm,
      hoeheCm: hoeheCm ?? this.hoeheCm,
      standort: standort ?? this.standort,
      bemerkung: bemerkung ?? this.bemerkung,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      aktualisiertAm: aktualisiertAm ?? this.aktualisiertAm,
    );
  }
}
