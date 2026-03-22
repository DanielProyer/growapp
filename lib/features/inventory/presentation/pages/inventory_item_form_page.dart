import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_constants.dart';
import '../../domain/entities/inventar_item.dart';
import '../providers/inventar_provider.dart';

class InventoryItemFormPage extends ConsumerStatefulWidget {
  final InventarItem? item;
  final String? vorausgewaehlterTyp;

  const InventoryItemFormPage({
    super.key,
    this.item,
    this.vorausgewaehlterTyp,
  });

  @override
  ConsumerState<InventoryItemFormPage> createState() =>
      _InventoryItemFormPageState();
}

class _InventoryItemFormPageState
    extends ConsumerState<InventoryItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _einheitController;
  late final TextEditingController _preisController;
  late final TextEditingController _mindestBestandController;
  late final TextEditingController _lieferantController;
  late final TextEditingController _bemerkungController;

  late String _typ;
  late String _kategorie;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nameController = TextEditingController(text: i?.name ?? '');
    _einheitController = TextEditingController(text: i?.einheit ?? '');
    _preisController =
        TextEditingController(text: i?.preis?.toStringAsFixed(2) ?? '');
    _mindestBestandController = TextEditingController(
        text: i != null && i.mindestBestand > 0
            ? _formatMenge(i.mindestBestand)
            : '');
    _lieferantController = TextEditingController(text: i?.lieferant ?? '');
    _bemerkungController = TextEditingController(text: i?.bemerkung ?? '');

    _typ = i?.typ ?? widget.vorausgewaehlterTyp ?? 'verbrauchsmaterial';
    _kategorie = i?.kategorie ?? AppConstants.inventarKategorienFuerTyp(_typ).first;

    // Sicherstellen, dass Kategorie zum Typ passt
    if (!AppConstants.inventarKategorienFuerTyp(_typ).contains(_kategorie)) {
      _kategorie = AppConstants.inventarKategorienFuerTyp(_typ).first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _einheitController.dispose();
    _preisController.dispose();
    _mindestBestandController.dispose();
    _lieferantController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  String? _trimOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  String _typLabel(String typ) {
    switch (typ) {
      case 'equipment':
        return 'Equipment';
      case 'verbrauchsmaterial':
        return 'Verbrauchsmaterial';
      default:
        return typ;
    }
  }

  String _kategorieLabel(String kategorie) {
    switch (kategorie) {
      case 'duenger':
        return 'Dünger';
      case 'schaedlingsbekaempfung':
        return 'Schädlingsbekämpfung';
      case 'medium':
        return 'Medium/Substrat';
      case 'beleuchtung':
        return 'Beleuchtung';
      case 'belueftung':
        return 'Belüftung/Klima';
      case 'bewaesserung':
        return 'Bewässerung';
      case 'messinstrumente':
        return 'Messinstrumente';
      case 'zubehoer':
        return 'Zubehör';
      case 'sonstige':
        return 'Sonstiges';
      default:
        return kategorie;
    }
  }

  String _formatMenge(double menge) {
    return menge == menge.roundToDouble()
        ? menge.toInt().toString()
        : menge.toStringAsFixed(2);
  }

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final item = InventarItem(
        id: widget.item?.id ?? '',
        name: _nameController.text.trim(),
        typ: _typ,
        kategorie: _kategorie,
        einheit: _trimOrNull(_einheitController),
        aktuellerBestand: widget.item?.aktuellerBestand ?? 0,
        mindestBestand: double.tryParse(
                _mindestBestandController.text.replaceAll(',', '.')) ??
            0,
        preis: _preisController.text.isNotEmpty
            ? double.tryParse(
                _preisController.text.replaceAll(',', '.'))
            : null,
        lieferant: _trimOrNull(_lieferantController),
        bemerkung: _trimOrNull(_bemerkungController),
      );

      final notifier = ref.read(inventarListeProvider.notifier);
      if (_isEdit) {
        await notifier.artikelAktualisieren(widget.item!.id, item);
      } else {
        await notifier.erstellen(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEdit ? 'Artikel aktualisiert' : 'Artikel erstellt')),
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
    final kategorien = AppConstants.inventarKategorienFuerTyp(_typ);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Artikel bearbeiten' : 'Neuer Artikel'),
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
              style: TextStyle(
                  color: _isLoading ? Colors.grey : Colors.white),
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
                  // ── Grunddaten ──
                  const _SectionHeader(title: 'Grunddaten'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'z.B. Canna Terra Professional',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name ist erforderlich'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _typ,
                          decoration:
                              const InputDecoration(labelText: 'Typ'),
                          items: AppConstants.inventarTypen
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(_typLabel(t)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _typ = v;
                                // Kategorie zurücksetzen wenn nicht mehr gültig
                                final neueKategorien =
                                    AppConstants.inventarKategorienFuerTyp(v);
                                if (!neueKategorien.contains(_kategorie)) {
                                  _kategorie = neueKategorien.first;
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('kategorie_$_typ'),
                          initialValue: _kategorie,
                          decoration: const InputDecoration(
                              labelText: 'Kategorie'),
                          items: kategorien
                              .map((k) => DropdownMenuItem(
                                    value: k,
                                    child: Text(_kategorieLabel(k)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _kategorie = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Details ──
                  const _SectionHeader(title: 'Details'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _einheitController,
                          decoration: const InputDecoration(
                            labelText: 'Einheit',
                            hintText: 'z.B. ml, L, kg, Stk',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _preisController,
                          decoration: const InputDecoration(
                            labelText: 'Preis',
                            suffixText: '€',
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.,]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mindestBestandController,
                    decoration: const InputDecoration(
                      labelText: 'Mindestbestand',
                      hintText: 'Warnung bei Unterschreitung',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d.,]')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lieferantController,
                    decoration: const InputDecoration(
                      labelText: 'Lieferant',
                      hintText: 'z.B. Growshop XY',
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Bemerkung ──
                  const _SectionHeader(title: 'Bemerkung'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bemerkungController,
                    decoration: const InputDecoration(
                      labelText: 'Allgemeine Bemerkung',
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
                          : const Icon(Icons.save),
                      label: Text(_isEdit
                          ? 'Artikel aktualisieren'
                          : 'Artikel erstellen'),
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
        Divider(
            color:
                Theme.of(context).colorScheme.primary.withAlpha(50)),
      ],
    );
  }
}
