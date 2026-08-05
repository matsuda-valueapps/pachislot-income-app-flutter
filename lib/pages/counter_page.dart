import 'package:flutter/material.dart';

import '../models/counter_item.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import '../widgets/counter/counter_card.dart';
import '../widgets/counter/game_counter.dart';
import '../widgets/counter/start_game_counter.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() =>
      _CounterPageState();
}

class _CounterPageState
    extends State<CounterPage> {
  final TextEditingController
      _startGameController =
      TextEditingController();

  final TextEditingController
      _currentGameController =
      TextEditingController();

  final List<CounterItem> _items = const [
    CounterItem(
      id: 'cherry',
      name: 'チェリー',
      color: Colors.red,
    ),
    CounterItem(
      id: 'bell',
      name: 'ベル',
      color: Colors.yellow,
    ),
    CounterItem(
      id: 'suika',
      name: 'スイカ',
      color: Colors.green,
    ),
    CounterItem(
      id: 'grape',
      name: 'ブドウ',
      color: Colors.purple,
    ),
    CounterItem(
      id: 'chance',
      name: 'チャンス目',
      color: Colors.blue,
    ),
  ];

  @override
  void dispose() {
    _startGameController.dispose();
    _currentGameController.dispose();

    super.dispose();
  }

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'SQLite実装時に保存処理を追加します',
        ),
      ),
    );
  }

  void _onReset() {
    _startGameController.clear();
    _currentGameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('リセットしました'),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小役カウンター'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                StartGameCounter(
                  controller:
                      _startGameController,
                ),

                GameCounter(
                  controller:
                      _currentGameController,
                ),

                ..._items.map(
                  (item) => CounterCard(
                    item: item,
                    probability: '1 / -----',
                    onIncrement: () {},
                    onDecrement: () {},
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onReset,
                        child: const Text(
                          'リセット',
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: AppSpacing.md,
                    ),

                    Expanded(
                      child: FilledButton(
                        onPressed: _onSave,
                        child: const Text(
                          '保存',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}