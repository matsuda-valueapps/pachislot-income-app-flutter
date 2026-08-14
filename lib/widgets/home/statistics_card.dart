import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../common/app_card.dart';
import '../common/section_title.dart';
import '../common/stat_tile.dart';

/// ホーム画面用 月間統計カード
class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    super.key,
    required this.monthLabel,
    required this.totalGames,
    required this.winGames,
    required this.winRate,
    required this.averageIncome,
  });

  /// 表示年月
  ///
  /// 例：
  /// 2026年8月
  final String monthLabel;

  /// 月間遊技回数
  final int totalGames;

  /// 月間勝利回数
  final int winGames;

  /// 月間勝率
  final double winRate;

  /// 月間平均収支
  final int averageIncome;

  /// 金額表示
  String _format(int value) {
    return NumberFormat('#,###').format(value);
  }

  /// 平均収支表示
  ///
  /// 画面幅が狭い端末でも金額を1行に収める。
  Widget _buildAverageIncome() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        '${averageIncome >= 0 ? '+' : ''}'
        '${_format(averageIncome)}円',
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          color:
              averageIncome >= 0
                  ? AppColors.profit
                  : AppColors.loss,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==========================================
          // タイトル
          // ==========================================

          SectionTitle(
            title: '$monthLabel統計',
          ),

          AppSpacing.gapLg,

          // ==========================================
          // 遊技回数・勝利回数
          // ==========================================

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
                  icon:
                      Icons.emoji_events_outlined,
                  valueColor:
                      AppColors.profit,
                ),
              ),
            ],
          ),

          AppSpacing.gapMd,

          // ==========================================
          // 勝率・平均収支
          // ==========================================

          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: '勝率',
                  value:
                      '${winRate.toStringAsFixed(1)}%',
                  icon: Icons.percent,
                  valueColor:
                      AppColors.primary,
                ),
              ),

              AppSpacing.gapMd,

              Expanded(
                child: StatTile(
                  label: '平均収支',
                  valueWidget:
                      _buildAverageIncome(),
                  icon:
                      Icons.bar_chart_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}