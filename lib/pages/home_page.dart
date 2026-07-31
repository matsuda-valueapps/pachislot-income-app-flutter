import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../widgets/home/calendar_card.dart';
import '../widgets/home/monthly_income_card.dart';
import '../widgets/home/statistics_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              CalendarCard(),

              AppSpacing.gapLg,

              MonthlyIncomeCard(
                income: 25800,
                investment: 145000,
                recovery: 170800,
              ),

              AppSpacing.gapLg,

              StatisticsCard(
                totalGames: 18,
                winGames: 11,
                averageIncome: 1433,
              ),
            ],
          ),
        ),
      ),
    );
  }
}