import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog zum Erstellen einer neuen Buchung (Eingang/Verbrauch)
class BuchungDialog extends StatefulWidget {
  final String artikelName;
  final String? einheit;

  const BuchungDialog({
    super.key,
    required this.artikelName,
    this.einheit,
  });

  @override
  State<BuchungDialog> createState() => _BuchungDialogState();
}

class _BuchungDialogState extends State<BuchungDialog> {
  final _formKey = GlobalKey<FormState>();
  String _typ = 'eingang';
  final _mengeController = TextEditingController();
  final _stueckpreisController = TextEditingController();
  final _bemerkungController = TextEditingController();
  DateTime _datum = DateTime.now();
  bool _preisAktualisieren = true;

  @override
  void dispose() {
    _mengeController.dispose();
    _stueckpreisController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  Future<void> _datumWaehlen() async {
    final gewaehlt = await showDatePicker(
      context: context,
      initialDate: _datum,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('de', 'DE'),
    );
    if (gewaehlt != null) {
      setState(() => _datum = gewaehlt);
    }
  }

  void _speichern() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final menge = double.tryParse(
            _mengeController.text.replaceAll(',', '.')) ??
        0;
    final stueckpreis = _stueckpreisController.text.isNotEmpty
        ? double.tryParse(
            _stueckpreisController.text.replaceAll(',', '.'))
        : null;

    Navigator.pop(context, {
      'typ': _typ,
      'menge': menge,
      'stueckpreis': stueckpreis,
      'datum': _datum,
      'bemerkung': _bemerkungController.text.trim().isEmpty
          ? null
          : _bemerkungController.text.trim(),
      'preis_aktualisieren': _preisAktualisieren && stueckpreis != null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final datumText =
        '${_datum.day.toString().padLeft(2, '0')}.${_datum.month.toString().padLeft(2, '0')}.${_datum.year}';

    return AlertDialog(
      title: Text('Buchung: ${widget.artikelName}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Typ: Eingang/Verbrauch
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'eingang',
                      label: Text('Eingang'),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                    ButtonSegment(
                      value: 'verbrauch',
                      label: Text('Verbrauch'),
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                  ],
                  selected: {_typ},
                  onSelectionChanged: (selected) {
                    setState(() => _typ = selected.first);
                  },
                ),

                const SizedBox(height: 16),

                // Menge
                TextFormField(
                  controller: _mengeController,
                  decoration: InputDecoration(
                    labelText: 'Menge *',
                    suffixText: widget.einheit,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[\d.,]')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Menge ist erforderlich';
                    }
                    final menge =
                        double.tryParse(v.replaceAll(',', '.'));
                    if (menge == null || menge <= 0) {
                      return 'Ungültige Menge';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Stückpreis (nur bei Eingang)
                if (_typ == 'eingang') ...[
                  TextFormField(
                    controller: _stueckpreisController,
                    decoration: const InputDecoration(
                      labelText: 'Stückpreis',
                      suffixText: '€',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d.,]')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text(
                      'Artikelpreis aktualisieren',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _preisAktualisieren,
                    onChanged: (v) =>
                        setState(() => _preisAktualisieren = v ?? true),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  const SizedBox(height: 4),
                ],

                // Datum
                InkWell(
                  onTap: _datumWaehlen,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Datum',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(datumText),
                  ),
                ),

                const SizedBox(height: 12),

                // Bemerkung
                TextFormField(
                  controller: _bemerkungController,
                  decoration: const InputDecoration(
                    labelText: 'Bemerkung',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _speichern,
          child: const Text('Buchen'),
        ),
      ],
    );
  }
}
