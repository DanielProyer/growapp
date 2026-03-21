import 'package:flutter/material.dart';

import '../../domain/entities/sorte.dart';

/// Karte für eine Sorte in der Listenansicht
class SortenKarte extends StatelessWidget {
  final Sorte sorte;
  final VoidCallback? onTap;

  const SortenKarte({
    super.key,
    required this.sorte,
    this.onTap,
  });

  Color _statusFarbe(String status) {
    switch (status) {
      case 'aktiv':
        return Colors.green;
      case 'selektion':
        return Colors.orange;
      case 'beendet':
        return Colors.grey;
      case 'stash':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kopfzeile: Name + Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sorte.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusFarbe(sorte.status).withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _statusFarbe(sorte.status).withAlpha(100),
                      ),
                    ),
                    child: Text(
                      sorte.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusFarbe(sorte.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Züchter
              if (sorte.zuechter != null && sorte.zuechter!.isNotEmpty)
                Text(
                  sorte.zuechter!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

              // Kreuzung
              if (sorte.kreuzung != null && sorte.kreuzung!.isNotEmpty)
                Text(
                  sorte.kreuzung!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Info-Chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // Genetik
                  if (sorte.indicaAnteil > 0 || sorte.sativaAnteil > 0)
                    _InfoChip(
                      icon: Icons.science_outlined,
                      label: sorte.genetik,
                    ),

                  // THC
                  if (sorte.thcGehalt != null)
                    _InfoChip(
                      icon: Icons.local_fire_department_outlined,
                      label: 'THC ${sorte.thcGehalt}%',
                    ),

                  // Blütezeit
                  if (sorte.bluetezeitZuechter != null)
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      label: '${sorte.bluetezeitZuechter} Tage',
                    ),

                  // Samen
                  if (sorte.samenAnzahl > 0)
                    _InfoChip(
                      icon: Icons.grain,
                      label: '${sorte.samenAnzahl} Samen',
                    ),

                  // Mutterpflanze
                  if (sorte.hatMutterpflanze)
                    const _InfoChip(
                      icon: Icons.park,
                      label: 'Mutter',
                    ),
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

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
