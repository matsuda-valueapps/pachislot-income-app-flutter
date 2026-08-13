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
  /// CalendarCardの再生成用Key
  ///
  /// CalendarCardを再生成することで、
  /// 初期選択日を今日へ戻す。
  Key _calendarKey = UniqueKey();

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
  // カレンダー再生成
  //==================================================

  /// HomePageへ戻ってきた際に、
  /// カレンダーを現在年月＋今日の選択状態へ戻す。
  ///
  /// この処理は「別画面からHomePageへ戻った場合」に使用する。
  ///
  /// 例：
  /// 7月を表示
  /// ↓
  /// 他画面へ移動
  /// ↓
  /// HomePageへ戻る
  /// ↓
  /// 8月（現在月）＋今日を選択
  Future<void> _resetHomeToCurrentMonth() async {
    if (!mounted) {
      return;
    }

    final provider =
        context.read<HomeProvider>();

    //==================================================
    // HomeProviderの表示年月を現在年月へ戻す
    //==================================================

    provider.resetToCurrentMonth();

    if (!mounted) {
      return;
    }

    //==================================================
    // CalendarCardを再生成
    //==================================================
    //
    // CalendarCardのinitState()で
    // _selectedDay = DateTime.now()
    // となるため、今日が選択状態になる。
    //==================================================

    setState(() {
      _calendarKey = UniqueKey();
    });
  }

  /// 現在年月を表示している場合のみ
  /// CalendarCardを再生成する。
  ///
  /// カレンダー内のキャンセル処理などで使用する。
  ///
  /// 現在年月の場合：
  /// → 今日を選択状態へ戻す。
  ///
  /// 過去月・未来月の場合：
  /// → CalendarCardを再生成しない。
  ///   現在の選択状態を維持する。
  void _resetCalendarIfCurrentMonth() {
    final provider =
        context.read<HomeProvider>();

    final focusedMonth =
        provider.focusedMonth;

    final now = DateTime.now();

    //==================================================
    // 現在年月の場合のみ再生成
    //==================================================

    if (focusedMonth.year == now.year &&
        focusedMonth.month == now.month) {
      if (!mounted) {
        return;
      }

      setState(() {
        _calendarKey = UniqueKey();
      });
    }
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

    if (!mounted) {
      return;
    }

    // 他画面からHomePageへ戻ってきたため、
    // 必ず現在月＋今日の選択状態へ戻す。
    await _resetHomeToCurrentMonth();
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

      //================================================
      // キャンセル
      //================================================

      if (!shouldEdit) {
        // 現在年月の場合のみ、
        // 今日を選択状態へ戻す。
        //
        // 過去月・未来月の場合は
        // 現在の選択状態を維持する。
        _resetCalendarIfCurrentMonth();

        return;
      }

      //================================================
      // 修正する
      //================================================

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

      if (!mounted) {
        return;
      }

      // 詳細画面という別画面から
      // HomePageへ戻ってきたため、
      // 必ず現在月＋今日へ戻す。
      await _resetHomeToCurrentMonth();

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

    //================================================
    // キャンセル
    //================================================

    if (!shouldInput) {
      // 現在年月の場合のみ、
      // 今日を選択状態へ戻す。
      //
      // 過去月・未来月の場合は
      // 現在の選択状態を維持する。
      _resetCalendarIfCurrentMonth();

      return;
    }

    //================================================
    // 入力する
    //================================================

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

    if (!mounted) {
      return;
    }

    // 入力画面という別画面から
    // HomePageへ戻ってきたため、
    // 必ず現在月＋今日へ戻す。
    await _resetHomeToCurrentMonth();
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
                key: _calendarKey,
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