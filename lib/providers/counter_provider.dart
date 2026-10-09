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

  /// 機種タイプ
  String _machineType = 'Aタイプ';

  //==================================================
  // ゲーム数
  //==================================================

  int _startGame = 0;

  int _currentGame = 0;

  //==================================================
  // Aタイプ小役
  //==================================================

  /// Aタイプの小役一覧
  List<CounterItem> _aItems = [
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
  // ATタイプ小役
  //==================================================

  /// ATタイプの小役一覧
  List<CounterItem> _atItems = [
    const CounterItem(
      id: 'strong_cherry',
      name: '強チェリー',
      color: Colors.red,
    ),
    const CounterItem(
      id: 'weak_cherry',
      name: '弱チェリー',
      color: Colors.red,
    ),
    const CounterItem(
      id: 'strong_bell',
      name: '強ベル',
      color: Colors.yellow,
    ),
    const CounterItem(
      id: 'weak_bell',
      name: '弱ベル',
      color: Colors.yellow,
    ),
    const CounterItem(
      id: 'strong_suika',
      name: '強スイカ',
      color: Colors.green,
    ),
    const CounterItem(
      id: 'weak_suika',
      name: '弱スイカ',
      color: Colors.green,
    ),
    const CounterItem(
      id: 'strong_grape',
      name: '強ブドウ',
      color: Colors.purple,
    ),
    const CounterItem(
      id: 'weak_grape',
      name: '弱ブドウ',
      color: Colors.purple,
    ),
    const CounterItem(
      id: 'strong_chance',
      name: '強チャンス目',
      color: Colors.blue,
    ),
    const CounterItem(
      id: 'weak_chance',
      name: '弱チャンス目',
      color: Colors.blue,
    ),
  ];

  //==================================================
  // Getter
  //==================================================

  /// 選択中の日付
  DateTime get selectedDate => _selectedDate;

  /// タイトル
  String get title => _title;

  /// 機種タイプ
  String get machineType => _machineType;

  /// ATタイプかどうか
  bool get isAtType => _machineType == 'ATタイプ';

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

  /// 現在選択されている機種タイプの小役一覧
  List<CounterItem> get items =>
      List.unmodifiable(_activeItems);

  /// 現在選択されている機種タイプの小役一覧
  List<CounterItem> get _activeItems =>
      isAtType ? _atItems : _aItems;

  /// AタイプとATタイプの両方のカウント
  ///
  /// 保存処理などで使用する。
  /// Aタイプの項目は既存のキーを維持し、
  /// ATタイプの項目はCounterRecordの
  /// Dartフィールド名に合わせたキーを使用する。
  Map<String, int> get activeCounts {
    return Map.unmodifiable({
      // Aタイプ
      'cherry': _getCount(_aItems, 'cherry'),
      'bell': _getCount(_aItems, 'bell'),
      'suika': _getCount(_aItems, 'suika'),
      'grape': _getCount(_aItems, 'grape'),
      'chance': _getCount(_aItems, 'chance'),

      // ATタイプ
      'strongCherry':
          _getCount(_atItems, 'strong_cherry'),
      'weakCherry':
          _getCount(_atItems, 'weak_cherry'),
      'strongBell':
          _getCount(_atItems, 'strong_bell'),
      'weakBell':
          _getCount(_atItems, 'weak_bell'),
      'strongSuika':
          _getCount(_atItems, 'strong_suika'),
      'weakSuika':
          _getCount(_atItems, 'weak_suika'),
      'strongGrape':
          _getCount(_atItems, 'strong_grape'),
      'weakGrape':
          _getCount(_atItems, 'weak_grape'),
      'strongChance':
          _getCount(_atItems, 'strong_chance'),
      'weakChance':
          _getCount(_atItems, 'weak_chance'),
    });
  }

  /// 指定された小役のカウントを取得する。
  int _getCount(
    List<CounterItem> source,
    String id,
  ) {
    for (final item in source) {
      if (item.id == id) {
        return item.count;
      }
    }

    return 0;
  }

  //==================================================
  // 機種タイプ
  //==================================================

  /// 機種タイプを変更する。
  ///
  /// AタイプとATタイプのカウントは
  /// それぞれ保持する。
  void setMachineType(String value) {
    if (value != 'Aタイプ' && value != 'ATタイプ') {
      return;
    }

    if (_machineType == value) {
      return;
    }

    _machineType = value;

    _saveDraft();

    notifyListeners();
  }

  //==================================================
  // SharedPreferences
  //==================================================

  /// 起動時に下書きを復元する。
  ///
  /// 日付・タイトル・機種タイプ・ゲーム数・
  /// AタイプおよびATタイプのカウントを復元する。
  Future<void> loadDraft() async {
    final draft = await CounterDraftService.loadDraft();

    //================================================
    // 日付
    //================================================

    final dateString =
        draft['date']?.toString() ?? '';

    if (dateString.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(dateString);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
    } else {
      _selectedDate = DateTime.now();
    }

    //================================================
    // タイトル
    //================================================

    _title = draft['title']?.toString() ?? '';

    //================================================
    // 機種タイプ
    //================================================

    final savedMachineType =
        draft['machineType']?.toString() ?? 'Aタイプ';

    _machineType =
        savedMachineType == 'ATタイプ'
            ? 'ATタイプ'
            : 'Aタイプ';

    //================================================
    // ゲーム数
    //================================================

    _startGame = _readInt(draft['startGame']);

    _currentGame = _readInt(draft['currentGame']);

    //================================================
    // Aタイプ小役
    //================================================

    _aItems = [
      _aItems[0].copyWith(
        count: _readInt(draft['cherry']),
      ),
      _aItems[1].copyWith(
        count: _readInt(draft['bell']),
      ),
      _aItems[2].copyWith(
        count: _readInt(draft['suika']),
      ),
      _aItems[3].copyWith(
        count: _readInt(draft['grape']),
      ),
      _aItems[4].copyWith(
        count: _readInt(draft['chance']),
      ),
    ];

    //================================================
    // ATタイプ小役
    //================================================

    _atItems = [
      _atItems[0].copyWith(
        count: _readInt(draft['strongCherry']),
      ),
      _atItems[1].copyWith(
        count: _readInt(draft['weakCherry']),
      ),
      _atItems[2].copyWith(
        count: _readInt(draft['strongBell']),
      ),
      _atItems[3].copyWith(
        count: _readInt(draft['weakBell']),
      ),
      _atItems[4].copyWith(
        count: _readInt(draft['strongSuika']),
      ),
      _atItems[5].copyWith(
        count: _readInt(draft['weakSuika']),
      ),
      _atItems[6].copyWith(
        count: _readInt(draft['strongGrape']),
      ),
      _atItems[7].copyWith(
        count: _readInt(draft['weakGrape']),
      ),
      _atItems[8].copyWith(
        count: _readInt(draft['strongChance']),
      ),
      _atItems[9].copyWith(
        count: _readInt(draft['weakChance']),
      ),
    ];

    notifyListeners();
  }

  /// 値を安全にintへ変換する。
  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// 下書きを自動保存する。
  ///
  /// 日付・タイトル・機種タイプ・ゲーム数・
  /// 両タイプの小役カウントを保存する。
  Future<void> _saveDraft() async {
    final counts = activeCounts;

    await CounterDraftService.saveDraft(
      date: _selectedDate,
      title: _title,
      machineType: _machineType,
      startGame: _startGame,
      currentGame: _currentGame,

      // Aタイプ
      cherry: counts['cherry'] ?? 0,
      bell: counts['bell'] ?? 0,
      suika: counts['suika'] ?? 0,
      grape: counts['grape'] ?? 0,
      chance: counts['chance'] ?? 0,

      // ATタイプ
      extraCounts: {
        'strongCherry': counts['strongCherry'] ?? 0,
        'weakCherry': counts['weakCherry'] ?? 0,
        'strongBell': counts['strongBell'] ?? 0,
        'weakBell': counts['weakBell'] ?? 0,
        'strongSuika': counts['strongSuika'] ?? 0,
        'weakSuika': counts['weakSuika'] ?? 0,
        'strongGrape': counts['strongGrape'] ?? 0,
        'weakGrape': counts['weakGrape'] ?? 0,
        'strongChance': counts['strongChance'] ?? 0,
        'weakChance': counts['weakChance'] ?? 0,
      },
    );
  }

  //==================================================
  // 日付
  //==================================================

  /// 日付を変更する。
  void setSelectedDate(DateTime value) {
    if (_selectedDate.year == value.year &&
        _selectedDate.month == value.month &&
        _selectedDate.day == value.day) {
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
  void setTitle(String value) {
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
  void setStartGame(int value) {
    if (_startGame == value) {
      return;
    }

    _startGame = value;

    _saveDraft();

    notifyListeners();
  }

  /// 現在ゲーム数を変更する。
  void setCurrentGame(int value) {
    if (_currentGame == value) {
      return;
    }

    _currentGame = value;

    _saveDraft();

    notifyListeners();
  }

  /// 開始ゲーム数TextField用
  void updateStartGame(String value) {
    final number = int.tryParse(value) ?? 0;

    setStartGame(number);
  }

  /// 現在ゲーム数TextField用
  void updateCurrentGame(String value) {
    final number = int.tryParse(value) ?? 0;

    setCurrentGame(number);
  }

  //==================================================
  // 小役カウント
  //==================================================

  /// 小役を1回増やす。
  void increment(String id) {
    final items = _activeItems;

    final index = items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      return;
    }

    final updatedItem = items[index].copyWith(
      count: items[index].count + 1,
    );

    if (isAtType) {
      _atItems[index] = updatedItem;
    } else {
      _aItems[index] = updatedItem;
    }

    _saveDraft();

    notifyListeners();
  }

  /// 小役を1回減らす。
  void decrement(String id) {
    final items = _activeItems;

    final index = items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      return;
    }

    if (items[index].count == 0) {
      return;
    }

    final updatedItem = items[index].copyWith(
      count: items[index].count - 1,
    );

    if (isAtType) {
      _atItems[index] = updatedItem;
    } else {
      _aItems[index] = updatedItem;
    }

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
  /// ・機種タイプ → Aタイプ
  /// ・開始ゲーム数 → 0
  /// ・現在ゲーム数 → 0
  /// ・AタイプおよびATタイプの全カウント → 0
  ///
  /// SharedPreferencesの下書きも削除する。
  Future<void> reset() async {
    //================================================
    // 基本情報
    //================================================

    _selectedDate = DateTime.now();

    _title = '';

    _machineType = 'Aタイプ';

    //================================================
    // ゲーム数
    //================================================

    _startGame = 0;

    _currentGame = 0;

    //================================================
    // Aタイプ小役
    //================================================

    _aItems = _aItems
        .map(
          (item) => item.copyWith(
            count: 0,
          ),
        )
        .toList();

    //================================================
    // ATタイプ小役
    //================================================

    _atItems = _atItems
        .map(
          (item) => item.copyWith(
            count: 0,
          ),
        )
        .toList();

    //================================================
    // 下書き削除
    //================================================

    await CounterDraftService.clearDraft();

    notifyListeners();
  }

  //==================================================
  // 確率
  //==================================================

  /// 小役の出現確率を計算する。
  String probability(String id) {
    final item = _activeItems.firstWhere(
      (item) => item.id == id,
    );

    //================================================
    // カウントなし / 遊技ゲーム数なし
    //================================================

    if (item.count == 0 || playGame == 0) {
      return '1 / -----';
    }

    //================================================
    // 確率計算
    //================================================

    final probability = playGame / item.count;

    //================================================
    // 割り切れる場合は整数表示
    //================================================

    if (probability == probability.roundToDouble()) {
      return '1 / ${probability.toInt()}';
    }

    //================================================
    // 割り切れない場合のみ
    // 小数第1位
    //================================================

    return '1 / ${probability.toStringAsFixed(1)}';
  }
}