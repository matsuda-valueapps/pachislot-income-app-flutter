import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

/// 小役カウンター共通ボタン
///
/// 用途
/// ・＋
/// ・－
/// ・保存
/// ・リセット
/// ・将来の機種選択
class CounterButton extends StatelessWidget {
  const CounterButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 38,
    this.iconSize = 20,
    this.backgroundColor = Colors.transparent,
    this.borderColor = AppColors.border,
    this.iconColor = AppColors.textPrimary,
  });

  /// アイコン
  final IconData icon;

  /// タップ
  final VoidCallback onPressed;

  /// ボタンサイズ
  final double size;

  /// アイコンサイズ
  final double iconSize;

  /// 背景色
  final Color backgroundColor;

  /// 枠線色
  final Color borderColor;

  /// アイコン色
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: borderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.sm,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}