import 'package:flutter/material.dart';

import '../models/memo_record.dart';
import '../services/database_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import 'memo_detail_page.dart';

class MemoListPage extends StatefulWidget {
  const MemoListPage({
    super.key,
  });

  @override
  State<MemoListPage> createState() =>
      _MemoListPageState();
}

class _MemoListPageState
    extends State<MemoListPage> {
  //==================================================
  // 保存済みメモ
  //==================================================

  List<MemoRecord> _memoRecords = [];

  /// 読み込み中かどうか
  bool _isLoading = true;

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

    _loadMemoRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  //==================================================
  // メモ一覧取得
  //==================================================

  /// SQLiteから保存済みメモを取得する。
  Future<void> _loadMemoRecords() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final records =
          await DatabaseService.instance
              .getMemoRecords();

      if (!mounted) {
        return;
      }

      setState(() {
        _memoRecords = records;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _memoRecords = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'メモの読み込みに失敗しました。',
          ),
        ),
      );
    }
  }

  //==================================================
  // 日付表示
  //==================================================

  /// SQLiteに保存されている
  /// YYYY-MM-DD形式の日付を
  /// YYYY年M月D日(曜日)形式へ変換する。
  ///
  /// 例：
  ///
  /// 2026-08-14
  /// ↓
  /// 2026年8月14日(金)
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
  // タイトル表示
  //==================================================

  /// タイトルが空の場合は「無題」と表示する。
  String _displayTitle(
    MemoRecord record,
  ) {
    final title =
        record.title.trim();

    if (title.isEmpty) {
      return '無題';
    }

    return title;
  }

  //==================================================
  // メモ詳細画面
  //==================================================

  /// 選択したメモの詳細画面を開く。
  ///
  /// 詳細画面では、
  ///
  /// ・メモ内容の確認
  /// ・メモの編集
  /// ・メモの削除
  ///
  /// を行う。
  ///
  /// 詳細画面から戻ってきた際には、
  /// SQLiteから最新のメモ一覧を再取得する。
  Future<void> _openMemoDetail(
    MemoRecord record,
  ) async {
    //================================================
    // メモ詳細画面を開く
    //================================================

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MemoDetailPage(
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
    // 詳細画面で、
    //
    // ・編集
    // ・削除
    //
    // が行われている可能性があるため、
    // SQLiteから最新データを再取得する。
    //================================================

    await _loadMemoRecords();
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

  /// メモの日付をDateTimeへ変換する。
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
              title: const Text(
                '日付で絞り込み',
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
                    leading: const Icon(
                      Icons
                          .calendar_month_rounded,
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
                    leading: const Icon(
                      Icons
                          .calendar_month_rounded,
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

  /// キーワード＋日付条件に一致する
  /// メモデータを取得する。
  ///
  /// 条件：
  ///
  /// ・タイトルまたはメモ本文に
  ///   キーワードを含む
  /// ・指定された日付範囲内
  ///
  /// 複数条件を指定した場合はAND条件。
  List<MemoRecord> _filterRecords(
    List<MemoRecord> records,
  ) {
    return records.where((record) {
      //==============================================
      // キーワード条件
      //==============================================

      if (_searchQuery.isNotEmpty) {
        final title =
            record.title
                .toLowerCase();

        final body =
            record.body
                .toLowerCase();

        final keywordMatches =
            title.contains(
                  _searchQuery,
                ) ||
                body.contains(
                  _searchQuery,
                );

        if (!keywordMatches) {
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
            'タイトル・メモを検索',
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
        icon: Icon(
          _hasDateFilter
              ? Icons.filter_alt
              : Icons.filter_alt_outlined,
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
  // メモカード
  //==================================================

  Widget _buildMemoCard(
    MemoRecord record,
  ) {
    final body =
        record.body.trim();

    return AppCard(
      onTap: () {
        _openMemoDetail(record);
      },
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          //================================================
          // 日付
          //================================================

          Text(
            _formatDate(record.date),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //================================================
          // タイトル
          //================================================

          Text(
            _displayTitle(record),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //================================================
          // 本文
          //================================================

          Text(
            body.isEmpty
                ? '本文はありません。'
                : body,
            maxLines: 5,
            overflow:
                TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color:
                  Colors.grey.shade800,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //================================================
          // 詳細表示案内
          //================================================

          Align(
            alignment:
                Alignment.centerRight,
            child: Text(
              'タップして詳細を見る',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // メモなし表示
  //==================================================

  Widget _buildEmptyView() {
    return RefreshIndicator(
      onRefresh:
          _loadMemoRecords,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            AppSpacing.page,
        children: const [
          SizedBox(
            height: 160,
          ),

          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey,
          ),

          SizedBox(
            height:
                AppSpacing.md,
          ),

          Center(
            child: Text(
              '保存されたメモはありません。',
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
          'メモデータ一覧',
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
    // メモなし
    //================================================

    if (_memoRecords.isEmpty) {
      return _buildEmptyView();
    }

    //================================================
    // 検索・絞り込み
    //================================================

    final filteredRecords =
        _filterRecords(
      _memoRecords,
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
                          _loadMemoRecords,
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

                          return _buildMemoCard(
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