import 'package:intl/intl.dart';

/// Curing-Messwert Entity - Einzelne Messung für ein Glas
class CuringMesswert {
  final String id;
  final String glasId;
  final DateTime datum;
  final int? rlfProzent;
  final double? temperatur;
  final double? gewichtG;
  final bool gelueftet;
  final int? lueftungsdauerMin;
  final String? bemerkung;
  final String? erstelltVon;

  const CuringMesswert({
    required this.id,
    required this.glasId,
    required this.datum,
    this.rlfProzent,
    this.temperatur,
    this.gewichtG,
    this.gelueftet = false,
    this.lueftungsdauerMin,
    this.bemerkung,
    this.erstelltVon,
  });

  String get datumFormatiert => DateFormat('dd.MM.yyyy').format(datum);
}
