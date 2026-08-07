import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../../theme/app_spacing.dart';
import 'input_field_decoration.dart';
import 'input_label.dart';

class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  /// ラベル
  final String label;

  /// コントローラー
  final TextEditingController controller;

  /// 入力変更
  final ValueChanged<String>? onChanged;

  /// キーボードアクション
  final TextInputAction textInputAction;

  /// バリデーション
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
          validator: validator,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.end,
          textInputAction: textInputAction,

          inputFormatters: [
            CurrencyInputFormatter(
              thousandSeparator: ThousandSeparator.Comma,
              mantissaLength: 0,
            ),
          ],

          decoration: InputFieldDecoration.build(
            hintText: '0',
            suffixText: '円',
          ),

          onChanged: onChanged,
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),
      ],
    );
  }
}