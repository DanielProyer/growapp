import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../grows/presentation/providers/grows_provider.dart';
import '../../../strains/presentation/providers/sorten_provider.dart';
import '../../domain/entities/curing_glas.dart';
import '../providers/curing_provider.dart';

class CuringGlasFormPage extends ConsumerStatefulWidget {
  final CuringGlas? glas;

  const CuringGlasFormPage({super.key, this.glas});

  @override
  ConsumerState<CuringGlasFormPage> createState() =>
      _CuringGlasFormPageState();
}

class _CuringGlasFormPageState extends ConsumerState<CuringGlasFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String? _durchgangId;
  late String? _sorteId;
  late final TextEditingController _glasNrController;
  late String? _behaelterTyp;
  late final TextEditingController _groesseMlController;
  late String? _trimMethode;
  DateTime? _ernteDatum;
  DateTime? _einglasDatum;
  late final TextEditingController _nassGewichtController;
  late final TextEditingController _trockenGewichtController;
  late final TextEditingController _endgewichtController;
  late final TextEditingController _zielRlfController;
  late final TextEditingController _bovedaTypController;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.glas != null;

  @override
  void initState() {
    super.initState();
    final g = widget.glas;
    _durchgangId = g?.durchgangId;
    _sorteId = g?.sorteId;
    _glasNrController =
        TextEditingController(text: g?.glasNr.toString() ?? '');
    _behaelterTyp = g?.behaelterTyp ?? 'glas';
    _groesseMlController =
        TextEditingController(text: g?.groesseMl?.toString() ?? '');
    _trimMethode = g?.trimMethode;
    _ernteDatum = g?.ernteDatum;
    _einglasDatum = g?.einglasDatum;
    _nassGewichtController =
        TextEditingController(text: g?.nassGewichtG?.toString() ?? '');
    _trockenGewichtController =
        TextEditingController(text: g?.trockenGewichtG?.toString() ?? '');
    _endgewichtController =
        TextEditingController(text: g?.endgewichtG?.toString() ?? '');
    _zielRlfController =
        TextEditingController(text: g?.zielRlf?.toString() ?? '62');
    _bovedaTypController =
        TextEditingController(text: g?.bovedaTyp ?? '');
    _bemerkungController =
        TextEditingController(text: g?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _glasNrController.dispose();
    _groesseMlController.dispose();
    _nassGewichtController.dispose();
    _trockenGewichtController.dispose();
    _endgewichtController.dispose();
    _zielRlfController.dispose();
    _bovedaTypController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  String _datumFormatiert(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _datumWaehlen({required bool istErnte}) async {
    final aktuell = istErnte ? _ernteDatum : _einglasDatum;
    final datum = await showDatePicker(
      context: context,
      initialDate: aktuell ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('de'),
    );
    if (datum != null) {
      setState(() {
        if (istErnte) {
          _ernteDatum = datum;
        } else {
          _einglasDatum = datum;
        }
      });
    }
  }

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_durchgangId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte einen Durchgang auswählen')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final glas = CuringGlas(
        id: widget.glas?.id ?? '',
        durchgangId: _durchgangId!,
        sorteId: _sorteId,
        glasNr: int.parse(_glasNrController.text.trim()),
        behaelterTyp: _behaelterTyp,
        groesseMl: int.tryParse(_groesseMlController.text.trim()),
        trimMethode: _trimMethode,
        ernteDatum: _ernteDatum,
        einglasDatum: _einglasDatum,
        nassGewichtG: double.tryParse(_nassGewichtController.text.trim()),
        trockenGewichtG:
            double.tryParse(_trockenGewichtController.text.trim()),
        endgewichtG: double.tryParse(_endgewichtController.text.trim()),
        zielRlf: int.tryParse(_zielRlfController.text.trim()),
        bovedaTyp: _bovedaTypController.text.trim().isEmpty
            ? null
            : _bovedaTypController.text.trim(),
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
        status: widget.glas?.status ?? 'trocknung',
        schimmelErkannt: widget.glas?.schimmelErkannt ?? false,
        qualitaetNotizen: widget.glas?.qualitaetNotizen ?? {},
      );

      final notifier = ref.read(curingGlaeserListeProvider.notifier);
      if (_isEdit) {
        await notifier.glasAktualisieren(widget.glas!.id, glas);
      } else {
        await notifier.erstellen(glas);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEdit ? 'Glas aktualisiert' : 'Glas erstellt')),
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
    final durchgaengeAsync = ref.watch(durchgaengeListeProvider);
    final sortenAsync = ref.watch(sortenListeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Glas bearbeiten' : 'Neues Glas'),
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
                  // Durchgang (Pflicht)
                  durchgaengeAsync.when(
                    data: (durchgaenge) => DropdownButtonFormField<String>(
                      initialValue: _durchgangId,
                      decoration: const InputDecoration(
                        labelText: 'Durchgang *',
                        prefixIcon: Icon(Icons.eco_outlined),
                      ),
                      items: durchgaenge
                          .map((d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.titel),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _durchgangId = v;
                          // Sorte vorbefüllen
                          if (v != null) {
                            final d = durchgaenge.firstWhere((d) => d.id == v);
                            _sorteId = d.sorteId;
                          }
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Bitte einen Durchgang auswählen' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text('Fehler beim Laden der Durchgänge'),
                  ),
                  const SizedBox(height: 16),

                  // Sorte (Optional)
                  sortenAsync.when(
                    data: (sorten) => DropdownButtonFormField<String>(
                      initialValue: _sorteId,
                      decoration: const InputDecoration(
                        labelText: 'Sorte (optional)',
                        prefixIcon: Icon(Icons.local_florist_outlined),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Keine Sorte'),
                        ),
                        ...sorten.map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            )),
                      ],
                      onChanged: (v) => setState(() => _sorteId = v),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text('Fehler beim Laden der Sorten'),
                  ),
                  const SizedBox(height: 16),

                  // Glas-Nr
                  TextFormField(
                    controller: _glasNrController,
                    decoration: const InputDecoration(
                      labelText: 'Glas-Nr. *',
                      prefixIcon: Icon(Icons.tag),
                      hintText: 'z.B. 1',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Bitte eine Glas-Nr. eingeben';
                      }
                      if (int.tryParse(v.trim()) == null) {
                        return 'Bitte eine gültige Zahl eingeben';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Behältertyp
                  DropdownButtonFormField<String>(
                    initialValue: _behaelterTyp,
                    decoration: const InputDecoration(
                      labelText: 'Behältertyp',
                      prefixIcon: Icon(Icons.local_bar_outlined),
                    ),
                    items: AppConstants.behaelterTypen
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(_behaelterTypLabel(t)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _behaelterTyp = v),
                  ),
                  const SizedBox(height: 16),

                  // Größe in ml
                  TextFormField(
                    controller: _groesseMlController,
                    decoration: const InputDecoration(
                      labelText: 'Größe (ml)',
                      prefixIcon: Icon(Icons.straighten),
                      hintText: 'z.B. 1000',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Trim-Methode
                  DropdownButtonFormField<String>(
                    initialValue: _trimMethode,
                    decoration: const InputDecoration(
                      labelText: 'Trim-Methode',
                      prefixIcon: Icon(Icons.content_cut),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Keine Auswahl'),
                      ),
                      ...AppConstants.trimMethoden.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(_trimMethodeLabel(t)),
                          )),
                    ],
                    onChanged: (v) => setState(() => _trimMethode = v),
                  ),
                  const SizedBox(height: 16),

                  // Erntedatum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.content_cut),
                    title: const Text('Erntedatum'),
                    subtitle: Text(
                      _ernteDatum != null
                          ? _datumFormatiert(_ernteDatum!)
                          : 'Nicht gesetzt',
                    ),
                    trailing: _ernteDatum != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _ernteDatum = null),
                          )
                        : null,
                    onTap: () => _datumWaehlen(istErnte: true),
                  ),
                  const Divider(),

                  // Einglasdatum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_bar),
                    title: const Text('Einglasdatum'),
                    subtitle: Text(
                      _einglasDatum != null
                          ? _datumFormatiert(_einglasDatum!)
                          : 'Nicht gesetzt',
                    ),
                    trailing: _einglasDatum != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _einglasDatum = null),
                          )
                        : null,
                    onTap: () => _datumWaehlen(istErnte: false),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Gewichte
                  TextFormField(
                    controller: _nassGewichtController,
                    decoration: const InputDecoration(
                      labelText: 'Nassgewicht (g)',
                      prefixIcon: Icon(Icons.scale),
                      hintText: 'z.B. 500.0',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _trockenGewichtController,
                    decoration: const InputDecoration(
                      labelText: 'Trockengewicht (g)',
                      prefixIcon: Icon(Icons.scale),
                      hintText: 'z.B. 125.0',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _endgewichtController,
                    decoration: const InputDecoration(
                      labelText: 'Endgewicht (g)',
                      prefixIcon: Icon(Icons.scale),
                      hintText: 'z.B. 120.0',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // Ziel-RLF
                  TextFormField(
                    controller: _zielRlfController,
                    decoration: const InputDecoration(
                      labelText: 'Ziel-RLF (%)',
                      prefixIcon: Icon(Icons.water_drop),
                      hintText: 'z.B. 62',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Boveda-Typ
                  TextFormField(
                    controller: _bovedaTypController,
                    decoration: const InputDecoration(
                      labelText: 'Boveda-Typ',
                      prefixIcon: Icon(Icons.water_drop_outlined),
                      hintText: 'z.B. 62%',
                    ),
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
                      label: Text(
                          _isEdit ? 'Glas aktualisieren' : 'Glas anlegen'),
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

  String _behaelterTypLabel(String typ) {
    switch (typ) {
      case 'glas':
        return 'Glas';
      case 'grove_bag':
        return 'Grove Bag';
      case 'cvault':
        return 'CVault';
      case 'eimer':
        return 'Eimer';
      case 'sonstig':
        return 'Sonstig';
      default:
        return typ;
    }
  }

  String _trimMethodeLabel(String methode) {
    switch (methode) {
      case 'nassschnitt':
        return 'Nassschnitt';
      case 'trimbag':
        return 'Trimbag';
      case 'handschnitt':
        return 'Handschnitt';
      default:
        return methode;
    }
  }
}
