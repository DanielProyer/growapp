import 'package:flutter/material.dart';

import '../../domain/entities/schaedlings_vorfall.dart';

/// Karte für die Vorfall-Liste
class VorfallKarte extends StatelessWidget {
  final SchaedlingsVorfall vorfall;
  final VoidCallback? onTap;

  const VorfallKarte({
    super.key,
    required this.vorfall,
    this.onTap,
  });

  IconData _schaedlingIcon(String typ) {
    switch (typ) {
      case 'thripse':
      case 'blattlaeuse':
      case 'weisse_fliegen':
      case 'minierfliegen':
      case 'raupen':
        return Icons.bug_report;
      case 'spinnmilben':
      case 'breitmilben':
      case 'rostmilben':
        return Icons.pest_control;
      case 'trauermücken':
        return Icons.air;
      case 'echter_mehltau':
      case 'falscher_mehltau':
      case 'botrytis':
      case 'alternaria':
      case 'septoria':
        return Icons.coronavirus;
      case 'wurzelfaeule':
      case 'umfallkrankheit':
        return Icons.grass;
      default:
        return Icons.warning;
    }
  }

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farbe = _schweregradFarbe(vorfall.schweregrad);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: farbe.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _schaedlingIcon(vorfall.schaedlingTyp),
                  color: farbe,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Inhalt
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vorfall.schaedlingLabel,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: farbe.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vorfall.schweregradLabel,
                            style: TextStyle(
                              color: farbe,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (vorfall.zeltName != null) ...[
                          Icon(Icons.house_outlined,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            vorfall.zeltName!,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          vorfall.erkanntDatumFormatiert,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: vorfall.istBehoben
                      ? Colors.green.withAlpha(30)
                      : Colors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vorfall.statusLabel,
                  style: TextStyle(
                    color: vorfall.istBehoben ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
