import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../grows/domain/entities/durchgang.dart';
import '../../../grows/presentation/providers/grows_provider.dart';
import '../../domain/entities/tages_log.dart';
import '../providers/tages_logs_provider.dart';

class DailyLogFormPage extends ConsumerStatefulWidget {
  final TagesLog? log;
  final String? vorausgewaehlterDurchgangId;

  const DailyLogFormPage({
    super.key,
    this.log,
    this.vorausgewaehlterDurchgangId,
  });

  @override
  ConsumerState<DailyLogFormPage> createState() => _DailyLogFormPageState();
}

class _DailyLogFormPageState extends ConsumerState<DailyLogFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _durchgangId;
  late DateTime _datum;

  // Umgebung
  late final TextEditingController _tempTagController;
  late final TextEditingController _tempNachtController;
  late final TextEditingController _relfTagController;
  late final TextEditingController _relfNachtController;
  late final TextEditingController _lichtWattController;
  late final TextEditingController _lampenHoeheController;
  late final TextEditingController _pflanzenHoeheController;

  // Bewässerung / Tank
  late final TextEditingController _wasserMlController;
  late final TextEditingController _phController;
  late final TextEditingController _ecController;
  late final TextEditingController _tankFuellstandController;
  late final TextEditingController _tankTempController;

  // Nährstoffe
  late List<_NaehrstoffEintrag> _naehrstoffEintraege;

  // Bemerkung
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.log != null;

  @override
  void initState() {
    super.initState();
    final l = widget.log;

    _durchgangId = l?.durchgangId ?? widget.vorausgewaehlterDurchgangId;
    _datum = l?.datum ?? DateTime.now();

    _tempTagController =
        TextEditingController(text: l?.tempTag?.toString() ?? '');
    _tempNachtController =
        TextEditingController(text: l?.tempNacht?.toString() ?? '');
    _relfTagController =
        TextEditingController(text: l?.relfTag?.toString() ?? '');
    _relfNachtController =
        TextEditingController(text: l?.relfNacht?.toString() ?? '');
    _lichtWattController =
        TextEditingController(text: l?.lichtWatt?.toString() ?? '');
    _lampenHoeheController =
        TextEditingController(text: l?.lampenHoehe?.toString() ?? '');
    _pflanzenHoeheController =
        TextEditingController(text: l?.pflanzenHoehe?.toString() ?? '');

    _wasserMlController =
        TextEditingController(text: l?.wasserMl?.toString() ?? '');
    _phController = TextEditingController(text: l?.ph?.toString() ?? '');
    _ecController = TextEditingController(text: l?.ec?.toString() ?? '');
    _tankFuellstandController =
        TextEditingController(text: l?.tankFuellstand?.toString() ?? '');
    _tankTempController =
        TextEditingController(text: l?.tankTemp?.toString() ?? '');

    _bemerkungController = TextEditingController(text: l?.bemerkung ?? '');

    // Nährstoffe initialisieren
    if (l?.naehrstoffe != null && l!.naehrstoffe!.isNotEmpty) {
      _naehrstoffEintraege = l.naehrstoffe!.entries
          .map((e) => _NaehrstoffEintrag(
                nameController: TextEditingController(text: e.key),
                mengeController:
                    TextEditingController(text: e.value.toString()),
              ))
          .toList();
    } else {
      _naehrstoffEintraege = [];
    }
  }

  @override
  void dispose() {
    _tempTagController.dispose();
    _tempNachtController.dispose();
    _relfTagController.dispose();
    _relfNachtController.dispose();
    _lichtWattController.dispose();
    _lampenHoeheController.dispose();
    _pflanzenHoeheController.dispose();
    _wasserMlController.dispose();
    _phController.dispose();
    _ecController.dispose();
    _tankFuellstandController.dispose();
    _tankTempController.dispose();
    _bemerkungController.dispose();
    for (final e in _naehrstoffEintraege) {
      e.nameController.dispose();
      e.mengeController.dispose();
    }
    super.dispose();
  }

  /// Berechnet Vegi/Blüte-Tag basierend auf Durchgang-Daten
  ({int? vegiTag, int? blueteTag}) _berechneTage(Durchgang durchgang) {
    int? vegiTag;
    int? blueteTag;

    if (durchgang.blueteStart != null) {
      final diff = _datum.difference(durchgang.blueteStart!).inDays;
      if (diff >= 0) blueteTag = diff + 1;
    }

    if (durchgang.vegiStart != null && blueteTag == null) {
      final diff = _datum.difference(durchgang.vegiStart!).inDays;
      if (diff >= 0) vegiTag = diff + 1;
    }

    return (vegiTag: vegiTag, blueteTag: blueteTag);
  }

  Map<String, double>? _parseNaehrstoffe() {
    final map = <String, double>{};
    for (final e in _naehrstoffEintraege) {
      final name = e.nameController.text.trim();
      final menge = double.tryParse(e.mengeController.text.trim());
      if (name.isNotEmpty && menge != null) {
        map[name] = menge;
      }
    }
    return map.isEmpty ? null : map;
  }

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_durchgangId == null) return;

    setState(() => _isLoading = true);

    try {
      // Durchgang-Daten laden für Tage-Berechnung
      final ds = ref.read(durchgaengeDatasourceProvider);
      final durchgang = await ds.laden(_durchgangId!);

      int? vegiTag;
      int? blueteTag;
      if (durchgang != null) {
        final tage = _berechneTage(durchgang);
        vegiTag = tage.vegiTag;
        blueteTag = tage.blueteTag;
      }

      final log = TagesLog(
        id: widget.log?.id ?? '',
        durchgangId: _durchgangId!,
        datum: _datum,
        vegiTag: vegiTag,
        blueteTag: blueteTag,
        tempTag: double.tryParse(_tempTagController.text),
        tempNacht: double.tryParse(_tempNachtController.text),
        relfTag: double.tryParse(_relfTagController.text),
        relfNacht: double.tryParse(_relfNachtController.text),
        lichtWatt: int.tryParse(_lichtWattController.text),
        lampenHoehe: int.tryParse(_lampenHoeheController.text),
        pflanzenHoehe: double.tryParse(_pflanzenHoeheController.text),
        wasserMl: int.tryParse(_wasserMlController.text),
        ph: double.tryParse(_phController.text),
        ec: double.tryParse(_ecController.text),
        tankFuellstand: int.tryParse(_tankFuellstandController.text),
        tankTemp: double.tryParse(_tankTempController.text),
        naehrstoffe: _parseNaehrstoffe(),
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      final logDs = ref.read(tagesLogsDatasourceProvider);
      if (_isEdit) {
        await tagesLogAktualisieren(logDs, log);
      } else {
        await tagesLogErstellen(logDs, log);
      }

      // Provider refreshen
      ref.invalidate(tagesLogsFuerDurchgangProvider(_durchgangId!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(_isEdit ? 'Log aktualisiert' : 'Log erstellt')),
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

  Future<void> _loeschen() async {
    if (widget.log == null) return;

    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log löschen?'),
        content: const Text('Dieser Eintrag wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Löschen',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (bestaetigt != true) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(tagesLogsFuerDurchgangProvider(widget.log!.durchgangId).notifier)
          .loeschen(widget.log!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log gelöscht')),
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
    final durchgaengeAsync = ref.watch(aktiveDurchgaengeProvider);
    final df = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Log bearbeiten' : 'Neuer Log'),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _isLoading ? null : _loeschen,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
            ),
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

                  // Grow-Dropdown
                  durchgaengeAsync.when(
                    data: (durchgaenge) {
                      // Beim Bearbeiten auch den aktuellen (evtl. beendeten) Grow anzeigen
                      final items = durchgaenge
                          .map((d) => DropdownMenuItem(
                              value: d.id, child: Text(d.titel)))
                          .toList();

                      return DropdownButtonFormField<String>(
                        initialValue: _durchgangId,
                        decoration: const InputDecoration(
                          labelText: 'Grow-Durchgang *',
                          prefixIcon: Icon(Icons.eco_outlined),
                        ),
                        items: items,
                        onChanged: _isEdit
                            ? null
                            : (v) => setState(() => _durchgangId = v),
                        validator: (v) =>
                            v == null ? 'Grow auswählen' : null,
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Fehler: $e'),
                  ),
                  const SizedBox(height: 12),

                  // Datum
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _datum,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        locale: const Locale('de'),
                      );
                      if (picked != null) {
                        setState(() => _datum = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Datum *',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        df.format(_datum),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Umgebung ──
                  const _SectionHeader(title: 'Umgebung'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tempTagController,
                          decoration: const InputDecoration(
                            labelText: 'Temp. Tag',
                            suffixText: '°C',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _tempNachtController,
                          decoration: const InputDecoration(
                            labelText: 'Temp. Nacht',
                            suffixText: '°C',
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
                          controller: _relfTagController,
                          decoration: const InputDecoration(
                            labelText: 'RLF Tag',
                            suffixText: '%',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _relfNachtController,
                          decoration: const InputDecoration(
                            labelText: 'RLF Nacht',
                            suffixText: '%',
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
                          controller: _lichtWattController,
                          decoration: const InputDecoration(
                            labelText: 'Licht',
                            suffixText: 'W',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lampenHoeheController,
                          decoration: const InputDecoration(
                            labelText: 'Lampenabstand',
                            suffixText: 'cm',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _pflanzenHoeheController,
                    decoration: const InputDecoration(
                      labelText: 'Pflanzenhöhe (Ø)',
                      suffixText: 'cm',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimalFormatter],
                  ),

                  const SizedBox(height: 28),

                  // ── Bewässerung / Tank ──
                  const _SectionHeader(title: 'Bewässerung / Tank'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _wasserMlController,
                          decoration: const InputDecoration(
                            labelText: 'Wasser',
                            suffixText: 'ml',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phController,
                          decoration: const InputDecoration(
                            labelText: 'pH-Wert',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _ecController,
                          decoration: const InputDecoration(
                            labelText: 'EC-Wert',
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
                          controller: _tankFuellstandController,
                          decoration: const InputDecoration(
                            labelText: 'Tank-Füllstand',
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _tankTempController,
                          decoration: const InputDecoration(
                            labelText: 'Tank-Temp.',
                            suffixText: '°C',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Nährstoffe ──
                  const _SectionHeader(title: 'Nährstoffe'),
                  const SizedBox(height: 4),
                  Text(
                    'Dünger und Zusätze mit Menge in ml/L',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),

                  ..._naehrstoffEintraege.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final e = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: e.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                hintText: 'z.B. Canna A',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: e.mengeController,
                              decoration: const InputDecoration(
                                labelText: 'Menge',
                                suffixText: 'ml/L',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [_decimalFormatter],
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _naehrstoffEintraege[idx]
                                    .nameController
                                    .dispose();
                                _naehrstoffEintraege[idx]
                                    .mengeController
                                    .dispose();
                                _naehrstoffEintraege.removeAt(idx);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),

                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _naehrstoffEintraege.add(_NaehrstoffEintrag(
                          nameController: TextEditingController(),
                          mengeController: TextEditingController(),
                        ));
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nährstoff hinzufügen'),
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
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(
                          _isEdit ? 'Log aktualisieren' : 'Log speichern'),
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

class _NaehrstoffEintrag {
  final TextEditingController nameController;
  final TextEditingController mengeController;

  _NaehrstoffEintrag({
    required this.nameController,
    required this.mengeController,
  });
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
