import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/kalender_eintrag.dart';
import '../providers/kalender_provider.dart';

/// Dashboard-Widget: Anstehende Termine
class AnstehendeTermineKarte extends ConsumerWidget {
  const AnstehendeTermineKarte({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termineAsync = ref.watch(anstehendeTermineProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Anstehende Termine',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.go('/kalender'),
                  child: const Text('Alle anzeigen'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            termineAsync.when(
              data: (termine) {
                if (termine.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Keine anstehenden Termine',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }
                return Column(
                  children: termine
                      .map((t) => _TerminZeile(
                            eintrag: t,
                            onErledigt: (erledigt) {
                              ref
                                  .read(kalenderListeProvider.notifier)
                                  .erledigtToggeln(t.id, erledigt);
                            },
                          ))
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('Fehler: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TerminZeile extends StatelessWidget {
  final KalenderEintrag eintrag;
  final ValueChanged<bool> onErledigt;

  const _TerminZeile({
    required this.eintrag,
    required this.onErledigt,
  });

  IconData _typIcon(String typ) {
    switch (typ) {
      case 'bewaesserung':
        return Icons.water_drop;
      case 'duengung':
        return Icons.science;
      case 'ernte':
        return Icons.content_cut;
      case 'stecklinge':
        return Icons.call_split;
      case 'umtopfen':
        return Icons.swap_vert;
      case 'schaedlingskontrolle':
        return Icons.bug_report;
      case 'foto':
        return Icons.camera_alt;
      case 'allgemein':
      default:
        return Icons.event;
    }
  }

  Color _typFarbe(String typ) {
    switch (typ) {
      case 'bewaesserung':
        return Colors.blue;
      case 'duengung':
        return Colors.green;
      case 'ernte':
        return Colors.amber;
      case 'stecklinge':
        return Colors.teal;
      case 'umtopfen':
        return Colors.brown;
      case 'schaedlingskontrolle':
        return Colors.red;
      case 'foto':
        return Colors.purple;
      case 'allgemein':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zeit = eintrag.geplantAm.toLocal();
    final datumStr = DateFormat('dd.MM.').format(zeit);
    final zeitStr =
        '${zeit.hour.toString().padLeft(2, '0')}:${zeit.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _typIcon(eintrag.typ),
            color: _typFarbe(eintrag.typ),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              eintrag.titel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$datumStr $zeitStr',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: Checkbox(
              value: eintrag.erledigt,
              onChanged: (v) => onErledigt(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
