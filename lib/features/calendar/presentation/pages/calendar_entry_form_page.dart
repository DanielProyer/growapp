import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../grows/presentation/providers/grows_provider.dart';
import '../../domain/entities/kalender_eintrag.dart';
import '../providers/kalender_provider.dart';

class CalendarEntryFormPage extends ConsumerStatefulWidget {
  final KalenderEintrag? eintrag;
  final DateTime? vorausgewaehltesDatum;

  const CalendarEntryFormPage({
    super.key,
    this.eintrag,
    this.vorausgewaehltesDatum,
  });

  @override
  ConsumerState<CalendarEntryFormPage> createState() =>
      _CalendarEntryFormPageState();
}

class _CalendarEntryFormPageState extends ConsumerState<CalendarEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titelController;
  late final TextEditingController _beschreibungController;
  late String _typ;
  late DateTime _datum;
  late TimeOfDay _uhrzeit;
  late int _erinnerungMinuten;
  String? _durchgangId;
  bool _speichert = false;

  bool get _istBearbeitung => widget.eintrag != null;

  @override
  void initState() {
    super.initState();
    final e = widget.eintrag;
    _titelController = TextEditingController(text: e?.titel ?? '');
    _beschreibungController =
        TextEditingController(text: e?.beschreibung ?? '');
    _typ = e?.typ ?? 'allgemein';
    _datum = e?.geplantAm.toLocal() ??
        widget.vorausgewaehltesDatum ??
        DateTime.now();
    _uhrzeit = e != null
        ? TimeOfDay.fromDateTime(e.geplantAm.toLocal())
        : const TimeOfDay(hour: 12, minute: 0);
    _erinnerungMinuten = e?.erinnerungMinuten ?? 0;
    _durchgangId = e?.durchgangId;
  }

  @override
  void dispose() {
    _titelController.dispose();
    _beschreibungController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final durchgaengeAsync = ref.watch(aktiveDurchgaengeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_istBearbeitung ? 'Termin bearbeiten' : 'Neuer Termin'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Titel
            TextFormField(
              controller: _titelController,
              decoration: const InputDecoration(
                labelText: 'Titel *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Titel eingeben' : null,
            ),
            const SizedBox(height: 16),

            // Typ
            DropdownButtonFormField<String>(
              initialValue: _typ,
              decoration: const InputDecoration(
                labelText: 'Typ',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.kalenderTypen.map((typ) {
                return DropdownMenuItem(
                  value: typ,
                  child: Row(
                    children: [
                      Icon(_typIcon(typ), size: 20),
                      const SizedBox(width: 8),
                      Text(_typLabel(typ)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _typ = v);
              },
            ),
            const SizedBox(height: 16),

            // Datum + Uhrzeit
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _datumWaehlen,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Datum',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd.MM.yyyy').format(_datum),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _uhrzeitWaehlen,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Uhrzeit',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        '${_uhrzeit.hour.toString().padLeft(2, '0')}:${_uhrzeit.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Erinnerung
            DropdownButtonFormField<int>(
              initialValue: _erinnerungMinuten,
              decoration: const InputDecoration(
                labelText: 'Erinnerung',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.erinnerungsOptionen.map((min) {
                return DropdownMenuItem(
                  value: min,
                  child: Text(_erinnerungLabel(min)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _erinnerungMinuten = v);
              },
            ),
            const SizedBox(height: 16),

            // Durchgang (optional)
            durchgaengeAsync.when(
              data: (durchgaenge) {
                if (durchgaenge.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<String?>(
                  initialValue: _durchgangId,
                  decoration: const InputDecoration(
                    labelText: 'Durchgang (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Kein Durchgang'),
                    ),
                    ...durchgaenge.map((d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(d.titel),
                        )),
                  ],
                  onChanged: (v) => setState(() => _durchgangId = v),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Beschreibung
            TextFormField(
              controller: _beschreibungController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Speichern-Button
            FilledButton.icon(
              onPressed: _speichert ? null : _speichern,
              icon: _speichert
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_istBearbeitung ? 'Aktualisieren' : 'Erstellen'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _datumWaehlen() async {
    final gewaehlt = await showDatePicker(
      context: context,
      initialDate: _datum,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('de'),
    );
    if (gewaehlt != null) {
      setState(() => _datum = gewaehlt);
    }
  }

  Future<void> _uhrzeitWaehlen() async {
    final gewaehlt = await showTimePicker(
      context: context,
      initialTime: _uhrzeit,
    );
    if (gewaehlt != null) {
      setState(() => _uhrzeit = gewaehlt);
    }
  }

  Future<void> _speichern() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _speichert = true);

    try {
      final geplantAm = DateTime(
        _datum.year,
        _datum.month,
        _datum.day,
        _uhrzeit.hour,
        _uhrzeit.minute,
      );

      final eintrag = KalenderEintrag(
        id: widget.eintrag?.id ?? '',
        titel: _titelController.text.trim(),
        beschreibung: _beschreibungController.text.trim().isEmpty
            ? null
            : _beschreibungController.text.trim(),
        typ: _typ,
        geplantAm: geplantAm,
        erledigt: widget.eintrag?.erledigt ?? false,
        durchgangId: _durchgangId,
        erinnerungMinuten: _erinnerungMinuten,
      );

      final notifier = ref.read(kalenderListeProvider.notifier);
      if (_istBearbeitung) {
        await notifier.eintragAktualisieren(widget.eintrag!.id, eintrag);
      } else {
        await notifier.erstellen(eintrag);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _speichert = false);
    }
  }

  String _typLabel(String typ) {
    switch (typ) {
      case 'bewaesserung':
        return 'Bewässerung';
      case 'duengung':
        return 'Düngung';
      case 'ernte':
        return 'Ernte';
      case 'stecklinge':
        return 'Stecklinge';
      case 'umtopfen':
        return 'Umtopfen';
      case 'schaedlingskontrolle':
        return 'Schädlingskontrolle';
      case 'foto':
        return 'Foto';
      case 'allgemein':
        return 'Allgemein';
      default:
        return typ;
    }
  }

  IconData _typIcon(String typ) {
    switch (typ) {
      case 'bewaesserung':
        return Icons.water_drop;
      case 'duengung':
        return Icons.science;
      case 'ernte':
        return Icons.content_cut;
      case 'stecklinge':
        return Icons.call_split;
      case 'umtopfen':
        return Icons.swap_vert;
      case 'schaedlingskontrolle':
        return Icons.bug_report;
      case 'foto':
        return Icons.camera_alt;
      case 'allgemein':
      default:
        return Icons.event;
    }
  }

  String _erinnerungLabel(int minuten) {
    switch (minuten) {
      case 0:
        return 'Keine Erinnerung';
      case 15:
        return '15 Min vorher';
      case 30:
        return '30 Min vorher';
      case 60:
        return '1 Std vorher';
      case 1440:
        return '1 Tag vorher';
      default:
        return '$minuten Min vorher';
    }
  }
}
