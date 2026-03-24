import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/steckling.dart';
import '../providers/muetter_provider.dart';

class CuttingFormPage extends ConsumerStatefulWidget {
  final String mutterId;
  final Steckling? steckling;

  const CuttingFormPage({
    super.key,
    required this.mutterId,
    this.steckling,
  });

  @override
  ConsumerState<CuttingFormPage> createState() => _CuttingFormPageState();
}

class _CuttingFormPageState extends ConsumerState<CuttingFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late DateTime _datum;
  late final TextEditingController _anzahlUntenController;
  late final TextEditingController _anzahlObenController;
  int? _erfolgsrate;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.steckling != null;

  @override
  void initState() {
    super.initState();
    final s = widget.steckling;
    _datum = s?.datum ?? DateTime.now();
    _anzahlUntenController =
        TextEditingController(text: s?.anzahlUnten?.toString() ?? '');
    _anzahlObenController =
        TextEditingController(text: s?.anzahlOben?.toString() ?? '');
    _erfolgsrate = s?.erfolgsrate;
    _bemerkungController = TextEditingController(text: s?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _anzahlUntenController.dispose();
    _anzahlObenController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

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

  String _datumFormatiert(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final unten = int.tryParse(_anzahlUntenController.text.trim());
    final oben = int.tryParse(_anzahlObenController.text.trim());

    if ((unten == null || unten == 0) && (oben == null || oben == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bitte mindestens eine Anzahl angeben')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final steckling = Steckling(
        id: widget.steckling?.id ?? '',
        mutterId: widget.mutterId,
        datum: _datum,
        anzahlUnten: unten,
        anzahlOben: oben,
        erfolgsrate: _erfolgsrate,
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      if (_isEdit) {
        await stecklingAktualisieren(ref,
            id: widget.steckling!.id, steckling: steckling);
      } else {
        await stecklingErstellen(ref, steckling: steckling);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEdit
                  ? 'Stecklingsschnitt aktualisiert'
                  : 'Stecklingsschnitt dokumentiert')),
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
        title: Text(_isEdit
            ? 'Stecklingsschnitt bearbeiten'
            : 'Stecklinge schneiden'),
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
                    title: const Text('Datum *'),
                    subtitle: Text(_datumFormatiert(_datum)),
                    onTap: _datumWaehlen,
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Anzahl unten
                  TextFormField(
                    controller: _anzahlUntenController,
                    decoration: const InputDecoration(
                      labelText: 'Anzahl Stecklinge unten',
                      prefixIcon: Icon(Icons.arrow_downward),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Anzahl oben
                  TextFormField(
                    controller: _anzahlObenController,
                    decoration: const InputDecoration(
                      labelText: 'Anzahl Stecklinge oben',
                      prefixIcon: Icon(Icons.arrow_upward),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Erfolgsrate Slider
                  Text(
                    'Erfolgsrate${_erfolgsrate != null ? ': $_erfolgsrate%' : ' (optional)'}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: (_erfolgsrate ?? 0).toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: _erfolgsrate != null
                              ? '$_erfolgsrate%'
                              : null,
                          onChanged: (v) =>
                              setState(() => _erfolgsrate = v.round()),
                        ),
                      ),
                      if (_erfolgsrate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Zurücksetzen',
                          onPressed: () =>
                              setState(() => _erfolgsrate = null),
                        ),
                    ],
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
                          : const Icon(Icons.content_cut),
                      label: Text(_isEdit
                          ? 'Schnitt aktualisieren'
                          : 'Schnitt dokumentieren'),
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
