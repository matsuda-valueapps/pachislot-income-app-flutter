import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/counter_record.dart';
import '../providers/counter_provider.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/counter/counter_card.dart';
import '../widgets/counter/game_counter.dart';
import '../widgets/counter/start_game_counter.dart';
import 'counter_list_page.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() =>
      _CounterPageState();
}

class _CounterPageState
    extends State<CounterPage> {
  //==================================================
  // Controller
  //==================================================

  /// 開始ゲーム数
  final TextEditingController
      _startGameController =
      TextEditingController();

  /// 現在ゲーム数
  final TextEditingController
      _currentGameController =
      TextEditingController();

  /// タイトル
  final TextEditingController
      _titleController =
      TextEditingController();

  //==================================================
  // 初期化
  //==================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final provider =
            context.read<CounterProvider>();

        await provider.loadDraft();

        if (!mounted) {
          return;
        }

        //================================================
        // ゲーム数
        //================================================

        _startGameController.text =
            provider.startGame == 0
                ? ''
                : provider.startGame.toString();

        _currentGameController.text =
            provider.currentGame == 0
                ? ''
                : provider.currentGame.toString();

        //================================================
        // タイトル
        //================================================

        _titleController.text =
            provider.title;
      },
    );
  }

  @override
  void dispose() {
    _startGameController.dispose();
    _currentGameController.dispose();
    _titleController.dispose();

    super.dispose();
  }

  //==================================================
  // 日付表示
  //==================================================

  /// 日付を
  /// 「2026年8月18日(火)」
  /// の形式で表示する。
  String _formatDate(
    DateTime date,
  ) {
    return DateFormat(
      'yyyy年M月d日(E)',
      'ja_JP',
    ).format(date);
  }

  //==================================================
  // 日付選択
  //==================================================

  /// 日付を選択する。
  Future<void> _selectDate(
    CounterProvider provider,
  ) async {
    final pickedDate =
        await showDatePicker(
      context: context,
      initialDate:
          provider.selectedDate,
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

    if (pickedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    provider.setSelectedDate(
      pickedDate,
    );
  }

  //==================================================
  // タイトル変更
  //==================================================

  /// タイトル変更
  void _onTitleChanged(
    CounterProvider provider,
    String value,
  ) {
    provider.setTitle(value);
  }

  //==================================================
  // SQLite保存用CounterRecord作成
  //==================================================

  /// SQLite保存用のCounterRecordを作成する。
  ///
  /// 保存時点の
  /// ・日付
  /// ・タイトル
  /// ・開始ゲーム数
  /// ・現在ゲーム数
  /// ・各小役カウント
  /// ・作成日時
  /// ・更新日時
  /// を正式保存用データへまとめる。
  CounterRecord _createCounterRecord(
    CounterProvider provider,
  ) {
    final now =
        DateTime.now();

    return CounterRecord(
      //================================================
      // 基本情報
      //================================================

      date: provider.selectedDate
          .toIso8601String()
          .split('T')
          .first,

      title:
          provider.title.trim(),

      //================================================
      // ゲーム数
      //================================================

      startGame:
          provider.startGame,

      currentGame:
          provider.currentGame,

      //================================================
      // 小役
      //================================================

      cherry: provider.items
          .firstWhere(
            (item) =>
                item.id == 'cherry',
          )
          .count,

      bell: provider.items
          .firstWhere(
            (item) =>
                item.id == 'bell',
          )
          .count,

      suika: provider.items
          .firstWhere(
            (item) =>
                item.id == 'suika',
          )
          .count,

      grape: provider.items
          .firstWhere(
            (item) =>
                item.id == 'grape',
          )
          .count,

      chance: provider.items
          .firstWhere(
            (item) =>
                item.id == 'chance',
          )
          .count,

      //================================================
      // 日時
      //================================================

      createdAt:
          now.toIso8601String(),

      updatedAt:
          now.toIso8601String(),
    );
  }

  //==================================================
  // 保存
  //==================================================

  /// 小役カウンター保存
  ///
  /// 1. 保存確認
  /// 2. SQLiteへ正式保存
  /// 3. 下書き削除
  /// 4. カウンター初期化
  Future<void> _onSave(
    CounterProvider provider,
  ) async {
    final result =
        await DialogService.showConfirm(
      context: context,
      title: '保存しますか？',
      message:
          'カウント内容を保存します。',
      confirmText: '保存',
    );

    if (!mounted) {
      return;
    }

    if (!result) {
      return;
    }

    try {
      //================================================
      // SQLite保存用データ作成
      //================================================

      final record =
          _createCounterRecord(
        provider,
      );

      //================================================
      // SQLiteへ正式保存
      //================================================

      await DatabaseService
          .instance
          .insertCounterRecord(
        record,
      );

      if (!mounted) {
        return;
      }

      //================================================
      // SQLite保存成功後に
      // カウンターを初期化
      //
      // provider.reset()の中で
      // CounterDraftService.clearDraft()
      // も実行される。
      //================================================

      await provider.reset();

      if (!mounted) {
        return;
      }

      //================================================
      // TextFieldも初期状態へ戻す
      //================================================

      _startGameController.clear();
      _currentGameController.clear();
      _titleController.clear();

      //================================================
      // 保存完了
      //================================================

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            '保存しました',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      //================================================
      // SQLite保存失敗
      //
      // この場合はprovider.reset()を
      // 実行しないため、
      // 下書きは残る。
      //================================================

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            '保存に失敗しました。もう一度お試しください。',
          ),
        ),
      );
    }
  }

  //==================================================
  // リセット
  //==================================================

  /// 小役カウンターをリセットする。
  Future<void> _onReset(
    CounterProvider provider,
  ) async {
    final result =
        await DialogService.showConfirm(
      context: context,
      title: 'リセットしますか？',
      message:
          '入力内容をすべてリセットします。',
      confirmText: 'リセット',
    );

    if (!mounted) {
      return;
    }

    if (!result) {
      return;
    }

    //================================================
    // Providerをリセット
    //================================================

    await provider.reset();

    //================================================
    // TextFieldも初期状態へ戻す
    //================================================

    _startGameController.clear();
    _currentGameController.clear();
    _titleController.clear();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'リセットしました',
        ),
      ),
    );
  }

  //==================================================
  // 保存小役データ一覧
  //==================================================

  /// 保存済み小役データ一覧画面を開く。
  Future<void> _openCounterListPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CounterListPage(),
      ),
    );
  }

  //==================================================
  // 日付フィールド
  //==================================================

  Widget _buildDateField(
    BuildContext context,
    CounterProvider provider,
  ) {
    final formattedDate =
        _formatDate(
      provider.selectedDate,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        //================================================
        // ラベル
        //================================================

        Text(
          '日付',
          style: AppTextStyles.body.copyWith(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        //================================================
        // 日付選択
        //================================================

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                _selectDate(provider),
            borderRadius:
                BorderRadius.circular(
              AppRadius.md,
            ),
            child: Ink(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    AppSpacing.md,
                vertical:
                    AppSpacing.md,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.md,
                ),
                border: Border.all(
                  color:
                      AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_month_rounded,
                    color:
                        AppColors.icon,
                  ),

                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),

                  Expanded(
                    child: Text(
                      formattedDate,
                      style:
                          AppTextStyles.body,
                    ),
                  ),

                  const Icon(
                    Icons
                        .arrow_drop_down_rounded,
                    color:
                        AppColors.iconDisabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //==================================================
  // タイトルフィールド
  //==================================================

  Widget _buildTitleField(
    BuildContext context,
    CounterProvider provider,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        //================================================
        // ラベル
        //================================================

        Text(
          'タイトル',
          style: AppTextStyles.body.copyWith(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        //================================================
        // 入力欄
        //================================================

        TextField(
          controller:
              _titleController,
          onChanged: (value) {
            _onTitleChanged(
              provider,
              value,
            );
          },
          textInputAction:
              TextInputAction.done,
          decoration:
              InputDecoration(
            hintText:
                '例：マルハン○○店北斗7番台',
            filled: true,
            fillColor:
                AppColors.surface,
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide:
                  BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .primary,
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
    final provider =
        context.watch<CounterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '小役カウンター',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              AppSpacing.page,
          child: AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                //================================================
                // 日付
                //================================================

                _buildDateField(
                  context,
                  provider,
                ),

                const SizedBox(
                  height:
                      AppSpacing.lg,
                ),

                //================================================
                // タイトル
                //================================================

                _buildTitleField(
                  context,
                  provider,
                ),

                const SizedBox(
                  height:
                      AppSpacing.lg,
                ),

                //================================================
                // 開始ゲーム数
                //================================================

                StartGameCounter(
                  controller:
                      _startGameController,
                  onChanged:
                      provider
                          .updateStartGame,
                ),

                //================================================
                // 現在ゲーム数
                //================================================

                GameCounter(
                  controller:
                      _currentGameController,
                  onChanged:
                      provider
                          .updateCurrentGame,
                ),

                //================================================
                // 小役カウンター
                //================================================

                ...provider.items.map(
                  (item) =>
                      CounterCard(
                    item: item,
                    probability:
                        provider
                            .probability(
                      item.id,
                    ),
                    onIncrement: () {
                      provider
                          .increment(
                        item.id,
                      );
                    },
                    onDecrement: () {
                      provider
                          .decrement(
                        item.id,
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height:
                      AppSpacing.lg,
                ),

                //================================================
                // リセット・保存
                //================================================

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed: () =>
                            _onReset(
                          provider,
                        ),
                        child:
                            const Text(
                          'リセット',
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
                        onPressed: () =>
                            _onSave(
                          provider,
                        ),
                        child:
                            const Text(
                          '保存',
                        ),
                      ),
                    ),
                  ],
                ),

                //================================================
                // 保存小役データ一覧
                //================================================

                const SizedBox(
                  height:
                      AppSpacing.md,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _openCounterListPage,
                    icon: const Icon(
                      Icons.history,
                    ),
                    label:
                        const Text(
                      '小役データ一覧',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}