// lib/widgets/animations/fade_animation.dart
import 'package:flutter/material.dart';

class FadeAnimation extends StatelessWidget {
  final Widget child;
  final double delay;
  final Duration duration;
  final Curve curve;

  const FadeAnimation({
    super.key,
    required this.child,
    this.delay = 0.0,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
    );
  }
}

class FadeSlideAnimation extends StatelessWidget {
  final Widget child;
  final double delay;
  final Offset offset;
  final Duration duration;
  final Curve curve;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.delay = 0.0,
    this.offset = const Offset(0, 20),
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        return Transform.translate(
          offset: offset * (1 - value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}