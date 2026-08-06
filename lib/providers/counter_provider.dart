import 'package:flutter/material.dart';

import '../models/counter_item.dart';
import '../services/counter_draft_service.dart';

/// 小役カウンター状態管理
class CounterProvider extends ChangeNotifier {
  CounterProvider();

  int _startGame = 0;
  int _currentGame = 0;

  List<CounterItem> _items = [
    const CounterItem(
      id: 'cherry',
      name: 'チェリー',
      color: Colors.red,
    ),
    const CounterItem(
      id: 'bell',
      name: 'ベル',
      color: Colors.yellow,
    ),
    const CounterItem(
      id: 'suika',
      name: 'スイカ',
      color: Colors.green,
    ),
    const CounterItem(
      id: 'grape',
      name: 'ブドウ',
      color: Colors.purple,
    ),
    const CounterItem(
      id: 'chance',
      name: 'チャンス目',
      color: Colors.blue,
    ),
  ];

  //==================================================
  // Getter
  //==================================================

  /// 開始ゲーム数
  int get startGame => _startGame;

  /// 現在ゲーム数
  int get currentGame => _currentGame;

  /// 遊技ゲーム数（現在 - 開始）
  int get playGame {
    final value = _currentGame - _startGame;

    if (value < 0) {
      return 0;
    }

    return value;
  }

  /// 小役一覧
  List<CounterItem> get items =>
      List.unmodifiable(_items);

  //==================================================
  // SharedPreferences
  //==================================================

  /// 起動時に復元
  Future<void> loadDraft() async {
    final draft =
        await CounterDraftService.loadDraft();

    _startGame = draft['startGame'] ?? 0;
    _currentGame = draft['currentGame'] ?? 0;

    _items = [
      _items[0].copyWith(
        count: draft['cherry'] ?? 0,
      ),
      _items[1].copyWith(
        count: draft['bell'] ?? 0,
      ),
      _items[2].copyWith(
        count: draft['suika'] ?? 0,
      ),
      _items[3].copyWith(
        count: draft['grape'] ?? 0,
      ),
      _items[4].copyWith(
        count: draft['chance'] ?? 0,
      ),
    ];

    notifyListeners();
  }

  /// 自動保存
  Future<void> _saveDraft() async {
    await CounterDraftService.saveDraft(
      startGame: _startGame,
      currentGame: _currentGame,
      cherry: _items[0].count,
      bell: _items[1].count,
      suika: _items[2].count,
      grape: _items[3].count,
      chance: _items[4].count,
    );
  }

  //==================================================
  // ゲーム数
  //==================================================

  void setStartGame(int value) {
    if (_startGame == value) return;

    _startGame = value;

    _saveDraft();

    notifyListeners();
  }

  void setCurrentGame(int value) {
    if (_currentGame == value) return;

    _currentGame = value;

    _saveDraft();

    notifyListeners();
  }

  /// TextField用
  void updateStartGame(String value) {
    final number = int.tryParse(value) ?? 0;
    setStartGame(number);
  }

  /// TextField用
  void updateCurrentGame(String value) {
    final number = int.tryParse(value) ?? 0;
    setCurrentGame(number);
  }

  //==================================================
  // 小役カウント
  //==================================================

  void increment(String id) {
    final index =
        _items.indexWhere((e) => e.id == id);

    if (index == -1) return;

    _items[index] = _items[index].copyWith(
      count: _items[index].count + 1,
    );

    _saveDraft();

    notifyListeners();
  }

  void decrement(String id) {
    final index =
        _items.indexWhere((e) => e.id == id);

    if (index == -1) return;

    if (_items[index].count == 0) return;

    _items[index] = _items[index].copyWith(
      count: _items[index].count - 1,
    );

    _saveDraft();

    notifyListeners();
  }

  //==================================================
  // リセット
  //==================================================

  Future<void> reset() async {
    _startGame = 0;
    _currentGame = 0;

    _items = _items
        .map(
          (item) => item.copyWith(
            count: 0,
          ),
        )
        .toList();

    await CounterDraftService.clearDraft();

    notifyListeners();
  }

  //==================================================
  // 確率
  //==================================================

  String probability(String id) {
    final item = _items.firstWhere(
      (e) => e.id == id,
    );

    if (item.count == 0 || playGame == 0) {
      return '1 / -----';
    }

    final probability =
        playGame / item.count;

    // 割り切れる場合は整数表示
    if (probability ==
        probability.roundToDouble()) {
      return '1 / ${probability.toInt()}';
    }

    // 割り切れない場合のみ小数第1位
    return '1 / ${probability.toStringAsFixed(1)}';
  }
}