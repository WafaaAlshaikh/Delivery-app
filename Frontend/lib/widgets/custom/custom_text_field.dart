// lib/widgets/custom/custom_text_field.dart
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final bool obscureText;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.focusNode,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      readOnly: readOnly,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.ink900,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: tr.t(label), 
        hintText: tr.t(hint),   
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: const IconThemeData(color: AppColors.ink300, size: 20),
                child: prefixIcon!,
              )
            : null,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}