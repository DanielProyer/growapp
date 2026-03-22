import 'package:flutter/material.dart';

import '../../domain/entities/inventar_item.dart';

/// Karte für einen Inventar-Artikel in der Listenansicht
class InventarItemKarte extends StatelessWidget {
  final InventarItem item;
  final VoidCallback? onTap;

  const InventarItemKarte({
    super.key,
    required this.item,
    this.onTap,
  });

  Color _kategorieFarbe(String kategorie) {
    switch (kategorie) {
      case 'duenger':
        return Colors.green;
      case 'schaedlingsbekaempfung':
        return Colors.red;
      case 'medium':
        return Colors.brown;
      case 'beleuchtung':
        return Colors.amber;
      case 'belueftung':
        return Colors.lightBlue;
      case 'bewaesserung':
        return Colors.blue;
      case 'messinstrumente':
        return Colors.purple;
      case 'zubehoer':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farbe = _kategorieFarbe(item.kategorie);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kopfzeile: Name + Kategorie-Badge
              Row(
                children: [
                  if (item.bestandNiedrig)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Colors.orange[700],
                      ),
                    ),
                  Expanded(
                    child: Text(
                      item.name,
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
                      color: farbe.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: farbe.withAlpha(100)),
                    ),
                    child: Text(
                      item.kategorieLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: farbe,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Lieferant
              if (item.lieferant != null && item.lieferant!.isNotEmpty)
                Text(
                  item.lieferant!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

              const SizedBox(height: 12),

              // Info-Chips: Bestand, Preis
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  // Bestand
                  _InfoChip(
                    icon: Icons.inventory_2_outlined,
                    label: item.einheit != null
                        ? '${_formatMenge(item.aktuellerBestand)} ${item.einheit}'
                        : _formatMenge(item.aktuellerBestand),
                    warnung: item.bestandNiedrig,
                  ),

                  // Preis
                  if (item.preis != null)
                    _InfoChip(
                      icon: Icons.euro_outlined,
                      label: '${item.preis!.toStringAsFixed(2)} €',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMenge(double menge) {
    return menge == menge.roundToDouble()
        ? menge.toInt().toString()
        : menge.toStringAsFixed(2);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool warnung;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.warnung = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = warnung ? Colors.orange[700] : Colors.grey[600];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: warnung ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
