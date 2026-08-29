import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/income_record.dart';
import '../providers/home_provider.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/action_button_icon.dart';
import '../widgets/search/service_icon.dart';
import 'income_detail_page.dart';

class IncomeListPage extends StatefulWidget {
  const IncomeListPage({super.key});

  @override
  State<IncomeListPage> createState() =>
      _IncomeListPageState();
}

class _IncomeListPageState
    extends State<IncomeListPage> {
  //==================================================
  // Controller
  //==================================================

  /// キーワード検索
  final TextEditingController
      _searchController =
      TextEditingController();

  //==================================================
  // キーワード検索
  //==================================================

  /// 現在の検索キーワード
  String _searchQuery = '';

  //==================================================
  // 日付フィルター
  //==================================================

  /// 絞り込み開始日
  DateTime? _filterStartDate;

  /// 絞り込み終了日
  DateTime? _filterEndDate;

  //==================================================
  // 収支フィルター
  //==================================================

  /// 収支絞り込み
  ///
  /// all    → すべて
  /// profit → プラス収支
  /// loss   → マイナス収支
  /// zero   → 収支0円
  String _profitFilter = 'all';

  //==================================================
  // 初期化
  //==================================================

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

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  //==================================================
  // 詳細画面
  //==================================================

  /// 詳細画面を開く
  Future<void> _openDetail(
    IncomeRecord record,
  ) async {
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
  }

  //==================================================
  // キーワード検索
  //==================================================

  /// 検索キーワードを変更する。
  void _onSearchChanged(
    String value,
  ) {
    setState(() {
      _searchQuery =
          value.trim().toLowerCase();
    });
  }

  //==================================================
  // 検索・フィルター
  //==================================================

  /// 検索条件に一致する収支データを取得する。
  ///
  /// 検索対象：
  /// ・ホール名
  /// ・機種名
  /// ・メモ
  ///
  /// フィルター対象：
  /// ・日付
  /// ・収支
  ///
  /// キーワード・日付・収支は
  /// すべて同時に適用する。
  List<IncomeRecord> _filterRecords(
    List<IncomeRecord> records,
  ) {
    return records.where((record) {
      //==============================================
      // キーワード検索
      //==============================================

      if (_searchQuery.isNotEmpty) {
        final hall =
            record.hall.toLowerCase();

        final machine =
            record.machine.toLowerCase();

        final memo =
            record.memo.toLowerCase();

        final matchesKeyword =
            hall.contains(
                  _searchQuery,
                ) ||
                machine.contains(
                  _searchQuery,
                ) ||
                memo.contains(
                  _searchQuery,
                );

        if (!matchesKeyword) {
          return false;
        }
      }

      //==============================================
      // 日付フィルター
      //==============================================

      if (_filterStartDate != null ||
          _filterEndDate != null) {
        DateTime? recordDate;

        try {
          recordDate =
              DateTime.parse(
            record.date,
          );
        } catch (_) {
          return false;
        }

        // 日付だけで比較するため、
        // 時刻を00:00:00へ統一する。
        final date = DateTime(
          recordDate.year,
          recordDate.month,
          recordDate.day,
        );

        //============================================
        // 開始日
        //============================================

        if (_filterStartDate != null) {
          final startDate =
              DateTime(
            _filterStartDate!.year,
            _filterStartDate!.month,
            _filterStartDate!.day,
          );

          if (date.isBefore(startDate)) {
            return false;
          }
        }

        //============================================
        // 終了日
        //============================================

        if (_filterEndDate != null) {
          final endDate =
              DateTime(
            _filterEndDate!.year,
            _filterEndDate!.month,
            _filterEndDate!.day,
          );

          if (date.isAfter(endDate)) {
            return false;
          }
        }
      }

      //==============================================
      // 収支フィルター
      //==============================================

      switch (_profitFilter) {
        case 'profit':
          // プラス収支
          if (record.profit <= 0) {
            return false;
          }
          break;

        case 'loss':
          // マイナス収支
          if (record.profit >= 0) {
            return false;
          }
          break;

        case 'zero':
          // 収支0円
          if (record.profit != 0) {
            return false;
          }
          break;

        case 'all':
        default:
          break;
      }

      return true;
    }).toList();
  }

  /// 検索欄をクリアする。
  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  //==================================================
  // 日付表示
  //==================================================

  /// 日付表示
  ///
  /// YYYY-MM-DD形式の日付を
  /// YYYY年M月D日(曜日)形式へ変換する。
  ///
  /// 例：
  ///
  /// 2026-08-12
  /// ↓
  /// 2026年8月12日(水)
  String _formatDate(
    String date,
  ) {
    try {
      final parsedDate =
          DateTime.parse(date);

      const weekdays = [
        '月',
        '火',
        '水',
        '木',
        '金',
        '土',
        '日',
      ];

      final weekday =
          weekdays[parsedDate.weekday - 1];

      return '${parsedDate.year}年'
          '${parsedDate.month}月'
          '${parsedDate.day}日'
          '($weekday)';
    } catch (_) {
      return date;
    }
  }

  /// フィルター用の日付表示
  String _formatFilterDate(
    DateTime? date,
  ) {
    if (date == null) {
      return '指定なし';
    }

    return '${date.year}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }

  //==================================================
  // 金額表示
  //==================================================

  /// 金額表示
  String _formatAmount(
    int amount,
  ) {
    final absoluteAmount =
        amount.abs().toString();

    final buffer =
        StringBuffer();

    for (int i = 0;
        i < absoluteAmount.length;
        i++) {
      final position =
          absoluteAmount.length - i;

      buffer.write(
        absoluteAmount[i],
      );

      if (position > 1 &&
          position % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  //==================================================
  // 収支表示
  //==================================================

  /// 収支表示
  String _formatProfit(
    int profit,
  ) {
    if (profit > 0) {
      return '+${_formatAmount(profit)}円';
    }

    if (profit < 0) {
      return '-${_formatAmount(profit)}円';
    }

    return '0円';
  }

  //==================================================
  // 収支カラー
  //==================================================

  Color _profitColor(
    BuildContext context,
    int profit,
  ) {
    if (profit > 0) {
      return Colors.green.shade700;
    }

    if (profit < 0) {
      return Colors.red.shade700;
    }

    return Theme.of(context)
        .colorScheme
        .onSurfaceVariant;
  }

  //==================================================
  // プレミアムガラスカード
  //==================================================

  /// 月間収支カードと同じ
  /// プレミアムガラスカード用Decoration。
  ///
  /// ・白
  /// ・ごく薄いブルー
  /// ・薄いブルー
  /// のグラデーションを使用する。
  ///
  /// 月間収支カードと同じデザイン言語に
  /// 統一するため、色・Border・Shadowを
  /// 月間収支カードと同一仕様にしている。
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

      // 月間収支カードと同じ角丸
      borderRadius: AppRadius.card,

      // 月間収支カードと同じ薄いブルーBorder
      border: Border.all(
        color: const Color.fromRGBO(
          157,
          201,
          246,
          0.78,
        ),
        width: 1.5,
      ),

      // 月間収支カードと同じ柔らかい立体影
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

  //==================================================
  // 検索欄
  //==================================================

  /// キーワード検索欄
  Widget _buildSearchField(
    BuildContext context,
  ) {
    return TextField(
      controller:
          _searchController,
      onChanged:
          _onSearchChanged,
      textInputAction:
          TextInputAction.search,
      decoration:
          InputDecoration(
        hintText:
            'ホール名・機種名・メモを検索',
        prefixIcon:
            const Icon(
          Icons.search,
        ),
        suffixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed:
                        _clearSearch,
                    icon:
                        const Icon(
                      Icons.clear,
                    ),
                  )
                : null,
        filled: true,
        fillColor:
            Theme.of(context)
                .colorScheme
                .surface,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outline,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outline,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              BorderSide(
            color: Theme.of(context)
                .colorScheme
                .primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal:
              AppSpacing.md,
          vertical:
              AppSpacing.md,
        ),
      ),
    );
  }

  //==================================================
  // フィルター状態
  //==================================================

  /// 日付・収支フィルターが
  /// 設定されているか。
  bool get _hasFilter {
    return _filterStartDate != null ||
        _filterEndDate != null ||
        _profitFilter != 'all';
  }

  /// 収支フィルター表示名
  String _profitFilterLabel() {
    switch (_profitFilter) {
      case 'profit':
        return 'プラス収支';

      case 'loss':
        return 'マイナス収支';

      case 'zero':
        return '収支0円';

      case 'all':
      default:
        return 'すべて';
    }
  }

  //==================================================
  // フィルター
  //==================================================

  /// 日付・収支フィルターを開く。
  Future<void> _showFilterSheet() async {
    DateTime? tempStartDate =
        _filterStartDate;

    DateTime? tempEndDate =
        _filterEndDate;

    String tempProfitFilter =
        _profitFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder:
              (
            context,
            setSheetState,
          ) {
            return SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(
                  AppSpacing.page.left,
                  AppSpacing.lg,
                  AppSpacing.page.right,
                  MediaQuery.of(
                    context,
                  ).viewInsets.bottom +
                      AppSpacing.lg,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: [
                      //========================================
                      // タイトル
                      //========================================

                      Row(
                        children: [
                          ActionButtonIcon.filter(
                            size: 38.0,
                          ),

                          const SizedBox(
                            width:
                                AppSpacing.sm,
                          ),

                          Expanded(
                            child: Text(
                              '日付・収支で絞り込み',
                              style:
                                  Theme.of(
                                context,
                              )
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.of(
                                sheetContext,
                              ).pop();
                            },
                            icon:
                                const Icon(
                              Icons.close,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.lg,
                      ),

                      //========================================
                      // 日付
                      //========================================

                      Text(
                        '日付',
                        style:
                            Theme.of(
                          context,
                        )
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.sm,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed: () async {
                                final picked =
                                    await showDatePicker(
                                  context:
                                      context,
                                  initialDate:
                                      tempStartDate ??
                                          tempEndDate ??
                                          DateTime.now(),
                                  firstDate:
                                      DateTime(
                                    2020,
                                  ),
                                  lastDate:
                                      DateTime(
                                    2100,
                                  ),
                                  locale:
                                      const Locale(
                                    'ja',
                                    'JP',
                                  ),
                                );

                                if (picked ==
                                    null) {
                                  return;
                                }

                                setSheetState(
                                  () {
                                    tempStartDate =
                                        picked;

                                    // 開始日が終了日より
                                    // 後にならないようにする。
                                    if (tempEndDate !=
                                            null &&
                                        tempEndDate!
                                            .isBefore(
                                          picked,
                                        )) {
                                      tempEndDate =
                                          picked;
                                    }
                                  },
                                );
                              },
                              icon: const ServiceIcon(
                                icon: 'google_calendar',
                                size: 36,
                              ),
                              label: Text(
                                _formatFilterDate(
                                  tempStartDate,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width:
                                AppSpacing.sm,
                          ),

                          const Text(
                            '～',
                          ),

                          const SizedBox(
                            width:
                                AppSpacing.sm,
                          ),

                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed: () async {
                                final picked =
                                    await showDatePicker(
                                  context:
                                      context,
                                  initialDate:
                                      tempEndDate ??
                                          tempStartDate ??
                                          DateTime.now(),
                                  firstDate:
                                      tempStartDate ??
                                          DateTime(
                                        2020,
                                      ),
                                  lastDate:
                                      DateTime(
                                    2100,
                                  ),
                                  locale:
                                      const Locale(
                                    'ja',
                                    'JP',
                                  ),
                                );

                                if (picked ==
                                    null) {
                                  return;
                                }

                                setSheetState(
                                  () {
                                    tempEndDate =
                                        picked;
                                  },
                                );
                              },
                              icon: const ServiceIcon(
                                icon: 'google_calendar',
                                size: 36,
                              ),
                              label: Text(
                                _formatFilterDate(
                                  tempEndDate,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.xs,
                      ),

                      //========================================
                      // 日付クリア
                      //========================================

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child:
                            TextButton(
                          onPressed: () {
                            setSheetState(
                              () {
                                tempStartDate =
                                    null;
                                tempEndDate =
                                    null;
                              },
                            );
                          },
                          child:
                              const Text(
                            'クリア',
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.md,
                      ),

                      //========================================
                      // 収支
                      //========================================

                      Text(
                        '収支',
                        style:
                            Theme.of(
                          context,
                        )
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.sm,
                      ),

                      RadioGroup<String>(
                        groupValue:
                            tempProfitFilter,
                        onChanged:
                            (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setSheetState(
                            () {
                              tempProfitFilter =
                                  value;
                            },
                          );
                        },
                        child: Column(
                          children: [
                            RadioListTile<
                                String>(
                              value:
                                  'all',
                              title:
                                  const Text(
                                'すべて',
                              ),
                              contentPadding:
                                  EdgeInsets.zero,
                            ),
                            RadioListTile<
                                String>(
                              value:
                                  'profit',
                              title:
                                  const Text(
                                'プラス収支',
                              ),
                              subtitle:
                                  const Text(
                                '収支が0円より大きいデータ',
                              ),
                              contentPadding:
                                  EdgeInsets.zero,
                            ),
                            RadioListTile<
                                String>(
                              value:
                                  'loss',
                              title:
                                  const Text(
                                'マイナス収支',
                              ),
                              subtitle:
                                  const Text(
                                '収支が0円より小さいデータ',
                              ),
                              contentPadding:
                                  EdgeInsets.zero,
                            ),
                            RadioListTile<
                                String>(
                              value:
                                  'zero',
                              title:
                                  const Text(
                                '収支0円',
                              ),
                              contentPadding:
                                  EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.lg,
                      ),

                      //========================================
                      // ボタン
                      //========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton(
                              onPressed: () {
                                setState(
                                  () {
                                    _filterStartDate =
                                        null;
                                    _filterEndDate =
                                        null;
                                    _profitFilter =
                                        'all';
                                  },
                                );

                                Navigator.of(
                                  sheetContext,
                                ).pop();
                              },
                              child:
                                  const Text(
                                'クリア',
                              ),
                            ),
                          ),

                          const SizedBox(
                            width:
                                AppSpacing.md,
                          ),

                          Expanded(
                            child:
                                FilledButton(
                              onPressed: () {
                                setState(
                                  () {
                                    _filterStartDate =
                                        tempStartDate;
                                    _filterEndDate =
                                        tempEndDate;
                                    _profitFilter =
                                        tempProfitFilter;
                                  },
                                );

                                Navigator.of(
                                  sheetContext,
                                ).pop();
                              },
                              child:
                                  const Text(
                                '適用',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //==================================================
  // 検索結果件数
  //==================================================

  /// 検索結果件数
  Widget _buildResultCount(
    BuildContext context,
    int count,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
      ),
      child: Text(
        '検索結果：$count件',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
              fontWeight:
                  FontWeight.w600,
            ),
      ),
    );
  }

  //==================================================
  // フィルターボタン
  //==================================================

  /// 日付・収支フィルターボタン
  Widget _buildFilterButton(
    BuildContext context,
  ) {
    return Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal:
            AppSpacing.page.left,
      ),
      child: OutlinedButton(
        onPressed:
            _showFilterSheet,
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            ActionButtonIcon.filter(
              size: 38.0,
            ),

            const SizedBox(
              width:
                  AppSpacing.sm,
            ),

            Text(
              _hasFilter
                  ? '日付・収支で絞り込み中'
                  : '日付・収支で絞り込み',
            ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // フィルター条件表示
  //==================================================

  /// 現在のフィルター条件を表示する。
  Widget _buildFilterSummary(
    BuildContext context,
  ) {
    if (!_hasFilter) {
      return const SizedBox.shrink();
    }

    final dateText =
        _filterStartDate == null &&
                _filterEndDate == null
            ? '日付：すべて'
            : '日付：'
                '${_formatFilterDate(_filterStartDate)}'
                ' ～ '
                '${_formatFilterDate(_filterEndDate)}';

    return Padding(
      padding:
          const EdgeInsets.only(
        top: AppSpacing.md,
      ),
      child: Text(
        '$dateText  収支：${_profitFilterLabel()}',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
        textAlign:
            TextAlign.center,
      ),
    );
  }

  //==================================================
  // 1件分の収支データカード
  //==================================================

  Widget _buildIncomeCard(
    BuildContext context,
    IncomeRecord record,
  ) {
    final profitColor =
        _profitColor(
      context,
      record.profit,
    );

    return Container(
      decoration:
          _buildGlassDecoration(),
      child: ClipRRect(
        borderRadius:
            AppRadius.card,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                _openDetail(record),
            borderRadius:
                AppRadius.card,
            child: Padding(
              padding:
                  const EdgeInsets.all(
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  //==========================================
                  // 日付
                  //==========================================

                  Center(
                    child: Text(
                      _formatDate(record.date),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.sm,
                  ),

                  //==========================================
                  // ホール名
                  //==========================================

                  if (record.hall.isNotEmpty)
                    Center(
                      child: Text(
                        record.hall,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                      ),
                    ),

                  //==========================================
                  // 機種名
                  //==========================================

                  if (record.machine.isNotEmpty) ...[
                    const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    Center(
                      child: Text(
                        record.machine,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                      ),
                    ),
                  ],

                  const SizedBox(
                    height:
                        AppSpacing.md,
                  ),

                  const Divider(),

                  const SizedBox(
                    height:
                        AppSpacing.sm,
                  ),

                  //==========================================
                  // 投資・回収・収支
                  //==========================================

                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildAmountColumn(
                          context,
                          label: '投資',
                          amount:
                              record.medalInvest +
                                  record.cashInvest,
                          color:
                              Colors.red.shade700,
                        ),
                      ),

                      Expanded(
                        child:
                            _buildAmountColumn(
                          context,
                          label: '回収',
                          amount:
                              record.medalReturn +
                                  record.cashReturn,
                          color:
                              Colors.green.shade700,
                        ),
                      ),

                      Expanded(
                        child:
                            _buildAmountColumn(
                          context,
                          label: '収支',
                          amount:
                              record.profit,
                          profitColor:
                              profitColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //==================================================
  // 金額表示用Column
  //==================================================

  Widget _buildAmountColumn(
    BuildContext context, {
    required String label,
    required int amount,
    Color? color,
    Color? profitColor,
  }) {
    final displayColor =
        profitColor ??
            color ??
            Theme.of(context)
                .colorScheme
                .onSurface;

    final displayAmount =
        label == '収支'
            ? _formatProfit(amount)
            : '${_formatAmount(amount)}円';

    return Column(
      children: [
        Text(
          label,
          style:
              Theme.of(context)
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
          height:
              AppSpacing.xs,
        ),

        //==============================================
        // 金額
        //==============================================

        Text(
          displayAmount,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          softWrap: false,
          textAlign:
              TextAlign.center,
          style:
              Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    color:
                        displayColor,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
        ),
      ],
    );
  }

  //==================================================
  // 空データ表示
  //==================================================

  Widget _buildEmptyView(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),

            const SizedBox(
              height:
                  AppSpacing.md,
            ),

            Text(
              '保存データがありません',
              style:
                  Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
            ),

            const SizedBox(
              height:
                  AppSpacing.sm,
            ),

            Text(
              '入力画面からデータを保存すると、\n'
              'ここに表示されます。',
              textAlign:
                  TextAlign.center,
              style:
                  Theme.of(context)
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
          ],
        ),
      ),
    );
  }

  //==================================================
  // 検索結果なし
  //==================================================

  Widget _buildNoSearchResultView(
    BuildContext context,
  ) {
    return ListView(
      padding:
          const EdgeInsets.all(
        AppSpacing.xl,
      ),
      children: [
        const SizedBox(
          height:
              AppSpacing.xl,
        ),

        Icon(
          Icons.search_off_rounded,
          size: 64,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),

        const SizedBox(
          height:
              AppSpacing.md,
        ),

        Text(
          '検索結果がありません',
          textAlign:
              TextAlign.center,
          style:
              Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
        ),

        const SizedBox(
          height:
              AppSpacing.sm,
        ),

        Text(
          '別のキーワード・条件で検索してください。',
          textAlign:
              TextAlign.center,
          style:
              Theme.of(context)
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
      ],
    );
  }

  //==================================================
  // エラー表示
  //==================================================

  Widget _buildErrorView(
    BuildContext context,
    String message,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),

            const SizedBox(
              height:
                  AppSpacing.md,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  Theme.of(context)
                      .textTheme
                      .bodyLarge,
            ),

            const SizedBox(
              height:
                  AppSpacing.md,
            ),

            FilledButton(
              onPressed: () async {
                final provider =
                    context.read<
                        HomeProvider>();

                await provider.refresh();
              },
              child: const Text(
                '再読み込み',
              ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '収支 Data 一覧',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(
          context,
          provider,
        ),
      ),
    );
  }

  //==================================================
  // 本文
  //==================================================

  Widget _buildBody(
    BuildContext context,
    HomeProvider provider,
  ) {
    //==========================================
    // 読み込み中
    //==========================================

    if (provider.isLoading &&
        !provider.hasData) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    //==========================================
    // エラー
    //==========================================

    if (provider.errorMessage != null &&
        !provider.hasData) {
      return _buildErrorView(
        context,
        provider.errorMessage!,
      );
    }

    //==========================================
    // データなし
    //==========================================

    if (!provider.hasData) {
      return _buildEmptyView(
        context,
      );
    }

    //==========================================
    // 検索・フィルター結果
    //==========================================

    final filteredRecords =
        _filterRecords(
      provider.incomeRecords,
    );

    //==========================================
    // 検索結果一覧
    //==========================================

    return Column(
      children: [
        //========================================
        // 検索欄
        //========================================

        Padding(
          padding:
              EdgeInsets.fromLTRB(
            AppSpacing.page.left,
            AppSpacing.page.top,
            AppSpacing.page.right,
            0,
          ),
          child: _buildSearchField(
            context,
          ),
        ),

        const SizedBox(
          height:
              AppSpacing.sm,
        ),

        //========================================
        // 検索結果件数
        //========================================

        Align(
          alignment:
              Alignment.centerLeft,
          child: Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal:
                  AppSpacing.page.left,
            ),
            child:
                _buildResultCount(
              context,
              filteredRecords.length,
            ),
          ),
        ),

        const SizedBox(
          height:
              AppSpacing.sm,
        ),

        //========================================
        // 日付・収支フィルター
        //========================================

        _buildFilterButton(
          context,
        ),

        _buildFilterSummary(
          context,
        ),

        const SizedBox(
          height:
              AppSpacing.sm,
        ),

        //========================================
        // 検索結果
        //========================================

        Expanded(
          child:
              filteredRecords.isEmpty
                  ? _buildNoSearchResultView(
                      context,
                    )
                  : RefreshIndicator(
                      onRefresh:
                          provider.refresh,
                      child:
                          ListView.separated(
                        padding:
                            EdgeInsets.fromLTRB(
                          AppSpacing.page.left,
                          AppSpacing.page.top,
                          AppSpacing.page.right,
                          AppSpacing.page.bottom,
                        ),
                        itemCount:
                            filteredRecords.length,
                        separatorBuilder:
                            (
                          context,
                          index,
                        ) =>
                                AppSpacing.gapMd,
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final record =
                              filteredRecords[
                                  index];

                          return _buildIncomeCard(
                            context,
                            record,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}