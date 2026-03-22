import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../photos/domain/entities/foto.dart';
import '../../../photos/presentation/pages/foto_detail_page.dart';
import '../../../photos/presentation/providers/fotos_provider.dart';
import '../../../photos/presentation/widgets/foto_karte.dart';
import '../../domain/entities/schaedlings_vorfall.dart';
import '../../domain/entities/schaedlings_behandlung.dart';
import '../providers/schaedlings_provider.dart';
import 'pest_incident_form_page.dart';
import 'pest_treatment_form_page.dart';

class PestIncidentDetailPage extends ConsumerStatefulWidget {
  final String vorfallId;

  const PestIncidentDetailPage({super.key, required this.vorfallId});

  @override
  ConsumerState<PestIncidentDetailPage> createState() =>
      _PestIncidentDetailPageState();
}

class _PestIncidentDetailPageState
    extends ConsumerState<PestIncidentDetailPage> {
  Future<void> _bearbeiten(SchaedlingsVorfall vorfall) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PestIncidentFormPage(vorfall: vorfall),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(vorfaelleListeProvider);
    }
  }

  Future<void> _loeschen(SchaedlingsVorfall vorfall) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vorfall löschen'),
        content: Text(
            'Möchtest du den Vorfall "${vorfall.schaedlingLabel}" wirklich löschen?'),
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
        await ref.read(vorfaelleListeProvider.notifier).loeschen(vorfall.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vorfall gelöscht')),
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

  void _behandlungHinzufuegen(SchaedlingsVorfall vorfall) async {
    final gespeichert = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PestTreatmentFormPage(
          vorfallId: vorfall.id,
          zeltId: vorfall.zeltId,
        ),
      ),
    );
    if (mounted && gespeichert == true) {
      ref.invalidate(behandlungenProvider(vorfall.id));
    }
  }

  Future<void> _behandlungLoeschenDialog(
      SchaedlingsBehandlung behandlung) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Behandlung löschen'),
        content: const Text(
            'Möchtest du diese Behandlung wirklich löschen?'),
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
        await behandlungLoeschen(ref, behandlung: behandlung);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Behandlung gelöscht')),
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
    final vorfallAsync = ref.watch(vorfallProvider(widget.vorfallId));

    return vorfallAsync.when(
      data: (vorfall) {
        if (vorfall == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Vorfall')),
            body: const Center(child: Text('Vorfall nicht gefunden.')),
          );
        }
        return _DetailContent(
          vorfall: vorfall,
          onBearbeiten: () => _bearbeiten(vorfall),
          onLoeschen: () => _loeschen(vorfall),
          onBehandlungHinzufuegen: () => _behandlungHinzufuegen(vorfall),
          onBehandlungLoeschen: _behandlungLoeschenDialog,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Vorfall')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Vorfall')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final SchaedlingsVorfall vorfall;
  final VoidCallback onBearbeiten;
  final VoidCallback onLoeschen;
  final VoidCallback onBehandlungHinzufuegen;
  final void Function(SchaedlingsBehandlung) onBehandlungLoeschen;

  const _DetailContent({
    required this.vorfall,
    required this.onBearbeiten,
    required this.onLoeschen,
    required this.onBehandlungHinzufuegen,
    required this.onBehandlungLoeschen,
  });

  Color _schweregradFarbe(String schweregrad) {
    switch (schweregrad) {
      case 'niedrig':
        return Colors.green;
      case 'mittel':
        return Colors.orange;
      case 'hoch':
        return Colors.deepOrange;
      case 'kritisch':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final behandlungenAsync =
        ref.watch(behandlungenProvider(vorfall.id));
    final farbe = _schweregradFarbe(vorfall.schweregrad);

    return Scaffold(
      appBar: AppBar(
        title: Text(vorfall.schaedlingLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onBearbeiten,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onLoeschen,
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
                // Stammdaten Card
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
                                vorfall.schaedlingLabel,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: farbe.withAlpha(30),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                vorfall.schweregradLabel,
                                style: TextStyle(
                                  color: farbe,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _DetailZeile('Status', vorfall.statusLabel),
                        if (vorfall.zeltName != null)
                          _DetailZeile('Zelt', vorfall.zeltName!),
                        _DetailZeile(
                            'Erkannt am', vorfall.erkanntDatumFormatiert),
                        if (vorfall.istBehoben)
                          _DetailZeile(
                              'Behoben am', vorfall.behobenDatumFormatiert),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Fotos
                _VorfallFotosSektion(vorfallId: vorfall.id),

                const SizedBox(height: 16),

                // Behandlungen Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Behandlungen',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                            ),
                            FilledButton.icon(
                              onPressed: onBehandlungHinzufuegen,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Hinzufügen'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        behandlungenAsync.when(
                          data: (behandlungen) {
                            if (behandlungen.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'Noch keine Behandlungen',
                                    style:
                                        TextStyle(color: Colors.grey[500]),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: behandlungen.map((b) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    _behandlungIcon(b.behandlungTyp),
                                    color: theme.colorScheme.primary,
                                  ),
                                  title: Text(
                                    b.mittel,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${b.behandlungTypLabel} · ${b.datumFormatiert}'),
                                      if (b.menge != null)
                                        Text('Menge: ${b.menge}'),
                                      if (b.wirksamkeit != null)
                                        Text(
                                            'Wirksamkeit: ${b.wirksamkeitLabel}'),
                                      if (b.bemerkung != null)
                                        Text(b.bemerkung!,
                                            style: TextStyle(
                                                color: Colors.grey[600])),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20),
                                    onPressed: () =>
                                        onBehandlungLoeschen(b),
                                  ),
                                  isThreeLine: true,
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

                // Bemerkung
                if (vorfall.bemerkung != null) ...[
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
                          Text(vorfall.bemerkung!),
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

  IconData _behandlungIcon(String typ) {
    switch (typ) {
      case 'biologisch':
        return Icons.eco;
      case 'chemisch':
        return Icons.science;
      case 'mechanisch':
        return Icons.handyman;
      case 'nuetzlinge':
        return Icons.pets;
      default:
        return Icons.medical_services;
    }
  }
}

class _VorfallFotosSektion extends ConsumerWidget {
  final String vorfallId;

  const _VorfallFotosSektion({required this.vorfallId});

  Future<void> _fotoAufnehmen(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final bild = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (bild == null || !context.mounted) return;

    final beschreibung = await _beschreibungDialog(context);
    if (beschreibung == null || !context.mounted) return;

    try {
      final bytes = await bild.readAsBytes();
      final dateiName = '${const Uuid().v4()}.jpg';
      final ds = ref.read(fotosDatasourceProvider);
      await ds.hochladenFuerVorfall(
        bytes: bytes,
        dateiName: dateiName,
        vorfallId: vorfallId,
        beschreibung: beschreibung.isEmpty ? null : beschreibung,
      );
      ref.invalidate(vorfallFotosProvider(vorfallId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto hochgeladen')),
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

  Future<String?> _beschreibungDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Foto-Beschreibung'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Beschreibung',
            hintText: 'Optional',
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _fotoLoeschen(
    BuildContext context,
    WidgetRef ref,
    Foto foto,
  ) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Foto löschen'),
        content: Text('Möchtest du "${foto.bezeichnung}" wirklich löschen?'),
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

    if (bestaetigt == true && context.mounted) {
      try {
        final ds = ref.read(fotosDatasourceProvider);
        await ds.loeschen(foto.id, foto.speicherPfad);
        ref.invalidate(vorfallFotosProvider(vorfallId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto gelöscht')),
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

  void _vollbildAnzeigen(
    BuildContext context,
    List<Foto> fotos,
    int index,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoDetailPage(fotos: fotos, startIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fotosAsync = ref.watch(vorfallFotosProvider(vorfallId));

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
                    fotosAsync.whenOrNull(
                          data: (f) => 'Fotos (${f.length})',
                        ) ??
                        'Fotos',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                PopupMenuButton<ImageSource>(
                  onSelected: (source) =>
                      _fotoAufnehmen(context, ref, source),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: ImageSource.camera,
                      child: ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('Kamera'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: ImageSource.gallery,
                      child: ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Galerie'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  offset: const Offset(0, 40),
                  child: const Icon(Icons.add_a_photo),
                ),
              ],
            ),
            const SizedBox(height: 12),
            fotosAsync.when(
              data: (fotos) {
                if (fotos.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        'Noch keine Fotos vorhanden',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: fotos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => SizedBox(
                      width: 100,
                      child: FotoKarte(
                        foto: fotos[index],
                        onTap: () =>
                            _vollbildAnzeigen(context, fotos, index),
                        onDelete: () =>
                            _fotoLoeschen(context, ref, fotos[index]),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 100,
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Text('Fehler: $e'),
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
