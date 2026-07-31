import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../common/app_card.dart';
import '../common/section_title.dart';
import '../common/stat_tile.dart';

/// ホーム画面用 統計カード
class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    super.key,
    required this.totalGames,
    required this.winGames,
    required this.averageIncome,
  });

  /// 遊技回数
  final int totalGames;

  /// 勝利回数
  final int winGames;

  /// 平均収支
  final int averageIncome;

  String _format(int value) {
    return NumberFormat('#,###').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final double winRate =
        totalGames == 0 ? 0 : (winGames / totalGames) * 100;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: '統計',
          ),

          AppSpacing.gapLg,

          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: '遊技回数',
                  value: '$totalGames 回',
                  icon: Icons.casino_outlined,
                ),
              ),

              AppSpacing.gapMd,

              Expanded(
                child: StatTile(
                  label: '勝利回数',
                  value: '$winGames 回',
                  icon: Icons.emoji_events_outlined,
                  valueColor: AppColors.profit,
                ),
              ),
            ],
          ),

          AppSpacing.gapMd,

          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: '勝率',
                  value: '${winRate.toStringAsFixed(1)}%',
                  icon: Icons.percent,
                  valueColor: AppColors.primary,
                ),
              ),

              AppSpacing.gapMd,

              Expanded(
                child: StatTile(
                  label: '平均収支',
                  value: '${averageIncome >= 0 ? '+' : ''}${_format(averageIncome)}円',
                  icon: Icons.bar_chart_outlined,
                  valueColor: averageIncome >= 0
                      ? AppColors.profit
                      : AppColors.loss,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}