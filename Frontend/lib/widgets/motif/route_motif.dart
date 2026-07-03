// lib/widgets/motif/route_motif.dart
//
// The app's signature element: a dashed delivery route curving from a
// "store" pin to a "home" pin, with a drifting dot that stands in for the
// order in transit. Used on the web branding panel and behind the OTP step.
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class RouteMotif extends StatefulWidget {
  final Color dashColor;
  final Color dotColor;
  final Color pinColor;

  const RouteMotif({
    super.key,
    this.dashColor = Colors.white24,
    this.dotColor = Colors.white,
    this.pinColor = Colors.white,
  });

  @override
  State<RouteMotif> createState() => _RouteMotifState();
}

class _RouteMotifState extends State<RouteMotif> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _RoutePainter(
            progress: _controller.value,
            dashColor: widget.dashColor,
            dotColor: widget.dotColor,
            pinColor: widget.pinColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RoutePainter extends CustomPainter {
  final double progress;
  final Color dashColor;
  final Color dotColor;
  final Color pinColor;

  _RoutePainter({
    required this.progress,
    required this.dashColor,
    required this.dotColor,
    required this.pinColor,
  });

  Path _buildPath(Size size) {
    final start = Offset(size.width * 0.12, size.height * 0.18);
    final end = Offset(size.width * 0.82, size.height * 0.86);
    final c1 = Offset(size.width * 0.05, size.height * 0.75);
    final c2 = Offset(size.width * 0.95, size.height * 0.25);

    final path = Path()..moveTo(start.dx, start.dy);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    // Dashed route line.
    final dashPaint = Paint()
      ..color = dashColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashLength = 8.0;
    const gapLength = 8.0;
    double distance = 0;
    while (distance < metric.length) {
      final next = distance + dashLength;
      canvas.drawPath(
        metric.extractPath(distance, next.clamp(0, metric.length)),
        dashPaint,
      );
      distance = next + gapLength;
    }

    // Start pin (store).
    final startTangent = metric.getTangentForOffset(0)!;
    _drawPin(canvas, startTangent.position, pinColor, filled: false);

    // End pin (home).
    final endTangent = metric.getTangentForOffset(metric.length)!;
    _drawPin(canvas, endTangent.position, pinColor, filled: true);

    // Drifting order dot.
    final dotTangent = metric.getTangentForOffset(metric.length * progress)!;
    final dotPaint = Paint()..color = dotColor;
    canvas.drawCircle(dotTangent.position, 6, dotPaint);
    canvas.drawCircle(
      dotTangent.position,
      10,
      Paint()
        ..color = dotColor.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawPin(Canvas canvas, Offset center, Color color, {required bool filled}) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 7, paint);
    if (!filled) {
      canvas.drawCircle(center, 2.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => oldDelegate.progress != progress;
}

/// Full branding panel shown on the left side of auth screens on wide/web
/// viewports. Carries the route motif, wordmark, and a rotating value prop.
class BrandPanel extends StatelessWidget {
  final String eyebrow;
  final String headline;
  final String caption;

  const BrandPanel({
    super.key,
    this.eyebrow = 'FASTA DELIVERY',
    required this.headline,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.duskGradient),
      child: Stack(
        children: [
          const Positioned.fill(
            child: RouteMotif(
              dashColor: Colors.white24,
              dotColor: AppColors.primary,
              pinColor: Colors.white70,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Text(
                        caption,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
