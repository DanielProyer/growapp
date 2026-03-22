import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../grow_tents/presentation/providers/zelte_provider.dart';
import '../../domain/entities/schaedlings_behandlung.dart';
import '../providers/schaedlings_provider.dart';

class PestTreatmentFormPage extends ConsumerStatefulWidget {
  final String? vorfallId;
  final String? zeltId;

  const PestTreatmentFormPage({
    super.key,
    this.vorfallId,
    this.zeltId,
  });

  @override
  ConsumerState<PestTreatmentFormPage> createState() =>
      _PestTreatmentFormPageState();
}

class _PestTreatmentFormPageState extends ConsumerState<PestTreatmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String? _zeltId;
  late String _behandlungTyp;
  late final TextEditingController _mittelController;
  late final TextEditingController _mengeController;
  late DateTime _datum;
  String? _wirksamkeit;
  late final TextEditingController _bemerkungController;

  bool get _istReaktiv => widget.vorfallId != null;

  @override
  void initState() {
    super.initState();
    _zeltId = widget.zeltId;
    _behandlungTyp = AppConstants.behandlungsTypen.first;
    _mittelController = TextEditingController();
    _mengeController = TextEditingController();
    _datum = DateTime.now();
    _bemerkungController = TextEditingController();
  }

  @override
  void dispose() {
    _mittelController.dispose();
    _mengeController.dispose();
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

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_zeltId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte ein Zelt auswählen')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final behandlung = SchaedlingsBehandlung(
        id: '',
        vorfallId: widget.vorfallId,
        zeltId: _zeltId!,
        behandlungTyp: _behandlungTyp,
        mittel: _mittelController.text.trim(),
        menge: _mengeController.text.trim().isEmpty
            ? null
            : _mengeController.text.trim(),
        datum: _datum,
        wirksamkeit: _wirksamkeit,
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      await behandlungErstellen(ref, behandlung: behandlung);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Behandlung erstellt')),
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
    final zelteAsync = ref.watch(zelteListeProvider);
    final titel =
        _istReaktiv ? 'Behandlung hinzufügen' : 'Prophylaxe-Behandlung';

    return Scaffold(
      appBar: AppBar(
        title: Text(titel),
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
                  // Zelt (nur bei prophylaktisch zeigen, bei reaktiv ist es vorbelegt)
                  if (!_istReaktiv)
                    zelteAsync.when(
                      data: (zelte) => DropdownButtonFormField<String>(
                        initialValue: _zeltId,
                        decoration: const InputDecoration(
                          labelText: 'Zelt *',
                          prefixIcon: Icon(Icons.house_outlined),
                        ),
                        items: zelte
                            .map((z) => DropdownMenuItem(
                                  value: z.id,
                                  child: Text(z.name),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _zeltId = v),
                        validator: (v) =>
                            v == null ? 'Bitte ein Zelt auswählen' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) =>
                          const Text('Fehler beim Laden der Zelte'),
                    ),
                  if (!_istReaktiv) const SizedBox(height: 16),

                  // Behandlungstyp
                  DropdownButtonFormField<String>(
                    initialValue: _behandlungTyp,
                    decoration: const InputDecoration(
                      labelText: 'Behandlungstyp *',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    items: AppConstants.behandlungsTypen
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(SchaedlingsBehandlung
                                  .behandlungTypLabelFuer(t)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _behandlungTyp = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mittel
                  TextFormField(
                    controller: _mittelController,
                    decoration: const InputDecoration(
                      labelText: 'Mittel / Produkt *',
                      hintText: 'z.B. Neem-Öl, Amblyseius cucumeris',
                      prefixIcon: Icon(Icons.science_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Mittel ist erforderlich'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Menge
                  TextFormField(
                    controller: _mengeController,
                    decoration: const InputDecoration(
                      labelText: 'Menge (optional)',
                      hintText: 'z.B. 5ml/L, 6 Beutel',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Datum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Datum'),
                    subtitle: Text(
                      '${_datum.day.toString().padLeft(2, '0')}.${_datum.month.toString().padLeft(2, '0')}.${_datum.year}',
                    ),
                    onTap: _datumWaehlen,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Wirksamkeit (nur bei reaktiver Behandlung sinnvoll)
                  if (_istReaktiv) ...[
                    DropdownButtonFormField<String?>(
                      initialValue: _wirksamkeit,
                      decoration: const InputDecoration(
                        labelText: 'Wirksamkeit (optional)',
                        prefixIcon: Icon(Icons.star_outline),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Nicht bewertet'),
                        ),
                        ...AppConstants.wirksamkeitsStufen
                            .map((w) => DropdownMenuItem<String?>(
                                  value: w,
                                  child: Text(SchaedlingsBehandlung
                                      .wirksamkeitLabelFuer(w)),
                                )),
                      ],
                      onChanged: (v) => setState(() => _wirksamkeit = v),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Bemerkung
                  TextFormField(
                    controller: _bemerkungController,
                    decoration: const InputDecoration(
                      labelText: 'Bemerkung',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
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
                      label: const Text('Behandlung speichern'),
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
