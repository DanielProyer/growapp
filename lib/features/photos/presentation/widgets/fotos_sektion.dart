import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/foto.dart';
import '../pages/foto_detail_page.dart';
import '../providers/fotos_provider.dart';
import 'foto_karte.dart';

/// Fotos-Sektion auf der Grow-Detailseite
class FotosSektion extends ConsumerWidget {
  final String durchgangId;

  const FotosSektion({super.key, required this.durchgangId});

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
    if (bild == null) return;
    if (!context.mounted) return;

    // Beschreibung abfragen
    final beschreibung = await _beschreibungDialog(context);
    if (!context.mounted) return;

    try {
      final bytes = await bild.readAsBytes();
      final dateiName = '${const Uuid().v4()}.jpg';
      final ds = ref.read(fotosDatasourceProvider);
      await ds.hochladen(
        bytes: bytes,
        dateiName: dateiName,
        durchgangId: durchgangId,
        beschreibung: beschreibung,
        aufgenommenAm: DateTime.now(),
      );
      ref.invalidate(fotosProvider(durchgangId));
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
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Beschreibung'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Optional: Beschreibung eingeben',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Überspringen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
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
        ref.invalidate(fotosProvider(durchgangId));
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
    final fotosAsync = ref.watch(fotosProvider(durchgangId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fotosAsync.whenOrNull(
                    data: (f) => 'Fotos (${f.length})',
                  ) ??
                  'Fotos',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
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
              child: IgnorePointer(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text('Foto'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        fotosAsync.when(
          data: (fotos) {
            if (fotos.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Noch keine Fotos',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dokumentiere den Grow mit Fotos.',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: fotos.length,
              itemBuilder: (context, index) => FotoKarte(
                foto: fotos[index],
                onTap: () => _vollbildAnzeigen(context, fotos, index),
                onDelete: () => _fotoLoeschen(context, ref, fotos[index]),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Fehler: $e'),
        ),
      ],
    );
  }
}
