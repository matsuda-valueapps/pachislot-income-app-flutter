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
  // 機種タイプ判定
  //==================================================

  bool get _isAtType => record.machineType == 'ATタイプ';

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
    return NumberFormat(
      '#,###',
      'ja_JP',
    ).format(value);
  }

  //==================================================
  // 小役アイコンサイズ
  //==================================================

  /// Aタイプは30px。
  /// ATタイプは強小役30px、弱小役24px。
  ///
  /// アイコンサイズは既存の設定を維持する。
  double _koyakuIconSize(String label) {
    if (!_isAtType) {
      return 30;
    }

    if (label.startsWith('弱')) {
      return 24;
    }

    return 30;
  }

  /// アイコン領域を36×36pxで統一する。
  ///
  /// 弱小役のアイコンを小さくしても、
  /// 小役名の開始位置がずれないようにする。
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
  // カウンター画面に合わせた背景色
  //==================================================

  /// 小役ごとの背景色を返す。
  ///
  /// AタイプとATタイプで共通の色系統を使用し、
  /// ATタイプの弱小役は強小役より薄い色にする。
  Color _koyakuBackgroundColor(String label) {
    if (label.contains('チェリー')) {
      if (_isAtType && label.startsWith('弱')) {
        return const Color(0xFFFFF6F6);
      }

      return const Color(0xFFFBE8E8);
    }

    if (label.contains('スイカ')) {
      if (_isAtType && label.startsWith('弱')) {
        return const Color(0xFFF4FAF4);
      }

      return const Color(0xFFE7F4E8);
    }

    if (label.contains('チャンス目')) {
      if (_isAtType && label.startsWith('弱')) {
        return const Color(0xFFF5F9FC);
      }

      return const Color(0xFFE2F0FC);
    }

    if (label.contains('ベル')) {
      if (_isAtType && label.startsWith('弱')) {
        return const Color(0xFFFFFCF3);
      }

      return const Color(0xFFFFF4D5);
    }

    if (label.contains('ブドウ')) {
      return const Color(0xFFF0E5F8);
    }

    return const Color(0xFFF4F8FC);
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
  // セクションタイトル
  //==================================================

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
            fontWeight: FontWeight.bold,
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
      return '1/-----';
    }

    final probability = playGame / count;

    if (probability == probability.roundToDouble()) {
      return '1/${probability.toInt()}';
    }

    return '1/${probability.toStringAsFixed(1)}';
  }

  //==================================================
  // Aタイプ：小役カウント＆出現確率
  //==================================================

  /// Aタイプは1行にまとめて表示する。
  ///
  /// 左側：アイコンと小役名
  /// 右側：カウントと出現確率
  ///
  /// ＋ボタン・－ボタンは表示しない。
  Widget _buildATypeKoyakuRow(
    BuildContext context, {
    required KoyakuType type,
    required String label,
    required int count,
  }) {
    final backgroundColor = _koyakuBackgroundColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDCDCDC),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildKoyakuIcon(
            type: type,
            label: label,
          ),

          const SizedBox(width: 6),

          // 小役名
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ),

          const SizedBox(width: 6),

          // カウント
          Text(
            '${_formatNumber(count)}回',
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),

          const SizedBox(width: 8),

          // 出現確率
          SizedBox(
            width: 76,
            child: Text(
              _probability(count),
              maxLines: 1,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // ATタイプ：小役カード
  //==================================================

  /// ATタイプは2列×4段で表示する。
  ///
  /// 1段目：強チェリー・弱チェリー
  /// 2段目：強スイカ・弱スイカ
  /// 3段目：強チャンス目・弱チャンス目
  /// 4段目：強ベル・弱ベル
  ///
  /// カード内は小役名と、
  /// カウント・出現確率の2行構成。
  Widget _buildAtTypeKoyakuCard(
    BuildContext context, {
    required KoyakuType type,
    required String label,
    required int count,
  }) {
    final backgroundColor = _koyakuBackgroundColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(
        // 小役名の表示領域を確保するため左右の余白を縮小
        horizontal: 4,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDEDEDE),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 小役アイコンと小役名
          Row(
            children: [
              // アイコンサイズは変更しない
              _buildKoyakuIcon(
                type: type,
                label: label,
              ),

              const SizedBox(width: 4),

              // 小役名が長い場合は省略せず、
              // カード内に収まるサイズに縮小する
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // カウントと出現確率
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatNumber(count)}回',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
              ),

              Expanded(
                child: Padding(
                  // カード右端との間に余白を設け、表示位置を少し左へ移動
                  padding: const EdgeInsets.only(right: 14),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _probability(count),
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //==================================================
  // Aタイプ：小役カウント＆出現確率一覧
  //==================================================

  Widget _buildATypeCounterSection(
    BuildContext context,
  ) {
    return _buildPremiumGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            '小役カウント＆出現確率',
          ),

          const SizedBox(height: AppSpacing.md),

          _buildATypeKoyakuRow(
            context,
            type: KoyakuType.cherry,
            label: 'チェリー',
            count: record.cherry,
          ),

          const SizedBox(height: 8),

          _buildATypeKoyakuRow(
            context,
            type: KoyakuType.watermelon,
            label: 'スイカ',
            count: record.suika,
          ),

          const SizedBox(height: 8),

          _buildATypeKoyakuRow(
            context,
            type: KoyakuType.chance,
            label: 'チャンス目',
            count: record.chance,
          ),

          const SizedBox(height: 8),

          _buildATypeKoyakuRow(
            context,
            type: KoyakuType.bell,
            label: 'ベル',
            count: record.bell,
          ),

          const SizedBox(height: 8),

          _buildATypeKoyakuRow(
            context,
            type: KoyakuType.grape,
            label: 'ブドウ',
            count: record.grape,
          ),
        ],
      ),
    );
  }

  //==================================================
  // ATタイプ：小役カウント＆出現確率一覧
  //==================================================

  Widget _buildAtTypeCounterSection(
    BuildContext context,
  ) {
    return _buildPremiumGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            '小役カウント＆出現確率',
          ),

          const SizedBox(height: AppSpacing.md),

          // 2列×4段
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            // カード間の横の隙間を縮め、カード幅を確保
            crossAxisSpacing: 6,

            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              // 1段目：チェリー
              _buildAtTypeKoyakuCard(
                context,
                type: KoyakuType.cherry,
                label: '強チェリー',
                count: record.strongCherry,
              ),
              _buildAtTypeKoyakuCard(
                context,
                type: KoyakuType.cherry,
                label: '弱チェリー',
                count: record.weakCherry,
              ),

              // 2段目：スイカ
              _buildAtTypeKoyakuCard(
                context,
                type: KoyakuType.watermelon,
                label: '強スイカ',
                count: record.strongSuika,
              ),
              _buildAtTypeKoyakuCard(
                context,
                type: KoyakuType.watermelon,
                label: '弱スイカ',
                count: record.weakSuika,
              ),

              // 3段目：チャンス目
              _buildAtTypeKoyakuCard(
                context,
                type: KoyakuType.chance,
                label: '強チャンス目',
                count: record.strongChance,
              ),
              _buildAtTypeKoyakuCard(
                context,
                type: KoyakuType.chance,
                label: '弱チャンス目',
                count: record.weakChance,
              ),

              // 4段目：ベル
              _buildAtTypeKoyakuCard(
                context,
                type: KoyakuType.bell,
                label: '強ベル',
                count: record.strongBell,
              ),
              _buildAtTypeKoyakuCard(
                context,
                type: KoyakuType.bell,
                label: '弱ベル',
                count: record.weakBell,
              ),
            ],
          ),
        ],
      ),
    );
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
        title: const Text('小役データ詳細'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //========================================
            // AdMobバナー
            //========================================

            const AdBanner(),

            //========================================
            // 詳細コンテンツ
            //========================================

            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //================================
                    // 基本情報
                    //================================

                    _buildPremiumGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            context,
                            '基本情報',
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

                    //================================
                    // ゲーム数
                    //================================

                    _buildPremiumGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            context,
                            'ゲーム数',
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
                            value:
                                '${_formatNumber(playGame)}G',
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.gapLg,

                    //================================
                    // 小役カウント＆出現確率
                    //================================

                    if (_isAtType)
                      _buildAtTypeCounterSection(context)
                    else
                      _buildATypeCounterSection(context),

                    //================================
                    // 編集
                    //================================

                    AppSpacing.gapLg,

                    PrimaryButton(
                      text: '編集',
                      iconWidget: const ActionButtonIcon.edit(
                        size: 38,
                      ),
                      onPressed: () => _openEditPage(context),
                    ),

                    //================================
                    // 削除
                    //================================

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