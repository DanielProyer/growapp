/// Zelt Entity - Repräsentiert ein Grow-Zelt / Grow-Bereich
class Zelt {
  final String id;
  final String name;
  final double? breiteCm;
  final double? tiefeCm;
  final double? hoeheCm;
  final String? lichtTyp;
  final int? lichtWatt;
  final String? lueftung;
  final String? bewaesserung;
  final String? standort;
  final int etagen;
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
    this.lichtTyp,
    this.lichtWatt,
    this.lueftung,
    this.bewaesserung,
    this.standort,
    this.etagen = 1,
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
    String? lichtTyp,
    int? lichtWatt,
    String? lueftung,
    String? bewaesserung,
    String? standort,
    int? etagen,
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
      lichtTyp: lichtTyp ?? this.lichtTyp,
      lichtWatt: lichtWatt ?? this.lichtWatt,
      lueftung: lueftung ?? this.lueftung,
      bewaesserung: bewaesserung ?? this.bewaesserung,
      standort: standort ?? this.standort,
      etagen: etagen ?? this.etagen,
      bemerkung: bemerkung ?? this.bemerkung,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      aktualisiertAm: aktualisiertAm ?? this.aktualisiertAm,
    );
  }
}
