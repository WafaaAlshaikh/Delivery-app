// lib/widgets/custom/custom_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

enum CustomButtonVariant { filled, outlined, ghost }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = CustomButtonVariant.filled,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width = double.infinity,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: switch (variant) {
        CustomButtonVariant.outlined => _buildOutlined(),
        CustomButtonVariant.ghost => _buildGhost(),
        CustomButtonVariant.filled => _buildFilled(),
      },
    );
  }

  Widget _buildFilled() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      child: _buildChild(fallbackColor: Colors.white),
    );
  }

  Widget _buildOutlined() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: BorderSide(color: backgroundColor ?? AppColors.border, width: 1.4),
      ),
      child: _buildChild(fallbackColor: AppColors.ink900),
    );
  }

  Widget _buildGhost() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: AppColors.primarySoft,
      ),
      child: _buildChild(fallbackColor: AppColors.primaryDark),
    );
  }

  Widget _buildChild({required Color fallbackColor}) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: textColor ?? fallbackColor,
        ),
      );
    }

    final resolvedColor = textColor ?? fallbackColor;

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: resolvedColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: resolvedColor, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(color: resolvedColor, fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}