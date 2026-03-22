import 'package:intl/intl.dart';

/// SchaedlingsBehandlung Entity - Repräsentiert eine Behandlung
class SchaedlingsBehandlung {
  final String id;
  final String? vorfallId;
  final String zeltId;
  final String behandlungTyp;
  final String mittel;
  final String? menge;
  final DateTime datum;
  final String? wirksamkeit;
  final String? bemerkung;
  final String? erstelltVon;
  final DateTime? erstelltAm;
  final DateTime? aktualisiertAm;

  // Join-Daten
  final String? zeltName;

  const SchaedlingsBehandlung({
    required this.id,
    this.vorfallId,
    required this.zeltId,
    required this.behandlungTyp,
    required this.mittel,
    this.menge,
    required this.datum,
    this.wirksamkeit,
    this.bemerkung,
    this.erstelltVon,
    this.erstelltAm,
    this.aktualisiertAm,
    this.zeltName,
  });

  bool get istProphylaktisch => vorfallId == null;

  String get behandlungTypLabel => behandlungTypLabelFuer(behandlungTyp);

  String get datumFormatiert => DateFormat('dd.MM.yyyy').format(datum);

  String get wirksamkeitLabel {
    if (wirksamkeit == null) return '';
    return wirksamkeitLabelFuer(wirksamkeit!);
  }

  static String behandlungTypLabelFuer(String typ) {
    switch (typ) {
      case 'biologisch':
        return 'Biologisch';
      case 'chemisch':
        return 'Chemisch';
      case 'mechanisch':
        return 'Mechanisch';
      case 'nuetzlinge':
        return 'Nützlinge';
      default:
        return typ;
    }
  }

  static String wirksamkeitLabelFuer(String w) {
    switch (w) {
      case 'keine':
        return 'Keine';
      case 'gering':
        return 'Gering';
      case 'mittel':
        return 'Mittel';
      case 'gut':
        return 'Gut';
      case 'sehr_gut':
        return 'Sehr gut';
      default:
        return w;
    }
  }
}
