import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/counter_record.dart';
import '../services/database_service.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/action_button_icon.dart';
import '../widgets/search/service_icon.dart';
import 'counter_detail_page.dart';

class CounterListPage extends StatefulWidget {
  const CounterListPage({
    super.key,
  });

  @override
  State<CounterListPage> createState() =>
      _CounterListPageState();
}

class _CounterListPageState
    extends State<CounterListPage> {
  //==================================================
  // データ
  //==================================================

  List<CounterRecord> _records = [];

  bool _isLoading = true;

  //==================================================
  // Controller
  //==================================================

  /// タイトル検索
  final TextEditingController
      _searchController =
      TextEditingController();

  //==================================================
  // キーワード検索
  //==================================================

  /// 現在の検索キーワード
  String _searchQuery = '';

  //==================================================
  // 日付絞り込み
  //==================================================

  /// 絞り込み開始日
  DateTime? _filterStartDate;

  /// 絞り込み終了日
  DateTime? _filterEndDate;

  //==================================================
  // 初期化
  //==================================================

  @override
  void initState() {
    super.initState();

    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  //==================================================
  // SQLite
  //==================================================

  /// 保存済み小役データを取得
  Future<void> _loadRecords() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final records =
          await DatabaseService.instance
              .getCounterRecords();

      if (!mounted) {
        return;
      }

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _records = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'データの取得に失敗しました。',
          ),
        ),
      );
    }
  }

  //==================================================
  // 詳細画面
  //==================================================

  /// 詳細画面を開く
  Future<void> _openDetail(
    CounterRecord record,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CounterDetailPage(
          record: record,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    //================================================
    // 詳細画面から戻ってきた
    //================================================
    //
    // 編集・削除が行われている可能性があるため、
    // SQLiteから最新データを再取得する。
    //================================================

    await _loadRecords();
  }

  //==================================================
  // 日付表示
  //==================================================

  /// 「2026年8月18日(火)」形式
  String _formatDate(
    String date,
  ) {
    try {
      final parsedDate =
          DateTime.parse(date);

      return DateFormat(
        'yyyy年M月d日(E)',
        'ja_JP',
      ).format(parsedDate);
    } catch (_) {
      return date;
    }
  }

  //==================================================
  // 日付表示
  //==================================================

  /// 絞り込み条件用の日付を
  /// YYYY/MM/DD形式で表示する。
  String _formatFilterDate(
    DateTime date,
  ) {
    return '${date.year}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }

  //==================================================
  // 数値表示
  //==================================================

  /// 3桁区切り
  String _formatNumber(
    int value,
  ) {
    return NumberFormat(
      '#,###',
      'ja_JP',
    ).format(value);
  }

  //==================================================
  // 小役合計
  //==================================================

  int _totalCount(
    CounterRecord record,
  ) {
    return record.cherry +
        record.bell +
        record.suika +
        record.grape +
        record.chance;
  }

  //==================================================
  // 検索
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

  /// 検索欄をクリアする。
  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  //==================================================
  // 日付絞り込み
  //==================================================

  /// 日付絞り込み中かどうか。
  bool get _hasDateFilter {
    return _filterStartDate != null ||
        _filterEndDate != null;
  }

  /// 日付を日単位に正規化する。
  DateTime _dateOnly(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  /// 小役データの日付をDateTimeへ変換する。
  DateTime? _parseRecordDate(
    String date,
  ) {
    try {
      return _dateOnly(
        DateTime.parse(date),
      );
    } catch (_) {
      return null;
    }
  }

  /// 日付絞り込みダイアログを表示する。
  Future<void> _showDateFilterDialog() async {
    DateTime? tempStartDate =
        _filterStartDate;

    DateTime? tempEndDate =
        _filterEndDate;

    final result =
        await showDialog<
            Map<String, DateTime?>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              scrollable: true,
              title: Row(
                children: [
                  //========================================
                  // 3D漏斗アイコン
                  //========================================

                  const ActionButtonIcon.filter(
                    size: 38.0,
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  //========================================
                  // タイトル
                  //========================================

                  const Expanded(
                    child: Text(
                      '日付で絞り込み',
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  //========================================
                  // 開始日
                  //========================================

                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading:
                        const ServiceIcon(
                      icon: 'google_calendar',
                      size: 36,
                    ),
                    title: const Text(
                      '開始日',
                    ),
                    subtitle: Text(
                      tempStartDate == null
                          ? '指定なし'
                          : _formatFilterDate(
                              tempStartDate!,
                            ),
                    ),
                    trailing: tempStartDate != null
                        ? IconButton(
                            onPressed: () {
                              setDialogState(() {
                                tempStartDate =
                                    null;
                              });
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,
                    onTap: () async {
                      final initialDate =
                          tempStartDate ??
                              tempEndDate ??
                              DateTime.now();

                      final pickedDate =
                          await showDatePicker(
                        context:
                            dialogContext,
                        initialDate:
                            initialDate,
                        firstDate:
                            DateTime(2020),
                        lastDate:
                            DateTime(2100),
                        locale:
                            const Locale(
                          'ja',
                          'JP',
                        ),
                      );

                      if (pickedDate ==
                          null) {
                        return;
                      }

                      setDialogState(() {
                        tempStartDate =
                            _dateOnly(
                          pickedDate,
                        );
                      });
                    },
                  ),

                  const Divider(),

                  //========================================
                  // 終了日
                  //========================================

                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading:
                        const ServiceIcon(
                      icon: 'google_calendar',
                      size: 36,
                    ),
                    title: const Text(
                      '終了日',
                    ),
                    subtitle: Text(
                      tempEndDate == null
                          ? '指定なし'
                          : _formatFilterDate(
                              tempEndDate!,
                            ),
                    ),
                    trailing: tempEndDate != null
                        ? IconButton(
                            onPressed: () {
                              setDialogState(() {
                                tempEndDate =
                                    null;
                              });
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,
                    onTap: () async {
                      final initialDate =
                          tempEndDate ??
                              tempStartDate ??
                              DateTime.now();

                      final pickedDate =
                          await showDatePicker(
                        context:
                            dialogContext,
                        initialDate:
                            initialDate,
                        firstDate:
                            DateTime(2020),
                        lastDate:
                            DateTime(2100),
                        locale:
                            const Locale(
                          'ja',
                          'JP',
                        ),
                      );

                      if (pickedDate ==
                          null) {
                        return;
                      }

                      setDialogState(() {
                        tempEndDate =
                            _dateOnly(
                          pickedDate,
                        );
                      });
                    },
                  ),
                ],
              ),

              actions: [
                //========================================
                // ボタン
                //========================================

                Row(
                  children: [
                    //======================================
                    // キャンセル
                    //======================================

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(
                            0,
                            48,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'キャンセル',
                          maxLines: 1,
                          softWrap: false,
                          overflow:
                              TextOverflow.ellipsis,
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    //======================================
                    // 適用
                    //======================================

                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // 開始日と終了日が逆の場合は
                          // 適用しない。
                          if (tempStartDate !=
                                  null &&
                              tempEndDate !=
                                  null &&
                              tempStartDate!
                                  .isAfter(
                                tempEndDate!,
                              )) {
                            ScaffoldMessenger
                                .of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '開始日は終了日以前の日付を指定してください。',
                                ),
                              ),
                            );

                            return;
                          }

                          Navigator.pop(
                            dialogContext,
                            {
                              'start':
                                  tempStartDate,
                              'end':
                                  tempEndDate,
                            },
                          );
                        },
                        style:
                            FilledButton.styleFrom(
                          minimumSize:
                              const Size(
                            0,
                            48,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          '適用',
                          maxLines: 1,
                          softWrap: false,
                          overflow:
                              TextOverflow.ellipsis,
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _filterStartDate =
          result['start'];
      _filterEndDate =
          result['end'];
    });
  }

  /// 日付絞り込みを解除する。
  void _clearDateFilter() {
    setState(() {
      _filterStartDate = null;
      _filterEndDate = null;
    });
  }

  //==================================================
  // 絞り込み
  //==================================================

  /// タイトル＋日付条件に一致する
  /// 小役データを取得する。
  ///
  /// 条件：
  ///
  /// ・タイトルにキーワードを含む
  /// ・指定された日付範囲内
  ///
  /// 複数条件を指定した場合はAND条件。
  List<CounterRecord> _filterRecords(
    List<CounterRecord> records,
  ) {
    return records.where((record) {
      //==============================================
      // タイトル条件
      //==============================================

      if (_searchQuery.isNotEmpty) {
        final title =
            record.title
                .toLowerCase();

        if (!title.contains(
          _searchQuery,
        )) {
          return false;
        }
      }

      //==============================================
      // 日付条件
      //==============================================

      final recordDate =
          _parseRecordDate(
        record.date,
      );

      if (_filterStartDate != null) {
        if (recordDate == null ||
            recordDate.isBefore(
              _filterStartDate!,
            )) {
          return false;
        }
      }

      if (_filterEndDate != null) {
        if (recordDate == null ||
            recordDate.isAfter(
              _filterEndDate!,
            )) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  //==================================================
  // 検索欄
  //==================================================

  /// タイトル検索欄
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
            'タイトルを検索',
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
  // 検索結果件数
  //==================================================

  /// 検索結果件数
  Widget _buildResultCount(
    BuildContext context,
    int count,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            AppSpacing.xs,
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
  // 日付絞り込みボタン
  //==================================================

  Widget _buildDateFilterButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed:
            _showDateFilterDialog,
        icon: const ActionButtonIcon.filter(
          size: 38.0,
        ),
        label: Text(
          _hasDateFilter
              ? '日付で絞り込み中'
              : '日付で絞り込み',
        ),
      ),
    );
  }

  //==================================================
  // 日付絞り込み条件
  //==================================================

  Widget _buildDateFilterSummary(
    BuildContext context,
  ) {
    if (!_hasDateFilter) {
      return const SizedBox.shrink();
    }

    String dateText;

    if (_filterStartDate != null &&
        _filterEndDate != null) {
      dateText =
          '${_formatFilterDate(_filterStartDate!)}'
          ' ～ '
          '${_formatFilterDate(_filterEndDate!)}';
    } else if (_filterStartDate != null) {
      dateText =
          '${_formatFilterDate(_filterStartDate!)}'
          ' ～';
    } else {
      dateText =
          '～ '
          '${_formatFilterDate(_filterEndDate!)}';
    }

    return Padding(
      padding:
          const EdgeInsets.only(
        top: AppSpacing.xs,
        left: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '日付：$dateText',
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
          ),

          TextButton(
            onPressed:
                _clearDateFilter,
            child: const Text(
              'クリア',
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // プレミアムガラスカード
  //==================================================

  /// メモデータ一覧画面と同じ
  /// 「プレミアムガラスカード」。
  ///
  /// グラデーション：
  /// 白
  /// ↓
  /// ごく薄いブルー
  /// ↓
  /// 薄いブルー
  ///
  /// ※ガラス内側ハイライトは入れない。
  /// ※上部ガラスハイライトも入れない。
  /// ※Stack / Positionedによる
  ///   ハイライト重ね合わせも行わない。
  Widget _buildPremiumGlassCard({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
  }) {
    final card = Container(
      decoration: BoxDecoration(
        //================================================
        // 白〜ごく薄いブルー〜薄いブルー
        //================================================

        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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

        //================================================
        // 外枠
        //================================================

        borderRadius:
            AppRadius.card,

        border: Border.all(
          color: Color.fromRGBO(
            157,
            201,
            246,
            0.78,
          ),
          width: 1.5,
        ),

        //================================================
        // 柔らかな2層シャドウ
        //================================================

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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              AppRadius.card,
          child: Padding(
            padding:
                const EdgeInsets.all(
              AppSpacing.md,
            ),
            child: child,
          ),
        ),
      ),
    );

    return card;
  }

  //==================================================
  // 1件分のカード
  //==================================================

  Widget _buildCounterCard(
    BuildContext context,
    CounterRecord record,
  ) {
    final title =
        record.title.trim().isEmpty
            ? 'タイトルなし'
            : record.title.trim();

    final playGame =
        record.currentGame -
            record.startGame;

    return _buildPremiumGlassCard(
      context: context,
      onTap: () =>
          _openDetail(record),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          //========================================
          // 日付
          //========================================

          Text(
            _formatDate(
              record.date,
            ),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //========================================
          // タイトル
          //========================================

          Text(
            title,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          const Divider(),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //========================================
          // ゲーム数
          //========================================

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: '開始',
                  value:
                      '${_formatNumber(record.startGame)}G',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: '現在',
                  value:
                      '${_formatNumber(record.currentGame)}G',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: '遊技',
                  value:
                      '${_formatNumber(playGame < 0 ? 0 : playGame)}G',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //========================================
          // 小役合計
          //========================================

          Align(
            alignment:
                Alignment.centerRight,
            child: Text(
              '小役合計 ${_formatNumber(_totalCount(record))}回',
              style: Theme.of(context)
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
          ),
        ],
      ),
    );
  }

  //==================================================
  // サマリー項目
  //==================================================

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
        ),
      ],
    );
  }

  //==================================================
  // データなし表示
  //==================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh:
          _loadRecords,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            AppSpacing.page,
        children: [
          const SizedBox(
            height: 160,
          ),

          Icon(
            Icons.calculate_outlined,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(
            height:
                AppSpacing.md,
          ),

          const Center(
            child: Text(
              '保存された小役データはありません。',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 検索結果なし
  //==================================================

  Widget _buildNoSearchResultView() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
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
          style: Theme.of(context)
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
          _hasDateFilter
              ? '検索条件を変更してください。'
              : '別のキーワードで検索してください。',
          textAlign:
              TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '小役DATA一覧',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  //==================================================
  // Body
  //==================================================

  Widget _buildBody() {
    //================================================
    // 読み込み中
    //================================================

    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    //================================================
    // 小役データなし
    //================================================

    if (_records.isEmpty) {
      return _buildEmptyState(
        context,
      );
    }

    //================================================
    // 検索・絞り込み
    //================================================

    final filteredRecords =
        _filterRecords(
      _records,
    );

    //================================================
    // 検索結果一覧
    //================================================

    return Column(
      children: [
        //============================================
        // 検索欄
        //============================================

        Padding(
          padding:
              EdgeInsets.fromLTRB(
            AppSpacing.page.left,
            AppSpacing.page.top,
            AppSpacing.page.right,
            0,
          ),
          child:
              _buildSearchField(
            context,
          ),
        ),

        const SizedBox(
          height:
              AppSpacing.sm,
        ),

        //============================================
        // 検索結果件数
        //============================================

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

        //============================================
        // 日付絞り込みボタン
        //============================================

        Padding(
          padding:
              EdgeInsets.symmetric(
            horizontal:
                AppSpacing.page.left,
          ),
          child:
              _buildDateFilterButton(
            context,
          ),
        ),

        //============================================
        // 日付絞り込み条件
        //============================================

        Padding(
          padding:
              EdgeInsets.symmetric(
            horizontal:
                AppSpacing.page.left,
          ),
          child:
              _buildDateFilterSummary(
            context,
          ),
        ),

        //============================================
        // 検索結果
        //============================================

        Expanded(
          child:
              filteredRecords.isEmpty
                  ? _buildNoSearchResultView()
                  : RefreshIndicator(
                      onRefresh:
                          _loadRecords,
                      child:
                          ListView.separated(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
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

                          return _buildCounterCard(
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