import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/counter_record.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/action_button_icon.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/counter/koyaku_icon.dart';
import 'counter_edit_page.dart';

class CounterDetailPage extends StatelessWidget {
  const CounterDetailPage({
    super.key,
    required this.record,
  });

  /// 表示する小役データ
  final CounterRecord record;

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
  // プレミアムガラスカード
  //==================================================

  /// プレミアムガラスカード
  ///
  /// 白
  /// ↓
  /// ごく薄いブルー
  /// ↓
  /// 薄いブルー
  ///
  /// の自然な縦グラデーション。
  ///
  /// 注意：
  /// ・ガラス内側ハイライトは入れない。
  /// ・上部ガラスハイライトは入れない。
  /// ・Stack / Positionedによる装飾は使用しない。
  Widget _buildPremiumGlassCard({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        //================================================
        // 白〜ごく薄いブルー〜薄いブルー
        //================================================
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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

        //================================================
        // カード角丸
        //================================================
        borderRadius:
            AppRadius.card,

        //================================================
        // 薄いブルーの境界線
        //================================================
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
        // 外側シャドウ
        //
        // 内側ハイライトではなく、
        // カード外側だけに自然な浮遊感を出す。
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
            offset: Offset(
              0,
              3,
            ),
          ),
        ],
      ),

      //================================================
      // カード内部
      //
      // 既存AppCardと同様の余白感を維持。
      //================================================
      child: ClipRRect(
        borderRadius:
            AppRadius.card,
        child: Padding(
          padding:
              const EdgeInsets.all(
            AppSpacing.lg,
          ),
          child: child,
        ),
      ),
    );
  }

  //==================================================
  // 項目
  //==================================================

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
            width: 110,
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
  // 小役項目
  //==================================================

  Widget _buildCounterRow(
    BuildContext context, {
    required KoyakuType type,
    required String label,
    required int count,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          //================================================
          // 小役アイコン
          //================================================

          KoyakuIcon(
            type: type,
            size: 32,
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          //================================================
          // 小役名
          //================================================

          Expanded(
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

          //================================================
          // カウント
          //================================================

          Text(
            '${_formatNumber(count)}回',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 小役確率項目
  //==================================================

  Widget _buildProbabilityRow(
    BuildContext context, {
    required KoyakuType type,
    required String label,
    required String probability,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          //================================================
          // 小役アイコン
          //================================================

          KoyakuIcon(
            type: type,
            size: 32,
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          //================================================
          // 小役名
          //================================================

          Expanded(
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

          //================================================
          // 確率
          //================================================

          Text(
            probability,
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
        ],
      ),
    );
  }

  //==================================================
  // 遊技ゲーム数
  //==================================================

  int _playGame() {
    final value =
        record.currentGame -
            record.startGame;

    if (value < 0) {
      return 0;
    }

    return value;
  }

  //==================================================
  // 確率
  //==================================================

  String _probability(
    int count,
  ) {
    final playGame =
        _playGame();

    if (count == 0 ||
        playGame == 0) {
      return '1 / -----';
    }

    final probability =
        playGame / count;

    if (probability ==
        probability.roundToDouble()) {
      return '1 / ${probability.toInt()}';
    }

    return '1 / ${probability.toStringAsFixed(1)}';
  }

  //==================================================
  // 編集
  //==================================================

  Future<void> _openEditPage(
    BuildContext context,
  ) async {
    final result =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CounterEditPage(
          record: record,
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

    // 編集成功時は、
    // 詳細画面も閉じて一覧へ
    // 最新データを返す。
    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  //==================================================
  // 削除
  //==================================================

  Future<void> _onDelete(
    BuildContext context,
  ) async {
    //================================================
    // ID確認
    //================================================

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

    //================================================
    // 確認ダイアログ
    //================================================

    final result =
        await DialogService.showConfirm(
      context: context,
      title: '削除しますか？',
      message:
          'この小役データを本当に削除しますか？',
      confirmText: '削除',
    );

    if (!context.mounted) {
      return;
    }

    if (!result) {
      return;
    }

    //================================================
    // SQLite DELETE
    //================================================

    try {
      await DatabaseService.instance
          .deleteCounterRecord(
        record.id!,
      );

      if (!context.mounted) {
        return;
      }

      //================================================
      // 一覧画面へ戻る
      //================================================

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
  Widget build(
    BuildContext context,
  ) {
    final title =
        record.title.trim().isEmpty
            ? 'タイトルなし'
            : record.title.trim();

    final playGame =
        _playGame();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '小役データ詳細',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              AppSpacing.page,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              //================================================
              // 基本情報
              //================================================

              _buildPremiumGlassCard(
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
                      height:
                          AppSpacing.md,
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
                      label: 'タイトル',
                      value: title,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              //================================================
              // ゲーム数
              //================================================

              _buildPremiumGlassCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ゲーム数',
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

                    _buildDetailRow(
                      context,
                      label: '開始ゲーム数',
                      value:
                          '${_formatNumber(record.startGame)}G',
                    ),

                    const Divider(),

                    _buildDetailRow(
                      context,
                      label: '現在ゲーム数',
                      value:
                          '${_formatNumber(record.currentGame)}G',
                    ),

                    const Divider(),

                    _buildDetailRow(
                      context,
                      label: '遊技ゲーム数',
                      value:
                          '${_formatNumber(playGame)}G',
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              //================================================
              // 小役
              //================================================

              _buildPremiumGlassCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '小役カウント',
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

                    _buildCounterRow(
                      context,
                      type:
                          KoyakuType.cherry,
                      label: 'チェリー',
                      count:
                          record.cherry,
                    ),

                    const Divider(),

                    _buildCounterRow(
                      context,
                      type:
                          KoyakuType.bell,
                      label: 'ベル',
                      count:
                          record.bell,
                    ),

                    const Divider(),

                    _buildCounterRow(
                      context,
                      type:
                          KoyakuType.watermelon,
                      label: 'スイカ',
                      count:
                          record.suika,
                    ),

                    const Divider(),

                    _buildCounterRow(
                      context,
                      type:
                          KoyakuType.grape,
                      label: 'ブドウ',
                      count:
                          record.grape,
                    ),

                    const Divider(),

                    _buildCounterRow(
                      context,
                      type:
                          KoyakuType.chance,
                      label: 'チャンス目',
                      count:
                          record.chance,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              //================================================
              // 確率
              //================================================

              _buildPremiumGlassCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '出現確率',
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

                    _buildProbabilityRow(
                      context,
                      type:
                          KoyakuType.cherry,
                      label: 'チェリー',
                      probability:
                          _probability(
                        record.cherry,
                      ),
                    ),

                    const Divider(),

                    _buildProbabilityRow(
                      context,
                      type:
                          KoyakuType.bell,
                      label: 'ベル',
                      probability:
                          _probability(
                        record.bell,
                      ),
                    ),

                    const Divider(),

                    _buildProbabilityRow(
                      context,
                      type:
                          KoyakuType.watermelon,
                      label: 'スイカ',
                      probability:
                          _probability(
                        record.suika,
                      ),
                    ),

                    const Divider(),

                    _buildProbabilityRow(
                      context,
                      type:
                          KoyakuType.grape,
                      label: 'ブドウ',
                      probability:
                          _probability(
                        record.grape,
                      ),
                    ),

                    const Divider(),

                    _buildProbabilityRow(
                      context,
                      type:
                          KoyakuType.chance,
                      label: 'チャンス目',
                      probability:
                          _probability(
                        record.chance,
                      ),
                    ),
                  ],
                ),
              ),

              //================================================
              // 編集
              //================================================

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

              //================================================
              // 削除
              //================================================

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