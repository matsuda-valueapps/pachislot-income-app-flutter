import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/income_record.dart';
import '../providers/home_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/section_title.dart';
import '../widgets/common/stat_tile.dart';
import '../widgets/search/service_icon.dart';

class AnnualIncomePage extends StatefulWidget {
  const AnnualIncomePage({
    super.key,
  });

  @override
  State<AnnualIncomePage> createState() =>
      _AnnualIncomePageState();
}

class _AnnualIncomePageState
    extends State<AnnualIncomePage> {
  //==================================================
  // State
  //==================================================

  /// 現在選択している年
  late int _selectedYear;

  @override
  void initState() {
    super.initState();

    _selectedYear = DateTime.now().year;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (!mounted) {
          return;
        }

        await context
            .read<HomeProvider>()
            .loadIncomeRecords();
      },
    );
  }

  //==================================================
  // 数値表示
  //==================================================

  /// 3桁区切りで数値を表示する。
  String _formatNumber(int value) {
    return NumberFormat(
      '#,###',
      'ja_JP',
    ).format(value);
  }

  /// 収支表示
  String _formatIncome(int value) {
    final prefix = value > 0 ? '+' : '';

    return '$prefix${_formatNumber(value)} 円';
  }

  //==================================================
  // 年一覧
  //==================================================

  /// 選択可能な年を取得する。
  ///
  /// ・現在年は必ず表示
  /// ・保存済みデータに存在する年もすべて表示
  /// ・同じ年は重複させない
  /// ・新しい年から順番に表示する
  List<int> _availableYears(
    HomeProvider provider,
  ) {
    final years = <int>{
      // 現在年はデータがなくても
      // 必ず選択可能にする。
      DateTime.now().year,
    };

    //================================================
    // 保存済みデータから年を取得
    //================================================

    for (final record in provider.incomeRecords) {
      try {
        final date = DateTime.parse(
          record.date,
        );

        years.add(date.year);
      } catch (_) {
        // 不正な日付は無視
      }
    }

    //================================================
    // 年をListへ変換
    //================================================

    final result = years.toList();

    //================================================
    // 新しい年 → 古い年の順に並べる
    //================================================

    result.sort(
      (a, b) => b.compareTo(a),
    );

    return result;
  }

  //==================================================
  // 年間データ
  //==================================================

  /// 選択した年の収支データを取得する。
  List<IncomeRecord> _yearlyRecords(
    HomeProvider provider,
  ) {
    return provider.incomeRecords
        .where(
          (record) {
            try {
              final date = DateTime.parse(
                record.date,
              );

              return date.year == _selectedYear;
            } catch (_) {
              return false;
            }
          },
        )
        .toList();
  }

  //==================================================
  // 年間集計
  //==================================================

  /// 年間収支
  int _yearlyIncome(
    List<IncomeRecord> records,
  ) {
    return records.fold(
      0,
      (sum, record) => sum + record.profit,
    );
  }

  /// 年間投資
  int _yearlyInvestment(
    List<IncomeRecord> records,
  ) {
    return records.fold(
      0,
      (sum, record) =>
          sum +
          record.medalInvest +
          record.cashInvest,
    );
  }

  /// 年間回収
  int _yearlyRecovery(
    List<IncomeRecord> records,
  ) {
    return records.fold(
      0,
      (sum, record) =>
          sum +
          record.medalReturn +
          record.cashReturn,
    );
  }

  /// 年間遊技回数
  int _yearlyGames(
    List<IncomeRecord> records,
  ) {
    return records.length;
  }

  /// 年間勝利回数
  ///
  /// 収支がプラスになった遊技を勝利として扱う。
  int _yearlyWinGames(
    List<IncomeRecord> records,
  ) {
    return records.where(
      (record) => record.profit > 0,
    ).length;
  }

  /// 年間勝率
  ///
  /// 遊技回数が0の場合は0.0%とする。
  double _yearlyWinRate(
    List<IncomeRecord> records,
  ) {
    final games = _yearlyGames(records);

    if (games == 0) {
      return 0.0;
    }

    final wins = _yearlyWinGames(records);

    return wins / games * 100;
  }

  /// 年間平均収支
  ///
  /// 年間収支 ÷ 年間遊技回数。
  ///
  /// 遊技回数が0の場合は0円とする。
  int _yearlyAverageIncome(
    List<IncomeRecord> records,
  ) {
    final games = _yearlyGames(records);

    if (games == 0) {
      return 0;
    }

    final income = _yearlyIncome(records);

    return (income / games).round();
  }

  //==================================================
  // 月別集計
  //==================================================

  /// 指定した月の収支
  int _monthlyIncome(
    List<IncomeRecord> records,
    int month,
  ) {
    return records
        .where(
          (record) {
            try {
              final date = DateTime.parse(
                record.date,
              );

              return date.month == month;
            } catch (_) {
              return false;
            }
          },
        )
        .fold(
          0,
          (sum, record) => sum + record.profit,
        );
  }

  /// 指定した月の投資
  int _monthlyInvestment(
    List<IncomeRecord> records,
    int month,
  ) {
    return records
        .where(
          (record) {
            try {
              final date = DateTime.parse(
                record.date,
              );

              return date.month == month;
            } catch (_) {
              return false;
            }
          },
        )
        .fold(
          0,
          (sum, record) =>
              sum +
              record.medalInvest +
              record.cashInvest,
        );
  }

  /// 指定した月の回収
  int _monthlyRecovery(
    List<IncomeRecord> records,
    int month,
  ) {
    return records
        .where(
          (record) {
            try {
              final date = DateTime.parse(
                record.date,
              );

              return date.month == month;
            } catch (_) {
              return false;
            }
          },
        )
        .fold(
          0,
          (sum, record) =>
              sum +
              record.medalReturn +
              record.cashReturn,
        );
  }

  /// 指定した月の遊技回数
  int _monthlyGames(
    List<IncomeRecord> records,
    int month,
  ) {
    return records
        .where(
          (record) {
            try {
              final date = DateTime.parse(
                record.date,
              );

              return date.month == month;
            } catch (_) {
              return false;
            }
          },
        )
        .length;
  }

  //==================================================
  // Premium Glass Card
  //==================================================

  /// プレミアムガラスカード
  ///
  /// ホーム画面の年間累計収支カードと
  /// 同じデザイン言語を使用する。
  BoxDecoration _buildGlassDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(
            250,
            253,
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
      borderRadius: AppRadius.card,
      border: Border.all(
        color: const Color.fromRGBO(
          157,
          201,
          246,
          0.78,
        ),
        width: 1.5,
      ),
      boxShadow: const [
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

  //==================================================
  // 年選択
  //==================================================

  Widget _buildYearSelector(
    BuildContext context,
    HomeProvider provider,
  ) {
    final years = _availableYears(provider);

    //================================================
    // 現在の選択年が一覧に存在するか確認
    //================================================

    final selectedYear =
        years.contains(_selectedYear)
            ? _selectedYear
            : years.first;

    //================================================
    // 選択年を補正
    //================================================

    if (_selectedYear != selectedYear) {
      _selectedYear = selectedYear;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: _buildGlassDecoration(),
      child: Row(
        children: [
          //========================================
                  // Googleカレンダー 3Dアイコン
                  //========================================

                  const ServiceIcon(
                    icon: 'google_calendar',
                    size: 38,
                  ),

                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),

          //============================================
          // 表示する年
          //============================================

          Expanded(
            child: Text(
              '表示年を選択',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              )
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          //============================================
          // 年選択Dropdown
          //============================================

          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedYear,
              isDense: true,
              alignment: Alignment.centerRight,
              items: years
                  .map(
                    (year) => DropdownMenuItem<int>(
                      value: year,
                      child: Text(
                        '$year年',
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                if (value == _selectedYear) {
                  return;
                }

                setState(() {
                  _selectedYear = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 年間累計収支カード
  //==================================================

  Widget _buildYearlyIncomeCard(
    BuildContext context,
    List<IncomeRecord> records,
  ) {
    final income = _yearlyIncome(records);

    final investment = _yearlyInvestment(records);

    final recovery = _yearlyRecovery(records);

    final incomeColor =
        income > 0
            ? Colors.green.shade700
            : income < 0
                ? Colors.red.shade700
                : Theme.of(context)
                    .colorScheme
                    .onSurface;

    return Container(
      padding: AppSpacing.card,
      decoration: _buildGlassDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedYear年累計収支',
              style: Theme.of(
                context,
              )
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Center(
              child: Text(
                _formatIncome(income),
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      color: incomeColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            const Divider(),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '年間投資',
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '${_formatNumber(investment)} 円',
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color:
                                  Colors.red.shade700,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '年間回収',
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '${_formatNumber(recovery)} 円',
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color:
                                  Colors.green.shade700,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // 年間統計カード
  //==================================================

  Widget _buildAnnualStatisticsCard(
    BuildContext context,
    List<IncomeRecord> records,
  ) {
    final games = _yearlyGames(records);

    final winGames = _yearlyWinGames(records);

    final winRate = _yearlyWinRate(records);

    final averageIncome =
        _yearlyAverageIncome(records);

    return Container(
      padding: AppSpacing.card,
      decoration: _buildGlassDecoration(),

      //================================================
      // ホーム画面のStatisticsCardと同じ構造にする。
      //
      // 以前はここに
      //
      // Padding(
      //   padding: AppSpacing.md,
      // )
      //
      // が追加されていたため、
      // StatTileの横幅がホーム画面より狭くなっていた。
      //
      // 追加Paddingを削除することで、
      // ホーム画面の「2026年9月統計」と
      // 同じ横幅・同じサイズになる。
      //================================================

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==========================================
          // タイトル
          // ==========================================

          SectionTitle(
            title: '$_selectedYear年統計',
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
                  value: '$games 回',
                  iconAsset:
                      'assets/images/statistics/play_count.png',
                ),
              ),

              AppSpacing.gapMd,

              Expanded(
                child: StatTile(
                  label: '勝利回数',
                  value: '$winGames 回',
                  iconAsset:
                      'assets/images/statistics/win_count.png',
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
                  iconAsset:
                      'assets/images/statistics/win_rate.png',
                  valueColor:
                      AppColors.primary,
                ),
              ),

              AppSpacing.gapMd,

              Expanded(
                child: StatTile(
                  label: '平均収支',
                  valueWidget:
                      _buildAverageIncome(
                    averageIncome,
                  ),
                  iconAsset:
                      'assets/images/statistics/average_profit.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //==================================================
  // 年間平均収支表示
  //==================================================

  /// 年間平均収支を表示する。
  ///
  /// 画面幅が狭い端末でも金額を1行に収める。
  ///
  /// FittedBoxをSizedBoxで横幅いっぱいに広げ、
  /// alignmentをcenterにすることで、
  /// 自動縮小した場合でも常に中央揃えを維持する。
  Widget _buildAverageIncome(
    int averageIncome,
  ) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          '${averageIncome >= 0 ? '+' : ''}'
          '${_formatNumber(averageIncome)}円',
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
      ),
    );
  }

  //==================================================
  // グラフ用最大値・最小値
  //==================================================

  double _calculateChartMaxY(
    List<int> monthlyValues,
  ) {
    final maxValue =
        monthlyValues.fold<double>(
      0,
      (current, value) =>
          math.max(
            current,
            value.abs().toDouble(),
          ),
    );

    if (maxValue == 0) {
      return 10000;
    }

    return maxValue * 1.2;
  }

  double _calculateChartMinY(
    List<int> monthlyValues,
  ) {
    final maxValue =
        monthlyValues.fold<double>(
      0,
      (current, value) =>
          math.max(
            current,
            value.abs().toDouble(),
          ),
    );

    if (maxValue == 0) {
      return -10000;
    }

    return -maxValue * 1.2;
  }

  //==================================================
  // 金額表示
  //==================================================

  String _formatAxisValue(
    double value,
  ) {
    final absValue = value.abs();

    String result;

    if (absValue >= 10000) {
      result =
          '${(absValue / 10000).round()}万';
    } else {
      result = '${absValue.round()}';
    }

    if (value < 0) {
      return '-$result';
    }

    return result;
  }

  //==================================================
  // グラフ端点の目盛り判定
  //==================================================

  /// グラフの最上端・最下端に表示される
  /// 端点ラベルを非表示にする。
  ///
  /// グラフ内部の目盛りのみ表示し、
  /// 境界値そのものは表示しない。
  bool _isChartBoundaryLabel(
    double value,
    double minY,
    double maxY,
  ) {
    const tolerance = 0.001;

    final isMax =
        (value - maxY).abs() <=
            math.max(
              maxY.abs(),
              1,
            ) *
            tolerance;

    final isMin =
        (value - minY).abs() <=
            math.max(
              minY.abs(),
              1,
            ) *
            tolerance;

    return isMax || isMin;
  }

  //==================================================
  // 月別収支横棒グラフ
  //==================================================

  Widget _buildMonthlyBarChart(
    BuildContext context,
    List<IncomeRecord> records,
  ) {
    final monthlyValues =
        List<int>.generate(
      12,
      (index) => _monthlyIncome(
        records,
        index + 1,
      ),
    );

    final maxY =
        _calculateChartMaxY(
      monthlyValues,
    );

    final minY =
        _calculateChartMinY(
      monthlyValues,
    );

    return Container(
      padding: AppSpacing.card,
      decoration: _buildGlassDecoration(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedYear年月別収支',
              style: Theme.of(
                context,
              )
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            SizedBox(
              //================================================
              // グラフ全体の高さ
              //
              // rotationQuarterTurns: 1 により、
              // 横方向のBarChartの12個のグループが
              // 画面上では縦方向に並ぶ。
              //
              // 高さ400により、
              // 1月～12月の上下間隔を確保する。
              //================================================
              height: 400,
              child: BarChart(
                BarChartData(
                  //================================================
                  // 横棒グラフ
                  //================================================
                  //
                  // 90度回転させることで、
                  // 横棒グラフとして表示する。
                  //================================================

                  rotationQuarterTurns: 1,

                  minY: minY,
                  maxY: maxY,

                  baselineY: 0,

                  alignment:
                      BarChartAlignment.spaceAround,

                  //================================================
                  // グリッド
                  //================================================
                  //
                  // rotationQuarterTurns: 1 のため、
                  //
                  // Chart上の「横線」
                  //       ↓ 90度回転
                  // 画面上の「縦線」
                  //
                  // となる。
                  //
                  // 金額目盛りはY軸の値なので、
                  // drawHorizontalLineを使用する。
                  //
                  // 画面上では縦方向の点線として表示される。
                  //
                  // 月ごとの横線は表示しない。
                  //================================================

                  gridData: FlGridData(
                    show: true,

                    //================================================
                    // 画面上で金額目盛りを
                    // 「縦の点線」にするため、
                    // Chart内部では横線を描画する。
                    //================================================

                    drawHorizontalLine: true,

                    // Chart内部の縦線は非表示。
                    drawVerticalLine: false,

                    getDrawingHorizontalLine:
                        (value) {
                      return FlLine(
                        color:
                            const Color.fromRGBO(
                          125,
                          164,
                          194,
                          0.65,
                        ),
                        strokeWidth: 1,
                        dashArray: [
                          8,
                          6,
                        ],
                      );
                    },
                  ),

                  borderData: FlBorderData(
                    show: false,
                  ),

                  //================================================
                  // Tooltip
                  //================================================

                  barTouchData: BarTouchData(
                    enabled: true,

                    touchTooltipData:
                        BarTouchTooltipData(
                      //================================================
                      // Tooltip背景色
                      //================================================

                      getTooltipColor:
                          (group) {
                        return const Color.fromRGBO(
                          185,
                          220,
                          245,
                          0.96,
                        );
                      },

                      tooltipBorderRadius:
                          BorderRadius.circular(
                        8,
                      ),

                      tooltipPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),

                      tooltipMargin: 8,

                      //================================================
                      // 5.0インチ端末でTooltipが
                      // 画面外へはみ出すことを防ぐ。
                      //================================================

                      fitInsideHorizontally: true,
                      fitInsideVertically: true,

                      getTooltipItem: (
                        group,
                        groupIndex,
                        rod,
                        rodIndex,
                      ) {
                        final month =
                            group.x + 1;

                        final value =
                            monthlyValues[
                                group.x];

                        final incomeColor =
                            value > 0
                                ? Colors
                                    .green
                                    .shade800
                                : value < 0
                                    ? Colors
                                        .red
                                        .shade800
                                    : Colors
                                        .black87;

                        return BarTooltipItem(
                          '$month月\n'
                          '${_formatIncome(value)}',
                          TextStyle(
                            color:
                                incomeColor,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ),

                  //================================================
                  // 目盛り
                  //================================================

                  titlesData: FlTitlesData(
                    //================================================
                    // 上側
                    //================================================

                    topTitles:
                        const AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: false,
                      ),
                    ),

                    //================================================
                    // 右側
                    //================================================
                    //
                    // rotationQuarterTurns: 1
                    // により、rightTitlesは画面下側へ
                    // 回転して表示される。
                    //
                    // ここへ金額目盛りを配置する。
                    //================================================

                    rightTitles:
                        AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: true,

                        //================================================
                        // 金額ラベルの領域。
                        //================================================

                        reservedSize: 32,

                        getTitlesWidget: (
                          value,
                          meta,
                        ) {
                          //================================================
                          // グラフ端点ラベルは非表示
                          //================================================

                          if (_isChartBoundaryLabel(
                            value,
                            minY,
                            maxY,
                          )) {
                            return const SizedBox
                                .shrink();
                          }

                          //================================================
                          // 金額ラベル
                          //================================================

                          return SideTitleWidget(
                            meta: meta,
                            space: 4,
                            child: Text(
                              _formatAxisValue(
                                value,
                              ),
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    //================================================
                    // 左側
                    //================================================
                    //
                    // 月表示はbottomTitlesへ設定する。
                    // rotationQuarterTurns: 1 により
                    // 実際の画面では左側へ回転して表示される。
                    //================================================

                    leftTitles:
                        const AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: false,
                      ),
                    ),

                    //================================================
                    // 下側
                    //================================================
                    //
                    // 月表示を設定する。
                    //
                    // rotationQuarterTurns: 1 により、
                    // 実際の画面ではグラフ左側へ
                    // 配置される。
                    //================================================

                    bottomTitles:
                        AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: true,

                        //================================================
                        // 月ラベル用の領域をさらに縮小。
                        //
                        // 22にすることで、
                        // カード左端から月ラベルまでの
                        // 余白を縮める。
                        //================================================

                        reservedSize: 22,

                        getTitlesWidget: (
                          value,
                          meta,
                        ) {
                          final month =
                              value.toInt() +
                                  1;

                          if (month < 1 ||
                              month > 12) {
                            return const SizedBox
                                .shrink();
                          }

                          return SideTitleWidget(
                            meta: meta,

                            //================================================
                            // 月ラベルとグラフとの距離を
                            // できるだけ小さくする。
                            //================================================

                            space: 0,

                            child: Text(
                              '$month月',
                              maxLines: 1,
                              softWrap: false,
                              style:
                                  const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  //================================================
                  // 棒グラフ
                  //================================================

                  barGroups:
                      List.generate(
                    12,
                    (index) {
                      final value =
                          monthlyValues[
                              index];

                      final rodColor =
                          value > 0
                              ? Colors
                                  .green
                                  .shade600
                              : value < 0
                                  ? Colors
                                      .red
                                      .shade600
                                  : Theme.of(
                                      context,
                                    )
                                      .colorScheme
                                      .outlineVariant;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value
                                .toDouble(),

                            // 横棒の太さ
                            width: 16,

                            color: rodColor,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              4,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // 月別収支一覧
  //==================================================

  Widget _buildMonthlyIncomeList(
    BuildContext context,
    List<IncomeRecord> records,
  ) {
    return Container(
      padding: AppSpacing.card,
      decoration: _buildGlassDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedYear年月別収支一覧',
              style: Theme.of(
                context,
              )
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: 12,
              separatorBuilder:
                  (context, index) =>
                      const Divider(
                height: 1,
              ),
              itemBuilder:
                  (context, index) {
                final month = index + 1;

                final income =
                    _monthlyIncome(
                  records,
                  month,
                );

                final investment =
                    _monthlyInvestment(
                  records,
                  month,
                );

                final recovery =
                    _monthlyRecovery(
                  records,
                  month,
                );

                final games =
                    _monthlyGames(
                  records,
                  month,
                );

                final incomeColor =
                    income > 0
                        ? Colors
                            .green
                            .shade700
                        : income < 0
                            ? Colors
                                .red
                                .shade700
                            : Theme.of(
                                context,
                              )
                                .colorScheme
                                .onSurface;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical:
                        AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 48,
                            child: Text(
                              '$month月',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              _formatIncome(
                                income,
                              ),
                              textAlign:
                                  TextAlign.right,
                              style:
                                  TextStyle(
                                color:
                                    incomeColor,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Row(
                        children: [
                          //================================================
                          // 投資
                          //
                          // FittedBox + scaleDown により、
                          // 5.0インチ端末など横幅が狭い場合でも
                          // 文字を自動縮小して必ず1行に収める。
                          //================================================
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment:
                                  Alignment.centerLeft,
                              child: Text(
                                '投資${_formatNumber(investment)}円',
                                maxLines: 1,
                                softWrap: false,
                                style:
                                    Theme.of(
                                  context,
                                )
                                        .textTheme
                                        .bodySmall,
                              ),
                            ),
                          ),

                          //================================================
                          // 回収
                          //
                          // 「回収1,022,000円」のように
                          // 金額が大きくなった場合でも
                          // 2行にならないようにする。
                          //================================================
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment:
                                  Alignment.center,
                              child: Text(
                                '回収${_formatNumber(recovery)}円',
                                maxLines: 1,
                                softWrap: false,
                                style:
                                    Theme.of(
                                  context,
                                )
                                        .textTheme
                                        .bodySmall,
                              ),
                            ),
                          ),

                          //================================================
                          // 遊技回数
                          //
                          // こちらも念のため1行固定。
                          //================================================
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment:
                                  Alignment.centerRight,
                              child: Text(
                                '$games回',
                                maxLines: 1,
                                softWrap: false,
                                style:
                                    Theme.of(
                                  context,
                                )
                                        .textTheme
                                        .bodySmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider =
        context.watch<HomeProvider>();

    final records =
        _yearlyRecords(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '年間収支グラフ',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: AppSpacing.page,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    //================================
                    // 年選択
                    //================================

                    _buildYearSelector(
                      context,
                      provider,
                    ),

                    AppSpacing.gapLg,

                    //================================
                    // 年間累計収支
                    //================================

                    _buildYearlyIncomeCard(
                      context,
                      records,
                    ),

                    AppSpacing.gapLg,

                    //================================
                    // 月別収支横棒グラフ
                    //================================

                    _buildMonthlyBarChart(
                      context,
                      records,
                    ),

                    AppSpacing.gapLg,

                    //================================
                    // 年間統計
                    //================================

                    _buildAnnualStatisticsCard(
                      context,
                      records,
                    ),

                    AppSpacing.gapLg,

                    //================================
                    // 月別収支一覧
                    //================================

                    _buildMonthlyIncomeList(
                      context,
                      records,
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}