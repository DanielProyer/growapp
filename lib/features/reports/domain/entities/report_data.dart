// Leichte DTOs für Chart-Daten

/// Ertrag pro Sorte
class YieldPerStrainData {
  final String sorteName;
  final double trockenErtragG;
  final int anzahlDurchgaenge;

  const YieldPerStrainData({
    required this.sorteName,
    required this.trockenErtragG,
    this.anzahlDurchgaenge = 1,
  });
}

/// Ertrag pro Watt
class YieldPerWattData {
  final String durchgangTitel;
  final double grammProWatt;

  const YieldPerWattData({
    required this.durchgangTitel,
    required this.grammProWatt,
  });
}

/// Zyklusdauer (Vegi/Blüte/Curing Tage)
class CycleDurationData {
  final String durchgangTitel;
  final int vegiTage;
  final int blueteTage;
  final int curingTage;

  const CycleDurationData({
    required this.durchgangTitel,
    this.vegiTage = 0,
    this.blueteTage = 0,
    this.curingTage = 0,
  });

  int get gesamtTage => vegiTage + blueteTage + curingTage;
}

/// Pflanzen-Attrition (Start→Vegi→Blüte)
class PlantAttritionData {
  final String durchgangTitel;
  final int start;
  final int vegi;
  final int bluete;

  const PlantAttritionData({
    required this.durchgangTitel,
    this.start = 0,
    this.vegi = 0,
    this.bluete = 0,
  });
}

/// Umgebungsdaten-Punkt für Zeitreihen
class EnvironmentDataPoint {
  final DateTime datum;
  final double? tempTag;
  final double? tempNacht;
  final double? relfTag;
  final double? relfNacht;
  final double? ph;
  final double? ec;
  final double? pflanzenHoehe;

  const EnvironmentDataPoint({
    required this.datum,
    this.tempTag,
    this.tempNacht,
    this.relfTag,
    this.relfNacht,
    this.ph,
    this.ec,
    this.pflanzenHoehe,
  });
}

/// Radar-Chart Daten für eine Pflanze
class PhenoRadarData {
  final String bezeichnung;
  final int? vigor;
  final int? struktur;
  final int? harz;
  final int? aroma;
  final int? ertrag;
  final int? schaedlingsresistenz;
  final int? festigkeit;
  final int? geschmack;
  final int? wirkung;

  const PhenoRadarData({
    required this.bezeichnung,
    this.vigor,
    this.struktur,
    this.harz,
    this.aroma,
    this.ertrag,
    this.schaedlingsresistenz,
    this.festigkeit,
    this.geschmack,
    this.wirkung,
  });

  List<double> get werte => [
        (vigor ?? 0).toDouble(),
        (struktur ?? 0).toDouble(),
        (harz ?? 0).toDouble(),
        (aroma ?? 0).toDouble(),
        (ertrag ?? 0).toDouble(),
        (schaedlingsresistenz ?? 0).toDouble(),
        (festigkeit ?? 0).toDouble(),
        (geschmack ?? 0).toDouble(),
        (wirkung ?? 0).toDouble(),
      ];

  static const List<String> kriterienNamen = [
    'Vigor',
    'Struktur',
    'Harz',
    'Aroma',
    'Ertrag',
    'Resistenz',
    'Festigkeit',
    'Geschmack',
    'Wirkung',
  ];
}

/// Keeper-Verteilung
class KeeperRateData {
  final int keeper;
  final int nein;
  final int vielleicht;

  const KeeperRateData({
    this.keeper = 0,
    this.nein = 0,
    this.vielleicht = 0,
  });

  int get gesamt => keeper + nein + vielleicht;
}

/// Score-Verteilung pro Kriterium
class ScoreDistributionData {
  final String kriterium;
  final double durchschnitt;

  const ScoreDistributionData({
    required this.kriterium,
    required this.durchschnitt,
  });
}

/// Wachstumskurve
class GrowthCurvePoint {
  final DateTime datum;
  final double? hoeheCm;
  final int? nodienAnzahl;
  final double? stammdicke;

  const GrowthCurvePoint({
    required this.datum,
    this.hoeheCm,
    this.nodienAnzahl,
    this.stammdicke,
  });
}

/// Wachstumskurve einer Pflanze
class GrowthCurveData {
  final String bezeichnung;
  final String pflanzeId;
  final List<GrowthCurvePoint> punkte;

  const GrowthCurveData({
    required this.bezeichnung,
    required this.pflanzeId,
    required this.punkte,
  });
}

/// Dashboard Quick Stats
class GrowQuickStats {
  final double? besterErtragG;
  final String? besterErtragSorte;
  final double? durchschnittGProWatt;
  final int abgeschlosseneDurchgaenge;

  const GrowQuickStats({
    this.besterErtragG,
    this.besterErtragSorte,
    this.durchschnittGProWatt,
    this.abgeschlosseneDurchgaenge = 0,
  });
}
