import 'package:shared_preferences/shared_preferences.dart';

/// 入力画面の下書き保存サービス
class InputDraftService {
  InputDraftService._();

  static const _dateKey = 'input_date';
  static const _hallKey = 'input_hall';
  static const _machineKey = 'input_machine';

  static const _medalInvestKey = 'input_medal_invest';
  static const _cashInvestKey = 'input_cash_invest';

  static const _medalReturnKey = 'input_medal_return';
  static const _cashReturnKey = 'input_cash_return';

  static const _memoKey = 'input_memo';

  /// 下書き保存
  static Future<void> saveDraft({
    required DateTime date,
    required String hall,
    required String machine,
    required String medalInvest,
    required String cashInvest,
    required String medalReturn,
    required String cashReturn,
    required String memo,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _dateKey,
      date.toIso8601String(),
    );

    await prefs.setString(
      _hallKey,
      hall,
    );

    await prefs.setString(
      _machineKey,
      machine,
    );

    await prefs.setString(
      _medalInvestKey,
      medalInvest,
    );

    await prefs.setString(
      _cashInvestKey,
      cashInvest,
    );

    await prefs.setString(
      _medalReturnKey,
      medalReturn,
    );

    await prefs.setString(
      _cashReturnKey,
      cashReturn,
    );

    await prefs.setString(
      _memoKey,
      memo,
    );
  }

  /// 下書き読込
  static Future<Map<String, dynamic>>
      loadDraft() async {
    final prefs =
        await SharedPreferences.getInstance();

    return {
      'date':
          prefs.getString(_dateKey),
      'hall':
          prefs.getString(_hallKey) ??
              '',
      'machine':
          prefs.getString(_machineKey) ??
              '',
      'medalInvest':
          prefs.getString(
                _medalInvestKey,
              ) ??
              '0',
      'cashInvest':
          prefs.getString(
                _cashInvestKey,
              ) ??
              '0',
      'medalReturn':
          prefs.getString(
                _medalReturnKey,
              ) ??
              '0',
      'cashReturn':
          prefs.getString(
                _cashReturnKey,
              ) ??
              '0',
      'memo':
          prefs.getString(_memoKey) ??
              '',
    };
  }

  /// 下書き削除
  static Future<void> clearDraft() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_dateKey);
    await prefs.remove(_hallKey);
    await prefs.remove(_machineKey);

    await prefs.remove(
      _medalInvestKey,
    );

    await prefs.remove(
      _cashInvestKey,
    );

    await prefs.remove(
      _medalReturnKey,
    );

    await prefs.remove(
      _cashReturnKey,
    );

    await prefs.remove(_memoKey);
  }
}