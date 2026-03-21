import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/durchgang.dart';

class DurchgangKarte extends StatelessWidget {
  final Durchgang durchgang;
  final VoidCallback? onTap;

  const DurchgangKarte({super.key, required this.durchgang, this.onTap});

  Color _statusFarbe(String status) {
    switch (status) {
      case 'vorbereitung':
        return Colors.grey;
      case 'keimung':
        return Colors.orange;
      case 'steckling':
        return Colors.teal;
      case 'vegetation':
        return Colors.lightGreen;
      case 'bluete':
        return Colors.purple;
      case 'ernte':
        return Colors.amber;
      case 'curing':
        return Colors.brown;
      case 'beendet':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd.MM.yyyy');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      durchgang.titel,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusFarbe(durchgang.status).withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              _statusFarbe(durchgang.status).withAlpha(100)),
                    ),
                    child: Text(
                      durchgang.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusFarbe(durchgang.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              if (durchgang.aktuellerZeltName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      durchgang.istSamen ? Icons.grass : Icons.content_cut,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${durchgang.typLabel} · ${durchgang.aktuellerZeltName}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (durchgang.pflanzenAnzahl != null)
                    _InfoChip(Icons.local_florist,
                        '${durchgang.pflanzenAnzahl} Pflanzen'),
                  if (durchgang.blueteStart != null)
                    _InfoChip(Icons.calendar_today_outlined,
                        'Blüte: ${df.format(durchgang.blueteStart!)}'),
                  if (durchgang.trockenErtragG != null)
                    _InfoChip(Icons.scale,
                        '${durchgang.trockenErtragG!.toStringAsFixed(0)}g'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
