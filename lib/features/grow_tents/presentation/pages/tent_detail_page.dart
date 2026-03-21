import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/anbauflaeche.dart';
import '../../domain/entities/zelt.dart';
import '../providers/zelte_provider.dart';
import 'anbauflaeche_form_page.dart';
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
        content: Text('Möchtest du "${zelt.name}" und alle Anbauflächen wirklich löschen?'),
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

  Future<void> _anbauflaecheLoeschen(
      BuildContext context, WidgetRef ref, Anbauflaeche a) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anbaufläche löschen'),
        content: Text('Möchtest du "${a.name}" wirklich löschen?'),
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
        final ds = ref.read(anbauflaechenDatasourceProvider);
        await ds.loeschen(a.id);
        ref.invalidate(anbauflaechenProvider(zelt.id));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anbaufläche gelöscht')),
          );
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
    final flaechenAsync = ref.watch(anbauflaechenProvider(zelt.id));

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

                const SizedBox(height: 24),

                // ── Anbauflächen ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Anbauflächen',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnbauflaecheFormPage(zeltId: zelt.id),
                          ),
                        );
                        ref.invalidate(anbauflaechenProvider(zelt.id));
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Hinzufügen'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                flaechenAsync.when(
                  data: (flaechen) {
                    if (flaechen.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.grid_view_outlined,
                                    size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Noch keine Anbauflächen',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Füge Anbauflächen mit Beleuchtung und Ausstattung hinzu.',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: flaechen
                          .map((a) => _AnbauflaecheKarte(
                                anbauflaeche: a,
                                onEdit: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AnbauflaecheFormPage(
                                        zeltId: zelt.id,
                                        anbauflaeche: a,
                                      ),
                                    ),
                                  );
                                  ref.invalidate(
                                      anbauflaechenProvider(zelt.id));
                                },
                                onDelete: () =>
                                    _anbauflaecheLoeschen(context, ref, a),
                              ))
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Fehler: $e'),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnbauflaecheKarte extends StatelessWidget {
  final Anbauflaeche anbauflaeche;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnbauflaecheKarte({
    required this.anbauflaeche,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final a = anbauflaeche;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grid_view_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    a.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (a.etage != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Etage ${a.etage}',
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                if (a.lichtTyp != null || a.lichtWatt != null)
                  _InfoItem(Icons.light_mode_outlined, a.lichtInfo),
                if (a.lueftung != null)
                  _InfoItem(Icons.air, a.lueftung!),
                if (a.bewaesserung != null)
                  _InfoItem(Icons.water_drop_outlined, a.bewaesserung!),
              ],
            ),
            if (a.bemerkung != null) ...[
              const SizedBox(height: 6),
              Text(a.bemerkung!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
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
