import 'package:flutter/material.dart';

import 'game_value_card.dart';

class StartGameCounter extends StatelessWidget {
  const StartGameCounter({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return GameValueCard(
      title: '開始ゲーム数',
      controller: controller,
    );
  }
}