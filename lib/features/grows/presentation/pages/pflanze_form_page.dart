import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../strains/presentation/providers/sorten_provider.dart';
import '../../domain/entities/pflanze.dart';
import '../providers/grows_provider.dart';

class PflanzeFormPage extends ConsumerStatefulWidget {
  final String durchgangId;
  final Pflanze? pflanze;
  final int? naechsteNummer;

  const PflanzeFormPage({
    super.key,
    required this.durchgangId,
    this.pflanze,
    this.naechsteNummer,
  });

  @override
  ConsumerState<PflanzeFormPage> createState() => _PflanzeFormPageState();
}

class _PflanzeFormPageState extends ConsumerState<PflanzeFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nrController;
  late String _status;
  String? _sorteId;

  // Termine
  DateTime? _aussaatDatum;
  DateTime? _keimDatum;
  DateTime? _topf1lDatum;
  DateTime? _blueteStart;
  DateTime? _ernteDatum;

  // Messungen
  late final TextEditingController _hoeheBlueteStartController;
  late final TextEditingController _hoeheErnteController;
  late final TextEditingController _stammdickeBlueteController;
  late final TextEditingController _stammdickeErnteController;
  late final TextEditingController _nassGewichtController;
  late final TextEditingController _trockenGewichtController;

  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.pflanze != null;

  @override
  void initState() {
    super.initState();
    final p = widget.pflanze;

    _nrController = TextEditingController(
        text: p?.pflanzenNr.toString() ??
            widget.naechsteNummer?.toString() ??
            '');
    _status = p?.status ?? 'keimung';
    _sorteId = p?.sorteId;

    _aussaatDatum = p?.aussaatDatum;
    _keimDatum = p?.keimDatum;
    _topf1lDatum = p?.topf1lDatum;
    _blueteStart = p?.blueteStart;
    _ernteDatum = p?.ernteDatum;

    _hoeheBlueteStartController =
        TextEditingController(text: p?.hoeheBlueteStart?.toString() ?? '');
    _hoeheErnteController =
        TextEditingController(text: p?.hoeheErnte?.toString() ?? '');
    _stammdickeBlueteController =
        TextEditingController(text: p?.stammdickeBluete?.toString() ?? '');
    _stammdickeErnteController =
        TextEditingController(text: p?.stammdickeErnte?.toString() ?? '');
    _nassGewichtController =
        TextEditingController(text: p?.nassGewichtG?.toString() ?? '');
    _trockenGewichtController =
        TextEditingController(text: p?.trockenGewichtG?.toString() ?? '');

    _bemerkungController = TextEditingController(text: p?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _nrController.dispose();
    _hoeheBlueteStartController.dispose();
    _hoeheErnteController.dispose();
    _stammdickeBlueteController.dispose();
    _stammdickeErnteController.dispose();
    _nassGewichtController.dispose();
    _trockenGewichtController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('de'),
    );
  }

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final pflanze = Pflanze(
        id: widget.pflanze?.id ?? '',
        durchgangId: widget.durchgangId,
        sorteId: _sorteId,
        pflanzenNr: int.parse(_nrController.text),
        status: _status,
        aussaatDatum: _aussaatDatum,
        keimDatum: _keimDatum,
        topf1lDatum: _topf1lDatum,
        blueteStart: _blueteStart,
        ernteDatum: _ernteDatum,
        hoeheBlueteStart:
            double.tryParse(_hoeheBlueteStartController.text),
        hoeheErnte: double.tryParse(_hoeheErnteController.text),
        stammdickeBluete:
            double.tryParse(_stammdickeBlueteController.text),
        stammdickeErnte:
            double.tryParse(_stammdickeErnteController.text),
        nassGewichtG: double.tryParse(_nassGewichtController.text),
        trockenGewichtG: double.tryParse(_trockenGewichtController.text),
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      final ds = ref.read(pflanzenDatasourceProvider);
      if (_isEdit) {
        await pflanzeAktualisieren(ds, pflanze);
      } else {
        await pflanzeErstellen(ds, pflanze);
      }

      ref.invalidate(pflanzenProvider(widget.durchgangId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEdit ? 'Pflanze aktualisiert' : 'Pflanze erstellt')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Fehler: $e'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortenAsync = ref.watch(sortenListeProvider);
    final df = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Pflanze bearbeiten' : 'Neue Pflanze'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _speichern,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save, color: Colors.white),
            label: Text('Speichern',
                style: TextStyle(
                    color: _isLoading ? Colors.grey : Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Grunddaten ──
                  const _SectionHeader(title: 'Grunddaten'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nrController,
                          decoration: const InputDecoration(
                            labelText: 'Pflanze Nr. *',
                            prefixIcon: Icon(Icons.tag),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Nummer erforderlich'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: AppConstants.pflanzenStatus
                              .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                      s[0].toUpperCase() + s.substring(1))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _status = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Optionale Sorte (Override)
                  sortenAsync.when(
                    data: (sorten) => DropdownButtonFormField<String>(
                      initialValue: _sorteId,
                      decoration: const InputDecoration(
                        labelText: 'Sorte (optional)',
                        hintText: 'Vom Durchgang geerbt',
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null,
                            child: Text('– Vom Durchgang geerbt –')),
                        ...sorten.map((s) => DropdownMenuItem(
                            value: s.id, child: Text(s.name))),
                      ],
                      onChanged: (v) => setState(() => _sorteId = v),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Fehler: $e'),
                  ),

                  const SizedBox(height: 28),

                  // ── Termine ──
                  const _SectionHeader(title: 'Termine'),
                  const SizedBox(height: 12),

                  _DateField(
                    label: 'Aussaat',
                    date: _aussaatDatum,
                    df: df,
                    onTap: () async {
                      final d = await _pickDate(context, _aussaatDatum);
                      if (d != null) setState(() => _aussaatDatum = d);
                    },
                    onClear: () => setState(() => _aussaatDatum = null),
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Keimung',
                    date: _keimDatum,
                    df: df,
                    onTap: () async {
                      final d = await _pickDate(context, _keimDatum);
                      if (d != null) setState(() => _keimDatum = d);
                    },
                    onClear: () => setState(() => _keimDatum = null),
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Umtopfen (1L)',
                    date: _topf1lDatum,
                    df: df,
                    onTap: () async {
                      final d = await _pickDate(context, _topf1lDatum);
                      if (d != null) setState(() => _topf1lDatum = d);
                    },
                    onClear: () => setState(() => _topf1lDatum = null),
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Blüte-Start',
                    date: _blueteStart,
                    df: df,
                    onTap: () async {
                      final d = await _pickDate(context, _blueteStart);
                      if (d != null) setState(() => _blueteStart = d);
                    },
                    onClear: () => setState(() => _blueteStart = null),
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Ernte-Datum',
                    date: _ernteDatum,
                    df: df,
                    onTap: () async {
                      final d = await _pickDate(context, _ernteDatum);
                      if (d != null) setState(() => _ernteDatum = d);
                    },
                    onClear: () => setState(() => _ernteDatum = null),
                  ),

                  const SizedBox(height: 28),

                  // ── Messungen ──
                  const _SectionHeader(title: 'Messungen'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoeheBlueteStartController,
                          decoration: const InputDecoration(
                            labelText: 'Höhe Blütestart',
                            suffixText: 'cm',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _hoeheErnteController,
                          decoration: const InputDecoration(
                            labelText: 'Höhe Ernte',
                            suffixText: 'cm',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stammdickeBlueteController,
                          decoration: const InputDecoration(
                            labelText: 'Stammdicke Blüte',
                            suffixText: 'mm',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stammdickeErnteController,
                          decoration: const InputDecoration(
                            labelText: 'Stammdicke Ernte',
                            suffixText: 'mm',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nassGewichtController,
                          decoration: const InputDecoration(
                            labelText: 'Nassgewicht',
                            suffixText: 'g',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _trockenGewichtController,
                          decoration: const InputDecoration(
                            labelText: 'Trockengewicht',
                            suffixText: 'g',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Bemerkung ──
                  const _SectionHeader(title: 'Bemerkung'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bemerkungController,
                    decoration: const InputDecoration(
                      labelText: 'Bemerkung',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _speichern,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_isEdit
                          ? 'Pflanze aktualisieren'
                          : 'Pflanze erstellen'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final _decimalFormatter =
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat df;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.label,
    required this.date,
    required this.df,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          date != null ? df.format(date!) : '',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Divider(color: Theme.of(context).colorScheme.primary.withAlpha(50)),
      ],
    );
  }
}
