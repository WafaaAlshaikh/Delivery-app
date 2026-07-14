// lib/screens/user/driver/communication/widgets/template_messages.dart

import 'package:flutter/material.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../../../../core/theme/typography.dart';
import '../../../../../../data/models/communication_model.dart';

class TemplateMessages extends StatelessWidget {
  final List<SmartSuggestion> templates;
  final ValueChanged<SmartSuggestion> onTemplateSelected;

  const TemplateMessages({
    super.key,
    required this.templates,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '📋 قوالب الرسائل',
                style: AppTypography.display(14, weight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'عرض الكل',
                  style: AppTypography.body(12, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: templates.take(8).map((template) {
              return _TemplateChip(
                template: template,
                onTap: () => onTemplateSelected(template),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final SmartSuggestion template;
  final VoidCallback onTap;

  const _TemplateChip({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              template.emoji,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              template.text,
              style: AppTypography.body(11, color: AppColors.ink700),
            ),
          ],
        ),
      ),
    );
  }
}