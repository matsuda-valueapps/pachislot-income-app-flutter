import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/income_record.dart';
import '../providers/home_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import 'income_detail_page.dart';

class IncomeListPage extends StatefulWidget {
  const IncomeListPage({super.key});

  @override
  State<IncomeListPage> createState() =>
      _IncomeListPageState();
}

class _IncomeListPageState
    extends State<IncomeListPage> {
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

  /// 日付表示
  String _formatDate(String date) {
    try {
      final parsedDate =
          DateTime.parse(date);

      return '${parsedDate.year}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }

  /// 金額表示
  String _formatAmount(int amount) {
    final absoluteAmount =
        amount.abs().toString();

    final buffer = StringBuffer();

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

  /// 収支表示
  String _formatProfit(int profit) {
    if (profit > 0) {
      return '+${_formatAmount(profit)}円';
    }

    if (profit < 0) {
      return '-${_formatAmount(profit)}円';
    }

    return '0円';
  }

  /// 収支の色
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

  /// 1件分の収支データカード
  Widget _buildIncomeCard(
    BuildContext context,
    IncomeRecord record,
  ) {
    final profitColor =
        _profitColor(
      context,
      record.profit,
    );

    return AppCard(
      child: InkWell(
        onTap: () =>
            _openDetail(record),
        borderRadius:
            BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 日付
              // ==========================================

              Text(
                _formatDate(record.date),
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

              // ==========================================
              // ホール名
              // ==========================================

              if (record.hall.isNotEmpty)
                Text(
                  record.hall,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),

              // ==========================================
              // 機種名
              // ==========================================

              if (record.machine.isNotEmpty) ...[
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  record.machine,
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

              const SizedBox(
                height: AppSpacing.md,
              ),

              const Divider(),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              // ==========================================
              // 投資・回収・収支
              // ==========================================

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
    );
  }

  /// 金額表示用Column
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
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          displayAmount,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                color: displayColor,
                fontWeight:
                    FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// 空データ表示
  Widget _buildEmptyView(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
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
              height: AppSpacing.md,
            ),

            Text(
              '保存データがありません',
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

            Text(
              '入力画面からデータを保存すると、\n'
              'ここに表示されます。',
              textAlign: TextAlign.center,
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
        ),
      ),
    );
  }

  /// エラー表示
  Widget _buildErrorView(
    BuildContext context,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
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
              height: AppSpacing.md,
            ),

            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),

            const SizedBox(
              height: AppSpacing.md,
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

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '保存データ',
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

  /// 本文
  Widget _buildBody(
    BuildContext context,
    HomeProvider provider,
  ) {
    // ==========================================
    // 読み込み中
    // ==========================================

    if (provider.isLoading &&
        !provider.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ==========================================
    // エラー
    // ==========================================

    if (provider.errorMessage != null &&
        !provider.hasData) {
      return _buildErrorView(
        context,
        provider.errorMessage!,
      );
    }

    // ==========================================
    // データなし
    // ==========================================

    if (!provider.hasData) {
      return _buildEmptyView(
        context,
      );
    }

    // ==========================================
    // 保存データ一覧
    // ==========================================

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page.left,
          AppSpacing.page.top,
          AppSpacing.page.right,
          AppSpacing.page.bottom,
        ),
        itemCount:
            provider.incomeRecords.length,
        separatorBuilder:
            (context, index) =>
                AppSpacing.gapMd,
        itemBuilder:
            (context, index) {
          final record =
              provider.incomeRecords[index];

          return _buildIncomeCard(
            context,
            record,
          );
        },
      ),
    );
  }
}