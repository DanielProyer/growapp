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
  static const String tabelleInventar = 'inventar';
  static const String tabelleInventarBuchungen = 'inventar_buchungen';
  static const String tabelleFotos = 'fotos';
  static const String tabelleKalenderEintraege = 'kalender_eintraege';
  static const String tabelleBenachrichtigungen = 'benachrichtigungen';

  // Durchgang-Status
  static const List<String> durchgangStatus = [
    'vorbereitung',
    'vegetation',
    'bluete',
    'ernte',
    'curing',
    'beendet',
  ];

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
    'aktiv',
    'selektion',
    'beendet',
    'stash',
  ];

  // Schädlingstypen
  static const List<String> schaedlingsTypen = [
    'thripse',
    'spinnmilben',
    'trauermücken',
    'sonstige',
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

  // Inventar-Kategorien
  static const List<String> inventarKategorien = [
    'duenger',
    'schaedlingsbekaempfung',
    'medium',
    'equipment',
    'sonstige',
  ];
}
