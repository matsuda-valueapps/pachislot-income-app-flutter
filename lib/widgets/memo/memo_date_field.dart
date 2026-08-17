import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../input/input_label.dart';

/// メモ画面用 日付選択フィールド
class MemoDateField extends StatelessWidget {
  const MemoDateField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  /// 選択中の日付
  final DateTime selectedDate;

  /// 日付タップ時の処理
  final VoidCallback onTap;

  //==================================================
  // 日付表示
  //==================================================

  /// 日付を
  /// YYYY年M月D日(曜日)
  /// 形式で表示する。
  ///
  /// 例：
  /// 2026/08/17（月）
  /// ↓
  /// 2026年8月17日(月)
  String _formatDate(DateTime date) {
    const weekdays = [
      '月',
      '火',
      '水',
      '木',
      '金',
      '土',
      '日',
    ];

    final weekday =
        weekdays[date.weekday - 1];

    return '${date.year}年'
        '${date.month}月'
        '${date.day}日'
        '($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        _formatDate(selectedDate);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const InputLabel(
          text: '日付',
        ),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(
              AppRadius.md,
            ),
            child: Ink(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    AppSpacing.md,
                vertical:
                    AppSpacing.md,
              ),
              decoration:
                  BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
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

                  const SizedBox(
                    width: AppSpacing.md,
                  ),

                  Expanded(
                    child: Text(
                      formattedDate,
                      style:
                          AppTextStyles.body,
                    ),
                  ),

                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color:
                        AppColors.iconDisabled,
                  ),
                ],
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