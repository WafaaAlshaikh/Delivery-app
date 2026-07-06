// lib/core/utils/responsive.dart
import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();
  static const double tablet = 700;
  static const double desktop = 1080;
}

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static DeviceType typeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.desktop) return DeviceType.desktop;
    if (width >= Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isDesktop(BuildContext context) => typeOf(context) == DeviceType.desktop;
  static bool isTablet(BuildContext context) => typeOf(context) == DeviceType.tablet;
  static bool isMobile(BuildContext context) => typeOf(context) == DeviceType.mobile;

  static double contentMaxWidth(BuildContext context) {
    final type = typeOf(context);
    switch (type) {
      case DeviceType.desktop:
        return 460;
      case DeviceType.tablet:
        return 520;
      case DeviceType.mobile:
        return double.infinity;
    }
  }
}


class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
