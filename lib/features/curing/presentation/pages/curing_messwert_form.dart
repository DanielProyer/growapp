import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/curing_messwert.dart';
import '../providers/curing_provider.dart';

class CuringMesswertForm extends ConsumerStatefulWidget {
  final String glasId;
  final CuringMesswert? messwert;

  const CuringMesswertForm({
    super.key,
    required this.glasId,
    this.messwert,
  });

  @override
  ConsumerState<CuringMesswertForm> createState() =>
      _CuringMesswertFormState();
}

class _CuringMesswertFormState extends ConsumerState<CuringMesswertForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late DateTime _datum;
  late final TextEditingController _rlfController;
  late final TextEditingController _temperaturController;
  late final TextEditingController _gewichtController;
  late bool _gelueftet;
  late final TextEditingController _lueftungsdauerController;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.messwert != null;

  @override
  void initState() {
    super.initState();
    final m = widget.messwert;
    _datum = m?.datum ?? DateTime.now();
    _rlfController =
        TextEditingController(text: m?.rlfProzent?.toString() ?? '');
    _temperaturController =
        TextEditingController(text: m?.temperatur?.toString() ?? '');
    _gewichtController =
        TextEditingController(text: m?.gewichtG?.toString() ?? '');
    _gelueftet = m?.gelueftet ?? false;
    _lueftungsdauerController =
        TextEditingController(text: m?.lueftungsdauerMin?.toString() ?? '');
    _bemerkungController =
        TextEditingController(text: m?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _rlfController.dispose();
    _temperaturController.dispose();
    _gewichtController.dispose();
    _lueftungsdauerController.dispose();
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
      final messwert = CuringMesswert(
        id: widget.messwert?.id ?? '',
        glasId: widget.glasId,
        datum: _datum,
        rlfProzent: int.tryParse(_rlfController.text.trim()),
        temperatur: double.tryParse(_temperaturController.text.trim()),
        gewichtG: double.tryParse(_gewichtController.text.trim()),
        gelueftet: _gelueftet,
        lueftungsdauerMin: _gelueftet
            ? int.tryParse(_lueftungsdauerController.text.trim())
            : null,
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      if (_isEdit) {
        await curingMesswertAktualisieren(
          ref,
          id: widget.messwert!.id,
          messwert: messwert,
        );
      } else {
        await curingMesswertErstellen(ref, messwert: messwert);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEdit
                  ? 'Messwert aktualisiert'
                  : 'Messwert erfasst')),
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
        title: Text(_isEdit ? 'Messwert bearbeiten' : 'Neuer Messwert'),
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

                  // RLF
                  TextFormField(
                    controller: _rlfController,
                    decoration: const InputDecoration(
                      labelText: 'RLF (%)',
                      prefixIcon: Icon(Icons.water_drop),
                      hintText: 'z.B. 62',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Temperatur
                  TextFormField(
                    controller: _temperaturController,
                    decoration: const InputDecoration(
                      labelText: 'Temperatur (°C)',
                      prefixIcon: Icon(Icons.thermostat),
                      hintText: 'z.B. 20.5',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // Gewicht
                  TextFormField(
                    controller: _gewichtController,
                    decoration: const InputDecoration(
                      labelText: 'Gewicht (g)',
                      prefixIcon: Icon(Icons.scale),
                      hintText: 'z.B. 120.5',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // Gelüftet Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Gelüftet (Burping)'),
                    secondary: const Icon(Icons.air),
                    value: _gelueftet,
                    onChanged: (v) => setState(() => _gelueftet = v),
                  ),

                  // Lüftungsdauer (nur wenn gelüftet)
                  if (_gelueftet) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lueftungsdauerController,
                      decoration: const InputDecoration(
                        labelText: 'Lüftungsdauer (min)',
                        prefixIcon: Icon(Icons.timer),
                        hintText: 'z.B. 15',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
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
                          ? 'Messwert aktualisieren'
                          : 'Messwert erfassen'),
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
