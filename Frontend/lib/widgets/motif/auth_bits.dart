// lib/widgets/motif/auth_bits.dart
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? highlight;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: 20),
        Text(
          tr.t(title), 
          style: AppTypography.display(26, weight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: AppTypography.body(14.5, color: AppColors.ink500),
            children: [
              TextSpan(text: tr.t(subtitle)), 
              if (highlight != null)
                TextSpan(
                  text: tr.t(highlight!), 
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr.t(message), 
              style: AppTypography.body(13.5, color: AppColors.error, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onPressed;

  const AuthFooterLink({
    super.key,
    required this.question,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          tr.t(question), 
          style: AppTypography.body(14, color: AppColors.ink500),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            tr.t(actionText), 
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class RoleOption {
  final String value;
  final IconData icon;
  final String label;
  
  const RoleOption({
    required this.value,
    required this.icon,
    required this.label,
  });
}

class RoleSelector extends StatelessWidget {
  final List<RoleOption> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const RoleSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Row(
      children: options.map((role) {
        final isSelected = role.value == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: role == options.last ? 0 : 10),
            child: GestureDetector(
              onTap: () => onChanged(role.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.4,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      role.icon,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.ink500,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr.t(role.label), 
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.ink500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class LabeledDivider extends StatelessWidget {
  final String label;
  
  const LabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            tr.t(label),
            style: AppTypography.body(12, color: AppColors.ink300),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}