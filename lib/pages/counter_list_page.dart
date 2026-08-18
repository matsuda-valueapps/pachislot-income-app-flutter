import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/counter_record.dart';
import '../services/database_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
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
  // 初期化
  //==================================================

  @override
  void initState() {
    super.initState();

    _loadRecords();
  }

  //==================================================
  // SQLite
  //==================================================

  /// 保存済み小役データを取得
  Future<void> _loadRecords() async {
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
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
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
    final result =
        await Navigator.push<bool>(
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
    // 詳細画面で
    // 編集・削除が行われた場合
    //================================================

    if (result == true) {
      await _loadRecords();
    }
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

    return AppCard(
      child: InkWell(
        onTap: () =>
            _openDetail(record),
        borderRadius:
            BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.all(
            AppSpacing.md,
          ),
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
        ),
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
  // Build
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '保存小役データ一覧',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _records.isEmpty
                ? _buildEmptyState(
                    context,
                  )
                : RefreshIndicator(
                    onRefresh:
                        _loadRecords,
                    child:
                        ListView.separated(
                      padding:
                          AppSpacing.page,
                      itemCount:
                          _records.length,
                      separatorBuilder:
                          (_, _) =>
                              AppSpacing.gapMd,
                      itemBuilder:
                          (context, index) {
                        return _buildCounterCard(
                          context,
                          _records[index],
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  //==================================================
  // データなし
  //==================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            AppSpacing.page,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .calculate_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Text(
              '保存された小役データはありません。',
              textAlign:
                  TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}