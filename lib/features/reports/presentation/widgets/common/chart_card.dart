import 'package:flutter/material.dart';

/// Wiederverwendbare Card-Hülle für Charts
class ChartCard extends StatelessWidget {
  final String titel;
  final String? untertitel;
  final Widget child;
  final double hoehe;
  final Widget? trailing;

  const ChartCard({
    super.key,
    required this.titel,
    this.untertitel,
    required this.child,
    this.hoehe = 250,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titel,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (untertitel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          untertitel!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: hoehe,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
