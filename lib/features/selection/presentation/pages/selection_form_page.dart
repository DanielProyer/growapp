import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../grows/presentation/providers/grows_provider.dart';
import '../../../strains/presentation/providers/sorten_provider.dart';
import '../../domain/entities/selektion.dart';
import '../providers/selektions_provider.dart';

class SelectionFormPage extends ConsumerStatefulWidget {
  final Selektion? selektion;

  const SelectionFormPage({super.key, this.selektion});

  @override
  ConsumerState<SelectionFormPage> createState() => _SelectionFormPageState();
}

class _SelectionFormPageState extends ConsumerState<SelectionFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late String? _sorteId;
  late String? _durchgangId;
  DateTime? _startDatum;
  late final TextEditingController _samenAnzahlController;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.selektion != null;

  @override
  void initState() {
    super.initState();
    final s = widget.selektion;
    _nameController = TextEditingController(text: s?.name ?? '');
    _sorteId = s?.sorteId;
    _durchgangId = s?.durchgangId;
    _startDatum = s?.startDatum ?? DateTime.now();
    _samenAnzahlController =
        TextEditingController(text: s?.samenAnzahl?.toString() ?? '');
    _bemerkungController = TextEditingController(text: s?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _samenAnzahlController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  String _datumFormatiert(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _datumWaehlen() async {
    final datum = await showDatePicker(
      context: context,
      initialDate: _startDatum ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('de'),
    );
    if (datum != null) {
      setState(() => _startDatum = datum);
    }
  }

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_sorteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine Sorte auswählen')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final selektion = Selektion(
        id: widget.selektion?.id ?? '',
        sorteId: _sorteId!,
        durchgangId: _durchgangId,
        name: _nameController.text.trim(),
        status: widget.selektion?.status ?? 'aktiv',
        startDatum: _startDatum,
        samenAnzahl: int.tryParse(_samenAnzahlController.text.trim()),
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      final notifier = ref.read(selektionenListeProvider.notifier);
      if (_isEdit) {
        await notifier.selektionAktualisieren(widget.selektion!.id, selektion);
      } else {
        await notifier.erstellen(selektion);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEdit
                  ? 'Selektion aktualisiert'
                  : 'Selektion erstellt')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortenAsync = ref.watch(sortenListeProvider);
    final durchgaengeAsync = ref.watch(durchgaengeListeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Selektion bearbeiten' : 'Neue Selektion'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _speichern,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              'Speichern',
              style:
                  TextStyle(color: _isLoading ? Colors.grey : Colors.white),
            ),
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
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Selektionsname *',
                      prefixIcon: Icon(Icons.science_outlined),
                      hintText: 'z.B. "Runtz S1 Pheno-Hunt"',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Bitte einen Namen eingeben'
                        : null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Sorte
                  sortenAsync.when(
                    data: (sorten) => DropdownButtonFormField<String>(
                      initialValue: _sorteId,
                      decoration: const InputDecoration(
                        labelText: 'Sorte *',
                        prefixIcon: Icon(Icons.local_florist_outlined),
                      ),
                      items: sorten
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _sorteId = v;
                        _durchgangId = null;
                      }),
                      validator: (v) =>
                          v == null ? 'Bitte eine Sorte auswählen' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text('Fehler beim Laden der Sorten'),
                  ),
                  const SizedBox(height: 16),

                  // Durchgang (optional, gefiltert nach Sorte)
                  durchgaengeAsync.when(
                    data: (durchgaenge) {
                      final gefiltert = _sorteId != null
                          ? durchgaenge
                              .where((d) => d.sorteId == _sorteId)
                              .toList()
                          : <dynamic>[];
                      return DropdownButtonFormField<String>(
                        initialValue: _durchgangId,
                        decoration: const InputDecoration(
                          labelText: 'Durchgang (optional)',
                          prefixIcon: Icon(Icons.eco_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Kein Durchgang'),
                          ),
                          ...gefiltert.map((d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.titel),
                              )),
                        ],
                        onChanged: (v) => setState(() => _durchgangId = v),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text('Fehler beim Laden der Durchgänge'),
                  ),
                  const SizedBox(height: 16),

                  // Startdatum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Startdatum'),
                    subtitle: Text(
                      _startDatum != null
                          ? _datumFormatiert(_startDatum!)
                          : 'Nicht gesetzt',
                    ),
                    trailing: _startDatum != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _startDatum = null),
                          )
                        : null,
                    onTap: _datumWaehlen,
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Samenanzahl
                  TextFormField(
                    controller: _samenAnzahlController,
                    decoration: const InputDecoration(
                      labelText: 'Samenanzahl',
                      prefixIcon: Icon(Icons.tag),
                      hintText: 'z.B. 10',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Bemerkung
                  TextFormField(
                    controller: _bemerkungController,
                    decoration: const InputDecoration(
                      labelText: 'Bemerkung',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 32),

                  // Speichern Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _speichern,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isEdit
                          ? 'Selektion aktualisieren'
                          : 'Selektion anlegen'),
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
