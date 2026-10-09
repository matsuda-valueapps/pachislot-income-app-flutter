import 'package:shared_preferences/shared_preferences.dart';

/// 小役カウンター下書き保存サービス
///
/// SharedPreferencesへ
/// ・日付
/// ・タイトル
/// ・機種タイプ
/// ・開始ゲーム数
/// ・現在ゲーム数
/// ・各小役カウント
/// を自動保存する。
class CounterDraftService {
  CounterDraftService._();

  //==================================================
  // Key
  //==================================================

  /// 日付
  static const String _dateKey =
      'counter_date';

  /// タイトル
  static const String _titleKey =
      'counter_title';

  /// 機種タイプ
  static const String _machineTypeKey =
      'counter_machine_type';

  /// 開始ゲーム数
  static const String _startGameKey =
      'counter_start_game';

  /// 現在ゲーム数
  static const String _currentGameKey =
      'counter_current_game';

  //==================================================
  // Aタイプ小役カウント
  //==================================================

  /// チェリー
  static const String _cherryKey =
      'counter_cherry';

  /// ベル
  static const String _bellKey =
      'counter_bell';

  /// スイカ
  static const String _suikaKey =
      'counter_suika';

  /// ブドウ
  static const String _grapeKey =
      'counter_grape';

  /// チャンス目
  static const String _chanceKey =
      'counter_chance';

  //==================================================
  // ATタイプ小役カウント
  //==================================================

  /// 強チェリー
  static const String _strongCherryKey =
      'counter_strong_cherry';

  /// 弱チェリー
  static const String _weakCherryKey =
      'counter_weak_cherry';

  /// 強ベル
  static const String _strongBellKey =
      'counter_strong_bell';

  /// 弱ベル
  static const String _weakBellKey =
      'counter_weak_bell';

  /// 強スイカ
  static const String _strongSuikaKey =
      'counter_strong_suika';

  /// 弱スイカ
  static const String _weakSuikaKey =
      'counter_weak_suika';

  /// 強ブドウ
  static const String _strongGrapeKey =
      'counter_strong_grape';

  /// 弱ブドウ
  static const String _weakGrapeKey =
      'counter_weak_grape';

  /// 強チャンス目
  static const String _strongChanceKey =
      'counter_strong_chance';

  /// 弱チャンス目
  static const String _weakChanceKey =
      'counter_weak_chance';

  //==================================================
  // 保存
  //==================================================

