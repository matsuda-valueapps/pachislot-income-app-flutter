import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/counter_record.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/counter/koyaku_icon.dart';

class CounterEditPage extends StatefulWidget {
  const CounterEditPage({
    super.key,
    required this.record,
  });

  /// 編集対象の小役データ
  final CounterRecord record;

  @override
  State<CounterEditPage> createState() =>
      _CounterEditPageState();
}

class _CounterEditPageState
    extends State<CounterEditPage> {
  //==================================================
  // Controller
  //==================================================

  /// タイトル
  late final TextEditingController
      _titleController;

  /// 開始ゲーム数
  late final TextEditingController
      _startGameController;

  /// 現在ゲーム数
  late final TextEditingController
      _currentGameController;

  /// チェリー
  late final TextEditingController
      _cherryController;

  /// ベル
  late final TextEditingController
      _bellController;

  /// スイカ
  late final TextEditingController
      _suikaController;

  /// ブドウ
  late final TextEditingController
      _grapeController;

  /// チャンス目
  late final TextEditingController
      _chanceController;

  //==================================================
  // 日付
  //==================================================

  late DateTime _selectedDate;

  //==================================================
  // 初期化
  //==================================================

  @override
  void initState() {
    super.initState();

    _selectedDate =
        _parseDate(widget.record.date);

    _titleController =
        TextEditingController(
      text: widget.record.title,
    );

    _startGameController =
        TextEditingController(
      text: widget.record.startGame
          .toString(),
    );

    _currentGameController =
        TextEditingController(
      text: widget.record.currentGame
          .toString(),
    );

    _cherryController =
        TextEditingController(
      text: widget.record.cherry
          .toString(),
    );

    _bellController =
        TextEditingController(
      text: widget.record.bell
          .toString(),
    );

    _suikaController =
        TextEditingController(
      text: widget.record.suika
          .toString(),
    );

    _grapeController =
        TextEditingController(
      text: widget.record.grape
          .toString(),
    );

    _chanceController =
        TextEditingController(
      text: widget.record.chance
          .toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startGameController.dispose();
    _currentGameController.dispose();
    _cherryController.dispose();
    _bellController.dispose();
    _suikaController.dispose();
    _grapeController.dispose();
    _chanceController.dispose();

    super.dispose();
  }

  //==================================================
  // 日付
  //==================================================

  DateTime _parseDate(
    String date,
  ) {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return DateTime.now();
    }
  }

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

  Future<void> _selectDate() async {
    final pickedDate =
        await showDatePicker(
      context: context,
      initialDate:
          _selectedDate,
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

    setState(() {
      _selectedDate =
          pickedDate;
    });
  }

  //==================================================
  // 数値
  //==================================================

  int _parseInt(
    TextEditingController controller,
  ) {
    final value =
        int.tryParse(
      controller.text
          .replaceAll(',', '')
          .trim(),
    );

    if (value == null ||
        value < 0) {
      return 0;
    }

    return value;
  }

  //==================================================
  // 入力フィールド
  //==================================================

  /// 数値入力フィールド
  ///
  /// [koyakuType] が指定されている場合は、
  /// 小役アイコン＋小役名を入力欄の上に表示する。
  ///
  /// ゲーム数など、通常の入力欄では
  /// 従来通りlabelTextを使用する。
  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    KoyakuType? koyakuType,
  }) {
    //================================================
    // 小役入力欄
    //================================================

    if (koyakuType != null) {
      return Padding(
        padding:
            const EdgeInsets.only(
          bottom: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            //==========================================
            // 小役アイコン＋小役名
            //==========================================

            Row(
              children: [
                KoyakuIcon(
                  type: koyakuType,
                  size: 32,
                ),

                const SizedBox(
                  width: AppSpacing.sm,
                ),

                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            //==========================================
            // 数値入力欄
            //==========================================

            TextField(
              controller:
                  controller,
              keyboardType:
                  TextInputType.number,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  InputDecoration(
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
        ),
      );
    }

    //================================================
    // 通常の数値入力欄
    //================================================

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: TextField(
        controller:
            controller,
        keyboardType:
            TextInputType.number,
        textInputAction:
            TextInputAction.next,
        decoration:
            InputDecoration(
          labelText:
              label,
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
    );
  }

  //==================================================
  // SQLite UPDATE
  //==================================================

  Future<void> _updateCounterRecord() async {
    if (widget.record.id == null) {
      throw StateError(
        '編集対象の小役データにIDがありません。',
      );
    }

    final now =
        DateTime.now();

    final updatedRecord =
        CounterRecord(
      //==============================================
      // 元データ
      //==============================================

      id: widget.record.id,

      //==============================================
      // 編集内容
      //==============================================

      date: _selectedDate
          .toIso8601String()
          .split('T')
          .first,

      title:
          _titleController.text.trim(),

      startGame:
          _parseInt(
        _startGameController,
      ),

      currentGame:
          _parseInt(
        _currentGameController,
      ),

      cherry:
          _parseInt(
        _cherryController,
      ),

      bell:
          _parseInt(
        _bellController,
      ),

      suika:
          _parseInt(
        _suikaController,
      ),

      grape:
          _parseInt(
        _grapeController,
      ),

      chance:
          _parseInt(
        _chanceController,
      ),

      //==============================================
      // 作成日時は元データを維持
      //==============================================

      createdAt:
          widget.record.createdAt,

      //==============================================
      // 更新日時だけ現在時刻へ変更
      //==============================================

      updatedAt:
          now.toIso8601String(),
    );

    await DatabaseService.instance
        .updateCounterRecord(
      updatedRecord,
    );
  }

  //==================================================
  // 更新
  //==================================================

  Future<void> _onUpdate() async {
    //================================================
    // 確認ダイアログ
    //================================================

    final result =
        await DialogService.showConfirm(
      context: context,
      title: '更新しますか？',
      message:
          '変更内容を保存します。',
      confirmText: '更新',
    );

    if (!mounted) {
      return;
    }

    if (!result) {
      return;
    }

    try {
      //================================================
      // SQLite UPDATE
      //================================================

      await _updateCounterRecord();

      if (!mounted) {
        return;
      }

      //================================================
      // 更新完了
      //================================================

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '更新しました',
          ),
        ),
      );

      //================================================
      // 詳細画面へ戻る
      //================================================

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '更新に失敗しました。もう一度お試しください。',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '小役データ編集',
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

              AppCard(
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

                    //==========================================
                    // 日付
                    //==========================================

                    Text(
                      '日付',
                      style: AppTextStyles
                          .body
                          .copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.sm,
                    ),

                    Material(
                      color:
                          Colors.transparent,
                      child: InkWell(
                        onTap:
                            _selectDate,
                        borderRadius:
                            BorderRadius
                                .circular(
                          AppRadius.md,
                        ),
                        child: Ink(
                          padding:
                              const EdgeInsets
                                  .symmetric(
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
                                BorderRadius
                                    .circular(
                              AppRadius.md,
                            ),
                            border:
                                Border.all(
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
                                  _formatDate(
                                    _selectedDate,
                                  ),
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

                    const SizedBox(
                      height:
                          AppSpacing.lg,
                    ),

                    //==========================================
                    // タイトル
                    //==========================================

                    TextField(
                      controller:
                          _titleController,
                      textInputAction:
                          TextInputAction.done,
                      decoration:
                          InputDecoration(
                        labelText:
                            'タイトル',
                        hintText:
                            'タイトルを入力してください',
                        filled: true,
                        fillColor:
                            AppColors.surface,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
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
                              BorderRadius
                                  .circular(
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
                              BorderRadius
                                  .circular(
                            AppRadius.md,
                          ),
                          borderSide:
                              BorderSide(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .primary,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              AppSpacing.md,
                          vertical:
                              AppSpacing.md,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              //================================================
              // ゲーム数
              //================================================

              AppCard(
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

                    _buildNumberField(
                      label:
                          '開始ゲーム数',
                      controller:
                          _startGameController,
                    ),

                    _buildNumberField(
                      label:
                          '現在ゲーム数',
                      controller:
                          _currentGameController,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              //================================================
              // 小役
              //================================================

              AppCard(
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

                    //==========================================
                    // チェリー
                    //==========================================

                    _buildNumberField(
                      label:
                          'チェリー',
                      controller:
                          _cherryController,
                      koyakuType:
                          KoyakuType.cherry,
                    ),

                    //==========================================
                    // ベル
                    //==========================================

                    _buildNumberField(
                      label:
                          'ベル',
                      controller:
                          _bellController,
                      koyakuType:
                          KoyakuType.bell,
                    ),

                    //==========================================
                    // スイカ
                    //==========================================

                    _buildNumberField(
                      label:
                          'スイカ',
                      controller:
                          _suikaController,
                      koyakuType:
                          KoyakuType.watermelon,
                    ),

                    //==========================================
                    // ブドウ
                    //==========================================

                    _buildNumberField(
                      label:
                          'ブドウ',
                      controller:
                          _grapeController,
                      koyakuType:
                          KoyakuType.grape,
                    ),

                    //==========================================
                    // チャンス目
                    //==========================================

                    _buildNumberField(
                      label:
                          'チャンス目',
                      controller:
                          _chanceController,
                      koyakuType:
                          KoyakuType.chance,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              //================================================
              // 更新
              //================================================

              PrimaryButton(
                text: '更新',
                onPressed: _onUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}