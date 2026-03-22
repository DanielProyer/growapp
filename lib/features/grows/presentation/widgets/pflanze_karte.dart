import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../photos/presentation/widgets/fotos_sektion.dart';
import '../../domain/entities/pflanze.dart';

class PflanzeKarte extends StatelessWidget {
  final Pflanze pflanze;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PflanzeKarte({
    super.key,
    required this.pflanze,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusFarbe(String status) {
    switch (status) {
      case 'keimung':
        return Colors.orange;
      case 'vegetation':
        return Colors.lightGreen;
      case 'bluete':
        return Colors.purple;
      case 'ernte':
        return Colors.amber;
      case 'beendet':
        return Colors.blueGrey;
      case 'entsorgt':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd.MM.yyyy');
    final farbe = _statusFarbe(pflanze.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nr + Status + Actions
            Row(
              children: [
                Icon(Icons.local_florist_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pflanze.bezeichnung,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: farbe.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: farbe.withAlpha(100)),
                  ),
                  child: Text(
                    pflanze.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: farbe,
                      fontWeight: FontWeight.w600,
                    ),
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

            // Info-Chips
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                if (pflanze.sorteName != null)
                  _InfoItem(Icons.local_florist, pflanze.sorteName!),
                if (pflanze.aussaatDatum != null)
                  _InfoItem(Icons.calendar_today_outlined,
                      'Aussaat: ${df.format(pflanze.aussaatDatum!)}'),
                if (pflanze.blueteStart != null)
                  _InfoItem(Icons.calendar_today_outlined,
                      'Blüte: ${df.format(pflanze.blueteStart!)}'),
                if (pflanze.hoeheBlueteStart != null)
                  _InfoItem(Icons.straighten,
                      '${pflanze.hoeheBlueteStart!.toStringAsFixed(0)} cm (Blüte)'),
                if (pflanze.hoeheErnte != null)
                  _InfoItem(Icons.straighten,
                      '${pflanze.hoeheErnte!.toStringAsFixed(0)} cm (Ernte)'),
                if (pflanze.trockenGewichtG != null)
                  _InfoItem(Icons.scale,
                      '${pflanze.trockenGewichtG!.toStringAsFixed(1)} g trocken'),
              ],
            ),

            // Bemerkung
            if (pflanze.bemerkung != null) ...[
              const SizedBox(height: 6),
              Text(
                pflanze.bemerkung!,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Fotos (Wachstumsverlauf)
            FotosSektion(pflanzeId: pflanze.id),
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
