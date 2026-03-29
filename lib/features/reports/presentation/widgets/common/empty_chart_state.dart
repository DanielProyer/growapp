import 'package:flutter/material.dart';

/// Anzeige wenn keine Daten für einen Chart vorhanden sind
class EmptyChartState extends StatelessWidget {
  final String nachricht;
  final IconData icon;

  const EmptyChartState({
    super.key,
    required this.nachricht,
    this.icon = Icons.bar_chart_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              nachricht,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
