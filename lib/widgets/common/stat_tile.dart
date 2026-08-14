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
    this.value,
    this.valueWidget,
    this.icon,
    this.valueColor,
    this.backgroundColor,
    this.onTap,
  }) : assert(
          value != null || valueWidget != null,
          'value または valueWidget のどちらかを指定してください。',
        );

  /// 項目名
  final String label;

  /// 値
  ///
  /// 通常の文字列を表示する場合に使用する。
  final String? value;

  /// 値Widget
  ///
  /// FittedBoxなどを使用して
  /// 独自の表示を行う場合に使用する。
  final Widget? valueWidget;

  /// アイコン（任意）
  final IconData? icon;

  /// 値の色
  ///
  /// valueを使用する場合に適用する。
  /// valueWidgetを使用する場合は
  /// Widget側で色を指定する。
  final Color? valueColor;

  /// 背景色
  final Color? backgroundColor;

  /// タップイベント
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        backgroundColor ?? AppColors.card;

    final Color textColor =
        valueColor ?? Colors.black87;

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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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

                //==================================================
                // 値
                //==================================================
                //
                // valueWidgetが指定されている場合
                // → Widgetをそのまま表示
                //
                // valueWidgetがない場合
                // → 従来通りString valueを表示
                //==================================================

                if (valueWidget != null)
                  valueWidget!
                else
                  Text(
                    value!,
                    maxLines: 1,
                    softWrap: false,
                    style:
                        AppTextStyles.statValue.copyWith(
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