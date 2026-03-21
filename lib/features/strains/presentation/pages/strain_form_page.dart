import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_constants.dart';
import '../../domain/entities/sorte.dart';
import '../providers/sorten_provider.dart';

class StrainFormPage extends ConsumerStatefulWidget {
  final Sorte? sorte; // null = neu erstellen, sonst bearbeiten

  const StrainFormPage({super.key, this.sorte});

  @override
  ConsumerState<StrainFormPage> createState() => _StrainFormPageState();
}

class _StrainFormPageState extends ConsumerState<StrainFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller
  late final TextEditingController _nameController;
  late final TextEditingController _zuechterController;
  late final TextEditingController _indicaController;
  late final TextEditingController _sativaController;
  late final TextEditingController _thcController;
  late final TextEditingController _cbdController;
  late final TextEditingController _bluetezeitZuechterController;
  late final TextEditingController _bluetezeitEigenController;
  late final TextEditingController _bluetezeitSicherheitController;
  late final TextEditingController _keimquoteController;
  late final TextEditingController _ertragSelektionController;
  late final TextEditingController _ertragProduktionController;
  late final TextEditingController _geschmackController;
  late final TextEditingController _wirkungController;
  late final TextEditingController _samenAnzahlController;
  late final TextEditingController _bemerkungController;

  late String _status;
  late bool _toppingEmpfohlen;
  late bool _hatMutterpflanze;

  bool get _isEdit => widget.sorte != null;

  @override
  void initState() {
    super.initState();
    final s = widget.sorte;
    _nameController = TextEditingController(text: s?.name ?? '');
    _zuechterController = TextEditingController(text: s?.zuechter ?? '');
    _indicaController =
        TextEditingController(text: s?.indicaAnteil.toString() ?? '0');
    _sativaController =
        TextEditingController(text: s?.sativaAnteil.toString() ?? '0');
    _thcController =
        TextEditingController(text: s?.thcGehalt?.toString() ?? '');
    _cbdController =
        TextEditingController(text: s?.cbdGehalt?.toString() ?? '');
    _bluetezeitZuechterController =
        TextEditingController(text: s?.bluetezeitZuechter?.toString() ?? '');
    _bluetezeitEigenController =
        TextEditingController(text: s?.bluetezeitEigen?.toString() ?? '');
    _bluetezeitSicherheitController =
        TextEditingController(text: s?.bluetezeitSicherheit?.toString() ?? '');
    _keimquoteController =
        TextEditingController(text: s?.keimquote?.toString() ?? '');
    _ertragSelektionController =
        TextEditingController(text: s?.ertragSelektion ?? '');
    _ertragProduktionController =
        TextEditingController(text: s?.ertragProduktion ?? '');
    _geschmackController = TextEditingController(text: s?.geschmack ?? '');
    _wirkungController = TextEditingController(text: s?.wirkung ?? '');
    _samenAnzahlController =
        TextEditingController(text: s?.samenAnzahl.toString() ?? '0');
    _bemerkungController = TextEditingController(text: s?.bemerkung ?? '');
    _status = s?.status ?? 'aktiv';
    _toppingEmpfohlen = s?.toppingEmpfohlen ?? false;
    _hatMutterpflanze = s?.hatMutterpflanze ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _zuechterController.dispose();
    _indicaController.dispose();
    _sativaController.dispose();
    _thcController.dispose();
    _cbdController.dispose();
    _bluetezeitZuechterController.dispose();
    _bluetezeitEigenController.dispose();
    _bluetezeitSicherheitController.dispose();
    _keimquoteController.dispose();
    _ertragSelektionController.dispose();
    _ertragProduktionController.dispose();
    _geschmackController.dispose();
    _wirkungController.dispose();
    _samenAnzahlController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  Future<void> _speichern() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final sorte = Sorte(
        id: widget.sorte?.id ?? '',
        name: _nameController.text.trim(),
        zuechter: _zuechterController.text.trim().isEmpty
            ? null
            : _zuechterController.text.trim(),
        indicaAnteil: int.tryParse(_indicaController.text) ?? 0,
        sativaAnteil: int.tryParse(_sativaController.text) ?? 0,
        thcGehalt: double.tryParse(_thcController.text),
        cbdGehalt: double.tryParse(_cbdController.text),
        bluetezeitZuechter:
            int.tryParse(_bluetezeitZuechterController.text),
        bluetezeitEigen: int.tryParse(_bluetezeitEigenController.text),
        bluetezeitSicherheit:
            int.tryParse(_bluetezeitSicherheitController.text),
        keimquote: int.tryParse(_keimquoteController.text),
        ertragSelektion: _ertragSelektionController.text.trim().isEmpty
            ? null
            : _ertragSelektionController.text.trim(),
        ertragProduktion: _ertragProduktionController.text.trim().isEmpty
            ? null
            : _ertragProduktionController.text.trim(),
        geschmack: _geschmackController.text.trim().isEmpty
            ? null
            : _geschmackController.text.trim(),
        wirkung: _wirkungController.text.trim().isEmpty
            ? null
            : _wirkungController.text.trim(),
        toppingEmpfohlen: _toppingEmpfohlen,
        samenAnzahl: int.tryParse(_samenAnzahlController.text) ?? 0,
        hatMutterpflanze: _hatMutterpflanze,
        status: _status,
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      final repo = ref.read(sortenRepositoryProvider);
      if (_isEdit) {
        await repo.aktualisieren(sorte);
      } else {
        await repo.erstellen(sorte);
      }

      // Liste aktualisieren und zurück navigieren
      await ref.read(sortenListeProvider.notifier).aktualisieren();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Sorte aktualisiert'
                : 'Sorte erstellt'),
          ),
        );
        context.pop();
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
        title: Text(_isEdit ? 'Sorte bearbeiten' : 'Neue Sorte'),
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
                color: _isLoading ? Colors.grey : Colors.white,
              ),
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
                  // === Grunddaten ===
                  _SectionHeader(title: 'Grunddaten'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'z.B. Wedding Cake',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name ist erforderlich';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _zuechterController,
                    decoration: const InputDecoration(
                      labelText: 'Züchter',
                      hintText: 'z.B. Barneys Farm',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: AppConstants.sortenStatus
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s[0].toUpperCase() + s.substring(1)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _status = value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // === Genetik ===
                  _SectionHeader(title: 'Genetik'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _indicaController,
                          decoration: const InputDecoration(
                            labelText: 'Indica %',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            final indica = int.tryParse(value) ?? 0;
                            if (indica <= 100) {
                              _sativaController.text =
                                  (100 - indica).toString();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _sativaController,
                          decoration: const InputDecoration(
                            labelText: 'Sativa %',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            final sativa = int.tryParse(value) ?? 0;
                            if (sativa <= 100) {
                              _indicaController.text =
                                  (100 - sativa).toString();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _thcController,
                          decoration: const InputDecoration(
                            labelText: 'THC %',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cbdController,
                          decoration: const InputDecoration(
                            labelText: 'CBD %',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === Blütezeit ===
                  _SectionHeader(title: 'Blütezeit'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bluetezeitZuechterController,
                          decoration: const InputDecoration(
                            labelText: 'Züchter (Tage)',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _bluetezeitEigenController,
                          decoration: const InputDecoration(
                            labelText: 'Eigen (Tage)',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _bluetezeitSicherheitController,
                          decoration: const InputDecoration(
                            labelText: 'Sicherheit (Tage)',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === Bestand & Ertrag ===
                  _SectionHeader(title: 'Bestand & Ertrag'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _samenAnzahlController,
                          decoration: const InputDecoration(
                            labelText: 'Samen vorrätig',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _keimquoteController,
                          decoration: const InputDecoration(
                            labelText: 'Keimquote %',
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ertragSelektionController,
                          decoration: const InputDecoration(
                            labelText: 'Ertrag Selektion',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _ertragProduktionController,
                          decoration: const InputDecoration(
                            labelText: 'Ertrag Produktion',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === Eigenschaften ===
                  _SectionHeader(title: 'Eigenschaften'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _geschmackController,
                    decoration: const InputDecoration(
                      labelText: 'Geschmack',
                      hintText: 'z.B. zitronig, erdig, süß',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _wirkungController,
                    decoration: const InputDecoration(
                      labelText: 'Wirkung',
                      hintText: 'z.B. entspannend, kreativ, euphorisch',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Topping empfohlen'),
                          value: _toppingEmpfohlen,
                          onChanged: (v) =>
                              setState(() => _toppingEmpfohlen = v),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Mutterpflanze'),
                          value: _hatMutterpflanze,
                          onChanged: (v) =>
                              setState(() => _hatMutterpflanze = v),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === Bemerkung ===
                  _SectionHeader(title: 'Bemerkung'),
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

                  // Speichern Button (für Mobile)
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
                          ? 'Sorte aktualisieren'
                          : 'Sorte erstellen'),
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
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
