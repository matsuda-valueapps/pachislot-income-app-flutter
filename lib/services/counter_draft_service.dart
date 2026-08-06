import 'package:shared_preferences/shared_preferences.dart';

/// 小役カウンター下書き保存サービス
///
/// SharedPreferencesへ
/// ・開始ゲーム数
/// ・現在ゲーム数
/// ・各小役カウント
/// を自動保存する。
class CounterDraftService {
  CounterDraftService._();

  //==================================================
  // Key
  //==================================================

  static const String _startGameKey = 'counter_start_game';
  static const String _currentGameKey = 'counter_current_game';

  static const String _cherryKey = 'counter_cherry';
  static const String _bellKey = 'counter_bell';
  static const String _suikaKey = 'counter_suika';
  static const String _grapeKey = 'counter_grape';
  static const String _chanceKey = 'counter_chance';

  //==================================================
  // 保存
  //==================================================

  static Future<void> saveDraft({
    required int startGame,
    required int currentGame,
    required int cherry,
    required int bell,
    required int suika,
    required int grape,
    required int chance,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_startGameKey, startGame);
    await prefs.setInt(_currentGameKey, currentGame);

    await prefs.setInt(_cherryKey, cherry);
    await prefs.setInt(_bellKey, bell);
    await prefs.setInt(_suikaKey, suika);
    await prefs.setInt(_grapeKey, grape);
    await prefs.setInt(_chanceKey, chance);
  }

  //==================================================
  // 読み込み
  //==================================================

  static Future<Map<String, int>> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'startGame': prefs.getInt(_startGameKey) ?? 0,
      'currentGame': prefs.getInt(_currentGameKey) ?? 0,

      'cherry': prefs.getInt(_cherryKey) ?? 0,
      'bell': prefs.getInt(_bellKey) ?? 0,
      'suika': prefs.getInt(_suikaKey) ?? 0,
      'grape': prefs.getInt(_grapeKey) ?? 0,
      'chance': prefs.getInt(_chanceKey) ?? 0,
    };
  }

  //==================================================
  // 下書き削除
  //==================================================

  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_startGameKey);
    await prefs.remove(_currentGameKey);

    await prefs.remove(_cherryKey);
    await prefs.remove(_bellKey);
    await prefs.remove(_suikaKey);
    await prefs.remove(_grapeKey);
    await prefs.remove(_chanceKey);
  }
}