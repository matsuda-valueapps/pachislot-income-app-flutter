import 'package:flutter/material.dart';

import 'game_value_card.dart';

class GameCounter extends StatelessWidget {
  const GameCounter({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return GameValueCard(
      title: '現在ゲーム数',
      controller: controller,
    );
  }
}