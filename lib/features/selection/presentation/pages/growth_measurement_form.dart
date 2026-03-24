import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/wachstums_messung.dart';
import '../providers/selektions_provider.dart';

class GrowthMeasurementForm extends ConsumerStatefulWidget {
  final String pflanzeId;
  final WachstumsMessung? messung;

  const GrowthMeasurementForm({
    super.key,
    required this.pflanzeId,
    this.messung,
  });

  @override
  ConsumerState<GrowthMeasurementForm> createState() =>
      _GrowthMeasurementFormState();
}

class _GrowthMeasurementFormState
    extends ConsumerState<GrowthMeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late DateTime _datum;
  late final TextEditingController _hoeheController;
  late final TextEditingController _nodienController;
  late final TextEditingController _stammdickeController;
  late bool _getoppt;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.messung != null;

  @override
  void initState() {
    super.initState();
    final m = widget.messung;
    _datum = m?.datum ?? DateTime.now();
    _hoeheController =
        TextEditingController(text: m?.hoeheCm?.toString() ?? '');
    _nodienController =
        TextEditingController(text: m?.nodienAnzahl?.toString() ?? '');
    _stammdickeController =
        TextEditingController(text: m?.stammdicke?.toString() ?? '');
    _getoppt = m?.getoppt ?? false;
    _bemerkungController = TextEditingController(text: m?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _hoeheController.dispose();
    _nodienController.dispose();
    _stammdickeController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  String _datumFormatiert(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _datumWaehlen() async {
    final datum = await showDatePicker(
      context: context,
      initialDate: _datum,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('de'),
    );
    if (datum != null) {
      setState(() => _datum = datum);
    }
  }

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final messung = WachstumsMessung(
        id: widget.messung?.id ?? '',
        pflanzeId: widget.pflanzeId,
        datum: _datum,
        hoeheCm: double.tryParse(_hoeheController.text.trim()),
        nodienAnzahl: int.tryParse(_nodienController.text.trim()),
        stammdicke: double.tryParse(_stammdickeController.text.trim()),
        getoppt: _getoppt,
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      if (_isEdit) {
        await messungAktualisieren(
          ref,
          id: widget.messung!.id,
          messung: messung,
        );
      } else {
        await messungErstellen(ref, messung: messung);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEdit
                  ? 'Messung aktualisiert'
                  : 'Messung gespeichert')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEdit ? 'Messung bearbeiten' : 'Neue Wachstumsmessung'),
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
                  // Datum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Datum'),
                    subtitle: Text(_datumFormatiert(_datum)),
                    onTap: _datumWaehlen,
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Höhe
                  TextFormField(
                    controller: _hoeheController,
                    decoration: const InputDecoration(
                      labelText: 'Höhe (cm)',
                      prefixIcon: Icon(Icons.straighten),
                      hintText: 'z.B. 45.5',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // Nodien
                  TextFormField(
                    controller: _nodienController,
                    decoration: const InputDecoration(
                      labelText: 'Nodien-Anzahl',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      hintText: 'z.B. 7',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Stammdicke
                  TextFormField(
                    controller: _stammdickeController,
                    decoration: const InputDecoration(
                      labelText: 'Stammdicke (mm)',
                      prefixIcon: Icon(Icons.circle_outlined),
                      hintText: 'z.B. 12.5',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // Getoppt
                  SwitchListTile(
                    title: const Text('Getoppt'),
                    subtitle: const Text('Pflanze wurde getoppt'),
                    value: _getoppt,
                    onChanged: (v) => setState(() => _getoppt = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // Bemerkung
                  TextFormField(
                    controller: _bemerkungController,
                    decoration: const InputDecoration(
                      labelText: 'Bemerkung',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
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
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isEdit
                          ? 'Messung aktualisieren'
                          : 'Messung speichern'),
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
