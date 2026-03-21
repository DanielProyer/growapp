import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../grow_tents/domain/entities/anbauflaeche.dart';
import '../../../grow_tents/presentation/providers/zelte_provider.dart';
import '../../../strains/presentation/providers/sorten_provider.dart';
import '../../domain/entities/durchgang.dart';
import '../providers/grows_provider.dart';

class GrowFormPage extends ConsumerStatefulWidget {
  final Durchgang? durchgang;

  const GrowFormPage({super.key, this.durchgang});

  @override
  ConsumerState<GrowFormPage> createState() => _GrowFormPageState();
}

class _GrowFormPageState extends ConsumerState<GrowFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _sorteId;
  String? _stecklingAnbauflaecheId;
  String? _vegiAnbauflaecheId;
  String? _blueteAnbauflaecheId;
  late String _typ;
  late String _status;
  late final TextEditingController _pflanzenStartController;
  late final TextEditingController _pflanzenVegiController;
  late final TextEditingController _pflanzenBlueteController;
  late final TextEditingController _bemerkungController;

  DateTime? _stecklingDatum;
  DateTime? _vegiStart;
  DateTime? _blueteStart;
  DateTime? _ernteDatum;
  DateTime? _einglasDatum;

  bool get _isEdit => widget.durchgang != null;

  @override
  void initState() {
    super.initState();
    final d = widget.durchgang;
    _sorteId = d?.sorteId;
    _stecklingAnbauflaecheId = d?.stecklingAnbauflaecheId;
    _vegiAnbauflaecheId = d?.vegiAnbauflaecheId;
    _blueteAnbauflaecheId = d?.blueteAnbauflaecheId;
    _typ = d?.typ ?? 'steckling';
    _status = d?.status ?? 'vorbereitung';
    _pflanzenStartController =
        TextEditingController(text: d?.pflanzenAnzahlStart?.toString() ?? '');
    _pflanzenVegiController =
        TextEditingController(text: d?.pflanzenAnzahlVegi?.toString() ?? '');
    _pflanzenBlueteController =
        TextEditingController(text: d?.pflanzenAnzahlBluete?.toString() ?? '');
    _bemerkungController = TextEditingController(text: d?.bemerkung ?? '');
    _stecklingDatum = d?.stecklingDatum;
    _vegiStart = d?.vegiStart;
    _blueteStart = d?.blueteStart;
    _ernteDatum = d?.ernteDatum;
    _einglasDatum = d?.einglasDatum;
  }

  @override
  void dispose() {
    _pflanzenStartController.dispose();
    _pflanzenVegiController.dispose();
    _pflanzenBlueteController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  String? _trimOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final d = Durchgang(
        id: widget.durchgang?.id ?? '',
        sorteId: _sorteId,
        typ: _typ,
        status: _status,
        pflanzenAnzahlStart: int.tryParse(_pflanzenStartController.text),
        pflanzenAnzahlVegi: int.tryParse(_pflanzenVegiController.text),
        pflanzenAnzahlBluete: int.tryParse(_pflanzenBlueteController.text),
        stecklingAnbauflaecheId: _stecklingAnbauflaecheId,
        vegiAnbauflaecheId: _vegiAnbauflaecheId,
        blueteAnbauflaecheId: _blueteAnbauflaecheId,
        stecklingDatum: _stecklingDatum,
        vegiStart: _vegiStart,
        blueteStart: _blueteStart,
        ernteDatum: _ernteDatum,
        einglasDatum: _einglasDatum,
        bemerkung: _trimOrNull(_bemerkungController),
        // Ernte-Felder behalten falls bearbeitet
        ernteMethode: widget.durchgang?.ernteMethode,
        trockenErtragG: widget.durchgang?.trockenErtragG,
        trimG: widget.durchgang?.trimG,
        ertragProWatt: widget.durchgang?.ertragProWatt,
        siebung1: widget.durchgang?.siebung1,
        siebung2: widget.durchgang?.siebung2,
        siebung3: widget.durchgang?.siebung3,
      );

      final ds = ref.read(durchgaengeDatasourceProvider);
      if (_isEdit) {
        await durchgangAktualisieren(ds, d);
      } else {
        await durchgangErstellen(ds, d);
      }

      await ref.read(durchgaengeListeProvider.notifier).aktualisieren();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEdit ? 'Durchgang aktualisiert' : 'Durchgang erstellt')),
        );
        context.pop();
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
    final zelteAsync = ref.watch(zelteListeProvider);
    final df = DateFormat('dd.MM.yyyy');

    // Alle Anbauflächen aus allen Zelten sammeln
    List<_FlaecheOption> flaechenOptionen = [];
    if (zelteAsync.hasValue) {
      for (final zelt in zelteAsync.value!) {
        final flaechenAsync = ref.watch(anbauflaechenProvider(zelt.id));
        if (flaechenAsync.hasValue) {
          for (final f in flaechenAsync.value!) {
            flaechenOptionen.add(_FlaecheOption(f, zelt.name));
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Durchgang bearbeiten' : 'Neuer Durchgang'),
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

                  // Sorte
                  sortenAsync.when(
                    data: (sorten) => DropdownButtonFormField<String>(
                      initialValue: _sorteId,
                      decoration: const InputDecoration(labelText: 'Sorte *'),
                      items: sorten
                          .map((s) => DropdownMenuItem(
                              value: s.id, child: Text(s.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _sorteId = v),
                      validator: (v) =>
                          v == null ? 'Sorte auswählen' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Fehler: $e'),
                  ),

                  const SizedBox(height: 12),

                  // Typ + Status
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _typ,
                          decoration:
                              const InputDecoration(labelText: 'Typ *'),
                          items: AppConstants.durchgangTypen
                              .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                      t == 'samen' ? 'Samen' : 'Steckling')))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _typ = v;
                                // Status zurücksetzen wenn er nicht zum neuen Typ passt
                                final erlaubt = AppConstants.durchgangStatusFuerTyp(v);
                                if (!erlaubt.contains(_status)) {
                                  _status = 'vorbereitung';
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('status-$_typ-$_status'),
                          initialValue: _status,
                          decoration:
                              const InputDecoration(labelText: 'Status'),
                          items: AppConstants.durchgangStatusFuerTyp(_typ)
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

                  const SizedBox(height: 28),

                  // ── Anbauflächen & Pflanzen pro Phase ──
                  const _SectionHeader(title: 'Anbauflächen & Pflanzen'),
                  const SizedBox(height: 4),
                  Text(
                    'Anbaufläche und Pflanzenanzahl pro Phase. Anzahl kann sinken durch Ausfälle oder Aussortierung.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),

                  // Erste Phase (abhängig vom Typ)
                  _PhaseRow(
                    label: _typ == 'samen' ? 'Keimung' : 'Steckling',
                    anbauflaecheId: _stecklingAnbauflaecheId,
                    flaechenOptionen: flaechenOptionen,
                    onAnbauflaecheChanged: (v) =>
                        setState(() => _stecklingAnbauflaecheId = v),
                    anzahlController: _pflanzenStartController,
                    anzahlLabel: _typ == 'samen' ? 'Samen' : 'Stecklinge',
                  ),
                  const SizedBox(height: 12),

                  // Vegi-Phase
                  _PhaseRow(
                    label: 'Vegetation',
                    anbauflaecheId: _vegiAnbauflaecheId,
                    flaechenOptionen: flaechenOptionen,
                    onAnbauflaecheChanged: (v) =>
                        setState(() => _vegiAnbauflaecheId = v),
                    anzahlController: _pflanzenVegiController,
                    anzahlLabel: 'Pflanzen',
                  ),
                  const SizedBox(height: 12),

                  // Blüte-Phase
                  _PhaseRow(
                    label: 'Blüte',
                    anbauflaecheId: _blueteAnbauflaecheId,
                    flaechenOptionen: flaechenOptionen,
                    onAnbauflaecheChanged: (v) =>
                        setState(() => _blueteAnbauflaecheId = v),
                    anzahlController: _pflanzenBlueteController,
                    anzahlLabel: 'Pflanzen',
                  ),

                  const SizedBox(height: 28),

                  // ── Termine ──
                  const _SectionHeader(title: 'Termine'),
                  const SizedBox(height: 12),

                  _DateField(
                    label: _typ == 'samen' ? 'Keimung' : 'Steckling',
                    date: _stecklingDatum,
                    df: df,
                    onTap: () async {
                      final d = await _pickDate(context, _stecklingDatum);
                      if (d != null) setState(() => _stecklingDatum = d);
                    },
                    onClear: () => setState(() => _stecklingDatum = null),
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Vegi-Start',
                    date: _vegiStart,
                    df: df,
                    onTap: () async {
                      final d = await _pickDate(context, _vegiStart);
                      if (d != null) setState(() => _vegiStart = d);
                    },
                    onClear: () => setState(() => _vegiStart = null),
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
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Einglas-Datum',
                    date: _einglasDatum,
                    df: df,
                    onTap: () async {
                      final d = await _pickDate(context, _einglasDatum);
                      if (d != null) setState(() => _einglasDatum = d);
                    },
                    onClear: () => setState(() => _einglasDatum = null),
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
                    maxLines: 4,
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
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_isEdit
                          ? 'Durchgang aktualisieren'
                          : 'Durchgang starten'),
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

class _FlaecheOption {
  final Anbauflaeche flaeche;
  final String zeltName;
  _FlaecheOption(this.flaeche, this.zeltName);
}

class _PhaseRow extends StatelessWidget {
  final String label;
  final String? anbauflaecheId;
  final List<_FlaecheOption> flaechenOptionen;
  final ValueChanged<String?> onAnbauflaecheChanged;
  final TextEditingController anzahlController;
  final String anzahlLabel;

  const _PhaseRow({
    required this.label,
    required this.anbauflaecheId,
    required this.flaechenOptionen,
    required this.onAnbauflaecheChanged,
    required this.anzahlController,
    required this.anzahlLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValue =
        flaechenOptionen.any((o) => o.flaeche.id == anbauflaecheId)
            ? anbauflaecheId
            : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            key: ValueKey('$label-$effectiveValue'),
            initialValue: effectiveValue,
            decoration: InputDecoration(labelText: '$label – Anbaufläche'),
            items: [
              const DropdownMenuItem(
                  value: null, child: Text('– nicht zugewiesen –')),
              ...flaechenOptionen.map((o) => DropdownMenuItem(
                  value: o.flaeche.id,
                  child: Text('${o.zeltName} → ${o.flaeche.name}'))),
            ],
            onChanged: onAnbauflaecheChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: anzahlController,
            decoration: InputDecoration(labelText: anzahlLabel),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}

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
