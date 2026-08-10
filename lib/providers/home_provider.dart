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

  //==================================================
  // 月間収支
  //==================================================

  /// 今月の収支データ
  List<IncomeRecord> get currentMonthRecords {
    final now = DateTime.now();

    final yearMonth =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}';

    return _incomeRecords
        .where(
          (record) =>
              record.date.startsWith(yearMonth),
        )
        .toList();
  }

  /// 今月の収支
  int get monthlyIncome {
    return currentMonthRecords.fold(
      0,
      (sum, record) =>
          sum + record.profit,
    );
  }

  /// 今月の投資額
  int get monthlyInvestment {
    return currentMonthRecords.fold(
      0,
      (sum, record) =>
          sum +
          record.medalInvest +
          record.cashInvest,
    );
  }

  /// 今月の回収額
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
  // 統計
  //==================================================

  /// 保存済みの稼働件数
  ///
  /// 1件のincome_recordを1稼働として数える。
  int get totalGames =>
      _incomeRecords.length;

  /// 勝ち件数
  ///
  /// 収支が0円より大きいデータを勝ちとして数える。
  int get winGames {
    return _incomeRecords
        .where(
          (record) => record.profit > 0,
        )
        .length;
  }

  /// 平均収支
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