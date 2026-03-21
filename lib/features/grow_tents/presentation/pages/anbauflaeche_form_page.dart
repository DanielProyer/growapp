import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/anbauflaeche.dart';
import '../providers/zelte_provider.dart';

class AnbauflaecheFormPage extends ConsumerStatefulWidget {
  final String zeltId;
  final Anbauflaeche? anbauflaeche;

  const AnbauflaecheFormPage({
    super.key,
    required this.zeltId,
    this.anbauflaeche,
  });

  @override
  ConsumerState<AnbauflaecheFormPage> createState() => _AnbauflaecheFormPageState();
}

class _AnbauflaecheFormPageState extends ConsumerState<AnbauflaecheFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _lichtTypController;
  late final TextEditingController _lichtWattController;
  late final TextEditingController _lueftungController;
  late final TextEditingController _bewaesserungController;
  late final TextEditingController _etageController;
  late final TextEditingController _bemerkungController;

  bool get _isEdit => widget.anbauflaeche != null;

  @override
  void initState() {
    super.initState();
    final a = widget.anbauflaeche;
    _nameController = TextEditingController(text: a?.name ?? '');
    _lichtTypController = TextEditingController(text: a?.lichtTyp ?? '');
    _lichtWattController = TextEditingController(text: a?.lichtWatt?.toString() ?? '');
    _lueftungController = TextEditingController(text: a?.lueftung ?? '');
    _bewaesserungController = TextEditingController(text: a?.bewaesserung ?? '');
    _etageController = TextEditingController(text: a?.etage?.toString() ?? '');
    _bemerkungController = TextEditingController(text: a?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lichtTypController.dispose();
    _lichtWattController.dispose();
    _lueftungController.dispose();
    _bewaesserungController.dispose();
    _etageController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  String? _trimOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final a = Anbauflaeche(
        id: widget.anbauflaeche?.id ?? '',
        zeltId: widget.zeltId,
        name: _nameController.text.trim(),
        lichtTyp: _trimOrNull(_lichtTypController),
        lichtWatt: int.tryParse(_lichtWattController.text),
        lueftung: _trimOrNull(_lueftungController),
        bewaesserung: _trimOrNull(_bewaesserungController),
        etage: int.tryParse(_etageController.text),
        bemerkung: _trimOrNull(_bemerkungController),
      );

      final ds = ref.read(anbauflaechenDatasourceProvider);
      if (_isEdit) {
        await anbauflaecheAktualisieren(ds, a);
      } else {
        await anbauflaecheErstellen(ds, a);
      }

      // Anbauflächen-Liste neu laden
      ref.invalidate(anbauflaechenProvider(widget.zeltId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? 'Anbaufläche aktualisiert' : 'Anbaufläche erstellt')),
        );
        Navigator.of(context).pop(true);
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
        title: Text(_isEdit ? 'Anbaufläche bearbeiten' : 'Neue Anbaufläche'),
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
                  const _SectionHeader(title: 'Grunddaten'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name *', hintText: 'z.B. P2, Etage 1 – Stecklinge'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name ist erforderlich' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _etageController,
                    decoration: const InputDecoration(labelText: 'Etage (optional)', hintText: 'z.B. 1, 2, 3'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 28),

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
                          decoration: const InputDecoration(labelText: 'Leistung', suffixText: 'Watt'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

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

                  const _SectionHeader(title: 'Bemerkung'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bemerkungController,
                    decoration: const InputDecoration(
                      labelText: 'Bemerkung',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _speichern,
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_isEdit ? 'Anbaufläche aktualisieren' : 'Anbaufläche erstellen'),
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
