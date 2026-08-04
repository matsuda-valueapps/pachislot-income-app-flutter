import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class QuickInputBar extends StatelessWidget {
  const QuickInputBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  /// 上段
  static const List<String> _topItems = [
    'G',
    'BIG',
    'REG',
    'AT',
    'CZ',
  ];

  /// 下段
  static const List<String> _bottomItems = [
    'ヤメ',
    '投資',
    'K',
    '回収',
    '枚',
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
    return Column(
      children: [
        _buildRow(_topItems),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        _buildRow(_bottomItems),
      ],
    );
  }

  Widget _buildRow(List<String> items) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            child: SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: () => _insertText(item),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}