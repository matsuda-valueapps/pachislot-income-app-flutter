import 'package:shared_preferences/shared_preferences.dart';

/// メモの下書き保存サービス
///
/// 役割
/// ・日付保存
/// ・タイトル保存
/// ・本文保存
/// ・日付読込
/// ・タイトル読込
/// ・本文読込
/// ・下書き削除
class MemoDraftService {
  MemoDraftService._();

  static const String _dateKey = 'memo_draft_date';
  static const String _titleKey = 'memo_draft_title';
  static const String _bodyKey = 'memo_draft_body';

  /// 日付保存
  static Future<void> saveDate(
    DateTime date,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _dateKey,
      date.toIso8601String(),
    );
  }

  /// タイトル保存
  static Future<void> saveTitle(
    String title,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _titleKey,
      title,
    );
  }

  /// 本文保存
  static Future<void> saveBody(
    String body,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _bodyKey,
      body,
    );
  }

  /// 日付取得
  static Future<String> loadDate() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_dateKey) ?? '';
  }

  /// タイトル取得
  static Future<String> loadTitle() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_titleKey) ?? '';
  }

  /// 本文取得
  static Future<String> loadBody() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_bodyKey) ?? '';
  }

  /// 下書き保存
  static Future<void> saveDraft({
    required DateTime date,
    required String title,
    required String body,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _dateKey,
      date.toIso8601String(),
    );

    await prefs.setString(
      _titleKey,
      title,
    );

    await prefs.setString(
      _bodyKey,
      body,
    );
  }

  /// 下書き読込
  static Future<Map<String, String>>
      loadDraft() async {
    final prefs =
        await SharedPreferences.getInstance();

    return {
      'date':
          prefs.getString(_dateKey) ?? '',
      'title':
          prefs.getString(_titleKey) ?? '',
      'body':
          prefs.getString(_bodyKey) ?? '',
    };
  }

  /// 下書き削除
  static Future<void> clearDraft() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_dateKey);

    await prefs.remove(_titleKey);

    await prefs.remove(_bodyKey);
  }
}