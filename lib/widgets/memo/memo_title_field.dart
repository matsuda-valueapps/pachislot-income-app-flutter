import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../input/input_field_decoration.dart';
import '../input/input_label.dart';

class MemoTitleField extends StatelessWidget {
  const MemoTitleField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InputLabel(
          text: 'メモタイトル',
        ),
        TextFormField(
          controller: controller,
          style: AppTextStyles.body,
          decoration: InputFieldDecoration.build(
            hintText: '例：2026/07/31 マルハン新宿',
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