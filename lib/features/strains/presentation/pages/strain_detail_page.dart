import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/sorte.dart';
import '../providers/sorten_provider.dart';
import 'strain_form_page.dart';

class StrainDetailPage extends ConsumerWidget {
  final String strainId;

  const StrainDetailPage({super.key, required this.strainId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorteAsync = ref.watch(sorteProvider(strainId));

    return sorteAsync.when(
      data: (sorte) {
        if (sorte == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sorte')),
            body: const Center(child: Text('Sorte nicht gefunden.')),
          );
        }
        return _DetailContent(sorte: sorte);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Sorte')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Sorte')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final Sorte sorte;

  const _DetailContent({required this.sorte});

  Color _statusFarbe(String status) {
    switch (status) {
      case 'aktiv':
        return Colors.green;
      case 'selektion':
        return Colors.orange;
      case 'beendet':
        return Colors.grey;
      case 'stash':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _loeschen(BuildContext context, WidgetRef ref) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sorte löschen'),
        content: Text('Möchtest du "${sorte.name}" wirklich löschen?'),
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
        await ref.read(sortenListeProvider.notifier).loeschen(sorte.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sorte gelöscht')),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(sorte.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StrainFormPage(sorte: sorte),
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
                // Header Card
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
                                sorte.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    _statusFarbe(sorte.status).withAlpha(30),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _statusFarbe(sorte.status)
                                      .withAlpha(100),
                                ),
                              ),
                              child: Text(
                                sorte.statusLabel,
                                style: TextStyle(
                                  color: _statusFarbe(sorte.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (sorte.zuechter != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Züchter: ${sorte.zuechter}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Genetik & THC/CBD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Genetik',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _DetailZeile('Indica / Sativa', sorte.genetik),
                        if (sorte.thcGehalt != null)
                          _DetailZeile('THC', '${sorte.thcGehalt}%'),
                        if (sorte.cbdGehalt != null)
                          _DetailZeile('CBD', '${sorte.cbdGehalt}%'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Blütezeit
                if (sorte.bluetezeitZuechter != null ||
                    sorte.bluetezeitEigen != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Blütezeit',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (sorte.bluetezeitZuechter != null)
                            _DetailZeile('Züchter',
                                '${sorte.bluetezeitZuechter} Tage'),
                          if (sorte.bluetezeitEigen != null)
                            _DetailZeile(
                                'Eigen', '${sorte.bluetezeitEigen} Tage'),
                          if (sorte.bluetezeitSicherheit != null)
                            _DetailZeile('Sicherheit',
                                '${sorte.bluetezeitSicherheit} Tage'),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Bestand
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bestand',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _DetailZeile(
                            'Samen vorrätig', '${sorte.samenAnzahl}'),
                        if (sorte.keimquote != null)
                          _DetailZeile('Keimquote', '${sorte.keimquote}%'),
                        _DetailZeile('Mutterpflanze',
                            sorte.hatMutterpflanze ? 'Ja' : 'Nein'),
                        _DetailZeile('Topping empfohlen',
                            sorte.toppingEmpfohlen ? 'Ja' : 'Nein'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Eigenschaften
                if (sorte.geschmack != null || sorte.wirkung != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Eigenschaften',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (sorte.geschmack != null)
                            _DetailZeile('Geschmack', sorte.geschmack!),
                          if (sorte.wirkung != null)
                            _DetailZeile('Wirkung', sorte.wirkung!),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Ertrag
                if (sorte.ertragSelektion != null ||
                    sorte.ertragProduktion != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ertrag',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (sorte.ertragSelektion != null)
                            _DetailZeile(
                                'Selektion', sorte.ertragSelektion!),
                          if (sorte.ertragProduktion != null)
                            _DetailZeile(
                                'Produktion', sorte.ertragProduktion!),
                        ],
                      ),
                    ),
                  ),

                // Bemerkung
                if (sorte.bemerkung != null) ...[
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
                          Text(sorte.bemerkung!),
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
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(wert)),
        ],
      ),
    );
  }
}
