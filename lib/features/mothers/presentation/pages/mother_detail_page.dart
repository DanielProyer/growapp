import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/mutterpflanze.dart';
import '../../domain/entities/steckling.dart';
import '../providers/muetter_provider.dart';
import 'mother_form_page.dart';
import 'cutting_form_page.dart';

class MotherDetailPage extends ConsumerStatefulWidget {
  final String mutterId;

  const MotherDetailPage({super.key, required this.mutterId});

  @override
  ConsumerState<MotherDetailPage> createState() => _MotherDetailPageState();
}

class _MotherDetailPageState extends ConsumerState<MotherDetailPage> {
  Future<void> _bearbeiten(Mutterpflanze mutter) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MotherFormPage(mutter: mutter),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(muetterListeProvider);
    }
  }

  Future<void> _stecklingeSchneiden(Mutterpflanze mutter) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CuttingFormPage(mutterId: mutter.id),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(stecklingeProvider(mutter.id));
      ref.invalidate(muetterListeProvider);
    }
  }

  Future<void> _entsorgen(Mutterpflanze mutter) async {
    final grundController = TextEditingController();
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mutterpflanze entsorgen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Möchtest du "${mutter.anzeigeName}" wirklich entsorgen?'),
            const SizedBox(height: 16),
            TextField(
              controller: grundController,
              decoration: const InputDecoration(
                labelText: 'Grund der Entsorgung',
                hintText: 'z.B. Schimmel, Alter, Platz...',
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Entsorgen'),
          ),
        ],
      ),
    );

    if (bestaetigt == true && mounted) {
      try {
        final grund = grundController.text.trim();
        await ref
            .read(muetterListeProvider.notifier)
            .entsorgen(mutter.id, grund.isEmpty ? 'Kein Grund angegeben' : grund);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mutterpflanze entsorgt')),
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
    grundController.dispose();
  }

  Future<void> _loeschen(Mutterpflanze mutter) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mutterpflanze löschen'),
        content: Text(
            'Möchtest du "${mutter.anzeigeName}" unwiderruflich löschen? Alle Stecklings-Daten werden ebenfalls gelöscht.'),
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
        await ref.read(muetterListeProvider.notifier).loeschen(mutter.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mutterpflanze gelöscht')),
          );
          context.pop();
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

  Future<void> _stecklingBearbeiten(
      Mutterpflanze mutter, Steckling steckling) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CuttingFormPage(
          mutterId: mutter.id,
          steckling: steckling,
        ),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(stecklingeProvider(mutter.id));
      ref.invalidate(muetterListeProvider);
    }
  }

  Future<void> _stecklingLoeschen(
      Mutterpflanze mutter, Steckling steckling) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stecklingsschnitt löschen'),
        content: Text(
            'Schnitt vom ${steckling.datumFormatiert} wirklich löschen?'),
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
        await stecklingLoeschen(ref, steckling: steckling);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stecklingsschnitt gelöscht')),
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

  @override
  Widget build(BuildContext context) {
    final mutterAsync = ref.watch(mutterProvider(widget.mutterId));

    return mutterAsync.when(
      data: (mutter) {
        if (mutter == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mutterpflanze')),
            body: const Center(child: Text('Mutterpflanze nicht gefunden.')),
          );
        }
        return _DetailContent(
          mutter: mutter,
          onBearbeiten: () => _bearbeiten(mutter),
          onStecklingeSchneiden: () => _stecklingeSchneiden(mutter),
          onEntsorgen: () => _entsorgen(mutter),
          onLoeschen: () => _loeschen(mutter),
          onStecklingBearbeiten: (s) => _stecklingBearbeiten(mutter, s),
          onStecklingLoeschen: (s) => _stecklingLoeschen(mutter, s),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Mutterpflanze')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Mutterpflanze')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final Mutterpflanze mutter;
  final VoidCallback onBearbeiten;
  final VoidCallback onStecklingeSchneiden;
  final VoidCallback onEntsorgen;
  final VoidCallback onLoeschen;
  final void Function(Steckling) onStecklingBearbeiten;
  final void Function(Steckling) onStecklingLoeschen;

  const _DetailContent({
    required this.mutter,
    required this.onBearbeiten,
    required this.onStecklingeSchneiden,
    required this.onEntsorgen,
    required this.onLoeschen,
    required this.onStecklingBearbeiten,
    required this.onStecklingLoeschen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stecklingeAsync = ref.watch(stecklingeProvider(mutter.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(mutter.anzeigeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Bearbeiten',
            onPressed: onBearbeiten,
          ),
          if (mutter.istAktiv)
            IconButton(
              icon: const Icon(Icons.content_cut),
              tooltip: 'Stecklinge schneiden',
              onPressed: onStecklingeSchneiden,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'entsorgen') onEntsorgen();
              if (value == 'loeschen') onLoeschen();
            },
            itemBuilder: (_) => [
              if (mutter.istAktiv)
                const PopupMenuItem(
                  value: 'entsorgen',
                  child: ListTile(
                    leading: Icon(Icons.delete_sweep, color: Colors.orange),
                    title: Text('Entsorgen'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'loeschen',
                child: ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Löschen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
                // Kopfbereich
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
                                mutter.anzeigeName,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: mutter.istAktiv
                                    ? Colors.green.withAlpha(30)
                                    : Colors.grey.withAlpha(30),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                mutter.statusLabel,
                                style: TextStyle(
                                  color: mutter.istAktiv
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (mutter.stecklingDatumFormatiert != null)
                          _DetailZeile(
                              'Steckling-Datum', mutter.stecklingDatumFormatiert!),
                        if (mutter.topf1lDatumFormatiert != null)
                          _DetailZeile(
                              'Topf 1L', mutter.topf1lDatumFormatiert!),
                        if (mutter.topf35lDatumFormatiert != null)
                          _DetailZeile(
                              'Topf 3.5L', mutter.topf35lDatumFormatiert!),
                        if (mutter.entsorgtDatumFormatiert != null)
                          _DetailZeile(
                              'Entsorgt am', mutter.entsorgtDatumFormatiert!),
                        if (mutter.entsorgtGrund != null)
                          _DetailZeile('Entsorgungsgrund', mutter.entsorgtGrund!),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Statistik
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Statistik',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatistikKarte(
                                label: 'Schnitte',
                                wert: '${mutter.anzahlSchnitte ?? 0}',
                                icon: Icons.content_cut,
                                farbe: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatistikKarte(
                                label: 'Stecklinge',
                                wert: '${mutter.gesamtStecklinge ?? 0}',
                                icon: Icons.nature,
                                farbe: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatistikKarte(
                                label: 'Erfolgsrate',
                                wert: mutter.durchschnittErfolgsrate != null
                                    ? '${mutter.durchschnittErfolgsrate!.round()}%'
                                    : '-',
                                icon: Icons.trending_up,
                                farbe: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bemerkung
                if (mutter.bemerkung != null) ...[
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
                          Text(mutter.bemerkung!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Stecklings-Historie
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Stecklings-Historie',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                            ),
                            if (mutter.istAktiv)
                              FilledButton.icon(
                                onPressed: onStecklingeSchneiden,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Schnitt'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        stecklingeAsync.when(
                          data: (stecklinge) {
                            if (stecklinge.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'Noch keine Stecklingsschnitte',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: stecklinge.map((s) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.content_cut,
                                    color: theme.colorScheme.primary,
                                  ),
                                  title: Text(
                                    s.datumFormatiert,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        [
                                          if (s.anzahlUnten != null)
                                            'Unten: ${s.anzahlUnten}',
                                          if (s.anzahlOben != null)
                                            'Oben: ${s.anzahlOben}',
                                          'Gesamt: ${s.gesamtAnzahl}',
                                        ].join(' · '),
                                      ),
                                      if (s.erfolgsrate != null)
                                        Text(
                                            'Erfolgsrate: ${s.erfolgsrateFormatiert}'),
                                      if (s.bemerkung != null)
                                        Text(s.bemerkung!,
                                            style: TextStyle(
                                                color: Colors.grey[600])),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'bearbeiten') {
                                        onStecklingBearbeiten(s);
                                      }
                                      if (value == 'loeschen') {
                                        onStecklingLoeschen(s);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'bearbeiten',
                                        child: Text('Bearbeiten'),
                                      ),
                                      PopupMenuItem(
                                        value: 'loeschen',
                                        child: Text('Löschen'),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, _) => Text('Fehler: $error'),
                        ),
                      ],
                    ),
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

class _StatistikKarte extends StatelessWidget {
  final String label;
  final String wert;
  final IconData icon;
  final Color farbe;

  const _StatistikKarte({
    required this.label,
    required this.wert,
    required this.icon,
    required this.farbe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: farbe.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: farbe, size: 24),
          const SizedBox(height: 8),
          Text(
            wert,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: farbe,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
