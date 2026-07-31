import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// 統計表示用タイル
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.backgroundColor,
    this.onTap,
  });

  /// 項目名
  final String label;

  /// 値
  final String value;

  /// アイコン（任意）
  final IconData? icon;

  /// 値の色
  final Color? valueColor;

  /// 背景色
  final Color? backgroundColor;

  /// タップイベント
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? AppColors.card;
    final Color textColor = valueColor ?? Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon case IconData iconData) ...[
                  Icon(
                    iconData,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  AppSpacing.gapSm,
                ],

                Text(
                  label,
                  style: AppTextStyles.label,
                ),

                AppSpacing.gapXs,

                Text(
                  value,
                  style: AppTextStyles.statValue.copyWith(
                    color: textColor,
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