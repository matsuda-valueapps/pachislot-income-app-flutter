import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// アプリ共通ボタン
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 52,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
  });

  /// ボタン文字
  final String text;

  /// 押下時処理
  final VoidCallback? onPressed;

  /// 左側アイコン
  final IconData? icon;

  /// 横幅
  final double width;

  /// 高さ
  final double height;

  /// 背景色
  final Color? backgroundColor;

  /// 文字色
  final Color? foregroundColor;

  /// ローディング表示
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        backgroundColor ?? AppColors.primary;

    final Color fgColor =
        foregroundColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed:
            isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  if (icon
                      case IconData iconData) ...[
                    Icon(iconData),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                  ],
                  Text(
                    text,
                    style:
                        AppTextStyles.button
                            .copyWith(
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}