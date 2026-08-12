import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../common/app_card.dart';
import '../common/section_title.dart';

/// ホーム画面用 月間収支カード
class MonthlyIncomeCard extends StatelessWidget {
  const MonthlyIncomeCard({
    super.key,
    required this.year,
    required this.month,
    required this.income,
    required this.investment,
    required this.recovery,
  });

  /// 表示する年
  final int year;

  /// 表示する月
  final int month;

  /// 月間収支
  final int income;

  /// 総投資額
  final int investment;

  /// 総回収額
  final int recovery;

  /// 金額フォーマット
  String _format(int value) {
    return NumberFormat('#,###').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isProfit = income >= 0;

    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==========================================
          // タイトル
          // ==========================================

          SectionTitle(
            title: '$year年$month月収支',
          ),

          AppSpacing.gapMd,

          // ==========================================
          // 収支
          // ==========================================

          Center(
            child: Text(
              '${isProfit ? '+' : ''}${_format(income)} 円',
              style:
                  AppTextStyles.amountLarge.copyWith(
                color: isProfit
                    ? AppColors.profit
                    : AppColors.loss,
              ),
            ),
          ),

          AppSpacing.gapLg,

          const Divider(
            color: AppColors.divider,
          ),

          AppSpacing.gapMd,

          // ==========================================
          // 投資・回収
          // ==========================================

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: '投資',
                  value:
                      '${_format(investment)} 円',
                  color: AppColors.loss,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: '回収',
                  value:
                      '${_format(recovery)} 円',
                  color: AppColors.profit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 投資・回収の項目
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.caption,
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}