import 'package:flutter/material.dart';

import '../models/counter_item.dart';
import '../services/counter_draft_service.dart';

/// 小役カウンター状態管理
class CounterProvider extends ChangeNotifier {
  CounterProvider();

  //==================================================
  // 基本情報
  //==================================================

  /// 日付
  DateTime _selectedDate = DateTime.now();

  /// タイトル
  String _title = '';

  //==================================================
  // ゲーム数
  //==================================================

  int _startGame = 0;
  int _currentGame = 0;

  //==================================================
  // 小役
  //==================================================

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

  /// 選択中の日付
  DateTime get selectedDate =>
      _selectedDate;

  /// タイトル
  String get title => _title;

  /// 開始ゲーム数
  int get startGame =>
      _startGame;

  /// 現在ゲーム数
  int get currentGame =>
      _currentGame;

  /// 遊技ゲーム数（現在 - 開始）
  int get playGame {
    final value =
        _currentGame - _startGame;

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

  /// 起動時に下書きを復元する。
  ///
  /// 日付・タイトル・ゲーム数・
  /// 各小役カウントを復元する。
  Future<void> loadDraft() async {
    final draft =
        await CounterDraftService.loadDraft();

    //================================================
    // 日付
    //================================================

    final dateString =
        draft['date']?.toString() ?? '';

    if (dateString.isNotEmpty) {
      try {
        _selectedDate =
            DateTime.parse(dateString);
      } catch (_) {
        _selectedDate =
            DateTime.now();
      }
    } else {
      _selectedDate =
          DateTime.now();
    }

    //================================================
    // タイトル
    //================================================

    _title =
        draft['title']?.toString() ?? '';

    //================================================
    // ゲーム数
    //================================================

    _startGame =
        draft['startGame'] ?? 0;

    _currentGame =
        draft['currentGame'] ?? 0;

    //================================================
    // 小役
    //================================================

    _items = [
      _items[0].copyWith(
        count:
            draft['cherry'] ?? 0,
      ),
      _items[1].copyWith(
        count:
            draft['bell'] ?? 0,
      ),
      _items[2].copyWith(
        count:
            draft['suika'] ?? 0,
      ),
      _items[3].copyWith(
        count:
            draft['grape'] ?? 0,
      ),
      _items[4].copyWith(
        count:
            draft['chance'] ?? 0,
      ),
    ];

    notifyListeners();
  }

  /// 下書きを自動保存する。
  ///
  /// 日付・タイトル・ゲーム数・
  /// 各小役カウントを保存する。
  Future<void> _saveDraft() async {
    await CounterDraftService.saveDraft(
      date: _selectedDate,
      title: _title,
      startGame: _startGame,
      currentGame: _currentGame,
      cherry:
          _items[0].count,
      bell:
          _items[1].count,
      suika:
          _items[2].count,
      grape:
          _items[3].count,
      chance:
          _items[4].count,
    );
  }

  //==================================================
  // 日付
  //==================================================

  /// 日付を変更する。
  void setSelectedDate(
    DateTime value,
  ) {
    if (_selectedDate.year ==
            value.year &&
        _selectedDate.month ==
            value.month &&
        _selectedDate.day ==
            value.day) {
      return;
    }

    _selectedDate = value;

    _saveDraft();

    notifyListeners();
  }

  //==================================================
  // タイトル
  //==================================================

  /// タイトルを変更する。
  void setTitle(
    String value,
  ) {
    if (_title == value) {
      return;
    }

    _title = value;

    _saveDraft();

    notifyListeners();
  }

  //==================================================
  // ゲーム数
  //==================================================

  /// 開始ゲーム数を変更する。
  void setStartGame(
    int value,
  ) {
    if (_startGame == value) {
      return;
    }

    _startGame = value;

    _saveDraft();

    notifyListeners();
  }

  /// 現在ゲーム数を変更する。
  void setCurrentGame(
    int value,
  ) {
    if (_currentGame == value) {
      return;
    }

    _currentGame = value;

    _saveDraft();

    notifyListeners();
  }

  /// 開始ゲーム数TextField用
  void updateStartGame(
    String value,
  ) {
    final number =
        int.tryParse(value) ?? 0;

    setStartGame(number);
  }

  /// 現在ゲーム数TextField用
  void updateCurrentGame(
    String value,
  ) {
    final number =
        int.tryParse(value) ?? 0;

    setCurrentGame(number);
  }

  //==================================================
  // 小役カウント
  //==================================================

  /// 小役を1回増やす。
  void increment(
    String id,
  ) {
    final index =
        _items.indexWhere(
      (e) => e.id == id,
    );

    if (index == -1) {
      return;
    }

    _items[index] =
        _items[index].copyWith(
      count:
          _items[index].count + 1,
    );

    _saveDraft();

    notifyListeners();
  }

  /// 小役を1回減らす。
  void decrement(
    String id,
  ) {
    final index =
        _items.indexWhere(
      (e) => e.id == id,
    );

    if (index == -1) {
      return;
    }

    if (_items[index].count == 0) {
      return;
    }

    _items[index] =
        _items[index].copyWith(
      count:
          _items[index].count - 1,
    );

    _saveDraft();

    notifyListeners();
  }

  //==================================================
  // リセット
  //==================================================

  /// 小役カウンターを初期状態へ戻す。
  ///
  /// ・日付 → 今日
  /// ・タイトル → 空
  /// ・開始ゲーム数 → 0
  /// ・現在ゲーム数 → 0
  /// ・各小役カウント → 0
  ///
  /// SharedPreferencesの下書きも削除する。
  Future<void> reset() async {
    //================================================
    // 基本情報
    //================================================

    _selectedDate =
        DateTime.now();

    _title = '';

    //================================================
    // ゲーム数
    //================================================

    _startGame = 0;
    _currentGame = 0;

    //================================================
    // 小役
    //================================================

    _items = _items
        .map(
          (item) => item.copyWith(
            count: 0,
          ),
        )
        .toList();

    //================================================
    // 下書き削除
    //================================================

    await CounterDraftService
        .clearDraft();

    notifyListeners();
  }

  //==================================================
  // 確率
  //==================================================

  /// 小役の出現確率を計算する。
  String probability(
    String id,
  ) {
    final item =
        _items.firstWhere(
      (e) => e.id == id,
    );

    //================================================
    // カウントなし / 遊技ゲーム数なし
    //================================================

    if (item.count == 0 ||
        playGame == 0) {
      return '1 / -----';
    }

    //================================================
    // 確率計算
    //================================================

    final probability =
        playGame / item.count;

    //================================================
    // 割り切れる場合は整数表示
    //================================================

    if (probability ==
        probability.roundToDouble()) {
      return '1 / ${probability.toInt()}';
    }

    //================================================
    // 割り切れない場合のみ
    // 小数第1位
    //================================================

    return '1 / ${probability.toStringAsFixed(1)}';
  }
}