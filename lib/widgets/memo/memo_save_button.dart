import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

import '../common/primary_button.dart';

class MemoSaveButton extends StatelessWidget {
  const MemoSaveButton({
    super.key,
    required this.onPressed,
    this.label = '保存',
    this.icon,
  });

  /// 保存・更新ボタン押下時
  final VoidCallback onPressed;

  /// ボタンに表示する文字
  ///
  /// 新規メモ：
  /// 「保存」
  ///
  /// 編集メモ：
  /// 「更新」
  final String label;

  /// ボタン左側に表示するWidgetアイコン
  ///
  /// 高級3Dアイコンなど、
  /// IconDataでは表現できないWidgetを表示する場合に使用する。
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
      ),
      child: PrimaryButton(
        text: label,
        onPressed: onPressed,
        iconWidget: icon,
      ),
    );
  }
}