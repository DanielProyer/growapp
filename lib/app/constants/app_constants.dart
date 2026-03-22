/// App-weite Konstanten
class AppConstants {
  AppConstants._();

  static const String appName = 'GrowApp';
  static const String appVersion = '0.1.0';

  // Breakpoints für Responsive Design
  static const double breakpointCompact = 600;
  static const double breakpointMedium = 1024;
  static const double breakpointExpanded = 1200;

  // Supabase Tabellennamen
  static const String tabelleProfile = 'profile';
  static const String tabelleSorten = 'sorten';
  static const String tabelleZelte = 'zelte';
  static const String tabelleDurchgaenge = 'durchgaenge';
  static const String tabelleTagesLogs = 'tages_logs';
  static const String tabellePflanzen = 'pflanzen';
  static const String tabelleSelektionen = 'selektionen';
  static const String tabelleSelektionsKriterien = 'selektions_kriterien';
  static const String tabelleSelektionsPflanzen = 'selektions_pflanzen';
  static const String tabelleWachstumsMessungen = 'wachstums_messungen';
  static const String tabelleMuetterpflanzen = 'muetterpflanzen';
  static const String tabelleStecklinge = 'stecklinge';
  static const String tabelleCuringGlaeser = 'curing_glaeser';
  static const String tabelleCuringMesswerte = 'curing_messwerte';
  static const String tabelleSchaedlingsVorfaelle = 'schaedlings_vorfaelle';
  static const String tabelleSchaedlingsBehandlungen = 'schaedlings_behandlungen';
  static const String tabelleInventar = 'inventar';
  static const String tabelleInventarBuchungen = 'inventar_buchungen';
  static const String tabelleFotos = 'fotos';
  static const String tabelleKalenderEintraege = 'kalender_eintraege';
  static const String tabelleBenachrichtigungen = 'benachrichtigungen';

  // Durchgang-Typen
  static const List<String> durchgangTypen = [
    'samen',
    'steckling',
  ];

  // Durchgang-Status (alle möglichen)
  static const List<String> durchgangStatus = [
    'vorbereitung',
    'keimung',
    'steckling',
    'vegetation',
    'bluete',
    'ernte',
    'curing',
    'beendet',
  ];

  // Status pro Typ
  static const List<String> durchgangStatusSamen = [
    'vorbereitung',
    'keimung',
    'vegetation',
    'bluete',
    'ernte',
    'curing',
    'beendet',
  ];

  static const List<String> durchgangStatusSteckling = [
    'vorbereitung',
    'steckling',
    'vegetation',
    'bluete',
    'ernte',
    'curing',
    'beendet',
  ];

  /// Status-Liste für einen bestimmten Typ
  static List<String> durchgangStatusFuerTyp(String typ) {
    return typ == 'samen' ? durchgangStatusSamen : durchgangStatusSteckling;
  }

  // Pflanzen-Status
  static const List<String> pflanzenStatus = [
    'keimung',
    'vegetation',
    'bluete',
    'ernte',
    'beendet',
    'entsorgt',
  ];

  // Sorten-Status
  static const List<String> sortenStatus = [
    'geplant',
    'aktiv',
    'selektion',
    'beendet',
    'stash',
  ];

  // Sorten-Geschlecht
  static const List<String> sortenGeschlecht = [
    'feminisiert',
    'regulaer',
    'automatik',
  ];

  // Schädlingstypen
  static const List<String> schaedlingsTypen = [
    'thripse',
    'spinnmilben',
    'trauermücken',
    'blattlaeuse',
    'weisse_fliegen',
    'minierfliegen',
    'breitmilben',
    'rostmilben',
    'raupen',
    'echter_mehltau',
    'falscher_mehltau',
    'botrytis',
    'wurzelfaeule',
    'alternaria',
    'septoria',
    'umfallkrankheit',
    'sonstige',
  ];

  // Behandlungstypen
  static const List<String> behandlungsTypen = [
    'biologisch',
    'chemisch',
    'mechanisch',
    'nuetzlinge',
  ];

  // Wirksamkeitsstufen
  static const List<String> wirksamkeitsStufen = [
    'keine',
    'gering',
    'mittel',
    'gut',
    'sehr_gut',
  ];

  // Schweregrade
  static const List<String> schweregrade = [
    'niedrig',
    'mittel',
    'hoch',
    'kritisch',
  ];

  // Erntemethoden
  static const List<String> ernteMethoden = [
    'nassschnitt',
    'trimbag',
    'handschnitt',
  ];

  // Keeper-Status
  static const List<String> keeperStatus = [
    'ja',
    'nein',
    'vielleicht',
  ];

  // Kalender-Typen
  static const List<String> kalenderTypen = [
    'bewaesserung',
    'duengung',
    'ernte',
    'stecklinge',
    'umtopfen',
    'schaedlingskontrolle',
    'foto',
    'allgemein',
  ];

  // Erinnerungs-Optionen (Minuten vor dem Termin, 0 = keine)
  static const List<int> erinnerungsOptionen = [
    0,
    15,
    30,
    60,
    1440,
  ];

  // Inventar-Typen
  static const List<String> inventarTypen = [
    'equipment',
    'verbrauchsmaterial',
  ];

  // Inventar-Kategorien nach Typ
  static const List<String> inventarKategorienEquipment = [
    'beleuchtung',
    'belueftung',
    'bewaesserung',
    'messinstrumente',
    'zubehoer',
    'sonstige',
  ];

  static const List<String> inventarKategorienVerbrauch = [
    'duenger',
    'schaedlingsbekaempfung',
    'medium',
    'sonstige',
  ];

  /// Kategorien für einen bestimmten Typ
  static List<String> inventarKategorienFuerTyp(String typ) {
    return typ == 'equipment'
        ? inventarKategorienEquipment
        : inventarKategorienVerbrauch;
  }
}
