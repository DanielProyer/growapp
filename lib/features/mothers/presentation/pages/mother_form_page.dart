import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../strains/presentation/providers/sorten_provider.dart';
import '../../domain/entities/mutterpflanze.dart';
import '../providers/muetter_provider.dart';

class MotherFormPage extends ConsumerStatefulWidget {
  final Mutterpflanze? mutter;

  const MotherFormPage({super.key, this.mutter});

  @override
  ConsumerState<MotherFormPage> createState() => _MotherFormPageState();
}

class _MotherFormPageState extends ConsumerState<MotherFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String? _sorteId;
  late final TextEditingController _klonNummerController;
  DateTime? _stecklingDatum;
  DateTime? _topf1lDatum;
  DateTime? _topf35lDatum;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.mutter != null;

  @override
  void initState() {
    super.initState();
    final m = widget.mutter;
    _sorteId = m?.sorteId;
    _klonNummerController =
        TextEditingController(text: m?.klonNummer?.toString() ?? '');
    _stecklingDatum = m?.stecklingDatum;
    _topf1lDatum = m?.topf1lDatum;
    _topf35lDatum = m?.topf35lDatum;
    _bemerkungController = TextEditingController(text: m?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _klonNummerController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  Future<void> _datumWaehlen(
      DateTime? aktuell, void Function(DateTime) setzen) async {
    final datum = await showDatePicker(
      context: context,
      initialDate: aktuell ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('de'),
    );
    if (datum != null) {
      setState(() => setzen(datum));
    }
  }

  String _datumFormatiert(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

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
      final klonNr = int.tryParse(_klonNummerController.text.trim());
      final mutter = Mutterpflanze(
        id: widget.mutter?.id ?? '',
        sorteId: _sorteId!,
        klonNummer: klonNr,
        status: widget.mutter?.status ?? 'aktiv',
        stecklingDatum: _stecklingDatum,
        topf1lDatum: _topf1lDatum,
        topf35lDatum: _topf35lDatum,
        entsorgtDatum: widget.mutter?.entsorgtDatum,
        entsorgtGrund: widget.mutter?.entsorgtGrund,
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      final notifier = ref.read(muetterListeProvider.notifier);
      if (_isEdit) {
        await notifier.mutterAktualisieren(widget.mutter!.id, mutter);
      } else {
        await notifier.erstellen(mutter);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEdit
                  ? 'Mutterpflanze aktualisiert'
                  : 'Mutterpflanze erstellt')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEdit ? 'Mutterpflanze bearbeiten' : 'Neue Mutterpflanze'),
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
                      onChanged: (v) => setState(() => _sorteId = v),
                      validator: (v) =>
                          v == null ? 'Bitte eine Sorte auswählen' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text('Fehler beim Laden der Sorten'),
                  ),
                  const SizedBox(height: 16),

                  // Klonnummer
                  TextFormField(
                    controller: _klonNummerController,
                    decoration: const InputDecoration(
                      labelText: 'Klonnummer',
                      prefixIcon: Icon(Icons.tag),
                      hintText: 'z.B. 1, 2, 3...',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Steckling-Datum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Steckling-Datum'),
                    subtitle: Text(
                      _stecklingDatum != null
                          ? _datumFormatiert(_stecklingDatum!)
                          : 'Nicht gesetzt',
                    ),
                    trailing: _stecklingDatum != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _stecklingDatum = null),
                          )
                        : null,
                    onTap: () => _datumWaehlen(
                        _stecklingDatum, (d) => _stecklingDatum = d),
                  ),
                  const Divider(),

                  // Topf 1L-Datum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Umtopfen in 1L'),
                    subtitle: Text(
                      _topf1lDatum != null
                          ? _datumFormatiert(_topf1lDatum!)
                          : 'Nicht gesetzt',
                    ),
                    trailing: _topf1lDatum != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _topf1lDatum = null),
                          )
                        : null,
                    onTap: () =>
                        _datumWaehlen(_topf1lDatum, (d) => _topf1lDatum = d),
                  ),
                  const Divider(),

                  // Topf 3.5L-Datum
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Umtopfen in 3.5L'),
                    subtitle: Text(
                      _topf35lDatum != null
                          ? _datumFormatiert(_topf35lDatum!)
                          : 'Nicht gesetzt',
                    ),
                    trailing: _topf35lDatum != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _topf35lDatum = null),
                          )
                        : null,
                    onTap: () => _datumWaehlen(
                        _topf35lDatum, (d) => _topf35lDatum = d),
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
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isEdit
                          ? 'Mutterpflanze aktualisieren'
                          : 'Mutterpflanze anlegen'),
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
