import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late final TextEditingController _standortController;
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
    _standortController = TextEditingController(text: z?.standort ?? '');
    _bemerkungController = TextEditingController(text: z?.bemerkung ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breiteController.dispose();
    _tiefeController.dispose();
    _hoeheController.dispose();
    _standortController.dispose();
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
      final zelt = Zelt(
        id: widget.zelt?.id ?? '',
        name: _nameController.text.trim(),
        breiteCm: double.tryParse(_breiteController.text),
        tiefeCm: double.tryParse(_tiefeController.text),
        hoeheCm: double.tryParse(_hoeheController.text),
        standort: _trimOrNull(_standortController),
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
                  const _SectionHeader(title: 'Grunddaten'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name *', hintText: 'z.B. Doppelzelt P2/P3'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name ist erforderlich' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _standortController,
                    decoration: const InputDecoration(labelText: 'Standort', hintText: 'z.B. Keller, Growraum'),
                  ),

                  const SizedBox(height: 28),

                  const _SectionHeader(title: 'Dimensionen'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _breiteController,
                          decoration: const InputDecoration(labelText: 'Breite', suffixText: 'cm'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _tiefeController,
                          decoration: const InputDecoration(labelText: 'Tiefe', suffixText: 'cm'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _hoeheController,
                          decoration: const InputDecoration(labelText: 'Höhe', suffixText: 'cm'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

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

                  const SizedBox(height: 16),

                  if (!_isEdit)
                    Text(
                      'Anbauflächen (Beleuchtung, Lüftung, Bewässerung) kannst du nach dem Erstellen hinzufügen.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
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
