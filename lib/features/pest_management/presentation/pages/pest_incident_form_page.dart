import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../grow_tents/presentation/providers/zelte_provider.dart';
import '../../domain/entities/schaedlings_vorfall.dart';
import '../providers/schaedlings_provider.dart';

class PestIncidentFormPage extends ConsumerStatefulWidget {
  final SchaedlingsVorfall? vorfall;

  const PestIncidentFormPage({super.key, this.vorfall});

  @override
  ConsumerState<PestIncidentFormPage> createState() =>
      _PestIncidentFormPageState();
}

class _PestIncidentFormPageState extends ConsumerState<PestIncidentFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String? _zeltId;
  late String _schaedlingTyp;
  late String _schweregrad;
  late DateTime _erkanntDatum;
  DateTime? _behobenDatum;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.vorfall != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vorfall;
    _zeltId = v?.zeltId;
    _schaedlingTyp = v?.schaedlingTyp ?? AppConstants.schaedlingsTypen.first;
    _schweregrad = v?.schweregrad ?? 'niedrig';
    _erkanntDatum = v?.erkanntDatum ?? DateTime.now();
    _behobenDatum = v?.behobenDatum;
    _bemerkungController = TextEditingController(text: v?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _bemerkungController.dispose();
    super.dispose();
  }

  Future<void> _datumWaehlen({required bool istBehoben}) async {
    final initial = istBehoben ? (_behobenDatum ?? DateTime.now()) : _erkanntDatum;
    final datum = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('de'),
    );
    if (datum != null) {
      setState(() {
        if (istBehoben) {
          _behobenDatum = datum;
        } else {
          _erkanntDatum = datum;
        }
      });
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
      final vorfall = SchaedlingsVorfall(
        id: widget.vorfall?.id ?? '',
        zeltId: _zeltId,
        schaedlingTyp: _schaedlingTyp,
        schweregrad: _schweregrad,
        erkanntDatum: _erkanntDatum,
        behobenDatum: _behobenDatum,
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      final notifier = ref.read(vorfaelleListeProvider.notifier);
      if (_isEdit) {
        await notifier.vorfallAktualisieren(widget.vorfall!.id, vorfall);
      } else {
        await notifier.erstellen(vorfall);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEdit ? 'Vorfall aktualisiert' : 'Vorfall erstellt')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Vorfall bearbeiten' : 'Neuer Vorfall'),
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
                  // Zelt
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
                    error: (_, _) => const Text('Fehler beim Laden der Zelte'),
                  ),
                  const SizedBox(height: 16),

                  // Schädlingstyp
                  DropdownButtonFormField<String>(
                    initialValue: _schaedlingTyp,
                    decoration: const InputDecoration(
                      labelText: 'Schädlingstyp *',
                      prefixIcon: Icon(Icons.bug_report_outlined),
                    ),
                    items: AppConstants.schaedlingsTypen
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                  SchaedlingsVorfall.schaedlingTypLabelFuer(t)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _schaedlingTyp = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Schweregrad
                  DropdownButtonFormField<String>(
                    initialValue: _schweregrad,
                    decoration: const InputDecoration(
                      labelText: 'Schweregrad',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                    ),
                    items: AppConstants.schweregrade
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(_schweregradLabel(s)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _schweregrad = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Erkannt-Datum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Erkannt am'),
                    subtitle: Text(
                      '${_erkanntDatum.day.toString().padLeft(2, '0')}.${_erkanntDatum.month.toString().padLeft(2, '0')}.${_erkanntDatum.year}',
                    ),
                    onTap: () => _datumWaehlen(istBehoben: false),
                  ),
                  const Divider(),

                  // Behoben-Datum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline),
                    title: const Text('Behoben am (optional)'),
                    subtitle: Text(
                      _behobenDatum != null
                          ? '${_behobenDatum!.day.toString().padLeft(2, '0')}.${_behobenDatum!.month.toString().padLeft(2, '0')}.${_behobenDatum!.year}'
                          : 'Nicht gesetzt',
                    ),
                    trailing: _behobenDatum != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _behobenDatum = null),
                          )
                        : null,
                    onTap: () => _datumWaehlen(istBehoben: true),
                  ),
                  const Divider(),
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
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                          _isEdit ? 'Vorfall aktualisieren' : 'Vorfall melden'),
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

  String _schweregradLabel(String s) {
    switch (s) {
      case 'niedrig':
        return 'Niedrig';
      case 'mittel':
        return 'Mittel';
      case 'hoch':
        return 'Hoch';
      case 'kritisch':
        return 'Kritisch';
      default:
        return s;
    }
  }
}
