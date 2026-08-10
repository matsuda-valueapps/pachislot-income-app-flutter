import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/income_list_page.dart';
import '../providers/home_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/home/calendar_card.dart';
import '../widgets/home/monthly_income_card.dart';
import '../widgets/home/statistics_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  /// 保存データ一覧画面を開く
  Future<void> _openIncomeList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const IncomeListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
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

              const CalendarCard(),

              AppSpacing.gapLg,

              // ==========================================
              // 今月の収支
              // ==========================================

              MonthlyIncomeCard(
                income:
                    provider.monthlyIncome,
                investment:
                    provider.monthlyInvestment,
                recovery:
                    provider.monthlyRecovery,
              ),

              AppSpacing.gapLg,

              // ==========================================
              // 統計
              // ==========================================

              StatisticsCard(
                totalGames:
                    provider.totalGames,
                winGames:
                    provider.winGames,
                averageIncome:
                    provider.averageIncome,
              ),

              AppSpacing.gapLg,

              // ==========================================
              // 保存データ一覧
              // ==========================================

              OutlinedButton.icon(
                onPressed: _openIncomeList,
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