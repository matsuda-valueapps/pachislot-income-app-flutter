import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class InputFieldDecoration {
  const InputFieldDecoration._();

  static InputDecoration build({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,
    String? prefixText,
    bool filled = true,
  }) {
    return InputDecoration(
      hintText: hintText,

      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

      prefixText: prefixText,
      suffixText: suffixText,

      filled: filled,
      fillColor: AppColors.surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
    );
  }
}