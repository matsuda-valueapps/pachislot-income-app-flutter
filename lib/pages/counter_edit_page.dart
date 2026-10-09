import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/counter_record.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/action_button_icon.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/counter/koyaku_icon.dart';
import '../widgets/search/service_icon.dart';

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

class _CounterEditPageState extends State<CounterEditPage> {
  //==================================================
  // Controller
  //==================================================

  /// タイトル
  late final TextEditingController _titleController;

  /// 開始ゲーム数
  late final TextEditingController _startGameController;

  /// 現在ゲーム数
  late final TextEditingController _currentGameController;

  //==================================================
  // 小役カウント（Aタイプ）
  //==================================================

  late final TextEditingController _cherryController;
  late final TextEditingController _bellController;
  late final TextEditingController _suikaController;
  late final TextEditingController _grapeController;
  late final TextEditingController _chanceController;

  //==================================================
  // 小役カウント（ATタイプ）
  //==================================================

  late final TextEditingController _strongCherryController;
  late final TextEditingController _weakCherryController;
  late final TextEditingController _strongBellController;
  late final TextEditingController _weakBellController;
  late final TextEditingController _strongSuikaController;
  late final TextEditingController _weakSuikaController;
  late final TextEditingController _strongGrapeController;
  late final TextEditingController _weakGrapeController;
  late final TextEditingController _strongChanceController;
  late final TextEditingController _weakChanceController;

  //==================================================
  // 機種タイプ
  //==================================================

  late String _machineType;

  bool get _isAtType => _machineType == 'ATタイプ';

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

    _selectedDate = _parseDate(widget.record.date);

    _machineType = widget.record.machineType == 'ATタイプ'
        ? 'ATタイプ'
        : 'Aタイプ';

    _titleController = TextEditingController(
      text: widget.record.title,
    );

    _startGameController = TextEditingController(
      text: widget.record.startGame.toString(),
    );

    _currentGameController = TextEditingController(
      text: widget.record.currentGame.toString(),
    );

    // Aタイプ
    _cherryController = TextEditingController(
      text: widget.record.cherry.toString(),
    );

    _bellController = TextEditingController(
      text: widget.record.bell.toString(),
    );

    _suikaController = TextEditingController(
      text: widget.record.suika.toString(),
    );

    _grapeController = TextEditingController(
      text: widget.record.grape.toString(),
    );

    _chanceController = TextEditingController(
      text: widget.record.chance.toString(),
    );

    // ATタイプ
    _strongCherryController = TextEditingController(
      text: widget.record.strongCherry.toString(),
    );

    _weakCherryController = TextEditingController(
      text: widget.record.weakCherry.toString(),
    );

    _strongBellController = TextEditingController(
      text: widget.record.strongBell.toString(),
    );

    _weakBellController = TextEditingController(
      text: widget.record.weakBell.toString(),
    );

    _strongSuikaController = TextEditingController(
      text: widget.record.strongSuika.toString(),
    );

    _weakSuikaController = TextEditingController(
      text: widget.record.weakSuika.toString(),
    );

    _strongGrapeController = TextEditingController(
      text: widget.record.strongGrape.toString(),
    );

    _weakGrapeController = TextEditingController(
      text: widget.record.weakGrape.toString(),
    );

    _strongChanceController = TextEditingController(
      text: widget.record.strongChance.toString(),
    );

    _weakChanceController = TextEditingController(
      text: widget.record.weakChance.toString(),
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

    _strongCherryController.dispose();
    _weakCherryController.dispose();
    _strongBellController.dispose();
    _weakBellController.dispose();
    _strongSuikaController.dispose();
    _weakSuikaController.dispose();
    _strongGrapeController.dispose();
    _weakGrapeController.dispose();
    _strongChanceController.dispose();
    _weakChanceController.dispose();

    super.dispose();
  }

  //==================================================
  // プレミアムガラスカード
  //==================================================

