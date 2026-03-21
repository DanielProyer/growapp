import 'package:flutter/material.dart';

import '../../domain/entities/zelt.dart';

/// Karte für ein Zelt in der Listenansicht
class ZeltKarte extends StatelessWidget {
  final Zelt zelt;
  final int anbauflaechenAnzahl;
  final VoidCallback? onTap;

  const ZeltKarte({
    super.key,
    required this.zelt,
    this.anbauflaechenAnzahl = 0,
    this.onTap,
  });

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
              // Name
              Text(
                zelt.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              if (zelt.standort != null && zelt.standort!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  zelt.standort!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Info-Chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _InfoChip(
                    icon: Icons.straighten,
                    label: zelt.dimensionen,
                  ),
                  if (zelt.grundflaecheM2 != null)
                    _InfoChip(
                      icon: Icons.square_foot,
                      label: '${zelt.grundflaecheM2!.toStringAsFixed(2)} m²',
                    ),
                  if (anbauflaechenAnzahl > 0)
                    _InfoChip(
                      icon: Icons.grid_view_outlined,
                      label: '$anbauflaechenAnzahl ${anbauflaechenAnzahl == 1 ? 'Anbaufläche' : 'Anbauflächen'}',
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
