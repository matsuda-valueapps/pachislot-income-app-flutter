import 'package:flutter/material.dart';

import '../models/counter_item.dart';

/// 小役カウンター状態管理
class CounterProvider extends ChangeNotifier {
  CounterProvider();

  /// 開始ゲーム数
  int _startGame = 0;

  /// 現在ゲーム数
  int _currentGame = 0;

  /// 小役一覧
  List<CounterItem> _items = const [
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

  //==========================
  // Getter
  //==========================

  int get startGame => _startGame;

  int get currentGame => _currentGame;

  List<CounterItem> get items =>
      List.unmodifiable(_items);

  //==========================
  // ゲーム数
  //==========================

  void setStartGame(int value) {
    _startGame = value;
    notifyListeners();
  }

  void setCurrentGame(int value) {
    _currentGame = value;
    notifyListeners();
  }

  //==========================
  // 小役カウント
  //==========================

  void increment(String id) {
    final index =
        _items.indexWhere((e) => e.id == id);

    if (index == -1) return;

    _items[index] = _items[index].copyWith(
      count: _items[index].count + 1,
    );

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

    notifyListeners();
  }

  //==========================
  // リセット
  //==========================

  void reset() {
    _startGame = 0;
    _currentGame = 0;

    _items = _items
        .map(
          (e) => e.copyWith(count: 0),
        )
        .toList();

    notifyListeners();
  }

  //==========================
  // 確率
  //==========================

  String probability(String id) {
    final item = _items.firstWhere(
      (e) => e.id == id,
    );

    if (item.count == 0 ||
        _currentGame == 0) {
      return '1 / -----';
    }

    final value =
        _currentGame / item.count;

    return '1 / ${value.toStringAsFixed(1)}';
  }
}