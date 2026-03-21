import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/zelt.dart';
import '../providers/zelte_provider.dart';
import 'tent_form_page.dart';

class TentDetailPage extends ConsumerWidget {
  final String tentId;

  const TentDetailPage({super.key, required this.tentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zeltAsync = ref.watch(zeltProvider(tentId));

    return zeltAsync.when(
      data: (zelt) {
        if (zelt == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Zelt')),
            body: const Center(child: Text('Zelt nicht gefunden.')),
          );
        }
        return _DetailContent(zelt: zelt);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Zelt')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Zelt')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final Zelt zelt;

  const _DetailContent({required this.zelt});

  Future<void> _loeschen(BuildContext context, WidgetRef ref) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zelt löschen'),
        content: Text('Möchtest du "${zelt.name}" wirklich löschen?'),
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
        await ref.read(zelteListeProvider.notifier).loeschen(zelt.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zelt gelöscht')),
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
        title: Text(zelt.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TentFormPage(zelt: zelt),
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
                        Text(
                          zelt.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (zelt.standort != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Standort: ${zelt.standort}',
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

                // Dimensionen
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dimensionen',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _DetailZeile('Maße', zelt.dimensionen),
                        if (zelt.grundflaecheM2 != null)
                          _DetailZeile('Grundfläche',
                              '${zelt.grundflaecheM2!.toStringAsFixed(2)} m²'),
                        if (zelt.etagen > 1)
                          _DetailZeile('Etagen', '${zelt.etagen}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Beleuchtung
                if (zelt.lichtTyp != null || zelt.lichtWatt != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Beleuchtung',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (zelt.lichtTyp != null)
                            _DetailZeile('Lichttyp', zelt.lichtTyp!),
                          if (zelt.lichtWatt != null)
                            _DetailZeile('Leistung', '${zelt.lichtWatt} Watt'),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Ausstattung
                if (zelt.lueftung != null || zelt.bewaesserung != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ausstattung',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (zelt.lueftung != null)
                            _DetailZeile('Lüftung', zelt.lueftung!),
                          if (zelt.bewaesserung != null)
                            _DetailZeile('Bewässerung', zelt.bewaesserung!),
                        ],
                      ),
                    ),
                  ),

                // Bemerkung
                if (zelt.bemerkung != null) ...[
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
                          Text(zelt.bemerkung!),
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
            width: 140,
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
