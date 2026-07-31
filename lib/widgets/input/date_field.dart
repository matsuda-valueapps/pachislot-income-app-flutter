import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import 'input_label.dart';

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('yyyy/MM/dd（E）', 'ja_JP').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const InputLabel(
          text: '日付',
        ),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              AppRadius.md,
            ),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
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
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.icon,
                  ),

                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Text(
                      formattedDate,
                      style: AppTextStyles.body,
                    ),
                  ),

                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.iconDisabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}