import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../common/section_title.dart';

/// ホーム画面用 月間収支カード
class MonthlyIncomeCard extends StatelessWidget {
  const MonthlyIncomeCard({
    super.key,
    required this.year,
    required this.month,
    required this.income,
    required this.investment,
    required this.recovery,
  });

  /// 表示する年
  final int year;

  /// 表示する月
  final int month;

  /// 月間収支
  final int income;

  /// 総投資額
  final int investment;

  /// 総回収額
  final int recovery;

  /// 金額フォーマット
  String _format(int value) {
    return NumberFormat('#,###').format(value);
  }

  //==================================================
  // プレミアムガラスカード
  //==================================================

  /// 薄いブルーの高級ガラスカード用Decoration。
  ///
  /// カレンダーと同じデザイン言語を使用する。
  ///
  /// ・白～ごく薄いブルーのグラデーション
  /// ・薄いブルーの外側Border
  /// ・柔らかい立体シャドウ
  ///
  /// ※カレンダー専用の
  /// 「内側の白いハイライト」は使用しない。
  BoxDecoration _buildGlassDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(
            255,
            255,
            255,
            0.98,
          ),
          Color.fromRGBO(
            247,
            251,
            255,
            0.98,
          ),
          Color.fromRGBO(
            239,
            247,
            255,
            0.98,
          ),
        ],
        stops: [
          0.0,
          0.52,
          1.0,
        ],
      ),

      // 既存カードと同じ角丸を維持
      borderRadius: AppRadius.card,

      // カレンダーと同系統の薄いブルーBorder
      border: Border.all(
        color: const Color.fromRGBO(
          157,
          201,
          246,
          0.78,
        ),
        width: 1.5,
      ),

      // カレンダーと同系統の柔らかい立体影
      boxShadow: const [
        //================================================
        // 下方向の柔らかい影
        //================================================
        BoxShadow(
          color: Color.fromRGBO(
            92,
            143,
            196,
            0.18,
          ),
          blurRadius: 22,
          spreadRadius: 2,
          offset: Offset(
            0,
            10,
          ),
        ),

        //================================================
        // 近距離の立体影
        //================================================
        BoxShadow(
          color: Color.fromRGBO(
            125,
            170,
            215,
            0.12,
          ),
          blurRadius: 8,
          spreadRadius: 0,
          offset: Offset(
            0,
            3,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isProfit = income >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
      ),
      padding: AppSpacing.card,
      decoration: _buildGlassDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==========================================
          // タイトル
          // ==========================================

          SectionTitle(
            title: '$year年$month月収支',
          ),

          AppSpacing.gapMd,

          // ==========================================
          // 収支
          // ==========================================

          Center(
            child: Text(
              '${isProfit ? '+' : ''}${_format(income)} 円',
              style:
                  AppTextStyles.amountLarge.copyWith(
                color: isProfit
                    ? AppColors.profit
                    : AppColors.loss,
              ),
            ),
          ),

          AppSpacing.gapLg,

          const Divider(
            color: AppColors.divider,
          ),

          AppSpacing.gapMd,

          // ==========================================
          // 投資・回収
          // ==========================================

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  title: '投資',
                  value:
                      '${_format(investment)} 円',
                  color: AppColors.loss,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  title: '回収',
                  value:
                      '${_format(recovery)} 円',
                  color: AppColors.profit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 投資・回収の項目
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.caption,
        ),

        const SizedBox(
          height: 2,
        ),

        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}