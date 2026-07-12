// lib/widgets/custom/custom_button.dart

import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';

enum CustomButtonVariant { 
  filled,  
  outlined,  
  ghost,     
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonVariant variant;
  
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  
  final IconData? icon;
  final double width;
  final double height;
  final double borderRadius;
  final double? elevation;
  
  final bool isOutlined; 
  final bool expanded;   

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = CustomButtonVariant.filled,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius = 18,
    this.elevation,
    this.isOutlined = false,
    this.expanded = true,
  });

  CustomButton.legacy({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
  })  : variant = isOutlined ? CustomButtonVariant.outlined : CustomButtonVariant.filled,
        borderColor = null,
        icon = null,
        width = double.infinity,
        height = 56,
        borderRadius = 12,
        elevation = 0,
        expanded = true;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return _buildLegacyOutlined(context);
    }

    return SizedBox(
      width: expanded ? width : null,
      height: height,
      child: switch (variant) {
        CustomButtonVariant.outlined => _buildOutlined(context),
        CustomButtonVariant.ghost => _buildGhost(context),
        CustomButtonVariant.filled => _buildFilled(context),
      },
    );
  }

  Widget _buildFilled(BuildContext context) {
    final tr = context.tr;
    final color = backgroundColor ?? AppColors.primary;
    final textCol = textColor ?? Colors.white;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textCol,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: elevation ?? 0,
        disabledBackgroundColor: color.withOpacity(0.5),
      ),
      child: _buildChild(context, fallbackColor: textCol),
    );
  }

  Widget _buildOutlined(BuildContext context) {
    final tr = context.tr;
    final borderCol = borderColor ?? backgroundColor ?? AppColors.border;
    final textCol = textColor ?? borderCol;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        side: BorderSide(color: borderCol, width: 1.4),
        foregroundColor: textCol,
      ),
      child: _buildChild(context, fallbackColor: textCol),
    );
  }

  Widget _buildGhost(BuildContext context) {
    final tr = context.tr;
    final textCol = textColor ?? AppColors.primaryDark;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: AppColors.primarySoft,
        foregroundColor: textCol,
      ),
      child: _buildChild(context, fallbackColor: textCol),
    );
  }

  Widget _buildLegacyOutlined(BuildContext context) {
    final color = backgroundColor ??AppColors.primary;
    final textCol = textColor ?? color;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildLegacyChild(context, color: textCol),
      ),
    );
  }

  Widget _buildLegacyFilled(BuildContext context) {
    final color = backgroundColor ??AppColors.primary;
    final textCol = textColor ?? Colors.white;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: _buildLegacyChild(context, color: textCol),
      ),
    );
  }

  Widget _buildChild(BuildContext context, {required Color fallbackColor}) {
    final tr = context.tr;
    
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: resolvedColor),
          const SizedBox(width: 8),
          Text(
            tr.t(text),
            style: TextStyle(
              color: resolvedColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      tr.t(text),
      style: TextStyle(
        color: resolvedColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLegacyChild(BuildContext context, {required Color color}) {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

extension CustomButtonExtension on CustomButton {
  static CustomButton filled({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: CustomButtonVariant.filled,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  static CustomButton outlined({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: CustomButtonVariant.outlined,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  static CustomButton ghost({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Color? textColor,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: CustomButtonVariant.ghost,
      textColor: textColor,
    );
  }
}