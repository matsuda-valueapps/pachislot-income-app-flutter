import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/calculator_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../common/action_button_icon.dart';

class CalculatorToggle extends StatelessWidget {
  const CalculatorToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, provider, child) {
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
              onTap: provider.toggle,
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    //==========================================
                    // 電卓アイコン＋電卓
                    //==========================================

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ActionButtonIcon.calculator(
                          size: 38,
                        ),

                        const SizedBox(
                          width: AppSpacing.sm,
                        ),

                        const Text(
                          '電卓',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),

                    //==========================================
                    // 開閉アイコン
                    //==========================================

                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedRotation(
                        turns: provider.isVisible ? 0.5 : 0,
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_up,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}