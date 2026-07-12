// lib/screens/landing/widgets/delivery_route_widget.dart

import 'package:flutter/material.dart';

class DeliveryRouteWidget extends StatelessWidget {
  const DeliveryRouteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 440,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(color: const Color(0xFFEFEAE0)),
            CustomPaint(size: Size.infinite, painter: _FakeMapGridPainter()),
            CustomPaint(size: Size.infinite, painter: _RoutePainter()),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live tracking',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🛵 On the way',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D7551),
                          ),
                        ),
                        Text(
                          '62%',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.62,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF0D7551),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FakeMapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final storePoint = Offset(size.width * 0.18, size.height * 0.72);
    final customerPoint = Offset(size.width * 0.82, size.height * 0.22);
    final midPoint1 = Offset(size.width * 0.35, size.height * 0.55);
    final midPoint2 = Offset(size.width * 0.6, size.height * 0.35);

    final path = Path()
      ..moveTo(storePoint.dx, storePoint.dy)
      ..quadraticBezierTo(
        midPoint1.dx,
        midPoint1.dy,
        midPoint2.dx,
        midPoint2.dy,
      )
      ..quadraticBezierTo(
        midPoint2.dx,
        midPoint2.dy,
        customerPoint.dx,
        customerPoint.dy,
      );

    final dashPaint = Paint()
      ..color = const Color(0xFF0D7551).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dashLength = 10.0;
      const gapLength = 8.0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, next.toDouble()),
          dashPaint,
        );
        distance += dashLength + gapLength;
      }
    }

    _drawPin(canvas, storePoint, const Color(0xFF0D7551), '🏪');
    _drawPin(canvas, customerPoint, const Color(0xFFF97316), '📍');

    final metricsList = path.computeMetrics().toList();
    if (metricsList.isNotEmpty) {
      final metric = metricsList.first;
      final tangent = metric.getTangentForOffset(metric.length * 0.62);
      if (tangent != null) {
        _drawBike(canvas, tangent.position);
      }
    }
  }

  void _drawPin(Canvas canvas, Offset point, Color color, String emoji) {
    canvas.drawCircle(point, 15, Paint()..color = color);
    canvas.drawCircle(
      point,
      15,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      point - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawBike(Canvas canvas, Offset point) {
    canvas.drawCircle(point, 18, Paint()..color = Colors.white);
    canvas.drawCircle(
      point,
      18,
      Paint()
        ..color = const Color(0xFF0D7551)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final textPainter = TextPainter(
      text: const TextSpan(text: '🛵', style: TextStyle(fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      point - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
