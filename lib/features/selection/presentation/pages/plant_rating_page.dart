import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_constants.dart';
import '../../domain/entities/selektions_pflanze.dart';
import '../../domain/entities/wachstums_messung.dart';
import '../providers/selektions_provider.dart';
import 'growth_measurement_form.dart';

class PlantRatingPage extends ConsumerStatefulWidget {
  final SelektionsPflanze selektionsPflanze;
  final String selektionId;

  const PlantRatingPage({
    super.key,
    required this.selektionsPflanze,
    required this.selektionId,
  });

  @override
  ConsumerState<PlantRatingPage> createState() => _PlantRatingPageState();
}

class _PlantRatingPageState extends ConsumerState<PlantRatingPage> {
  bool _isLoading = false;

  // Bewertungen
  late int? _vigor;
  late int? _struktur;
  late int? _harz;
  late int? _aroma;
  late int? _ertrag;
  late int? _schaedlingsresistenz;
  late int? _festigkeit;
  late int? _geschmack;
  late int? _wirkung;

  // Zusatzfelder
  late String _keeperStatus;
  late bool _vorselektion;
  late final TextEditingController _bemerkungController;

  // JSONB-Notizen
  late Map<String, dynamic> _bewertungNotizen;
  late Map<String, dynamic> _trichomNotizen;

  // TextController für Notizen pro Kriterium
  late final TextEditingController _notizenVigor;
  late final TextEditingController _notizenStruktur;
  late final TextEditingController _notizenHarz;
  late final TextEditingController _notizenAroma;
  late final TextEditingController _notizenErtrag;
  late final TextEditingController _notizenResistenz;
  late final TextEditingController _notizenFestigkeit;
  late final TextEditingController _notizenGeschmack;
  late final TextEditingController _notizenWirkung;

  // Aroma-Kategorien und Wirkungstyp
  late Set<String> _aromaKategorien;
  late String? _wirkungstyp;
  late String? _verzweigung;
  late bool _hermaphrodit;

  @override
  void initState() {
    super.initState();
    final p = widget.selektionsPflanze;

    _vigor = p.bewertungVigor;
    _struktur = p.bewertungStruktur;
    _harz = p.bewertungHarz;
    _aroma = p.bewertungAroma;
    _ertrag = p.bewertungErtrag;
    _schaedlingsresistenz = p.bewertungSchaedlingsresistenz;
    _festigkeit = p.bewertungFestigkeit;
    _geschmack = p.bewertungGeschmack;
    _wirkung = p.bewertungWirkung;

    _keeperStatus = p.keeperStatus;
    _vorselektion = p.vorselektion;
    _bemerkungController = TextEditingController(text: p.bemerkung ?? '');

    _bewertungNotizen = Map<String, dynamic>.from(p.bewertungNotizen);
    _trichomNotizen = Map<String, dynamic>.from(p.trichomNotizen);

    _notizenVigor =
        TextEditingController(text: _bewertungNotizen['vigor'] as String? ?? '');
    _notizenStruktur = TextEditingController(
        text: _bewertungNotizen['struktur'] as String? ?? '');
    _notizenHarz =
        TextEditingController(text: _bewertungNotizen['harz'] as String? ?? '');
    _notizenAroma = TextEditingController(
        text: _bewertungNotizen['aroma'] as String? ?? '');
    _notizenErtrag = TextEditingController(
        text: _bewertungNotizen['ertrag'] as String? ?? '');
    _notizenResistenz = TextEditingController(
        text: _bewertungNotizen['resistenz'] as String? ?? '');
    _notizenFestigkeit = TextEditingController(
        text: _bewertungNotizen['festigkeit'] as String? ?? '');
    _notizenGeschmack = TextEditingController(
        text: _bewertungNotizen['geschmack'] as String? ?? '');
    _notizenWirkung = TextEditingController(
        text: _bewertungNotizen['wirkung'] as String? ?? '');

    final kategorienRaw = _bewertungNotizen['aroma_kategorien'];
    _aromaKategorien = kategorienRaw is List
        ? kategorienRaw.cast<String>().toSet()
        : <String>{};

    _wirkungstyp = _bewertungNotizen['wirkungstyp'] as String?;
    _verzweigung = _bewertungNotizen['verzweigung'] as String?;
    _hermaphrodit = _bewertungNotizen['hermaphrodit'] as bool? ?? false;
  }

