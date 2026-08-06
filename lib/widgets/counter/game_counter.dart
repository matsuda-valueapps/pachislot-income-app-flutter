import 'package:flutter/material.dart';

import 'game_value_card.dart';

class GameCounter extends StatelessWidget {
  const GameCounter({
    super.key,
    required this.controller,
    this.onChanged,
  });

  /// TextEditingController
  final TextEditingController controller;

  /// 値変更時
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GameValueCard(
      title: '現在ゲーム数',
      controller: controller,
      onChanged: onChanged,
    );
  }
}