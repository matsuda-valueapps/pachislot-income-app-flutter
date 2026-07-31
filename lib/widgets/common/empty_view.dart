import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// データが存在しない場合の共通表示
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
    this.description,
    this.action,
    this.padding = AppSpacing.page,
  });

  /// アイコン
  final IconData icon;

  /// メッセージ
  final String message;

  /// 補足説明
  final String? description;

  /// ボタンなど（任意）
  final Widget? action;

  /// 外側余白
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: Colors.grey.shade400,
            ),

            AppSpacing.gapLg,

            Text(
              message,
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),

            if (description case String desc) ...[
              AppSpacing.gapSm,
              Text(
                desc,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (action case Widget widget) ...[
              AppSpacing.gapLg,
              widget,
            ],
          ],
        ),
      ),
    );
  }
}