  @override
  void dispose() {
    _bemerkungController.dispose();
    _notizenVigor.dispose();
    _notizenStruktur.dispose();
    _notizenHarz.dispose();
    _notizenAroma.dispose();
    _notizenErtrag.dispose();
    _notizenResistenz.dispose();
    _notizenFestigkeit.dispose();
    _notizenGeschmack.dispose();
    _notizenWirkung.dispose();
    super.dispose();
  }

  Map<String, dynamic> _baueBewertungNotizen() {
    final notizen = <String, dynamic>{};

    void setzeWennNichtLeer(String key, String wert) {
      if (wert.trim().isNotEmpty) notizen[key] = wert.trim();
    }

    setzeWennNichtLeer('vigor', _notizenVigor.text);
    setzeWennNichtLeer('struktur', _notizenStruktur.text);
    setzeWennNichtLeer('harz', _notizenHarz.text);
    setzeWennNichtLeer('aroma', _notizenAroma.text);
    setzeWennNichtLeer('ertrag', _notizenErtrag.text);
    setzeWennNichtLeer('resistenz', _notizenResistenz.text);
    setzeWennNichtLeer('festigkeit', _notizenFestigkeit.text);
    setzeWennNichtLeer('geschmack', _notizenGeschmack.text);
    setzeWennNichtLeer('wirkung', _notizenWirkung.text);

    if (_wirkungstyp != null) notizen['wirkungstyp'] = _wirkungstyp;
    if (_aromaKategorien.isNotEmpty) {
      notizen['aroma_kategorien'] = _aromaKategorien.toList();
    }
    if (_verzweigung != null) notizen['verzweigung'] = _verzweigung;
    if (_hermaphrodit) notizen['hermaphrodit'] = true;

    return notizen;
  }

