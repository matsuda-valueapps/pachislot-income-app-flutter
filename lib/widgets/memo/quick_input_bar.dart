import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class QuickInputBar extends StatelessWidget {
  const QuickInputBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  static const List<String> _items = [
    'BIG',
    'REG',
    'AT',
    'CZ',
    'ヤメ',
    '投資',
    '回収',
  ];

  void _insertText(String text) {
    final value = controller.value;

    final start = value.selection.start;
    final end = value.selection.end;

    // カーソル位置が取得できない場合は末尾へ追加
    if (start < 0 || end < 0) {
      controller.text += '$text ';
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      return;
    }

    final newText = value.text.replaceRange(
      start,
      end,
      '$text ',
    );

    controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + text.length + 1,
      ),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _items.map((item) {
        return ActionChip(
          label: Text(item),
          onPressed: () => _insertText(item),
        );
      }).toList(),
    );
  }
}