  /// 小役データ一覧・詳細画面と共通の
  /// プレミアムガラスカード。
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
            color: Color.fromRGBO(70, 120, 170, 0.10),
            blurRadius: 18,
            spreadRadius: -4,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color.fromRGBO(70, 130, 190, 0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: child,
      ),
    );
  }

  //==================================================
  // 日付
  //==================================================

  DateTime _parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat(
      'yyyy年M月d日(E)',
      'ja_JP',
    ).format(date);
  }

  //==================================================
  // 日付選択
  //==================================================

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ja', 'JP'),
    );

    if (pickedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  //==================================================
  // 数値
  //==================================================

  int _parseInt(TextEditingController controller) {
    final value = int.tryParse(
      controller.text.replaceAll(',', '').trim(),
    );

    if (value == null || value < 0) {
      return 0;
    }

    return value;
  }

  //==================================================
  // 機種タイプ選択
  //==================================================

  Widget _buildMachineTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '機種タイプ',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        DropdownButtonFormField<String>(
          initialValue: _machineType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Aタイプ',
              child: Text('Aタイプ'),
            ),
            DropdownMenuItem(
              value: 'ATタイプ',
              child: Text('ATタイプ'),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _machineType = value;
            });
          },
        ),
      ],
    );
  }

  //==================================================
  // 入力フィールド
  //==================================================

  /// 数値入力フィールド
  ///
  /// koyakuTypeが指定されている場合は、
  /// 小役アイコンと小役名を入力欄の上に表示する。
  ///
  /// Aタイプ：アイコン36px
  /// ATタイプ：強小役36px、弱小役28px
  ///
  /// アイコンの表示領域を36pxで統一し、
  /// 強・弱でサイズが変わっても小役名の位置を揃える。
  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    KoyakuType? koyakuType,
  }) {
    if (koyakuType != null) {
      final bool isWeakAtType =
          _isAtType && label.startsWith('弱');

      final double iconSize = isWeakAtType ? 28 : 36;

      return Padding(
        padding: const EdgeInsets.only(
          bottom: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: KoyakuIcon(
                      type: koyakuType,
                      size: iconSize,
                    ),
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: _inputDecoration(label: label),
      ),
    );
  }

  //==================================================
  // 入力欄の共通デザイン
  //==================================================

  InputDecoration _inputDecoration({
    String? label,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
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

    final now = DateTime.now();

    final updatedRecord = CounterRecord(
      // 元データ
      id: widget.record.id,

      // 基本情報
      date: _selectedDate.toIso8601String().split('T').first,
      title: _titleController.text.trim(),
      machineType: _machineType,

      // ゲーム数
      startGame: _parseInt(_startGameController),
      currentGame: _parseInt(_currentGameController),

      // Aタイプ
      cherry: _parseInt(_cherryController),
      bell: _parseInt(_bellController),
      suika: _parseInt(_suikaController),
      grape: _parseInt(_grapeController),
      chance: _parseInt(_chanceController),

      // ATタイプ
      strongCherry: _parseInt(_strongCherryController),
      weakCherry: _parseInt(_weakCherryController),
      strongBell: _parseInt(_strongBellController),
      weakBell: _parseInt(_weakBellController),
      strongSuika: _parseInt(_strongSuikaController),
      weakSuika: _parseInt(_weakSuikaController),
      strongGrape: _parseInt(_strongGrapeController),
      weakGrape: _parseInt(_weakGrapeController),
      strongChance: _parseInt(_strongChanceController),
      weakChance: _parseInt(_weakChanceController),

      // 作成日時は元データを維持
      createdAt: widget.record.createdAt,

      // 更新日時だけ現在時刻へ変更
      updatedAt: now.toIso8601String(),
    );

    await DatabaseService.instance.updateCounterRecord(
      updatedRecord,
    );
  }

  //==================================================
  // 更新
  //==================================================

  Future<void> _onUpdate() async {
    final result = await DialogService.showConfirm(
      context: context,
      title: '更新しますか？',
      message: '変更内容を保存します。',
      confirmText: '更新',
    );

    if (!mounted) {
      return;
    }

    if (!result) {
      return;
    }

    try {
      await _updateCounterRecord();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('更新しました'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小役DATA編集'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //==========================================
              // 基本情報
              //==========================================

              _buildPremiumGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppSpacing.md,
                  ),
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

                      // 日付
                      Text(
                        '日付',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(
                            AppRadius.md,
                          ),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.md,
                              ),
                              border: Border.all(
                                color: AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                const ServiceIcon(
                                  icon: 'google_calendar',
                                  size: 38,
                                ),
                                const SizedBox(
                                  width: AppSpacing.md,
                                ),
                                Expanded(
                                  child: Text(
                                    _formatDate(_selectedDate),
                                    style: AppTextStyles.body,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: AppColors.iconDisabled,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      // 機種タイプ
                      _buildMachineTypeSelector(),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      // タイトル
                      TextField(
                        controller: _titleController,
                        textInputAction: TextInputAction.done,
                        decoration: _inputDecoration(
                          label: 'タイトル',
                        ).copyWith(
                          hintText: 'タイトルを入力してください',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.gapLg,

              //==========================================
              // ゲーム数
              //==========================================

              _buildPremiumGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppSpacing.md,
                  ),
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
                      _buildNumberField(
                        label: '開始ゲーム数',
                        controller: _startGameController,
                      ),
                      _buildNumberField(
                        label: '現在ゲーム数',
                        controller: _currentGameController,
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.gapLg,

              //==========================================
              // 小役カウント
              //==========================================

              _buildPremiumGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppSpacing.md,
                  ),
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
                        // ATタイプ：強・弱チェリー
                        _buildNumberField(
                          label: '強チェリー',
                          controller: _strongCherryController,
                          koyakuType: KoyakuType.cherry,
                        ),
                        _buildNumberField(
                          label: '弱チェリー',
                          controller: _weakCherryController,
                          koyakuType: KoyakuType.cherry,
                        ),

                        // ATタイプ：強・弱ベル
                        _buildNumberField(
                          label: '強ベル',
                          controller: _strongBellController,
                          koyakuType: KoyakuType.bell,
                        ),
                        _buildNumberField(
                          label: '弱ベル',
                          controller: _weakBellController,
                          koyakuType: KoyakuType.bell,
                        ),

                        // ATタイプ：強・弱スイカ
                        _buildNumberField(
                          label: '強スイカ',
                          controller: _strongSuikaController,
                          koyakuType: KoyakuType.watermelon,
                        ),
                        _buildNumberField(
                          label: '弱スイカ',
                          controller: _weakSuikaController,
                          koyakuType: KoyakuType.watermelon,
                        ),

                        // ATタイプ：強・弱ブドウ
                        _buildNumberField(
                          label: '強ブドウ',
                          controller: _strongGrapeController,
                          koyakuType: KoyakuType.grape,
                        ),
                        _buildNumberField(
                          label: '弱ブドウ',
                          controller: _weakGrapeController,
                          koyakuType: KoyakuType.grape,
                        ),

                        // ATタイプ：強・弱チャンス目
                        _buildNumberField(
                          label: '強チャンス目',
                          controller: _strongChanceController,
                          koyakuType: KoyakuType.chance,
                        ),
                        _buildNumberField(
                          label: '弱チャンス目',
                          controller: _weakChanceController,
                          koyakuType: KoyakuType.chance,
                        ),
                      ] else ...[
                        // Aタイプ：従来の5種類
                        _buildNumberField(
                          label: 'チェリー',
                          controller: _cherryController,
                          koyakuType: KoyakuType.cherry,
                        ),
                        _buildNumberField(
                          label: 'ベル',
                          controller: _bellController,
                          koyakuType: KoyakuType.bell,
                        ),
                        _buildNumberField(
                          label: 'スイカ',
                          controller: _suikaController,
                          koyakuType: KoyakuType.watermelon,
                        ),
                        _buildNumberField(
                          label: 'ブドウ',
                          controller: _grapeController,
                          koyakuType: KoyakuType.grape,
                        ),
                        _buildNumberField(
                          label: 'チャンス目',
                          controller: _chanceController,
                          koyakuType: KoyakuType.chance,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              AppSpacing.gapLg,

              //==========================================
              // 更新
              //==========================================

              PrimaryButton(
                text: '更新',
                onPressed: _onUpdate,
                iconWidget: const ActionButtonIcon.update(
                  size: 38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}