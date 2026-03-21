import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/app_constants.dart';
import '../../domain/entities/sorte.dart';
import '../providers/sorten_provider.dart';

class StrainFormPage extends ConsumerStatefulWidget {
  final Sorte? sorte;

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
  late final TextEditingController _kreuzungController;
  late final TextEditingController _indicaController;
  late final TextEditingController _sativaController;
  late final TextEditingController _thcController;
  late final TextEditingController _cbdController;
  late final TextEditingController _bluetezeitZuechterController;
  late final TextEditingController _bluetezeitEigenController;
  late final TextEditingController _pflanzenhoheZuechterController;
  late final TextEditingController _pflanzenhoheEigenController;
  late final TextEditingController _ertragZuechterController;
  late final TextEditingController _ertragEigenController;
  late final TextEditingController _keimquoteController;
  late final TextEditingController _samenAnzahlController;
  late final TextEditingController _aromaController;
  late final TextEditingController _geschmackController;
  late final TextEditingController _terpenprofilController;
  late final TextEditingController _wirkungHighController;
  late final TextEditingController _growTippController;
  late final TextEditingController _bemerkungController;

  late String _status;
  late String _geschlecht;

  bool get _isEdit => widget.sorte != null;

  @override
  void initState() {
    super.initState();
    final s = widget.sorte;
    _nameController = TextEditingController(text: s?.name ?? '');
    _zuechterController = TextEditingController(text: s?.zuechter ?? '');
    _kreuzungController = TextEditingController(text: s?.kreuzung ?? '');
    _indicaController = TextEditingController(text: '${s?.indicaAnteil ?? 0}');
    _sativaController = TextEditingController(text: '${s?.sativaAnteil ?? 0}');
    _thcController = TextEditingController(text: s?.thcGehalt?.toString() ?? '');
    _cbdController = TextEditingController(text: s?.cbdGehalt?.toString() ?? '');
    _bluetezeitZuechterController = TextEditingController(text: s?.bluetezeitZuechter?.toString() ?? '');
    _bluetezeitEigenController = TextEditingController(text: s?.bluetezeitEigen?.toString() ?? '');
    _pflanzenhoheZuechterController = TextEditingController(text: s?.pflanzenhoheZuechter ?? '');
    _pflanzenhoheEigenController = TextEditingController(text: s?.pflanzenhoheEigen ?? '');
    _ertragZuechterController = TextEditingController(text: s?.ertragZuechter ?? '');
    _ertragEigenController = TextEditingController(text: s?.ertragEigen ?? '');
    _keimquoteController = TextEditingController(text: s?.keimquote?.toString() ?? '');
    _samenAnzahlController = TextEditingController(text: '${s?.samenAnzahl ?? 0}');
    _aromaController = TextEditingController(text: s?.aroma ?? '');
    _geschmackController = TextEditingController(text: s?.geschmack ?? '');
    _terpenprofilController = TextEditingController(text: s?.terpenprofil ?? '');
    _wirkungHighController = TextEditingController(text: s?.wirkungHigh ?? '');
    _growTippController = TextEditingController(text: s?.growTipp ?? '');
    _bemerkungController = TextEditingController(text: s?.bemerkung ?? '');
    _status = s?.status ?? 'aktiv';
    _geschlecht = s?.geschlecht ?? 'feminisiert';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _zuechterController.dispose();
    _kreuzungController.dispose();
    _indicaController.dispose();
    _sativaController.dispose();
    _thcController.dispose();
    _cbdController.dispose();
    _bluetezeitZuechterController.dispose();
    _bluetezeitEigenController.dispose();
    _pflanzenhoheZuechterController.dispose();
    _pflanzenhoheEigenController.dispose();
    _ertragZuechterController.dispose();
    _ertragEigenController.dispose();
    _keimquoteController.dispose();
    _samenAnzahlController.dispose();
    _aromaController.dispose();
    _geschmackController.dispose();
    _terpenprofilController.dispose();
    _wirkungHighController.dispose();
    _growTippController.dispose();
    _bemerkungController.dispose();
    super.dispose();
  }

  String? _trimOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  String _geschlechtLabel(String value) {
    switch (value) {
      case 'feminisiert':
        return 'Feminisiert';
      case 'regulaer':
        return 'Regulär';
      case 'automatik':
        return 'Automatik';
      default:
        return value;
    }
  }

