import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../grows/domain/entities/durchgang.dart';
import '../../../grows/presentation/providers/grows_provider.dart';
import '../../domain/entities/curing_glas.dart';
import '../../domain/entities/curing_messwert.dart';
import '../providers/curing_provider.dart';
import '../widgets/rlf_verlauf_chart.dart';
import 'curing_glas_form_page.dart';
import 'curing_messwert_form.dart';

class CuringGlasDetailPage extends ConsumerStatefulWidget {
  final String glasId;

  const CuringGlasDetailPage({super.key, required this.glasId});

  @override
  ConsumerState<CuringGlasDetailPage> createState() =>
      _CuringGlasDetailPageState();
}

class _CuringGlasDetailPageState extends ConsumerState<CuringGlasDetailPage> {
  Future<void> _bearbeiten(CuringGlas glas) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CuringGlasFormPage(glas: glas),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(curingGlaeserListeProvider);
    }
  }

  Future<void> _messwertHinzufuegen(CuringGlas glas) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CuringMesswertForm(glasId: glas.id),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(curingMesswerteProvider(glas.id));
      ref.invalidate(curingGlaeserListeProvider);
    }
  }

  Future<void> _messwertBearbeiten(CuringMesswert messwert) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CuringMesswertForm(
          glasId: messwert.glasId,
          messwert: messwert,
        ),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(curingMesswerteProvider(messwert.glasId));
      ref.invalidate(curingGlaeserListeProvider);
    }
  }

  Future<void> _statusAendern(CuringGlas glas) async {
    String? neuerStatus;
    if (glas.status == 'trocknung') {
      neuerStatus = 'curing';
    } else if (glas.status == 'curing') {
      neuerStatus = 'fertig';
    }

    if (neuerStatus == null) return;

    final label = neuerStatus == 'curing' ? 'Curing' : 'Fertig';
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Status auf "$label" setzen?'),
        content: Text('Glas #${glas.glasNr} wird auf "$label" gesetzt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(label),
          ),
        ],
      ),
    );

    if (bestaetigt == true && mounted) {
      try {
        final updated = CuringGlas(
          id: glas.id,
          durchgangId: glas.durchgangId,
          sorteId: glas.sorteId,
          glasNr: glas.glasNr,
          trimMethode: glas.trimMethode,
          status: neuerStatus,
          schimmelErkannt: glas.schimmelErkannt,
          ernteDatum: glas.ernteDatum,
          einglasDatum: glas.einglasDatum,
          nassGewichtG: glas.nassGewichtG,
          trockenGewichtG: glas.trockenGewichtG,
          endgewichtG: glas.endgewichtG,
          zielRlf: glas.zielRlf,
          behaelterTyp: glas.behaelterTyp,
          groesseMl: glas.groesseMl,
          bovedaTyp: glas.bovedaTyp,
          qualitaetNotizen: glas.qualitaetNotizen,
          bemerkung: glas.bemerkung,
        );
        await ref
            .read(curingGlaeserListeProvider.notifier)
            .glasAktualisieren(glas.id, updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status auf "$label" gesetzt')),
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

  Future<void> _loeschen(CuringGlas glas) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Glas löschen'),
        content: Text(
            'Glas #${glas.glasNr} unwiderruflich löschen? Alle Messwerte werden ebenfalls gelöscht.'),
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
            .read(curingGlaeserListeProvider.notifier)
            .loeschen(glas.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Glas gelöscht')),
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

  Future<void> _schimmelToggle(CuringGlas glas) async {
    try {
      final updated = CuringGlas(
        id: glas.id,
        durchgangId: glas.durchgangId,
        sorteId: glas.sorteId,
        glasNr: glas.glasNr,
        trimMethode: glas.trimMethode,
        status: glas.status,
        schimmelErkannt: !glas.schimmelErkannt,
        ernteDatum: glas.ernteDatum,
        einglasDatum: glas.einglasDatum,
        nassGewichtG: glas.nassGewichtG,
        trockenGewichtG: glas.trockenGewichtG,
        endgewichtG: glas.endgewichtG,
        zielRlf: glas.zielRlf,
        behaelterTyp: glas.behaelterTyp,
        groesseMl: glas.groesseMl,
        bovedaTyp: glas.bovedaTyp,
        qualitaetNotizen: glas.qualitaetNotizen,
        bemerkung: glas.bemerkung,
      );
      await ref
          .read(curingGlaeserListeProvider.notifier)
          .glasAktualisieren(glas.id, updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  Future<void> _messwertLoeschen(CuringMesswert messwert) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Messwert löschen'),
        content: Text('Messwert vom ${messwert.datumFormatiert} löschen?'),
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
        await curingMesswertLoeschen(ref, messwert: messwert);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Messwert gelöscht')),
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
    final glasAsync = ref.watch(curingGlasProvider(widget.glasId));

    return glasAsync.when(
      data: (glas) {
        if (glas == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Curing')),
            body: const Center(child: Text('Glas nicht gefunden.')),
          );
        }
        return _DetailContent(
          glas: glas,
          onBearbeiten: () => _bearbeiten(glas),
          onMesswertHinzufuegen: () => _messwertHinzufuegen(glas),
          onMesswertBearbeiten: _messwertBearbeiten,
          onStatusAendern: () => _statusAendern(glas),
          onLoeschen: () => _loeschen(glas),
          onSchimmelToggle: () => _schimmelToggle(glas),
          onMesswertLoeschen: _messwertLoeschen,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Curing')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Curing')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final CuringGlas glas;
  final VoidCallback onBearbeiten;
  final VoidCallback onMesswertHinzufuegen;
  final void Function(CuringMesswert) onMesswertBearbeiten;
  final VoidCallback onStatusAendern;
  final VoidCallback onLoeschen;
  final VoidCallback onSchimmelToggle;
  final void Function(CuringMesswert) onMesswertLoeschen;

  const _DetailContent({
    required this.glas,
    required this.onBearbeiten,
    required this.onMesswertHinzufuegen,
    required this.onMesswertBearbeiten,
    required this.onStatusAendern,
    required this.onLoeschen,
    required this.onSchimmelToggle,
    required this.onMesswertLoeschen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final messwerteAsync = ref.watch(curingMesswerteProvider(glas.id));
    final durchgangAsync = ref.watch(durchgangProvider(glas.durchgangId));
    final durchgang = durchgangAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text('Glas #${glas.glasNr}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Bearbeiten',
            onPressed: onBearbeiten,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'status') onStatusAendern();
              if (value == 'loeschen') onLoeschen();
            },
            itemBuilder: (_) => [
              if (glas.status != 'fertig')
                PopupMenuItem(
                  value: 'status',
                  child: ListTile(
                    leading: Icon(
                      glas.status == 'trocknung'
                          ? Icons.local_bar
                          : Icons.check_circle,
                      color: glas.status == 'trocknung'
                          ? Colors.blue
                          : Colors.green,
                    ),
                    title: Text(glas.status == 'trocknung'
                        ? 'Einglasen (→ Curing)'
                        : 'Fertig'),
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
                _kopfCard(theme, durchgang),
                const SizedBox(height: 16),

                // Info-Kacheln
                _infoGrid(theme),
                const SizedBox(height: 16),

                // Gewichtsverlust
                if (glas.trocknungsVerlustProzent != null ||
                    glas.curingVerlustProzent != null)
                  _gewichtsverlustCard(theme),
                if (glas.trocknungsVerlustProzent != null ||
                    glas.curingVerlustProzent != null)
                  const SizedBox(height: 16),

                // Qualitäts-Notizen
                if (glas.qualitaetNotizen.isNotEmpty)
                  _qualitaetCard(theme),
                if (glas.qualitaetNotizen.isNotEmpty)
                  const SizedBox(height: 16),

                // Schimmel-Toggle
                Card(
                  child: SwitchListTile(
                    title: const Text('Schimmel erkannt'),
                    subtitle: glas.schimmelErkannt
                        ? const Text('Achtung! Schimmelbefall festgestellt.',
                            style: TextStyle(color: Colors.red))
                        : null,
                    value: glas.schimmelErkannt,
                    activeTrackColor: Colors.red.withAlpha(120),
                    onChanged: (_) => onSchimmelToggle(),
                    secondary: Icon(
                      Icons.warning_amber_rounded,
                      color: glas.schimmelErkannt ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Details-Card
                _detailsCard(theme),
                const SizedBox(height: 16),

                // RLF-Chart
                messwerteAsync.when(
                  data: (messwerte) {
                    if (messwerte.length >= 2) {
                      return Column(
                        children: [
                          RlfVerlaufChart(
                            messwerte: messwerte.reversed.toList(),
                            zielRlf: glas.zielRlf,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),

                // Messwerte-Timeline
                _messwerteSection(theme, messwerteAsync),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kopfCard(ThemeData theme, Durchgang? durchgang) {
    Color statusFarbe;
    switch (glas.status) {
      case 'trocknung':
        statusFarbe = Colors.orange;
        break;
      case 'curing':
        statusFarbe = Colors.blue;
        break;
      case 'fertig':
        statusFarbe = Colors.green;
        break;
      default:
        statusFarbe = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Glas #${glas.glasNr}',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusFarbe.withAlpha(30),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    glas.statusLabel,
                    style: TextStyle(
                      color: statusFarbe,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (glas.sorteName != null)
              _DetailZeile('Sorte', glas.sorteName!),
            if (durchgang != null)
              _DetailZeile('Durchgang', durchgang.titel),
            _DetailZeile('Behälter', glas.behaelterTypLabel),
            if (glas.groesseMl != null)
              _DetailZeile('Größe', '${glas.groesseMl} ml'),
            if (glas.einglasDatum != null)
              _DetailZeile('Meilenstein', glas.meilenstein),
          ],
        ),
      ),
    );
  }

  Widget _infoGrid(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Messdaten',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoKachel(
                  label: 'Erntedatum',
                  wert: glas.ernteDatumFormatiert ?? '-',
                  icon: Icons.content_cut,
                ),
                _InfoKachel(
                  label: 'Einglasdatum',
                  wert: glas.einglasDatumFormatiert ?? '-',
                  icon: Icons.local_bar,
                ),
                _InfoKachel(
                  label: 'Nassgewicht',
                  wert: glas.nassGewichtG != null
                      ? '${glas.nassGewichtG!.toStringAsFixed(1)}g'
                      : '-',
                  icon: Icons.scale,
                ),
                _InfoKachel(
                  label: 'Trockengewicht',
                  wert: glas.trockenGewichtG != null
                      ? '${glas.trockenGewichtG!.toStringAsFixed(1)}g'
                      : '-',
                  icon: Icons.scale,
                ),
                _InfoKachel(
                  label: 'Endgewicht',
                  wert: glas.endgewichtG != null
                      ? '${glas.endgewichtG!.toStringAsFixed(1)}g'
                      : '-',
                  icon: Icons.scale,
                ),
                _InfoKachel(
                  label: 'Ziel-RLF',
                  wert: glas.zielRlf != null ? '${glas.zielRlf}%' : '-',
                  icon: Icons.water_drop,
                ),
                _InfoKachel(
                  label: 'Letzte RLF',
                  wert: glas.letzteRlf != null ? '${glas.letzteRlf}%' : '-',
                  icon: Icons.water_drop_outlined,
                ),
                _InfoKachel(
                  label: 'Curing-Tage',
                  wert: glas.einglasDatum != null
                      ? '${glas.curingTage}'
                      : '-',
                  icon: Icons.timer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gewichtsverlustCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gewichtsverlust',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (glas.trocknungsVerlustProzent != null) ...[
              _VerlustBalken(
                label: 'Trocknung (nass → trocken)',
                prozent: glas.trocknungsVerlustProzent!,
                maxProzent: 80,
                farbe: Colors.orange,
              ),
              const SizedBox(height: 12),
            ],
            if (glas.curingVerlustProzent != null) ...[
              _VerlustBalken(
                label: 'Curing (trocken → end)',
                prozent: glas.curingVerlustProzent!,
                maxProzent: 10,
                farbe: Colors.blue,
              ),
              const SizedBox(height: 12),
            ],
            if (glas.gesamtVerlustProzent != null)
              _VerlustBalken(
                label: 'Gesamt (nass → end)',
                prozent: glas.gesamtVerlustProzent!,
                maxProzent: 85,
                farbe: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _qualitaetCard(ThemeData theme) {
    final notizen = glas.qualitaetNotizen;
    final aromaKategorien = notizen['aroma_kategorien'];
    final aromaIntensitaet = notizen['aroma_intensitaet'];
    final rauchQualitaet = notizen['rauch_qualitaet'];
    final farbe = notizen['farbe'];
    final trichome = notizen['trichome'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qualität',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (aromaKategorien is List && aromaKategorien.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: aromaKategorien
                    .map<Widget>((k) => Chip(
                          label: Text(k.toString()),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
            if (aromaIntensitaet != null)
              _DetailZeile('Aroma-Intensität', '$aromaIntensitaet/10'),
            if (rauchQualitaet != null)
              _DetailZeile('Rauchqualität', rauchQualitaet.toString()),
            if (farbe != null) _DetailZeile('Farbe', farbe.toString()),
            if (trichome != null)
              _DetailZeile('Trichome', trichome.toString()),
          ],
        ),
      ),
    );
  }

  Widget _detailsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (glas.trimMethodeLabel != null)
              _DetailZeile('Trim-Methode', glas.trimMethodeLabel!),
            if (glas.bovedaTyp != null)
              _DetailZeile('Boveda', glas.bovedaTyp!),
            if (glas.bemerkung != null)
              _DetailZeile('Bemerkung', glas.bemerkung!),
            _DetailZeile('Messwerte', '${glas.messwerteAnzahl}'),
          ],
        ),
      ),
    );
  }

  Widget _messwerteSection(
      ThemeData theme, AsyncValue<List<CuringMesswert>> messwerteAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Messwerte',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                FilledButton.icon(
                  onPressed: onMesswertHinzufuegen,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Hinzufügen'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            messwerteAsync.when(
              data: (messwerte) {
                if (messwerte.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Noch keine Messwerte erfasst',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }
                return Column(
                  children: messwerte
                      .map((m) => _MesswertZeile(
                            messwert: m,
                            zielRlf: glas.zielRlf,
                            onEdit: () => onMesswertBearbeiten(m),
                            onDelete: () => onMesswertLoeschen(m),
                          ))
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('Fehler: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoKachel extends StatelessWidget {
  final String label;
  final String wert;
  final IconData icon;

  const _InfoKachel({
    required this.label,
    required this.wert,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              wert,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerlustBalken extends StatelessWidget {
  final String label;
  final double prozent;
  final double maxProzent;
  final Color farbe;

  const _VerlustBalken({
    required this.label,
    required this.prozent,
    required this.maxProzent,
    required this.farbe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            Text('${prozent.toStringAsFixed(1)}%',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: farbe, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (prozent / maxProzent).clamp(0.0, 1.0),
          backgroundColor: farbe.withAlpha(30),
          valueColor: AlwaysStoppedAnimation<Color>(farbe),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _MesswertZeile extends StatelessWidget {
  final CuringMesswert messwert;
  final int? zielRlf;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MesswertZeile({
    required this.messwert,
    this.zielRlf,
    required this.onEdit,
    required this.onDelete,
  });

  Color _rlfFarbe(int rlf) {
    if (rlf < 50 || rlf > 70) return Colors.red;
    if (rlf >= 58 && rlf <= 65) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                messwert.datumFormatiert,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
            if (messwert.rlfProzent != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _rlfFarbe(messwert.rlfProzent!).withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${messwert.rlfProzent}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _rlfFarbe(messwert.rlfProzent!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (messwert.temperatur != null) ...[
              Text('${messwert.temperatur!.toStringAsFixed(1)}°C',
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
            ],
            if (messwert.gewichtG != null) ...[
              Text('${messwert.gewichtG!.toStringAsFixed(1)}g',
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
            ],
            if (messwert.gelueftet) ...[
              Icon(Icons.air, size: 16, color: Colors.blue[400]),
              if (messwert.lueftungsdauerMin != null)
                Text(' ${messwert.lueftungsdauerMin}min',
                    style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
            ],
            const Spacer(),
            PopupMenuButton<String>(
              iconSize: 18,
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                PopupMenuItem(value: 'delete', child: Text('Löschen')),
              ],
            ),
          ],
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
