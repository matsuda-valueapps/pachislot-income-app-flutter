import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/counter_provider.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          context.read<CounterProvider>();

      await provider.loadDraft();

      _startGameController.text =
          provider.startGame == 0
              ? ''
              : provider.startGame.toString();

      _currentGameController.text =
          provider.currentGame == 0
              ? ''
              : provider.currentGame.toString();
    });
  }

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

  Future<void> _onReset(
    CounterProvider provider,
  ) async {
    await provider.reset();

    _startGameController.clear();
    _currentGameController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'リセットしました',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<CounterProvider>();

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
                  onChanged:
                      provider.updateStartGame,
                ),

                GameCounter(
                  controller:
                      _currentGameController,
                  onChanged:
                      provider.updateCurrentGame,
                ),

                ...provider.items.map(
                  (item) => CounterCard(
                    item: item,
                    probability:
                        provider.probability(
                      item.id,
                    ),
                    onIncrement: () {
                      provider.increment(
                        item.id,
                      );
                    },
                    onDecrement: () {
                      provider.decrement(
                        item.id,
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _onReset(
                          provider,
                        ),
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