import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'calculator_controller.dart';
import 'calculator_display.dart';
import 'calculator_keypad.dart';

class CalculatorPanel extends StatelessWidget {
  const CalculatorPanel({
    super.key,
    required this.controller,
  });

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            top: AppSpacing.lg,
          ),
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppRadius.md,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalculatorDisplay(
                value: controller.display,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              CalculatorKeypad(
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }
}