import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/zelt.dart';
import '../providers/zelte_provider.dart';

class TentFormPage extends ConsumerStatefulWidget {
  final Zelt? zelt;

  const TentFormPage({super.key, this.zelt});

  @override
  ConsumerState<TentFormPage> createState() => _TentFormPageState();
}

class _TentFormPageState extends ConsumerState<TentFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _breiteController;
  late final TextEditingController _tiefeController;
  late final TextEditingController _hoeheController;
  late final TextEditingController _lichtTypController;
  late final TextEditingController _lichtWattController;
  late final TextEditingController _lueftungController;
  late final TextEditingController _bewaesserungController;
  late final TextEditingController _standortController;
  late final TextEditingController _etagenController;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.zelt != null;

  @override
  void initState() {
    super.initState();
    final z = widget.zelt;
    _nameController = TextEditingController(text: z?.name ?? '');
    _breiteController = TextEditingController(text: z?.breiteCm?.toStringAsFixed(0) ?? '');
    _tiefeController = TextEditingController(text: z?.tiefeCm?.toStringAsFixed(0) ?? '');
    _hoeheController = TextEditingController(text: z?.hoeheCm?.toStringAsFixed(0) ?? '');
    _lichtTypController = TextEditingController(text: z?.lichtTyp ?? '');
    _lichtWattController = TextEditingController(text: z?.lichtWatt?.toString() ?? '');
    _lueftungController = TextEditingController(text: z?.lueftung ?? '');
    _bewaesserungController = TextEditingController(text: z?.bewaesserung ?? '');
    _standortController = TextEditingController(text: z?.standort ?? '');
    _etagenController = TextEditingController(text: '${z?.etagen ?? 1}');
    _bemerkungController = TextEditingController(text: z?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breiteController.dispose();
    _tiefeController.dispose();
    _hoeheController.dispose();
    _lichtTypController.dispose();
    _lichtWattController.dispose();
    _lueftungController.dispose();
    _bewaesserungController.dispose();
    _standortController.dispose();
    _etagenController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  String? _trimOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _speichern() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final zelt = Zelt(
        id: widget.zelt?.id ?? '',
        name: _nameController.text.trim(),
        breiteCm: double.tryParse(_breiteController.text),
        tiefeCm: double.tryParse(_tiefeController.text),
        hoeheCm: double.tryParse(_hoeheController.text),
        lichtTyp: _trimOrNull(_lichtTypController),
        lichtWatt: int.tryParse(_lichtWattController.text),
        lueftung: _trimOrNull(_lueftungController),
        bewaesserung: _trimOrNull(_bewaesserungController),
        standort: _trimOrNull(_standortController),
        etagen: int.tryParse(_etagenController.text) ?? 1,
        bemerkung: _trimOrNull(_bemerkungController),
      );

      final repo = ref.read(zelteRepositoryProvider);
      if (_isEdit) {
        await repo.aktualisieren(zelt);
      } else {
        await repo.erstellen(zelt);
      }

      await ref.read(zelteListeProvider.notifier).aktualisieren();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? 'Zelt aktualisiert' : 'Zelt erstellt')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: Theme.of(context).colorScheme.error),
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
        title: Text(_isEdit ? 'Zelt bearbeiten' : 'Neues Zelt'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _speichern,
            icon: _isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save, color: Colors.white),
            label: Text('Speichern', style: TextStyle(color: _isLoading ? Colors.grey : Colors.white)),
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
                    decoration: const InputDecoration(labelText: 'Name *', hintText: 'z.B. P1 Produktion'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name ist erforderlich' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _standortController,
                    decoration: const InputDecoration(labelText: 'Standort', hintText: 'z.B. Keller, Growraum'),
                  ),

                  const SizedBox(height: 28),

                  // ── Dimensionen ──
                  const _SectionHeader(title: 'Dimensionen'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _breiteController,
                          decoration: const InputDecoration(labelText: 'Breite (cm)'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _tiefeController,
                          decoration: const InputDecoration(labelText: 'Tiefe (cm)'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _hoeheController,
                          decoration: const InputDecoration(labelText: 'Höhe (cm)'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _etagenController,
                    decoration: const InputDecoration(labelText: 'Etagen', hintText: '1'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 28),

                  // ── Beleuchtung ──
                  const _SectionHeader(title: 'Beleuchtung'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lichtTypController,
                          decoration: const InputDecoration(labelText: 'Lichttyp', hintText: 'z.B. LED, NDL, CMH'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lichtWattController,
                          decoration: const InputDecoration(labelText: 'Leistung (Watt)'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Ausstattung ──
                  const _SectionHeader(title: 'Ausstattung'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lueftungController,
                    decoration: const InputDecoration(labelText: 'Lüftung', hintText: 'z.B. Abluft 150mm + AKF'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bewaesserungController,
                    decoration: const InputDecoration(labelText: 'Bewässerung', hintText: 'z.B. Autopot, Blumat, Hand'),
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

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _speichern,
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_isEdit ? 'Zelt aktualisieren' : 'Zelt erstellen'),
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
        Divider(color: Theme.of(context).colorScheme.primary.withAlpha(50)),
      ],
    );
  }
}
