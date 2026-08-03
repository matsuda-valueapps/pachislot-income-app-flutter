import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class CalculatorToggle extends StatelessWidget {
  const CalculatorToggle({
    super.key,
    required this.isOpen,
    required this.onPressed,
  });

  /// BottomSheetが開いているか
  final bool isOpen;

  /// タップ時
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppRadius.md,
          ),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_outlined,
                ),

                const SizedBox(
                  width: AppSpacing.sm,
                ),

                const Expanded(
                  child: Text(
                    '電卓',
                    style: AppTextStyles.body,
                  ),
                ),

                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}