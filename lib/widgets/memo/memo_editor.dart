import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../input/input_field_decoration.dart';
import '../input/input_label.dart';

class MemoEditor extends StatelessWidget {
  const MemoEditor({
    super.key,
    required this.controller,
    this.minLines = 12,
    this.maxLines,
  });

  final TextEditingController controller;
  final int minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InputLabel(
          text: 'メモ',
        ),

        TextFormField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputFieldDecoration.build(
            hintText: '遊技内容を自由に入力してください',
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),
      ],
    );
  }
}