import 'package:flutter/material.dart';

import '../models/income_record.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/action_button_icon.dart';
import '../widgets/common/primary_button.dart';
import 'input_page.dart';

class IncomeDetailPage extends StatelessWidget {
  const IncomeDetailPage({
    super.key,
    required this.record,
  });

  /// 表示する収支データ
  final IncomeRecord record;

  //==================================================
  // 日付表示
  //==================================================

  /// 日付表示
  ///
  /// SQLiteに保存されている
  /// YYYY-MM-DD形式の日付を、
  /// YYYY年M月D日(曜日)形式へ変換する。
  ///
  /// 例：
  /// 2026-08-12
  /// ↓
  /// 2026年8月12日(水)
  String _formatDate(String date) {
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
  // 金額表示
  //==================================================

  /// 金額表示
  String _formatAmount(int amount) {
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
  String _formatProfit(int profit) {
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
  /// 月間収支カードおよび
  /// 収支データ一覧画面と同じデザイン仕様。
  ///
  /// ※「ガラス内側ハイライト」
  /// ※「上部ガラスハイライト」
  /// は使用しない。
  BoxDecoration _buildGlassDecoration() {
    return BoxDecoration(
      //================================================
      // ガラス調背景
      //================================================
      //
      // 白をベースに、
      // 下方向へごく薄いブルーを加える。
      //================================================

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

      //================================================
      // カード角丸
      //================================================

      borderRadius:
          AppRadius.card,

      //================================================
      // 薄いブルーBorder
      //================================================

      border: Border.all(
        color: const Color.fromRGBO(
          157,
          201,
          246,
          0.78,
        ),
        width: 1.5,
      ),

      //================================================
      // 柔らかな立体シャドウ
      //================================================

      boxShadow: const [
        //================================================
        // 下方向の柔らかな影
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
  // プレミアムガラスカード Widget
  //==================================================

  /// 詳細画面の各カードを
  /// プレミアムガラスカードとして表示する。
  ///
  /// 対象：
  /// ・基本情報
  /// ・投資
  /// ・回収
  /// ・収支
  /// ・メモ
  ///
  /// 既存のカード内部レイアウトは変更せず、
  /// 外側の装飾だけを変更する。
  ///
  /// ※ガラス内側ハイライトなし
  /// ※上部ガラスハイライトなし
  Widget _buildGlassCard({
    required Widget child,
  }) {
    return Container(
      decoration:
          _buildGlassDecoration(),
      child: Padding(
        padding:
            const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: child,
      ),
    );
  }

  //==================================================
  // 詳細項目
  //==================================================

  /// 項目
  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 金額項目
  //==================================================

  /// 金額項目
  Widget _buildAmountRow(
    BuildContext context, {
    required String label,
    required int amount,
    required Color color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              '${_formatAmount(amount)}円',
              textAlign:
                  TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    color: color,
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 収支カード
  //==================================================

  /// 収支表示
  Widget _buildProfitCard(
    BuildContext context,
  ) {
    final profitColor =
        _profitColor(
      context,
      record.profit,
    );

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '収支',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Center(
            child: Text(
              _formatProfit(
                record.profit,
              ),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    color: profitColor,
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 編集画面
  //==================================================

  /// 編集画面を開く
  Future<void> _openEditPage(
    BuildContext context,
  ) async {
    final result =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InputPage(
          record: record,
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

    // 編集画面から戻ってきた場合、
    // 詳細画面も最新のSQLiteデータを
    // 表示するために一度閉じる。
    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  //==================================================
  // 削除処理
  //==================================================

  /// 削除処理
  Future<void> _onDelete(
    BuildContext context,
  ) async {
    // SQLiteの更新・削除にはIDが必要。
    if (record.id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '削除できませんでした。',
          ),
        ),
      );

      return;
    }

    // ==========================================
    // 削除確認ダイアログ
    // ==========================================

    final result =
        await DialogService.showConfirm(
      context: context,
      title: '削除しますか？',
      message:
          'このデータを本当に削除しますか？',
      confirmText: '削除',
    );

    if (!context.mounted) {
      return;
    }

    if (!result) {
      return;
    }

    // ==========================================
    // SQLite DELETE
    // ==========================================

    try {
      await DatabaseService.instance
          .deleteIncomeRecord(
        record.id!,
      );

      if (!context.mounted) {
        return;
      }

      // ==========================================
      // 保存データ一覧へ戻る
      // ==========================================

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '削除に失敗しました。もう一度お試しください。',
          ),
        ),
      );
    }
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    final medalInvest =
        record.medalInvest;

    final cashInvest =
        record.cashInvest;

    final medalReturn =
        record.medalReturn;

    final cashReturn =
        record.cashReturn;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '収支 Data 詳細',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // 基本情報
              // ==========================================

              _buildGlassCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本情報',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    _buildDetailRow(
                      context,
                      label: '日付',
                      value:
                          _formatDate(
                        record.date,
                      ),
                    ),

                    const Divider(),

                    _buildDetailRow(
                      context,
                      label: 'ホール名',
                      value:
                          record.hall.isEmpty
                              ? '―'
                              : record.hall,
                    ),

                    const Divider(),

                    _buildDetailRow(
                      context,
                      label: '機種名',
                      value:
                          record.machine.isEmpty
                              ? '―'
                              : record.machine,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              // ==========================================
              // 投資
              // ==========================================

              _buildGlassCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '投資',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    _buildAmountRow(
                      context,
                      label: '貯メダル投資',
                      amount: medalInvest,
                      color:
                          Colors.red.shade700,
                    ),

                    const Divider(),

                    _buildAmountRow(
                      context,
                      label: '現金投資',
                      amount: cashInvest,
                      color:
                          Colors.red.shade700,
                    ),

                    const Divider(),

                    _buildAmountRow(
                      context,
                      label: '投資合計',
                      amount:
                          medalInvest +
                              cashInvest,
                      color:
                          Colors.red.shade700,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              // ==========================================
              // 回収
              // ==========================================

              _buildGlassCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '回収',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    _buildAmountRow(
                      context,
                      label: '貯メダル回収',
                      amount: medalReturn,
                      color:
                          Colors.green.shade700,
                    ),

                    const Divider(),

                    _buildAmountRow(
                      context,
                      label: '現金回収',
                      amount: cashReturn,
                      color:
                          Colors.green.shade700,
                    ),

                    const Divider(),

                    _buildAmountRow(
                      context,
                      label: '回収合計',
                      amount:
                          medalReturn +
                              cashReturn,
                      color:
                          Colors.green.shade700,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              // ==========================================
              // 収支
              // ==========================================

              _buildProfitCard(context),

              // ==========================================
              // メモ
              // ==========================================

              if (record.memo.isNotEmpty) ...[
                AppSpacing.gapLg,

                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'メモ',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),

                      const SizedBox(
                        height:
                            AppSpacing.md,
                      ),

                      Text(
                        record.memo,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],

              // ==========================================
              // 編集
              // ==========================================

              AppSpacing.gapLg,

              PrimaryButton(
                text: '編集',
                iconWidget:
                    const ActionButtonIcon.edit(
                  size: 38,
                ),
                onPressed: () =>
                    _openEditPage(
                  context,
                ),
              ),

              // ==========================================
              // 削除
              // ==========================================

              AppSpacing.gapMd,

              PrimaryButton(
                text: '削除',
                iconWidget:
                    const ActionButtonIcon.delete(
                  size: 38,
                ),
                backgroundColor:
                    Colors.red.shade700,
                onPressed: () =>
                    _onDelete(
                  context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}