/// TagesLog Entity - Repräsentiert einen täglichen Log-Eintrag
class TagesLog {
  final String id;
  final String durchgangId;
  final DateTime datum;
  final int? vegiTag;
  final int? blueteTag;

  // Umgebung
  final double? tempTag;
  final double? tempNacht;
  final double? relfTag;
  final double? relfNacht;
  final int? lichtWatt;
  final int? lampenHoehe;
  final double? pflanzenHoehe;

  // Bewässerung / Tank
  final int? wasserMl;
  final double? ph;
  final double? ec;
  final int? tankFuellstand;
  final double? tankTemp;

  // Nährstoffe
  final Map<String, double>? naehrstoffe;

  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  // Verknüpfte Daten (aus Joins)
  final String? durchgangTitel;
  final String? sorteName;

  const TagesLog({
    required this.id,
    required this.durchgangId,
    required this.datum,
    this.vegiTag,
    this.blueteTag,
    this.tempTag,
    this.tempNacht,
    this.relfTag,
    this.relfNacht,
    this.lichtWatt,
    this.lampenHoehe,
    this.pflanzenHoehe,
    this.wasserMl,
    this.ph,
    this.ec,
    this.tankFuellstand,
    this.tankTemp,
    this.naehrstoffe,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
    this.durchgangTitel,
    this.sorteName,
  });

  /// Hat Umgebungsdaten?
  bool get hatUmgebung =>
      tempTag != null ||
      tempNacht != null ||
      relfTag != null ||
      relfNacht != null;

  /// Hat Bewässerungsdaten?
  bool get hatBewaesserung =>
      wasserMl != null || ph != null || ec != null;

  /// Hat Nährstoffdaten?
  bool get hatNaehrstoffe =>
      naehrstoffe != null && naehrstoffe!.isNotEmpty;
}
