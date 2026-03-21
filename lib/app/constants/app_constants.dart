/// App-weite Konstanten
class AppConstants {
  AppConstants._();

  static const String appName = 'GrowApp';
  static const String appVersion = '0.1.0';

  // Breakpoints für Responsive Design
  static const double breakpointCompact = 600;
  static const double breakpointMedium = 1024;
  static const double breakpointExpanded = 1200;

  // Grow-Status
  static const List<String> growStatuses = [
    'vorbereitung',
    'vegetation',
    'blüte',
    'ernte',
    'curing',
    'beendet',
  ];

  // Pflanzen-Status
  static const List<String> plantStatuses = [
    'keimung',
    'vegetation',
    'blüte',
    'ernte',
    'beendet',
    'entsorgt',
  ];

  // Sorten-Status
  static const List<String> strainStatuses = [
    'aktiv',
    'selektion',
    'beendet',
    'stash',
  ];

  // Schädlingstypen
  static const List<String> pestTypes = [
    'thripse',
    'spinnmilben',
    'trauermücken',
    'sonstige',
  ];

  // Schweregrade
  static const List<String> severityLevels = [
    'niedrig',
    'mittel',
    'hoch',
    'kritisch',
  ];

  // Erntemethoden
  static const List<String> harvestMethods = [
    'nassschnitt',
    'trimbag',
    'handschnitt',
  ];

  // Keeper-Status
  static const List<String> keeperStatuses = [
    'ja',
    'nein',
    'vielleicht',
  ];

  // Inventar-Kategorien
  static const List<String> inventoryCategories = [
    'dünger',
    'schädlingsbekämpfung',
    'medium',
    'equipment',
    'sonstige',
  ];
}
