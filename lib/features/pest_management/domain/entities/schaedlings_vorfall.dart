import 'package:intl/intl.dart';

/// SchaedlingsVorfall Entity - Repräsentiert einen Schädlingsvorfall
class SchaedlingsVorfall {
  final String id;
  final String? zeltId;
  final String? durchgangId;
  final String schaedlingTyp;
  final String schweregrad;
  final DateTime erkanntDatum;
  final DateTime? behobenDatum;
  final String? behandlung;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  // Join-Daten
  final String? zeltName;

  const SchaedlingsVorfall({
    required this.id,
    this.zeltId,
    this.durchgangId,
    required this.schaedlingTyp,
    this.schweregrad = 'niedrig',
    required this.erkanntDatum,
    this.behobenDatum,
    this.behandlung,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
    this.zeltName,
  });

  bool get istBehoben => behobenDatum != null;

  String get statusLabel => istBehoben ? 'Behoben' : 'Offen';

  String get schaedlingLabel => schaedlingTypLabelFuer(schaedlingTyp);

  String get schweregradLabel {
    switch (schweregrad) {
      case 'niedrig':
        return 'Niedrig';
      case 'mittel':
        return 'Mittel';
      case 'hoch':
        return 'Hoch';
      case 'kritisch':
        return 'Kritisch';
      default:
        return schweregrad;
    }
  }

  String get erkanntDatumFormatiert =>
      DateFormat('dd.MM.yyyy').format(erkanntDatum);

  String get behobenDatumFormatiert => behobenDatum != null
      ? DateFormat('dd.MM.yyyy').format(behobenDatum!)
      : '';

  static String schaedlingTypLabelFuer(String typ) {
    switch (typ) {
      case 'thripse':
        return 'Thripse';
      case 'spinnmilben':
        return 'Spinnmilben';
      case 'trauermücken':
        return 'Trauermücken';
      case 'blattlaeuse':
        return 'Blattläuse';
      case 'weisse_fliegen':
        return 'Weiße Fliegen';
      case 'minierfliegen':
        return 'Minierfliegen';
      case 'breitmilben':
        return 'Breitmilben';
      case 'rostmilben':
        return 'Rostmilben';
      case 'raupen':
        return 'Raupen';
      case 'echter_mehltau':
        return 'Echter Mehltau';
      case 'falscher_mehltau':
        return 'Falscher Mehltau';
      case 'botrytis':
        return 'Botrytis';
      case 'wurzelfaeule':
        return 'Wurzelfäule';
      case 'alternaria':
        return 'Alternaria';
      case 'septoria':
        return 'Septoria';
      case 'umfallkrankheit':
        return 'Umfallkrankheit';
      case 'sonstige':
        return 'Sonstige';
      default:
        return typ;
    }
  }
}
