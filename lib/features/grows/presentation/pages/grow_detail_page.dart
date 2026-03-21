import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/durchgang.dart';
import '../providers/grows_provider.dart';
import 'grow_form_page.dart';

class GrowDetailPage extends ConsumerWidget {
  final String growId;

  const GrowDetailPage({super.key, required this.growId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dAsync = ref.watch(durchgangProvider(growId));

    return dAsync.when(
      data: (d) {
        if (d == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Durchgang')),
            body: const Center(child: Text('Durchgang nicht gefunden.')),
          );
        }
        return _DetailContent(durchgang: d);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Durchgang')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Durchgang')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final Durchgang durchgang;

  const _DetailContent({required this.durchgang});

  Color _statusFarbe(String status) {
    switch (status) {
      case 'vorbereitung': return Colors.grey;
      case 'keimung': return Colors.orange;
      case 'steckling': return Colors.teal;
      case 'vegetation': return Colors.lightGreen;
      case 'bluete': return Colors.purple;
      case 'ernte': return Colors.amber;
      case 'curing': return Colors.brown;
      case 'beendet': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  Future<void> _loeschen(BuildContext context, WidgetRef ref) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durchgang löschen'),
        content: const Text('Möchtest du diesen Durchgang wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (bestaetigt == true && context.mounted) {
      try {
        await ref.read(durchgaengeListeProvider.notifier).loeschen(durchgang.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Durchgang gelöscht')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }

  String _flaecheLabel(String? flaecheName, String? zeltName) {
    if (flaecheName == null) return '–';
    if (zeltName != null) return '$zeltName → $flaecheName';
    return flaecheName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final df = DateFormat('dd.MM.yyyy');
    final d = durchgang;

    final hatAnbauflaechen = d.stecklingAnbauflaecheId != null ||
        d.vegiAnbauflaecheId != null ||
        d.blueteAnbauflaecheId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(d.titel),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GrowFormPage(durchgang: d),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _loeschen(context, ref),
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
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                d.sorteName ?? 'Unbekannte Sorte',
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (d.istSamen ? Colors.orange : Colors.teal).withAlpha(30),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: (d.istSamen ? Colors.orange : Colors.teal).withAlpha(100)),
                                  ),
                                  child: Text(
                                    d.typLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: d.istSamen ? Colors.orange : Colors.teal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusFarbe(d.status).withAlpha(30),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: _statusFarbe(d.status).withAlpha(100)),
                                  ),
                                  child: Text(
                                    d.statusLabel,
                                    style: TextStyle(
                                      color: _statusFarbe(d.status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (d.pflanzenAnzahl != null) ...[
                          const SizedBox(height: 4),
                          Text('${d.pflanzenAnzahl} Pflanzen',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600])),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Anbauflächen pro Phase
                if (hatAnbauflaechen)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anbauflächen',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (d.stecklingAnbauflaecheId != null)
                            _DetailZeile(d.erstePhaseLabel,
                                _flaecheLabel(d.stecklingAnbauflaecheName, d.stecklingZeltName)),
                          if (d.vegiAnbauflaecheId != null)
                            _DetailZeile('Vegetation',
                                _flaecheLabel(d.vegiAnbauflaecheName, d.vegiZeltName)),
                          if (d.blueteAnbauflaecheId != null)
                            _DetailZeile('Blüte',
                                _flaecheLabel(d.blueteAnbauflaecheName, d.blueteZeltName)),
                        ],
                      ),
                    ),
                  ),

                if (hatAnbauflaechen) const SizedBox(height: 16),

                // Termine
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Termine',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        if (d.stecklingDatum != null)
                          _DetailZeile(d.erstePhaseLabel, df.format(d.stecklingDatum!)),
                        if (d.vegiStart != null)
                          _DetailZeile('Vegi-Start', df.format(d.vegiStart!)),
                        if (d.blueteStart != null)
                          _DetailZeile('Blüte-Start', df.format(d.blueteStart!)),
                        if (d.ernteDatum != null)
                          _DetailZeile('Ernte', df.format(d.ernteDatum!)),
                        if (d.einglasDatum != null)
                          _DetailZeile('Einglas-Datum', df.format(d.einglasDatum!)),
                        if (d.stecklingDatum == null &&
                            d.vegiStart == null &&
                            d.blueteStart == null &&
                            d.ernteDatum == null)
                          Text('Noch keine Termine eingetragen',
                              style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ),

                // Ernte-Ergebnisse
                if (d.trockenErtragG != null || d.trimG != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ernte',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (d.ernteMethode != null)
                            _DetailZeile('Methode', d.ernteMethode!),
                          if (d.trockenErtragG != null)
                            _DetailZeile('Trocken-Ertrag',
                                '${d.trockenErtragG!.toStringAsFixed(1)} g'),
                          if (d.trimG != null)
                            _DetailZeile(
                                'Trim', '${d.trimG!.toStringAsFixed(1)} g'),
                          if (d.ertragProWatt != null)
                            _DetailZeile('Ertrag/Watt',
                                '${d.ertragProWatt!.toStringAsFixed(2)} g/W'),
                          if (d.siebung1 != null)
                            _DetailZeile('Siebung 1',
                                '${d.siebung1!.toStringAsFixed(1)} g'),
                          if (d.siebung2 != null)
                            _DetailZeile('Siebung 2',
                                '${d.siebung2!.toStringAsFixed(1)} g'),
                          if (d.siebung3 != null)
                            _DetailZeile('Siebung 3',
                                '${d.siebung3!.toStringAsFixed(1)} g'),
                        ],
                      ),
                    ),
                  ),
                ],

                // Bemerkung
                if (d.bemerkung != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bemerkung',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Text(d.bemerkung!),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailZeile extends StatelessWidget {
  final String label;
  final String wert;

  const _DetailZeile(this.label, this.wert);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(wert)),
        ],
      ),
    );
  }
}