  Future<void> _speichern() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final sorte = Sorte(
        id: widget.sorte?.id ?? '',
        name: _nameController.text.trim(),
        zuechter: _trimOrNull(_zuechterController),
        geschlecht: _geschlecht,
        kreuzung: _trimOrNull(_kreuzungController),
        indicaAnteil: int.tryParse(_indicaController.text) ?? 0,
        sativaAnteil: int.tryParse(_sativaController.text) ?? 0,
        thcGehalt: double.tryParse(_thcController.text),
        cbdGehalt: double.tryParse(_cbdController.text),
        bluetezeitZuechter: int.tryParse(_bluetezeitZuechterController.text),
        bluetezeitEigen: int.tryParse(_bluetezeitEigenController.text),
        pflanzenhoheZuechter: _trimOrNull(_pflanzenhoheZuechterController),
        pflanzenhoheEigen: _trimOrNull(_pflanzenhoheEigenController),
        ertragZuechter: _trimOrNull(_ertragZuechterController),
        ertragEigen: _trimOrNull(_ertragEigenController),
        keimquote: int.tryParse(_keimquoteController.text),
        samenAnzahl: int.tryParse(_samenAnzahlController.text) ?? 0,
        aroma: _trimOrNull(_aromaController),
        geschmack: _trimOrNull(_geschmackController),
        terpenprofil: _trimOrNull(_terpenprofilController),
        wirkungHigh: _trimOrNull(_wirkungHighController),
        growTipp: _trimOrNull(_growTippController),
        status: _status,
        bemerkung: _trimOrNull(_bemerkungController),
      );

      final repo = ref.read(sortenRepositoryProvider);
      if (_isEdit) {
        await repo.aktualisieren(sorte);
      } else {
        await repo.erstellen(sorte);
      }

      await ref.read(sortenListeProvider.notifier).aktualisieren();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? 'Sorte aktualisiert' : 'Sorte erstellt')),
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
        title: Text(_isEdit ? 'Sorte bearbeiten' : 'Neue Sorte'),
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
                    decoration: const InputDecoration(labelText: 'Name *', hintText: 'z.B. Wedding Cake'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name ist erforderlich' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _zuechterController,
                    decoration: const InputDecoration(labelText: 'Züchter / Breeder', hintText: 'z.B. Barneys Farm'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: AppConstants.sortenStatus
                              .map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1))))
                              .toList(),
                          onChanged: (v) { if (v != null) setState(() => _status = v); },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _geschlecht,
                          decoration: const InputDecoration(labelText: 'Geschlecht'),
                          items: AppConstants.sortenGeschlecht
                              .map((g) => DropdownMenuItem(value: g, child: Text(_geschlechtLabel(g))))
                              .toList(),
                          onChanged: (v) { if (v != null) setState(() => _geschlecht = v); },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Genetik ──
                  const _SectionHeader(title: 'Genetik'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kreuzungController,
                    decoration: const InputDecoration(
                      labelText: 'Kreuzung',
                      hintText: 'z.B. Jelly Donutz #117 × Purple Cartel',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _indicaController,
                          decoration: const InputDecoration(labelText: 'Indica %'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (v) {
                            final indica = int.tryParse(v) ?? 0;
                            if (indica <= 100) _sativaController.text = '${100 - indica}';
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _sativaController,
                          decoration: const InputDecoration(labelText: 'Sativa %'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (v) {
                            final sativa = int.tryParse(v) ?? 0;
                            if (sativa <= 100) _indicaController.text = '${100 - sativa}';
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
                          decoration: const InputDecoration(labelText: 'THC %'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cbdController,
                          decoration: const InputDecoration(labelText: 'CBD %'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Aroma, Geschmack & Wirkung ──
                  const _SectionHeader(title: 'Aroma, Geschmack & Wirkung'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _aromaController,
                    decoration: const InputDecoration(labelText: 'Aroma', hintText: 'z.B. fruchtig, süß, erdig'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _geschmackController,
                    decoration: const InputDecoration(labelText: 'Geschmack', hintText: 'z.B. zitronig, würzig, blumig'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _terpenprofilController,
                    decoration: const InputDecoration(labelText: 'Terpenprofil', hintText: 'z.B. Myrcen, Limonen, Caryophyllen'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _wirkungHighController,
                    decoration: const InputDecoration(
                      labelText: 'Wirkung & High',
                      hintText: 'Beschreibe die Wirkung...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 28),

                  // ── Anbau ──
                  const _SectionHeader(title: 'Anbau'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bluetezeitZuechterController,
                          decoration: const InputDecoration(labelText: 'Blütezeit Züchter', suffixText: 'Tage'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _bluetezeitEigenController,
                          decoration: const InputDecoration(labelText: 'Blütezeit Eigen', suffixText: 'Tage'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pflanzenhoheZuechterController,
                          decoration: const InputDecoration(labelText: 'Pflanzenhöhe Züchter', suffixText: 'cm'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _pflanzenhoheEigenController,
                          decoration: const InputDecoration(labelText: 'Pflanzenhöhe Eigen', suffixText: 'cm'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ertragZuechterController,
                          decoration: const InputDecoration(labelText: 'Ertrag Züchter', suffixText: 'g/m²'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _ertragEigenController,
                          decoration: const InputDecoration(labelText: 'Ertrag Eigen', suffixText: 'g/m²'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _growTippController,
                    decoration: const InputDecoration(
                      labelText: 'Grow-Tipp',
                      hintText: 'Tipps zum Anbau dieser Sorte...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 28),

                  // ── Bestand ──
                  const _SectionHeader(title: 'Bestand'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _samenAnzahlController,
                          decoration: const InputDecoration(labelText: 'Samen vorrätig'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _keimquoteController,
                          decoration: const InputDecoration(labelText: 'Keimquote %'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
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
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_isEdit ? 'Sorte aktualisieren' : 'Sorte erstellen'),
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