  Future<void> _speichern() async {
    setState(() => _isLoading = true);

    try {
      final pflanze = SelektionsPflanze(
        id: widget.selektionsPflanze.id,
        selektionId: widget.selektionsPflanze.selektionId,
        pflanzeId: widget.selektionsPflanze.pflanzeId,
        keeperStatus: _keeperStatus,
        vorselektion: _vorselektion,
        bewertungVigor: _vigor,
        bewertungStruktur: _struktur,
        bewertungHarz: _harz,
        bewertungAroma: _aroma,
        bewertungErtrag: _ertrag,
        bewertungSchaedlingsresistenz: _schaedlingsresistenz,
        bewertungFestigkeit: _festigkeit,
        bewertungGeschmack: _geschmack,
        bewertungWirkung: _wirkung,
        trichomNotizen: _trichomNotizen,
        bewertungNotizen: _baueBewertungNotizen(),
        bemerkung: _bemerkungController.text.trim().isEmpty
            ? null
            : _bemerkungController.text.trim(),
      );

      await selektionsPflanzeAktualisieren(
        ref,
        id: widget.selektionsPflanze.id,
        pflanze: pflanze,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bewertung gespeichert')),
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

  Future<void> _trichomEintragHinzufuegen() async {
    final wocheController = TextEditingController();
    final statusController = TextEditingController();

    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trichom-Eintrag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wocheController,
              decoration: const InputDecoration(
                labelText: 'BT-Woche (z.B. bt50, bt55)',
                hintText: 'bt50',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: statusController,
              decoration: const InputDecoration(
                labelText: 'Status',
                hintText: 'z.B. 100% klar, 20% bernstein',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );

    if (bestaetigt == true) {
      final woche = wocheController.text.trim();
      final status = statusController.text.trim();
      if (woche.isNotEmpty && status.isNotEmpty) {
        setState(() {
          _trichomNotizen[woche] = status;
        });
      }
    }
    wocheController.dispose();
    statusController.dispose();
  }

  Future<void> _messungHinzufuegen() async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GrowthMeasurementForm(
          pflanzeId: widget.selektionsPflanze.pflanzeId,
        ),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(
          wachstumsMessungenProvider(widget.selektionsPflanze.pflanzeId));
    }
  }

  Future<void> _messungLoeschenDialog(WachstumsMessung messung) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Messung löschen'),
        content:
            Text('Messung vom ${messung.datumFormatiert} wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (bestaetigt == true && mounted) {
      try {
        await messungLoeschen(ref, messung: messung);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Messung gelöscht')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }

  Widget _bewertungSlider({
    required String label,
    required String beschreibung,
    required int? wert,
    required void Function(int?) onChanged,
    required TextEditingController notizenController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text(
              wert != null ? '$wert/10' : '-',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: wert != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ],
        ),
        Text(beschreibung,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Row(
          children: [
            if (wert != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => onChanged(null),
                tooltip: 'Zurücksetzen',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            Expanded(
              child: Slider(
                value: (wert ?? 5).toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: wert?.toString(),
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ],
        ),
        TextField(
          controller: notizenController,
          decoration: InputDecoration(
            hintText: 'Notiz zu $label...',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(fontSize: 13),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messungenAsync = ref.watch(
        wachstumsMessungenProvider(widget.selektionsPflanze.pflanzeId));

    // Gesamtbewertung berechnen
    final scores = <int>[
      if (_vigor != null) _vigor!,
      if (_struktur != null) _struktur!,
      if (_harz != null) _harz!,
      if (_aroma != null) _aroma!,
      if (_ertrag != null) _ertrag!,
      if (_schaedlingsresistenz != null) _schaedlingsresistenz!,
      if (_festigkeit != null) _festigkeit!,
      if (_geschmack != null) _geschmack!,
      if (_wirkung != null) _wirkung!,
    ];
    final gesamt = scores.isNotEmpty
        ? scores.reduce((a, b) => a + b) / scores.length
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selektionsPflanze.bezeichnung} bewerten'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sektion 1: Stammdaten
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stammdaten',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(widget.selektionsPflanze.bezeichnung,
                                style: theme.textTheme.titleSmall),
                            if (widget.selektionsPflanze.sorteName != null) ...[
                              const SizedBox(width: 8),
                              Text('(${widget.selektionsPflanze.sorteName})',
                                  style:
                                      TextStyle(color: Colors.grey[600])),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Keeper-Status
                        const Text('Keeper-Status',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                                value: 'ja',
                                label: Text('Keeper'),
                                icon: Icon(Icons.star)),
                            ButtonSegment(
                                value: 'vielleicht',
                                label: Text('Vielleicht'),
                                icon: Icon(Icons.help_outline)),
                            ButtonSegment(
                                value: 'nein',
                                label: Text('Nein'),
                                icon: Icon(Icons.close)),
                          ],
                          selected: {_keeperStatus},
                          onSelectionChanged: (v) =>
                              setState(() => _keeperStatus = v.first),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Vorselektion'),
                          subtitle: const Text(
                              'Pflanze für engere Auswahl markieren'),
                          value: _vorselektion,
                          onChanged: (v) =>
                              setState(() => _vorselektion = v),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (gesamt != null) ...[
                          const Divider(),
                          Row(
                            children: [
                              const Text('Gesamtbewertung',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme.primaryContainer,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  gesamt.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: theme.colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sektion 2: Wachstum & Resistenz
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wachstum & Resistenz',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        _bewertungSlider(
                          label: 'Wuchsverhalten',
                          beschreibung:
                              'Wuchskraft, Geschwindigkeit, Gesundheit',
                          wert: _vigor,
                          onChanged: (v) =>
                              setState(() => _vigor = v),
                          notizenController: _notizenVigor,
                        ),
                        _bewertungSlider(
                          label: 'Schädlingsresistenz',
                          beschreibung:
                              'Widerstandsfähigkeit gegen Schädlinge',
                          wert: _schaedlingsresistenz,
                          onChanged: (v) =>
                              setState(() => _schaedlingsresistenz = v),
                          notizenController: _notizenResistenz,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sektion 3: Blüten-Qualität
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Blüten-Qualität',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        _bewertungSlider(
                          label: 'Budstruktur',
                          beschreibung:
                              'Form, Kompaktheit, Calyx-Blatt-Verhältnis',
                          wert: _struktur,
                          onChanged: (v) =>
                              setState(() => _struktur = v),
                          notizenController: _notizenStruktur,
                        ),
                        _bewertungSlider(
                          label: 'Festigkeit',
                          beschreibung: 'Dichte/Härte der Buds',
                          wert: _festigkeit,
                          onChanged: (v) =>
                              setState(() => _festigkeit = v),
                          notizenController: _notizenFestigkeit,
                        ),
                        _bewertungSlider(
                          label: 'Harzgehalt',
                          beschreibung:
                              'Trichom-Dichte, Harzproduktion',
                          wert: _harz,
                          onChanged: (v) =>
                              setState(() => _harz = v),
                          notizenController: _notizenHarz,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sektion 4: Sensorik
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sensorik (nach Cure)',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        _bewertungSlider(
                          label: 'Aroma',
                          beschreibung:
                              'Geruchsintensität und -qualität',
                          wert: _aroma,
                          onChanged: (v) =>
                              setState(() => _aroma = v),
                          notizenController: _notizenAroma,
                        ),
                        _bewertungSlider(
                          label: 'Geschmack',
                          beschreibung: 'Geschmack beim Konsum',
                          wert: _geschmack,
                          onChanged: (v) =>
                              setState(() => _geschmack = v),
                          notizenController: _notizenGeschmack,
                        ),
                        _bewertungSlider(
                          label: 'Wirkung',
                          beschreibung:
                              'Qualität und Intensität der Wirkung',
                          wert: _wirkung,
                          onChanged: (v) =>
                              setState(() => _wirkung = v),
                          notizenController: _notizenWirkung,
                        ),

                        // Wirkungstyp
                        DropdownButtonFormField<String>(
                          initialValue: _wirkungstyp,
                          decoration: const InputDecoration(
                            labelText: 'Wirkungstyp',
                            prefixIcon: Icon(Icons.psychology_outlined),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Nicht bewertet'),
                            ),
                            ...AppConstants.wirkungsTypen
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(_wirkungsTypLabel(t)),
                                    )),
                          ],
                          onChanged: (v) =>
                              setState(() => _wirkungstyp = v),
                        ),
                        const SizedBox(height: 16),

                        // Aroma-Kategorien
                        const Text('Aroma-Kategorien',
                            style:
                                TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              AppConstants.aromaKategorien.map((k) {
                            final selected =
                                _aromaKategorien.contains(k);
                            return FilterChip(
                              label: Text(_aromaKategorieLabel(k)),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _aromaKategorien.add(k);
                                  } else {
                                    _aromaKategorien.remove(k);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sektion 5: Ertrag
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ertrag',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        _bewertungSlider(
                          label: 'Ertrag',
                          beschreibung:
                              'Ertragsmenge relativ zur Pflanzengröße',
                          wert: _ertrag,
                          onChanged: (v) =>
                              setState(() => _ertrag = v),
                          notizenController: _notizenErtrag,
                        ),
                        // Verzweigung
                        DropdownButtonFormField<String>(
                          initialValue: _verzweigung,
                          decoration: const InputDecoration(
                            labelText: 'Verzweigung',
                            prefixIcon: Icon(Icons.account_tree_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: null,
                                child: Text('Nicht bewertet')),
                            DropdownMenuItem(
                                value: 'gering',
                                child: Text('Gering')),
                            DropdownMenuItem(
                                value: 'mittel',
                                child: Text('Mittel')),
                            DropdownMenuItem(
                                value: 'stark',
                                child: Text('Stark')),
                          ],
                          onChanged: (v) =>
                              setState(() => _verzweigung = v),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Hermaphrodit'),
                          subtitle: const Text(
                              'Zwitterblüten / Nanners beobachtet'),
                          value: _hermaphrodit,
                          onChanged: (v) =>
                              setState(() => _hermaphrodit = v),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sektion 6: Trichom-Tracking
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Trichom-Tracking',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                            ),
                            FilledButton.icon(
                              onPressed: _trichomEintragHinzufuegen,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Eintrag'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_trichomNotizen.isEmpty)
                          Text('Noch keine Trichom-Einträge',
                              style: TextStyle(color: Colors.grey[500]))
                        else
                          ...(_trichomNotizen.entries.toList()
                                ..sort((a, b) =>
                                    a.key.compareTo(b.key)))
                              .map((e) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.remove_red_eye,
                                        color: theme.colorScheme.primary),
                                    title: Text(e.key.toUpperCase()),
                                    subtitle:
                                        Text(e.value.toString()),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _trichomNotizen.remove(e.key);
                                        });
                                      },
                                    ),
                                  )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sektion 7: Wachstumsmessungen
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Wachstumsmessungen',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                            ),
                            FilledButton.icon(
                              onPressed: _messungHinzufuegen,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Messung'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        messungenAsync.when(
                          data: (messungen) {
                            if (messungen.isEmpty) {
                              return Text(
                                  'Noch keine Wachstumsmessungen',
                                  style: TextStyle(
                                      color: Colors.grey[500]));
                            }
                            return Column(
                              children: messungen.map((m) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(Icons.straighten,
                                      color:
                                          theme.colorScheme.primary),
                                  title: Text(m.datumFormatiert),
                                  subtitle: Text([
                                    if (m.hoeheCm != null)
                                      '${m.hoeheCm} cm',
                                    if (m.nodienAnzahl != null)
                                      '${m.nodienAnzahl} Nodien',
                                    if (m.stammdicke != null)
                                      '${m.stammdicke} mm',
                                    if (m.getoppt) 'Getoppt',
                                  ].join(' · ')),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 18),
                                    onPressed: () =>
                                        _messungLoeschenDialog(m),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (error, _) =>
                              Text('Fehler: $error'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sektion 8: Allgemein
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Allgemein',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _bemerkungController,
                          decoration: const InputDecoration(
                            labelText: 'Bemerkung',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          textCapitalization:
                              TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

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
                    label: const Text('Bewertung speichern'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _wirkungsTypLabel(String typ) {
    switch (typ) {
      case 'aufputschend':
        return 'Aufputschend';
      case 'ausgewogen':
        return 'Ausgewogen';
      case 'entspannend':
        return 'Entspannend';
      case 'narkotisch':
        return 'Narkotisch';
      default:
        return typ;
    }
  }

  String _aromaKategorieLabel(String k) {
    switch (k) {
      case 'zitrus':
        return 'Zitrus';
      case 'frucht':
        return 'Frucht';
      case 'suess':
        return 'Süß';
      case 'erdig':
        return 'Erdig';
      case 'wuerzig':
        return 'Würzig';
      case 'blumig':
        return 'Blumig';
      case 'kiefer':
        return 'Kiefer';
      case 'gas':
        return 'Gas';
      case 'skunky':
        return 'Skunky';
      case 'kaese':
        return 'Käse';
      case 'holzig':
        return 'Holzig';
      case 'kaffee':
        return 'Kaffee';
      case 'kraeuter':
        return 'Kräuter';
      case 'hash':
        return 'Hash';
      default:
        return k;
    }
  }
}
