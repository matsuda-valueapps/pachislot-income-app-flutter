import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'input_field_decoration.dart';
import 'input_label.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.validator,
  });

  /// ラベル
  final String label;

  /// TextEditingController
  final TextEditingController controller;

  /// ヒント
  final String? hintText;

  /// キーボードのアクション
  final TextInputAction textInputAction;

  /// 入力変更
  final ValueChanged<String>? onChanged;

  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel(
          text: label,
        ),

        TextFormField(
          controller: controller,
          textInputAction: textInputAction,
          onChanged: onChanged,
          validator: validator,
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