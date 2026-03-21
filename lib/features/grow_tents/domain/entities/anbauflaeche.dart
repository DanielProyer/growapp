/// Anbaufläche Entity - Zone innerhalb eines Zelts mit eigener Ausstattung
class Anbauflaeche {
  final String id;
  final String zeltId;
  final String name;
  final String? lichtTyp;
  final int? lichtWatt;
  final String? lueftung;
  final String? bewaesserung;
  final int? etage;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  const Anbauflaeche({
    required this.id,
    required this.zeltId,
    required this.name,
    this.lichtTyp,
    this.lichtWatt,
    this.lueftung,
    this.bewaesserung,
    this.etage,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
  });

  /// Licht-Info als String
  String get lichtInfo {
    if (lichtTyp == null && lichtWatt == null) return 'Kein Licht';
    final typ = lichtTyp ?? '';
    final watt = lichtWatt != null ? '${lichtWatt}W' : '';
    if (typ.isNotEmpty && watt.isNotEmpty) return '$typ ($watt)';
    return typ.isNotEmpty ? typ : watt;
  }

  Anbauflaeche copyWith({
    String? id,
    String? zeltId,
    String? name,
    String? lichtTyp,
    int? lichtWatt,
    String? lueftung,
    String? bewaesserung,
    int? etage,
    String? bemerkung,
    String? erstelltVon,
    DateTime? erstelltAm,
    DateTime? aktualisiertAm,
  }) {
    return Anbauflaeche(
      id: id ?? this.id,
      zeltId: zeltId ?? this.zeltId,
      name: name ?? this.name,
      lichtTyp: lichtTyp ?? this.lichtTyp,
      lichtWatt: lichtWatt ?? this.lichtWatt,
      lueftung: lueftung ?? this.lueftung,
      bewaesserung: bewaesserung ?? this.bewaesserung,
      etage: etage ?? this.etage,
      bemerkung: bemerkung ?? this.bemerkung,
      erstelltVon: erstelltVon ?? this.erstelltVon,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      aktualisiertAm: aktualisiertAm ?? this.aktualisiertAm,
    );
  }
}
