import 'package:flutter/material.dart';

class MemoPage extends StatelessWidget {
  const MemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'メモ画面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}