  /// 下書きを保存する。
  ///
  /// 日付・タイトル・機種タイプ・ゲーム数・
  /// 各小役カウントをSharedPreferencesへ保存する。
  ///
  /// machineTypeとextraCountsは省略可能。
  /// 既存の呼び出し元との互換性を維持する。
  static Future<void> saveDraft({
    required DateTime date,
    required String title,
    required int startGame,
    required int currentGame,
    required int cherry,
    required int bell,
    required int suika,
    required int grape,
    required int chance,
    String machineType = 'Aタイプ',
    Map<String, int> extraCounts = const {},
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    //================================================
    // 日付
    //================================================

    await prefs.setString(
      _dateKey,
      date.toIso8601String(),
    );

    //================================================
    // タイトル
    //================================================

    await prefs.setString(
      _titleKey,
      title,
    );

    //================================================
    // 機種タイプ
    //================================================

    await prefs.setString(
      _machineTypeKey,
      machineType,
    );

    //================================================
    // ゲーム数
    //================================================

    await prefs.setInt(
      _startGameKey,
      startGame,
    );

    await prefs.setInt(
      _currentGameKey,
      currentGame,
    );

    //================================================
    // Aタイプ小役カウント
    //================================================

    await prefs.setInt(
      _cherryKey,
      cherry,
    );

    await prefs.setInt(
      _bellKey,
      bell,
    );

    await prefs.setInt(
      _suikaKey,
      suika,
    );

    await prefs.setInt(
      _grapeKey,
      grape,
    );

    await prefs.setInt(
      _chanceKey,
      chance,
    );

    //================================================
    // ATタイプ小役カウント
    //================================================

    await prefs.setInt(
      _strongCherryKey,
      extraCounts['strongCherry'] ?? 0,
    );

    await prefs.setInt(
      _weakCherryKey,
      extraCounts['weakCherry'] ?? 0,
    );

    await prefs.setInt(
      _strongBellKey,
      extraCounts['strongBell'] ?? 0,
    );

    await prefs.setInt(
      _weakBellKey,
      extraCounts['weakBell'] ?? 0,
    );

    await prefs.setInt(
      _strongSuikaKey,
      extraCounts['strongSuika'] ?? 0,
    );

    await prefs.setInt(
      _weakSuikaKey,
      extraCounts['weakSuika'] ?? 0,
    );

    await prefs.setInt(
      _strongGrapeKey,
      extraCounts['strongGrape'] ?? 0,
    );

    await prefs.setInt(
      _weakGrapeKey,
      extraCounts['weakGrape'] ?? 0,
    );

    await prefs.setInt(
      _strongChanceKey,
      extraCounts['strongChance'] ?? 0,
    );

    await prefs.setInt(
      _weakChanceKey,
      extraCounts['weakChance'] ?? 0,
    );
  }

  //==================================================
  // 読み込み
  //==================================================

  /// 保存済みの下書きを読み込む。
  ///
  /// 旧バージョンの下書きに新しい項目がない場合は、
  /// Aタイプ・追加カウント0として扱う。
  static Future<Map<String, dynamic>>
      loadDraft() async {
    final prefs =
        await SharedPreferences.getInstance();

    return {
      //================================================
      // 日付
      //================================================

      'date':
          prefs.getString(
            _dateKey,
          ) ?? '',

      //================================================
      // タイトル
      //================================================

      'title':
          prefs.getString(
            _titleKey,
          ) ?? '',

      //================================================
      // 機種タイプ
      //================================================

      'machineType':
          prefs.getString(
            _machineTypeKey,
          ) ?? 'Aタイプ',

      //================================================
      // ゲーム数
      //================================================

      'startGame':
          prefs.getInt(
            _startGameKey,
          ) ?? 0,

      'currentGame':
          prefs.getInt(
            _currentGameKey,
          ) ?? 0,

      //================================================
      // Aタイプ小役カウント
      //================================================

      'cherry':
          prefs.getInt(
            _cherryKey,
          ) ?? 0,

      'bell':
          prefs.getInt(
            _bellKey,
          ) ?? 0,

      'suika':
          prefs.getInt(
            _suikaKey,
          ) ?? 0,

      'grape':
          prefs.getInt(
            _grapeKey,
          ) ?? 0,

      'chance':
          prefs.getInt(
            _chanceKey,
          ) ?? 0,

      //================================================
      // ATタイプ小役カウント
      //================================================

      'strongCherry':
          prefs.getInt(
            _strongCherryKey,
          ) ?? 0,

      'weakCherry':
          prefs.getInt(
            _weakCherryKey,
          ) ?? 0,

      'strongBell':
          prefs.getInt(
            _strongBellKey,
          ) ?? 0,

      'weakBell':
          prefs.getInt(
            _weakBellKey,
          ) ?? 0,

      'strongSuika':
          prefs.getInt(
            _strongSuikaKey,
          ) ?? 0,

      'weakSuika':
          prefs.getInt(
            _weakSuikaKey,
          ) ?? 0,

      'strongGrape':
          prefs.getInt(
            _strongGrapeKey,
          ) ?? 0,

      'weakGrape':
          prefs.getInt(
            _weakGrapeKey,
          ) ?? 0,

      'strongChance':
          prefs.getInt(
            _strongChanceKey,
          ) ?? 0,

      'weakChance':
          prefs.getInt(
            _weakChanceKey,
          ) ?? 0,
    };
  }

  //==================================================
  // 下書き削除
  //==================================================

  /// 保存済みの下書きをすべて削除する。
  ///
  /// 日付・タイトル・機種タイプ・ゲーム数・
  /// AタイプおよびATタイプの小役カウントを削除する。
  static Future<void> clearDraft() async {
    final prefs =
        await SharedPreferences.getInstance();

    //================================================
    // 日付
    //================================================

    await prefs.remove(
      _dateKey,
    );

    //================================================
    // タイトル
    //================================================

    await prefs.remove(
      _titleKey,
    );

    //================================================
    // 機種タイプ
    //================================================

    await prefs.remove(
      _machineTypeKey,
    );

    //================================================
    // ゲーム数
    //================================================

    await prefs.remove(
      _startGameKey,
    );

    await prefs.remove(
      _currentGameKey,
    );

    //================================================
    // Aタイプ小役カウント
    //================================================

    await prefs.remove(
      _cherryKey,
    );

    await prefs.remove(
      _bellKey,
    );

    await prefs.remove(
      _suikaKey,
    );

    await prefs.remove(
      _grapeKey,
    );

    await prefs.remove(
      _chanceKey,
    );

    //================================================
    // ATタイプ小役カウント
    //================================================

    await prefs.remove(
      _strongCherryKey,
    );

    await prefs.remove(
      _weakCherryKey,
    );

    await prefs.remove(
      _strongBellKey,
    );

    await prefs.remove(
      _weakBellKey,
    );

    await prefs.remove(
      _strongSuikaKey,
    );

    await prefs.remove(
      _weakSuikaKey,
    );

    await prefs.remove(
      _strongGrapeKey,
    );

    await prefs.remove(
      _weakGrapeKey,
    );

    await prefs.remove(
      _strongChanceKey,
    );

    await prefs.remove(
      _weakChanceKey,
    );
  }
}