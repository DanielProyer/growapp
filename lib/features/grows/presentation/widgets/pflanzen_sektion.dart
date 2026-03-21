import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pflanze.dart';
import '../pages/pflanze_form_page.dart';
import '../providers/grows_provider.dart';
import 'pflanze_karte.dart';

/// Pflanzen-Sektion auf der Grow-Detailseite
class PflanzenSektion extends ConsumerWidget {
  final String durchgangId;

  const PflanzenSektion({super.key, required this.durchgangId});

  Future<void> _pflanzeLoeschen(
      BuildContext context, WidgetRef ref, Pflanze p) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pflanze löschen'),
        content: Text('Möchtest du "${p.bezeichnung}" wirklich löschen?'),
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
        final ds = ref.read(pflanzenDatasourceProvider);
        await ds.loeschen(p.id);
        ref.invalidate(pflanzenProvider(durchgangId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pflanze gelöscht')),
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

  int _naechsteNummer(List<Pflanze> pflanzen) {
    if (pflanzen.isEmpty) return 1;
    return pflanzen.map((p) => p.pflanzenNr).reduce(max) + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pflanzenAsync = ref.watch(pflanzenProvider(durchgangId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pflanzenAsync.whenOrNull(
                    data: (p) => 'Pflanzen (${p.length})',
                  ) ??
                  'Pflanzen',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final pflanzen = pflanzenAsync.valueOrNull ?? [];
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PflanzeFormPage(
                      durchgangId: durchgangId,
                      naechsteNummer: _naechsteNummer(pflanzen),
                    ),
                  ),
                );
                ref.invalidate(pflanzenProvider(durchgangId));
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Hinzufügen'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        pflanzenAsync.when(
          data: (pflanzen) {
            if (pflanzen.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.local_florist_outlined,
                            size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Noch keine Pflanzen',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Füge einzelne Pflanzen hinzu, um sie individuell zu tracken.',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: pflanzen
                  .map((p) => PflanzeKarte(
                        pflanze: p,
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PflanzeFormPage(
                                durchgangId: durchgangId,
                                pflanze: p,
                              ),
                            ),
                          );
                          ref.invalidate(pflanzenProvider(durchgangId));
                        },
                        onDelete: () =>
                            _pflanzeLoeschen(context, ref, p),
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Fehler: $e'),
        ),
      ],
    );
  }
}
