// lib/widgets/motif/auth_shell.dart
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/responsive.dart';
import 'route_motif.dart';

/// Wraps every auth screen. On phones it's a plain scrollable canvas.
/// On tablet/web it becomes a two-pane layout: brand story on the left,
/// the actual form in a card on the right — so the app doesn't look like
/// a phone screen stretched across a browser window.
class AuthShell extends StatelessWidget {
  final String brandHeadline;
  final String brandCaption;
  final Widget child;

  const AuthShell({
    super.key,
    required this.brandHeadline,
    required this.brandCaption,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = !Responsive.isMobile(context);

    if (!isWide) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(child: child),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: BrandPanel(headline: brandHeadline, caption: brandCaption),
          ),
          Expanded(
            flex: 6,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
