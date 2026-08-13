import 'package:flutter/foundation.dart';

import '../models/income_record.dart';
import '../services/database_service.dart';

/// ホーム画面の収支データ状態管理
class HomeProvider extends ChangeNotifier {
  HomeProvider();

  /// SQLiteから取得した収支データ
  List<IncomeRecord> _incomeRecords = [];

  /// 読み込み中
  bool _isLoading = false;

  /// エラー
  String? _errorMessage;

  /// 現在カレンダーで表示している年月
  DateTime _focusedMonth = DateTime.now();

  //==================================================
  // Getter
  //==================================================

  /// 保存済み収支データ
  List<IncomeRecord> get incomeRecords =>
      List.unmodifiable(_incomeRecords);

  /// 読み込み中か
  bool get isLoading => _isLoading;

  /// エラーメッセージ
  String? get errorMessage => _errorMessage;

  /// データが存在するか
  bool get hasData =>
      _incomeRecords.isNotEmpty;

  /// 現在カレンダーで表示している年月
  DateTime get focusedMonth =>
      _focusedMonth;

  /// 現在表示中の年
  int get focusedYear =>
      _focusedMonth.year;

  /// 現在表示中の月
  int get focusedMonthNumber =>
      _focusedMonth.month;

  /// 現在表示中の年月ラベル
  ///
  /// 例：
  /// 2026年8月
  String get focusedMonthLabel =>
      '$focusedYear年$focusedMonthNumber月';

  //==================================================
  // カレンダー表示月
  //==================================================

  /// カレンダーで表示する年月を変更
  ///
  /// CalendarCardから呼び出す。
  void setFocusedMonth(DateTime month) {
    final normalizedMonth = DateTime(
      month.year,
      month.month,
      1,
    );

    // 同じ年月なら更新しない
    if (_focusedMonth.year ==
            normalizedMonth.year &&
        _focusedMonth.month ==
            normalizedMonth.month) {
      return;
    }

    _focusedMonth = normalizedMonth;

    notifyListeners();
  }

  /// カレンダーの表示年月を現在年月へ戻す。
  ///
  /// MainPageから呼び出す。
  ///
  /// 他のBottomNavigation画面から
  /// ホーム画面へ戻った際に、
  /// カレンダーを必ず現在年月へ戻すために使用する。
  ///
  /// 例：
  ///
  /// 2026年7月を表示中
  /// ↓
  /// 「入力」へ移動
  /// ↓
  /// 「ホーム」へ戻る
  /// ↓
  /// 2026年8月へ戻る
  void resetToCurrentMonth() {
    final now = DateTime.now();

    final currentMonth = DateTime(
      now.year,
      now.month,
      1,
    );

    // すでに現在年月の場合は、
    // focusedMonthを変更しない。
    if (_focusedMonth.year ==
            currentMonth.year &&
        _focusedMonth.month ==
            currentMonth.month) {
      return;
    }

    _focusedMonth = currentMonth;

    notifyListeners();
  }

  //==================================================
  // 月間データ
  //==================================================

  /// カレンダーで現在表示している月の収支データ
  List<IncomeRecord> get currentMonthRecords {
    final yearMonth =
        '${focusedYear.toString().padLeft(4, '0')}-'
        '${focusedMonthNumber.toString().padLeft(2, '0')}';

    return _incomeRecords
        .where(
          (record) =>
              record.date.startsWith(yearMonth),
        )
        .toList();
  }

  /// 現在表示中の月の収支
  int get monthlyIncome {
    return currentMonthRecords.fold(
      0,
      (sum, record) =>
          sum + record.profit,
    );
  }

  /// 現在表示中の月の投資額
  int get monthlyInvestment {
    return currentMonthRecords.fold(
      0,
      (sum, record) =>
          sum +
          record.medalInvest +
          record.cashInvest,
    );
  }

  /// 現在表示中の月の回収額
  int get monthlyRecovery {
    return currentMonthRecords.fold(
      0,
      (sum, record) =>
          sum +
          record.medalReturn +
          record.cashReturn,
    );
  }

  //==================================================
  // 月間統計
  //==================================================

  /// 現在表示中の月の遊技回数
  ///
  /// 1件のincome_recordを1遊技として数える。
  int get monthlyTotalGames =>
      currentMonthRecords.length;

  /// 現在表示中の月の勝利回数
  ///
  /// 収支が0円より大きいデータを
  /// 勝利として数える。
  int get monthlyWinGames {
    return currentMonthRecords
        .where(
          (record) => record.profit > 0,
        )
        .length;
  }

  /// 現在表示中の月の勝率
  ///
  /// 遊技回数が0回の場合は0.0を返す。
  double get monthlyWinRate {
    if (monthlyTotalGames == 0) {
      return 0.0;
    }

    return monthlyWinGames /
        monthlyTotalGames *
        100;
  }

  /// 現在表示中の月の平均収支
  ///
  /// 月間収支を月間遊技回数で割る。
  ///
  /// 遊技回数が0回の場合は0円を返す。
  int get monthlyAverageIncome {
    if (monthlyTotalGames == 0) {
      return 0;
    }

    return monthlyIncome ~/
        monthlyTotalGames;
  }

  //==================================================
  // 全期間統計
  //==================================================

  /// 保存済みの全期間の稼働件数
  ///
  /// 1件のincome_recordを1稼働として数える。
  int get totalGames =>
      _incomeRecords.length;

  /// 全期間の勝ち件数
  ///
  /// 収支が0円より大きいデータを
  /// 勝ちとして数える。
  int get winGames {
    return _incomeRecords
        .where(
          (record) => record.profit > 0,
        )
        .length;
  }

  /// 全期間の平均収支
  ///
  /// 保存済みの全収支データを対象に計算する。
  int get averageIncome {
    if (_incomeRecords.isEmpty) {
      return 0;
    }

    final totalIncome =
        _incomeRecords.fold<int>(
      0,
      (sum, record) =>
          sum + record.profit,
    );

    return totalIncome ~/
        _incomeRecords.length;
  }

  //==================================================
  // SQLite
  //==================================================

  /// SQLiteから保存済みの収支データを取得
  Future<void> loadIncomeRecords() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final records =
          await DatabaseService.instance
              .getIncomeRecords();

      _incomeRecords = records;
    } catch (e) {
      _errorMessage =
          '収支データの取得に失敗しました。';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  /// SQLiteから保存済みの収支データを再取得
  Future<void> refresh() async {
    await loadIncomeRecords();
  }
}