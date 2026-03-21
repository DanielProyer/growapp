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

  String? _anbauflaecheId;
  String? _sorteId;
  late String _status;
  late final TextEditingController _pflanzenAnzahlController;
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
    _anbauflaecheId = d?.anbauflaecheId;
    _sorteId = d?.sorteId;
    _status = d?.status ?? 'vorbereitung';
    _pflanzenAnzahlController =
        TextEditingController(text: d?.pflanzenAnzahl?.toString() ?? '');
    _bemerkungController = TextEditingController(text: d?.bemerkung ?? '');
    _stecklingDatum = d?.stecklingDatum;
    _vegiStart = d?.vegiStart;
    _blueteStart = d?.blueteStart;
    _ernteDatum = d?.ernteDatum;
    _einglasDatum = d?.einglasDatum;
  }

  @override
  void dispose() {
    _pflanzenAnzahlController.dispose();
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
        anbauflaecheId: _anbauflaecheId,
        sorteId: _sorteId,
        status: _status,
        pflanzenAnzahl: int.tryParse(_pflanzenAnzahlController.text),
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

                  // Anbaufläche
                  DropdownButtonFormField<String>(
                    initialValue: _anbauflaecheId,
                    decoration:
                        const InputDecoration(labelText: 'Anbaufläche *'),
                    items: flaechenOptionen
                        .map((o) => DropdownMenuItem(
                            value: o.flaeche.id,
                            child: Text('${o.zeltName} → ${o.flaeche.name}')))
                        .toList(),
                    onChanged: (v) => setState(() => _anbauflaecheId = v),
                    validator: (v) =>
                        v == null ? 'Anbaufläche auswählen' : null,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration:
                              const InputDecoration(labelText: 'Status'),
                          items: AppConstants.durchgangStatus
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _pflanzenAnzahlController,
                          decoration: const InputDecoration(
                              labelText: 'Pflanzenanzahl'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Termine ──
                  const _SectionHeader(title: 'Termine'),
                  const SizedBox(height: 12),

                  _DateField(
                    label: 'Steckling/Keimung',
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
