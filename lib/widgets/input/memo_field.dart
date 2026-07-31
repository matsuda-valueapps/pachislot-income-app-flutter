import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'input_field_decoration.dart';
import 'input_label.dart';

class MemoField extends StatelessWidget {
  const MemoField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 5,
  });

  final TextEditingController controller;
  final String? hintText;
  final int maxLines;

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
          maxLines: maxLines,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputFieldDecoration.build(
            hintText: hintText,
          ),
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),
      ],
    );
  }
}