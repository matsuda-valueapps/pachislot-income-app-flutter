import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../common/app_card.dart';
import 'input_label.dart';

class ProfitCard extends StatelessWidget {
  const ProfitCard({
    super.key,
    required this.profit,
  });

  final int profit;

  @override
  Widget build(BuildContext context) {
    Color textColor;

    if (profit > 0) {
      textColor = AppColors.profit;
    } else if (profit < 0) {
      textColor = AppColors.loss;
    } else {
      textColor = AppColors.textPrimary;
    }

    final formatter = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InputLabel(
          text: '収支',
        ),

        AppCard(
          child: Center(
            child: Text(
              '${formatter.format(profit)} 円',
              style: AppTextStyles.cardTitle.copyWith(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),
      ],
    );
  }
}