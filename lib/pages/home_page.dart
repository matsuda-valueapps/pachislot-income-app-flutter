import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/income_record.dart';
import '../pages/income_detail_page.dart';
import '../pages/income_list_page.dart';
import '../pages/input_page.dart';
import '../providers/home_provider.dart';
import '../services/dialog_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/home/calendar_card.dart';
import '../widgets/home/monthly_income_card.dart';
import '../widgets/home/statistics_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final provider =
            context.read<HomeProvider>();

        await provider.loadIncomeRecords();
      },
    );
  }

  //==================================================
  // 保存データ一覧
  //==================================================

  /// 保存データ一覧画面を開く
  Future<void> _openIncomeList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const IncomeListPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    // 保存データ一覧から戻ってきた後、
    // SQLiteの最新データを再取得する。
    await context
        .read<HomeProvider>()
        .refresh();
  }

  //==================================================
  // カレンダー日付タップ
  //==================================================

  /// 指定された日付の保存データを検索する。
  ///
  /// CalendarCardはSQLiteを直接操作せず、
  /// HomeProviderが保持している収支データを
  /// HomePageから検索する。
  IncomeRecord? _findIncomeRecordByDate(
    DateTime selectedDate,
    HomeProvider provider,
  ) {
    for (final record
        in provider.incomeRecords) {
      try {
        final recordDate =
            DateTime.parse(record.date);

        if (recordDate.year ==
                selectedDate.year &&
            recordDate.month ==
                selectedDate.month &&
            recordDate.day ==
                selectedDate.day) {
          return record;
        }
      } catch (_) {
        // 日付が不正なデータは無視する。
      }
    }

    return null;
  }

  /// カレンダーの日付がタップされた時の処理
  Future<void> _handleCalendarDateSelected(
    DateTime selectedDate,
  ) async {
    final provider =
        context.read<HomeProvider>();

    final record =
        _findIncomeRecordByDate(
      selectedDate,
      provider,
    );

    if (!mounted) {
      return;
    }

    //==================================================
    // 保存データあり
    //==================================================

    if (record != null) {
      final shouldEdit =
          await DialogService.showConfirm(
        context: context,
        title: 'データを修正しますか？',
        message:
            '${selectedDate.year}年'
            '${selectedDate.month}月'
            '${selectedDate.day}日の'
            '保存データがあります。',
        confirmText: '修正する',
      );

      if (!mounted) {
        return;
      }

      if (!shouldEdit) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              IncomeDetailPage(
            record: record,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      // 詳細画面から戻ってきた後、
      // SQLiteの最新データを再取得する。
      await context
          .read<HomeProvider>()
          .refresh();

      return;
    }

    //==================================================
    // 保存データなし
    //==================================================

    final shouldInput =
        await DialogService.showConfirm(
      context: context,
      title: 'データを入力しますか？',
      message:
          '${selectedDate.year}年'
          '${selectedDate.month}月'
          '${selectedDate.day}日の'
          'データは保存されていません。',
      confirmText: '入力する',
    );

    if (!mounted) {
      return;
    }

    if (!shouldInput) {
      return;
    }

    // 保存データがない場合は、
    // タップした日付を初期日付として
    // 新規入力画面を開く。
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputPage(
          initialDate: selectedDate,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    // 入力画面から戻ってきた後、
    // SQLiteの最新データを再取得する。
    await context
        .read<HomeProvider>()
        .refresh();
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ホーム',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // カレンダー
              // ==========================================

              CalendarCard(
                onDateSelected:
                    _handleCalendarDateSelected,
              ),

              AppSpacing.gapLg,

              // ==========================================
              // 表示中の月の収支
              // ==========================================

              MonthlyIncomeCard(
                year:
                    provider.focusedMonth.year,
                month:
                    provider.focusedMonth.month,
                income:
                    provider.monthlyIncome,
                investment:
                    provider.monthlyInvestment,
                recovery:
                    provider.monthlyRecovery,
              ),

              AppSpacing.gapLg,

              // ==========================================
              // 表示中の月の統計
              // ==========================================

              StatisticsCard(
                monthLabel:
                    provider.focusedMonthLabel,
                totalGames:
                    provider.monthlyTotalGames,
                winGames:
                    provider.monthlyWinGames,
                winRate:
                    provider.monthlyWinRate,
                averageIncome:
                    provider.monthlyAverageIncome,
              ),

              AppSpacing.gapLg,

              // ==========================================
              // 保存データ一覧
              // ==========================================

              OutlinedButton.icon(
                onPressed:
                    _openIncomeList,
                icon: const Icon(
                  Icons.history,
                ),
                label: const Text(
                  '保存データを見る',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}