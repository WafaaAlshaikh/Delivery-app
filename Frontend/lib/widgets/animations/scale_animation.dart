// lib/widgets/animations/scale_animation.dart
import 'package:flutter/material.dart';

class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final double delay;
  final double scale;
  final Duration duration;
  final Curve curve;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.delay = 0.0,
    this.scale = 0.8,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutBack,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: scale, end: 1),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}