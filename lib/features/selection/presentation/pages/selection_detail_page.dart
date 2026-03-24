import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../grows/presentation/providers/grows_provider.dart';
import '../../domain/entities/selektion.dart';
import '../../domain/entities/selektions_pflanze.dart';
import '../providers/selektions_provider.dart';
import 'selection_form_page.dart';
import 'plant_rating_page.dart';

class SelectionDetailPage extends ConsumerStatefulWidget {
  final String selektionId;

  const SelectionDetailPage({super.key, required this.selektionId});

  @override
  ConsumerState<SelectionDetailPage> createState() =>
      _SelectionDetailPageState();
}

class _SelectionDetailPageState extends ConsumerState<SelectionDetailPage> {
  Future<void> _bearbeiten(Selektion selektion) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectionFormPage(selektion: selektion),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(selektionenListeProvider);
    }
  }

  Future<void> _pflanzenHinzufuegen(Selektion selektion) async {
    if (selektion.durchgangId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Kein Durchgang verknüpft. Bitte zuerst einen Durchgang zuordnen.')),
      );
      return;
    }

    final existierendePflanzen =
        ref.read(selektionsPflanzenProvider(selektion.id));
    final existierendePflanzeIds = existierendePflanzen.valueOrNull
            ?.map((p) => p.pflanzeId)
            .toSet() ??
        {};

    final durchgangPflanzen =
        await ref.read(pflanzenProvider(selektion.durchgangId!).future);

    final verfuegbar = durchgangPflanzen
        .where((p) => !existierendePflanzeIds.contains(p.id))
        .toList();

    if (verfuegbar.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Keine weiteren Pflanzen im Durchgang verfügbar.')),
        );
      }
      return;
    }

    final ausgewaehlt = <String>{};
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Pflanzen hinzufügen'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: verfuegbar.map((p) {
                return CheckboxListTile(
                  title: Text(p.bezeichnung),
                  subtitle: p.sorteName != null ? Text(p.sorteName!) : null,
                  value: ausgewaehlt.contains(p.id),
                  onChanged: (v) {
                    setDialogState(() {
                      if (v == true) {
                        ausgewaehlt.add(p.id);
                      } else {
                        ausgewaehlt.remove(p.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: ausgewaehlt.isEmpty
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: Text('${ausgewaehlt.length} hinzufügen'),
            ),
          ],
        ),
      ),
    );

    if (bestaetigt == true && mounted) {
      try {
        for (final pflanzeId in ausgewaehlt) {
          await selektionsPflanzeHinzufuegen(
            ref,
            selektionId: selektion.id,
            pflanzeId: pflanzeId,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('${ausgewaehlt.length} Pflanze(n) hinzugefügt')),
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

  Future<void> _statusAendern(Selektion selektion) async {
    final neuerStatus =
        selektion.istAktiv ? 'abgeschlossen' : 'aktiv';
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(selektion.istAktiv
            ? 'Selektion abschließen'
            : 'Selektion reaktivieren'),
        content: Text(selektion.istAktiv
            ? 'Möchtest du "${selektion.name}" abschließen?'
            : 'Möchtest du "${selektion.name}" wieder aktivieren?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(selektion.istAktiv ? 'Abschließen' : 'Aktivieren'),
          ),
        ],
      ),
    );

    if (bestaetigt == true && mounted) {
      try {
        await ref
            .read(selektionenListeProvider.notifier)
            .statusAendern(selektion.id, neuerStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(selektion.istAktiv
                    ? 'Selektion abgeschlossen'
                    : 'Selektion aktiviert')),
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

  Future<void> _loeschen(Selektion selektion) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selektion löschen'),
        content: Text(
            'Möchtest du "${selektion.name}" unwiderruflich löschen? Alle Bewertungen werden ebenfalls gelöscht.'),
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
        await ref
            .read(selektionenListeProvider.notifier)
            .loeschen(selektion.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selektion gelöscht')),
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

  Future<void> _pflanzeBewerten(
      Selektion selektion, SelektionsPflanze pflanze) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PlantRatingPage(
          selektionsPflanze: pflanze,
          selektionId: selektion.id,
        ),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(selektionsPflanzenProvider(selektion.id));
      ref.invalidate(selektionenListeProvider);
    }
  }

  Future<void> _pflanzeEntfernen(
      Selektion selektion, SelektionsPflanze pflanze) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pflanze entfernen'),
        content: Text(
            '${pflanze.bezeichnung} aus der Selektion entfernen? Die Bewertungen gehen verloren.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );

    if (bestaetigt == true && mounted) {
      try {
        await selektionsPflanzeEntfernen(
          ref,
          id: pflanze.id,
          selektionId: selektion.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pflanze entfernt')),
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
    final selektionAsync = ref.watch(selektionProvider(widget.selektionId));

    return selektionAsync.when(
      data: (selektion) {
        if (selektion == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Selektion')),
            body: const Center(child: Text('Selektion nicht gefunden.')),
          );
        }
        return _DetailContent(
          selektion: selektion,
          onBearbeiten: () => _bearbeiten(selektion),
          onPflanzenHinzufuegen: () => _pflanzenHinzufuegen(selektion),
          onStatusAendern: () => _statusAendern(selektion),
          onLoeschen: () => _loeschen(selektion),
          onPflanzeBewerten: (p) => _pflanzeBewerten(selektion, p),
          onPflanzeEntfernen: (p) => _pflanzeEntfernen(selektion, p),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Selektion')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Selektion')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final Selektion selektion;
  final VoidCallback onBearbeiten;
  final VoidCallback onPflanzenHinzufuegen;
  final VoidCallback onStatusAendern;
  final VoidCallback onLoeschen;
  final void Function(SelektionsPflanze) onPflanzeBewerten;
  final void Function(SelektionsPflanze) onPflanzeEntfernen;

  const _DetailContent({
    required this.selektion,
    required this.onBearbeiten,
    required this.onPflanzenHinzufuegen,
    required this.onStatusAendern,
    required this.onLoeschen,
    required this.onPflanzeBewerten,
    required this.onPflanzeEntfernen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pflanzenAsync =
        ref.watch(selektionsPflanzenProvider(selektion.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(selektion.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Bearbeiten',
            onPressed: onBearbeiten,
          ),
          if (selektion.durchgangId != null)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Pflanzen hinzufügen',
              onPressed: onPflanzenHinzufuegen,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'status') onStatusAendern();
              if (value == 'loeschen') onLoeschen();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'status',
                child: ListTile(
                  leading: Icon(
                    selektion.istAktiv ? Icons.check_circle : Icons.refresh,
                    color: selektion.istAktiv ? Colors.blue : Colors.green,
                  ),
                  title: Text(selektion.istAktiv
                      ? 'Abschließen'
                      : 'Reaktivieren'),
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
                                selektion.name,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selektion.istAktiv
                                    ? Colors.green.withAlpha(30)
                                    : Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                selektion.statusLabel,
                                style: TextStyle(
                                  color: selektion.istAktiv
                                      ? Colors.green
                                      : Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (selektion.sorteName != null)
                          _DetailZeile('Sorte', selektion.sorteName!),
                        if (selektion.startDatumFormatiert != null)
                          _DetailZeile(
                              'Startdatum', selektion.startDatumFormatiert!),
                        if (selektion.samenAnzahl != null)
                          _DetailZeile(
                              'Samenanzahl', '${selektion.samenAnzahl}'),
                        if (selektion.bemerkung != null)
                          _DetailZeile('Bemerkung', selektion.bemerkung!),
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
                                label: 'Pflanzen',
                                wert: '${selektion.pflanzenAnzahl ?? 0}',
                                icon: Icons.eco,
                                farbe: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatistikKarte(
                                label: 'Keeper',
                                wert: '${selektion.keeperAnzahl ?? 0}',
                                icon: Icons.star,
                                farbe: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatistikKarte(
                                label: 'Ø Bewertung',
                                wert: selektion.durchschnittBewertung != null
                                    ? selektion.durchschnittBewertung!
                                        .toStringAsFixed(1)
                                    : '-',
                                icon: Icons.analytics,
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

                // Pflanzen-Liste
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Pflanzen',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                            ),
                            if (selektion.durchgangId != null)
                              FilledButton.icon(
                                onPressed: onPflanzenHinzufuegen,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Hinzufügen'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        pflanzenAsync.when(
                          data: (pflanzen) {
                            if (pflanzen.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                child: Center(
                                  child: Text(
                                    'Noch keine Pflanzen in dieser Selektion',
                                    style:
                                        TextStyle(color: Colors.grey[500]),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: pflanzen.map((p) {
                                return _PflanzenKarte(
                                  pflanze: p,
                                  onTap: () => onPflanzeBewerten(p),
                                  onEntfernen: () => onPflanzeEntfernen(p),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator()),
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

class _PflanzenKarte extends StatelessWidget {
  final SelektionsPflanze pflanze;
  final VoidCallback onTap;
  final VoidCallback onEntfernen;

  const _PflanzenKarte({
    required this.pflanze,
    required this.onTap,
    required this.onEntfernen,
  });

  Color _keeperFarbe() {
    switch (pflanze.keeperStatus) {
      case 'ja':
        return Colors.green;
      case 'vielleicht':
        return Colors.orange;
      case 'nein':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bewertung = pflanze.berechneteBewertung;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Keeper-Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _keeperFarbe().withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: pflanze.vorselektion
                      ? Icon(Icons.star, color: _keeperFarbe(), size: 22)
                      : Text(
                          pflanze.keeperLabel.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: _keeperFarbe(),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pflanze.bezeichnung,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _keeperFarbe().withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pflanze.keeperLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _keeperFarbe(),
                            ),
                          ),
                        ),
                        if (pflanze.vorselektion) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star,
                              size: 16, color: Colors.amber),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Mini-Balkengrafik
                    _MiniBewertungsBars(
                        bewertungen: pflanze.alleBewertungen),
                  ],
                ),
              ),

              // Gesamtbewertung
              if (bewertung != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    bewertung.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'bewerten') onTap();
                  if (value == 'entfernen') onEntfernen();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'bewerten', child: Text('Bewerten')),
                  PopupMenuItem(
                      value: 'entfernen', child: Text('Entfernen')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBewertungsBars extends StatelessWidget {
  final List<int?> bewertungen;

  const _MiniBewertungsBars({required this.bewertungen});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: bewertungen.map((b) {
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: b != null
                  ? _farbeFuerWert(b)
                  : Colors.grey.withAlpha(40),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _farbeFuerWert(int wert) {
    if (wert >= 8) return Colors.green;
    if (wert >= 6) return Colors.lightGreen;
    if (wert >= 4) return Colors.orange;
    if (wert >= 2) return Colors.deepOrange;
    return Colors.red;
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
