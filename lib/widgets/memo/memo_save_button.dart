import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../common/primary_button.dart';

class MemoSaveButton extends StatelessWidget {
  const MemoSaveButton({
    super.key,
    required this.onPressed,
  });

  /// 保存ボタン押下時
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
      ),
      child: PrimaryButton(
        text: '保存',
        onPressed: onPressed,
      ),
    );
  }
}