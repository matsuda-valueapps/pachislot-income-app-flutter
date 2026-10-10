import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/counter_record.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/action_button_icon.dart';
import '../widgets/common/ad_banner.dart';
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

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
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

  String _formatNumber(int value) {
    return NumberFormat('#,###', 'ja_JP').format(value);
  }

  //==================================================
  // 機種タイプ判定
  //==================================================

  bool get _isAtType => record.machineType == 'ATタイプ';

  //==================================================
  // 小役アイコンサイズ
  //==================================================

  /// ATタイプは強36px・弱28px、
  /// Aタイプは全種類36px。
  double _koyakuIconSize(String label) {
    if (!_isAtType) {
      return 36;
    }

    if (label.startsWith('弱')) {
      return 28;
    }

    return 36;
  }

  /// アイコンの表示領域は常に36×36pxに固定する。
  ///
  /// 弱小役のアイコンが28pxでも、
  /// 右側の小役名の開始位置がずれないようにする。
  Widget _buildKoyakuIcon({
    required KoyakuType type,
    required String label,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Center(
        child: KoyakuIcon(
          type: type,
          size: _koyakuIconSize(label),
        ),
      ),
    );
  }

  //==================================================
  // プレミアムガラスカード
  //==================================================

  Widget _buildPremiumGlassCard({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(250, 253, 255, 0.98),
            Color.fromRGBO(247, 251, 255, 0.98),
            Color.fromRGBO(239, 247, 255, 0.98),
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
            color: Color.fromRGBO(92, 143, 196, 0.18),
            blurRadius: 22,
            spreadRadius: 2,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color.fromRGBO(125, 170, 215, 0.12),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }

  //==================================================
  // 基本情報項目
  //==================================================

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 小役カウント項目
  //==================================================

  Widget _buildCounterRow(
    BuildContext context, {
    required KoyakuType type,
    required String label,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // アイコン領域を36pxで統一
          _buildKoyakuIcon(
            type: type,
            label: label,
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          // 小役名
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
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // カウント
          Text(
            '${_formatNumber(count)}回',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 小役出現確率項目
  //==================================================

  Widget _buildProbabilityRow(
    BuildContext context, {
    required KoyakuType type,
    required String label,
    required String probability,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // アイコン領域を36pxで統一
          _buildKoyakuIcon(
            type: type,
            label: label,
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          // 小役名
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
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // 確率
          Text(
            probability,
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  fontWeight: FontWeight.w600,
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
    final value = record.currentGame - record.startGame;

    if (value < 0) {
      return 0;
    }

    return value;
  }

  //==================================================
  // 出現確率
  //==================================================

  String _probability(int count) {
    final playGame = _playGame();

    if (count == 0 || playGame == 0) {
      return '1 / -----';
    }

    final probability = playGame / count;

    if (probability == probability.roundToDouble()) {
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
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CounterEditPage(
          record: record,
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

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
    if (record.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('削除できませんでした。'),
        ),
      );
      return;
    }

    final result = await DialogService.showConfirm(
      context: context,
      title: '削除しますか？',
      message: 'この小役データを本当に削除しますか？',
      confirmText: '削除',
    );

    if (!context.mounted) {
      return;
    }

    if (!result) {
      return;
    }

    try {
      await DatabaseService.instance.deleteCounterRecord(
        record.id!,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
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
    final title = record.title.trim().isEmpty
        ? 'タイトルなし'
        : record.title.trim();

    final playGame = _playGame();

    return Scaffold(
      appBar: AppBar(
        title: const Text('小役DATA詳細'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AdMobバナー
            const AdBanner(),

            // 詳細コンテンツ
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //========================================
                    // 基本情報
                    //========================================

                    _buildPremiumGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '基本情報',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(
                            height: AppSpacing.md,
                          ),
                          _buildDetailRow(
                            context,
                            label: '日付',
                            value: _formatDate(record.date),
                          ),
                          const Divider(),
                          _buildDetailRow(
                            context,
                            label: 'タイトル',
                            value: title,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            context,
                            label: '機種タイプ',
                            value: record.machineType,
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.gapLg,

                    //========================================
                    // ゲーム数
                    //========================================

                    _buildPremiumGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ゲーム数',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(
                            height: AppSpacing.md,
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
                            value: '${_formatNumber(playGame)}G',
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.gapLg,

                    //========================================
                    // 小役カウント
                    //========================================

                    _buildPremiumGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '小役カウント',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(
                            height: AppSpacing.md,
                          ),

                          if (_isAtType) ...[
                            _buildCounterRow(
                              context,
                              type: KoyakuType.cherry,
                              label: '強チェリー',
                              count: record.strongCherry,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.cherry,
                              label: '弱チェリー',
                              count: record.weakCherry,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.bell,
                              label: '強ベル',
                              count: record.strongBell,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.bell,
                              label: '弱ベル',
                              count: record.weakBell,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.watermelon,
                              label: '強スイカ',
                              count: record.strongSuika,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.watermelon,
                              label: '弱スイカ',
                              count: record.weakSuika,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.grape,
                              label: '強ブドウ',
                              count: record.strongGrape,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.grape,
                              label: '弱ブドウ',
                              count: record.weakGrape,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.chance,
                              label: '強チャンス目',
                              count: record.strongChance,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.chance,
                              label: '弱チャンス目',
                              count: record.weakChance,
                            ),
                          ] else ...[
                            _buildCounterRow(
                              context,
                              type: KoyakuType.cherry,
                              label: 'チェリー',
                              count: record.cherry,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.bell,
                              label: 'ベル',
                              count: record.bell,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.watermelon,
                              label: 'スイカ',
                              count: record.suika,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.grape,
                              label: 'ブドウ',
                              count: record.grape,
                            ),
                            const Divider(),
                            _buildCounterRow(
                              context,
                              type: KoyakuType.chance,
                              label: 'チャンス目',
                              count: record.chance,
                            ),
                          ],
                        ],
                      ),
                    ),

                    AppSpacing.gapLg,

                    //========================================
                    // 出現確率
                    //========================================

                    _buildPremiumGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '出現確率',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(
                            height: AppSpacing.md,
                          ),

                          if (_isAtType) ...[
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.cherry,
                              label: '強チェリー',
                              probability:
                                  _probability(record.strongCherry),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.cherry,
                              label: '弱チェリー',
                              probability:
                                  _probability(record.weakCherry),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.bell,
                              label: '強ベル',
                              probability:
                                  _probability(record.strongBell),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.bell,
                              label: '弱ベル',
                              probability:
                                  _probability(record.weakBell),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.watermelon,
                              label: '強スイカ',
                              probability:
                                  _probability(record.strongSuika),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.watermelon,
                              label: '弱スイカ',
                              probability:
                                  _probability(record.weakSuika),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.grape,
                              label: '強ブドウ',
                              probability:
                                  _probability(record.strongGrape),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.grape,
                              label: '弱ブドウ',
                              probability:
                                  _probability(record.weakGrape),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.chance,
                              label: '強チャンス目',
                              probability:
                                  _probability(record.strongChance),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.chance,
                              label: '弱チャンス目',
                              probability:
                                  _probability(record.weakChance),
                            ),
                          ] else ...[
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.cherry,
                              label: 'チェリー',
                              probability: _probability(record.cherry),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.bell,
                              label: 'ベル',
                              probability: _probability(record.bell),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.watermelon,
                              label: 'スイカ',
                              probability: _probability(record.suika),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.grape,
                              label: 'ブドウ',
                              probability: _probability(record.grape),
                            ),
                            const Divider(),
                            _buildProbabilityRow(
                              context,
                              type: KoyakuType.chance,
                              label: 'チャンス目',
                              probability: _probability(record.chance),
                            ),
                          ],
                        ],
                      ),
                    ),

                    //========================================
                    // 編集
                    //========================================

                    AppSpacing.gapLg,

                    PrimaryButton(
                      text: '編集',
                      iconWidget: const ActionButtonIcon.edit(
                        size: 38,
                      ),
                      onPressed: () => _openEditPage(context),
                    ),

                    //========================================
                    // 削除
                    //========================================

                    AppSpacing.gapMd,

                    PrimaryButton(
                      text: '削除',
                      iconWidget: const ActionButtonIcon.delete(
                        size: 38,
                      ),
                      backgroundColor: Colors.red.shade700,
                      onPressed: () => _onDelete(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}