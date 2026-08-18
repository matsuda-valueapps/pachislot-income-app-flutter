import 'package:shared_preferences/shared_preferences.dart';

/// 小役カウンター下書き保存サービス
///
/// SharedPreferencesへ
/// ・日付
/// ・タイトル
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

  /// 開始ゲーム数
  static const String _startGameKey =
      'counter_start_game';

  /// 現在ゲーム数
  static const String _currentGameKey =
      'counter_current_game';

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
  // 保存
  //==================================================

  /// 下書きを保存する。
  ///
  /// 日付・タイトル・ゲーム数・
  /// 各小役カウントをSharedPreferencesへ保存する。
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
    // 小役カウント
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
  }

  //==================================================
  // 読み込み
  //==================================================

  /// 保存済みの下書きを読み込む。
  ///
  /// 既存ユーザーなど、日付・タイトルが
  /// まだ保存されていない場合は、
  ///
  /// date  → ''
  /// title → ''
  ///
  /// を返す。
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
      // 小役カウント
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
    };
  }

  //==================================================
  // 下書き削除
  //==================================================

  /// 保存済みの下書きをすべて削除する。
  ///
  /// 日付・タイトル・ゲーム数・
  /// 各小役カウントを削除する。
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
    // ゲーム数
    //================================================

    await prefs.remove(
      _startGameKey,
    );

    await prefs.remove(
      _currentGameKey,
    );

    //================================================
    // 小役カウント
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
  }
}