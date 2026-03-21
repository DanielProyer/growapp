import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/tages_log.dart';

class TagesLogKarte extends StatelessWidget {
  final TagesLog log;
  final VoidCallback? onTap;

  const TagesLogKarte({super.key, required this.log, this.onTap});

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
                      df.format(log.datum),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (log.vegiTag != null || log.blueteTag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: log.blueteTag != null
                            ? Colors.purple.withAlpha(30)
                            : Colors.lightGreen.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: log.blueteTag != null
                              ? Colors.purple.withAlpha(100)
                              : Colors.lightGreen.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        log.blueteTag != null
                            ? 'Blüte Tag ${log.blueteTag}'
                            : 'Vegi Tag ${log.vegiTag}',
                        style: TextStyle(
                          fontSize: 12,
                          color: log.blueteTag != null
                              ? Colors.purple
                              : Colors.lightGreen[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (log.tempTag != null)
                    _InfoChip(Icons.thermostat,
                        '${log.tempTag!.toStringAsFixed(1)}°C'),
                  if (log.relfTag != null)
                    _InfoChip(Icons.water_drop_outlined,
                        '${log.relfTag!.toStringAsFixed(0)}%'),
                  if (log.ph != null)
                    _InfoChip(Icons.science_outlined,
                        'pH ${log.ph!.toStringAsFixed(1)}'),
                  if (log.ec != null)
                    _InfoChip(Icons.electric_bolt_outlined,
                        'EC ${log.ec!.toStringAsFixed(2)}'),
                  if (log.pflanzenHoehe != null)
                    _InfoChip(Icons.height,
                        '${log.pflanzenHoehe!.toStringAsFixed(0)} cm'),
                  if (log.wasserMl != null)
                    _InfoChip(Icons.local_drink_outlined,
                        '${log.wasserMl} ml'),
                ],
              ),

              if (log.bemerkung != null && log.bemerkung!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  log.bemerkung!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
