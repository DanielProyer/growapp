import 'package:flutter/material.dart';

import '../../domain/entities/curing_messwert.dart';

/// Mini-Chart für den RLF-Verlauf eines Curing-Glases
class RlfVerlaufChart extends StatelessWidget {
  final List<CuringMesswert> messwerte;
  final int? zielRlf;

  const RlfVerlaufChart({
    super.key,
    required this.messwerte,
    this.zielRlf,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Nur Messwerte mit RLF-Daten
    final rlfWerte = messwerte
        .where((m) => m.rlfProzent != null)
        .toList();

    if (rlfWerte.length < 2) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RLF-Verlauf',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                _Legende(farbe: Colors.green, label: '58-65%'),
                const SizedBox(width: 12),
                _Legende(farbe: Colors.orange, label: '50-58 / 65-70%'),
                const SizedBox(width: 12),
                _Legende(farbe: Colors.red, label: '<50 / >70%'),
                if (zielRlf != null) ...[
                  const SizedBox(width: 12),
                  _Legende(farbe: Colors.blue, label: 'Ziel $zielRlf%'),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: Size.infinite,
                painter: _RlfChartPainter(
                  werte: rlfWerte,
                  zielRlf: zielRlf,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  final Color farbe;
  final String label;

  const _Legende({required this.farbe, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: farbe,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class _RlfChartPainter extends CustomPainter {
  final List<CuringMesswert> werte;
  final int? zielRlf;

  _RlfChartPainter({required this.werte, this.zielRlf});

  @override
  void paint(Canvas canvas, Size size) {
    if (werte.isEmpty) return;

    final rlfValues = werte.map((w) => w.rlfProzent!.toDouble()).toList();

    // Y-Achsen-Range
    double minY = rlfValues.reduce((a, b) => a < b ? a : b) - 5;
    double maxY = rlfValues.reduce((a, b) => a > b ? a : b) + 5;
    minY = minY.clamp(30, 90);
    maxY = maxY.clamp(minY + 10, 100);

    final rangeY = maxY - minY;
    const paddingLeft = 32.0;
    const paddingBottom = 20.0;
    final chartWidth = size.width - paddingLeft;
    final chartHeight = size.height - paddingBottom;

    // Hintergrund-Zonen
    final gruenOben = chartHeight - ((65 - minY) / rangeY * chartHeight);
    final gruenUnten = chartHeight - ((58 - minY) / rangeY * chartHeight);

    // Grüner Bereich (58-65%)
    canvas.drawRect(
      Rect.fromLTRB(
        paddingLeft,
        gruenOben.clamp(0, chartHeight),
        size.width,
        gruenUnten.clamp(0, chartHeight),
      ),
      Paint()..color = Colors.green.withAlpha(20),
    );

    // Ziel-RLF Linie
    if (zielRlf != null) {
      final zielY = chartHeight - ((zielRlf! - minY) / rangeY * chartHeight);
      if (zielY >= 0 && zielY <= chartHeight) {
        final dashPaint = Paint()
          ..color = Colors.blue.withAlpha(150)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

        const dashWidth = 5.0;
        const dashGap = 3.0;
        var startX = paddingLeft;
        while (startX < size.width) {
          canvas.drawLine(
            Offset(startX, zielY),
            Offset((startX + dashWidth).clamp(paddingLeft, size.width), zielY),
            dashPaint,
          );
          startX += dashWidth + dashGap;
        }
      }
    }

    // Y-Achsen-Beschriftungen
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var v = minY.ceil(); v <= maxY.floor(); v += 5) {
      final y = chartHeight - ((v - minY) / rangeY * chartHeight);
      textPainter
        ..text = TextSpan(
          text: '$v',
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        )
        ..layout()
        ..paint(canvas, Offset(0, y - textPainter.height / 2));

      // Gitternetzlinie
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.grey.withAlpha(30)
          ..strokeWidth = 0.5,
      );
    }

    // Datenpunkte und Linien
    final points = <Offset>[];
    for (var i = 0; i < rlfValues.length; i++) {
      final x = paddingLeft +
          (rlfValues.length > 1
              ? i / (rlfValues.length - 1) * chartWidth
              : chartWidth / 2);
      final y = chartHeight - ((rlfValues[i] - minY) / rangeY * chartHeight);
      points.add(Offset(x, y));
    }

    // Linie zeichnen
    if (points.length >= 2) {
      final linePaint = Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Punkte zeichnen
    for (var i = 0; i < points.length; i++) {
      final rlf = rlfValues[i].round();
      Color farbe;
      if (rlf >= 58 && rlf <= 65) {
        farbe = Colors.green;
      } else if (rlf < 50 || rlf > 70) {
        farbe = Colors.red;
      } else {
        farbe = Colors.orange;
      }

      canvas.drawCircle(
        points[i],
        4,
        Paint()..color = farbe,
      );
      canvas.drawCircle(
        points[i],
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RlfChartPainter oldDelegate) {
    return oldDelegate.werte != werte || oldDelegate.zielRlf != zielRlf;
  }
}
