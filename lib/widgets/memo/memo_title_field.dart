import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../input/input_field_decoration.dart';
import '../input/input_label.dart';

class MemoTitleField extends StatelessWidget {
  const MemoTitleField({
    super.key,
    required this.controller,
    this.onTap,
    this.readOnly = false,
  });

  /// タイトル
  final TextEditingController controller;

  /// タップ時処理
  final VoidCallback? onTap;

  /// 読み取り専用
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InputLabel(
          text: 'タイトル',
        ),

        TextFormField(
          controller: controller,
          style: AppTextStyles.body,

          readOnly: readOnly,

          onTap: onTap,

          decoration: InputFieldDecoration.build(
            hintText: '例：マルハン○○店',
          ),

          textInputAction: TextInputAction.next,

          maxLength: 50,
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),
      ],
    );
  }
}