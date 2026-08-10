import 'package:flutter/material.dart';

import '../models/income_record.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../services/input_draft_service.dart';

import '../theme/app_spacing.dart';

import '../widgets/common/app_card.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/input/amount_field.dart';
import '../widgets/input/date_field.dart';
import '../widgets/input/profit_card.dart';
import '../widgets/input/text_input_field.dart';
import '../widgets/input/memo_field.dart';

import '../utils/input_validators.dart';

class InputPage extends StatefulWidget {
  const InputPage({
    super.key,
    this.record,
  });

  /// 編集対象の収支データ
  ///
  /// nullの場合は新規入力。
  /// null以外の場合は編集モード。
  final IncomeRecord? record;

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  /// 編集モードかどうか
  bool get _isEditMode => widget.record != null;

  /// 保存後の画面初期化中フラグ
  bool _isResetting = false;

  /// Form管理
  final _formKey = GlobalKey<FormState>();

  /// 日付
  DateTime _selectedDate = DateTime.now();

  /// ホール名
  final _hallController = TextEditingController();

  /// 機種名
  final _machineController = TextEditingController();

  /// 貯メダル投資
  final _medalInvestController =
      TextEditingController(text: '0');

  /// 現金投資
  final _cashInvestController =
      TextEditingController(text: '0');

  /// 貯メダル回収
  final _medalReturnController =
      TextEditingController(text: '0');

  /// 現金回収
  final _cashReturnController =
      TextEditingController(text: '0');

  /// 収支
  int _profit = 0;

  /// メモ
  final _memoController = TextEditingController();

  //==================================================
  // 初期化
  //==================================================

  @override
  void initState() {
    super.initState();

    // ============================================================
    // 新規 / 編集を分離
    // ============================================================

    if (_isEditMode) {
      // 編集モードではSQLiteの既存データを読み込む。
      _loadRecord();
    } else {
      // 新規モードでは下書きを読み込む。
      _loadDraft();
    }

    // ============================================================
    // 収支計算
    // ============================================================

    _medalInvestController.addListener(
      _calculateProfit,
    );

    _cashInvestController.addListener(
      _calculateProfit,
    );

    _medalReturnController.addListener(
      _calculateProfit,
    );

    _cashReturnController.addListener(
      _calculateProfit,
    );

    // ============================================================
    // 下書き保存
    //
    // 新規モードのみ使用する。
    // 編集モードでは下書きを使用しない。
    // ============================================================

    if (!_isEditMode) {
      _hallController.addListener(
        _saveDraft,
      );

      _machineController.addListener(
        _saveDraft,
      );

      _medalInvestController.addListener(
        _saveDraft,
      );

      _cashInvestController.addListener(
        _saveDraft,
      );

      _medalReturnController.addListener(
        _saveDraft,
      );

      _cashReturnController.addListener(
        _saveDraft,
      );

      _memoController.addListener(
        _saveDraft,
      );
    }
  }

  @override
  void dispose() {
    // ============================================================
    // 収支計算Listener解除
    // ============================================================

    _medalInvestController.removeListener(
      _calculateProfit,
    );

    _cashInvestController.removeListener(
      _calculateProfit,
    );

    _medalReturnController.removeListener(
      _calculateProfit,
    );

    _cashReturnController.removeListener(
      _calculateProfit,
    );

    // ============================================================
    // 下書き保存Listener解除
    //
    // 新規モードのみ登録しているため、
    // 新規モードのみ解除する。
    // ============================================================

    if (!_isEditMode) {
      _hallController.removeListener(
        _saveDraft,
      );

      _machineController.removeListener(
        _saveDraft,
      );

      _medalInvestController.removeListener(
        _saveDraft,
      );

      _cashInvestController.removeListener(
        _saveDraft,
      );

      _medalReturnController.removeListener(
        _saveDraft,
      );

      _cashReturnController.removeListener(
        _saveDraft,
      );

      _memoController.removeListener(
        _saveDraft,
      );
    }

    // ============================================================
    // Controller破棄
    // ============================================================

    _hallController.dispose();
    _machineController.dispose();
    _memoController.dispose();

    _medalInvestController.dispose();
    _cashInvestController.dispose();
    _medalReturnController.dispose();
    _cashReturnController.dispose();

    super.dispose();
  }

  //==================================================
  // 日付
  //==================================================

  /// 日付選択
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

    // 新規モードのみ下書き保存。
    if (!_isEditMode) {
      await _saveDraft();
    }
  }

  //==================================================
  // 金額
  //==================================================

  /// 金額文字列を数値へ変換（カンマ除去）
  int _parseAmount(
    TextEditingController controller,
  ) {
    return int.tryParse(
          controller.text.replaceAll(',', ''),
        ) ??
        0;
  }

  /// 金額欄の文字列をSQLite保存用の整数へ変換
  int _parseAmountText(
    TextEditingController controller,
  ) {
    return int.tryParse(
          controller.text.replaceAll(',', ''),
        ) ??
        0;
  }

  /// 整数を入力欄表示用の3桁カンマ付き文字列へ変換
  String _formatAmount(int amount) {
    final value = amount.abs().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final position = value.length - i;

      buffer.write(value[i]);

      if (position > 1 &&
          position % 3 == 1) {
        buffer.write(',');
      }
    }

    if (amount < 0) {
      return '-${buffer.toString()}';
    }

    return buffer.toString();
  }

  //==================================================
  // 収支計算
  //==================================================

  /// 収支計算
  void _calculateProfit() {
    final medalInvest =
        _parseAmount(
      _medalInvestController,
    );

    final cashInvest =
        _parseAmount(
      _cashInvestController,
    );

    final medalReturn =
        _parseAmount(
      _medalReturnController,
    );

    final cashReturn =
        _parseAmount(
      _cashReturnController,
    );

    final newProfit =
        (medalReturn + cashReturn) -
        (medalInvest + cashInvest);

    if (_profit != newProfit) {
      if (!mounted) {
        _profit = newProfit;
        return;
      }

      setState(() {
        _profit = newProfit;
      });
    }
  }

  //==================================================
  // 新規モード
  //==================================================

  /// 下書き読込
  ///
  /// 新規入力時のみ使用する。
  Future<void> _loadDraft() async {
    final draft =
        await InputDraftService.loadDraft();

    if (!mounted) {
      return;
    }

    setState(() {
      final dateString =
          draft['date'];

      if (dateString != null &&
          dateString
              .toString()
              .isNotEmpty) {
        try {
          _selectedDate =
              DateTime.parse(
            dateString.toString(),
          );
        } catch (_) {
          _selectedDate =
              DateTime.now();
        }
      }

      _hallController.text =
          draft['hall'] ?? '';

      _machineController.text =
          draft['machine'] ?? '';

      _medalInvestController.text =
          draft['medalInvest'] ?? '0';

      _cashInvestController.text =
          draft['cashInvest'] ?? '0';

      _medalReturnController.text =
          draft['medalReturn'] ?? '0';

      _cashReturnController.text =
          draft['cashReturn'] ?? '0';

      _memoController.text =
          draft['memo'] ?? '';
    });

    _calculateProfit();
  }

  /// 下書き保存
  ///
  /// 新規入力時のみ使用する。
  Future<void> _saveDraft() async {
    if (_isResetting) {
      return;
    }

    if (_isEditMode) {
      return;
    }

    await InputDraftService.saveDraft(
      date: _selectedDate,
      hall: _hallController.text,
      machine: _machineController.text,
      medalInvest:
          _medalInvestController.text,
      cashInvest:
          _cashInvestController.text,
      medalReturn:
          _medalReturnController.text,
      cashReturn:
          _cashReturnController.text,
      memo: _memoController.text,
    );
  }

  //==================================================
  // 編集モード
  //==================================================

  /// 保存済みデータを入力欄へ読み込む
  ///
  /// 編集モードではSharedPreferencesの下書きではなく、
  /// IncomeRecordの正式保存データを使用する。
  void _loadRecord() {
    final record = widget.record;

    if (record == null) {
      return;
    }

    DateTime parsedDate;

    try {
      parsedDate =
          DateTime.parse(record.date);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    _selectedDate = parsedDate;

    _hallController.text =
        record.hall;

    _machineController.text =
        record.machine;

    _medalInvestController.text =
        _formatAmount(
      record.medalInvest,
    );

    _cashInvestController.text =
        _formatAmount(
      record.cashInvest,
    );

    _medalReturnController.text =
        _formatAmount(
      record.medalReturn,
    );

    _cashReturnController.text =
        _formatAmount(
      record.cashReturn,
    );

    _memoController.text =
        record.memo;

    _profit = record.profit;
  }

  //==================================================
  // 新規保存後の初期化
  //==================================================

  /// 保存成功後に入力画面を初期状態へ戻す
  ///
  /// 新規保存時のみ使用する。
  Future<void> _resetAfterSave() async {
    _isResetting = true;

    if (mounted) {
      setState(() {
        _selectedDate =
            DateTime.now();

        _hallController.clear();
        _machineController.clear();

        _medalInvestController.text =
            '0';

        _cashInvestController.text =
            '0';

        _medalReturnController.text =
            '0';

        _cashReturnController.text =
            '0';

        _memoController.clear();

        _profit = 0;
      });
    }

    _isResetting = false;

    // 正式保存が成功した後に
    // 下書きを削除する。
    await InputDraftService.clearDraft();
  }

  //==================================================
  // SQLite INSERT
  //==================================================

  /// 新規データをSQLiteへ正式保存
  ///
  /// 新規モード専用。
  Future<void> _insertIncomeRecord() async {
    final now = DateTime.now();

    final record = IncomeRecord(
      date: _selectedDate
          .toIso8601String()
          .split('T')
          .first,
      hall:
          _hallController.text.trim(),
      machine:
          _machineController.text.trim(),
      medalInvest:
          _parseAmountText(
        _medalInvestController,
      ),
      cashInvest:
          _parseAmountText(
        _cashInvestController,
      ),
      medalReturn:
          _parseAmountText(
        _medalReturnController,
      ),
      cashReturn:
          _parseAmountText(
        _cashReturnController,
      ),
      profit: _profit,
      memo: _memoController.text,
      createdAt:
          now.toIso8601String(),
      updatedAt:
          now.toIso8601String(),
    );

    await DatabaseService.instance
        .insertIncomeRecord(record);
  }

  //==================================================
  // SQLite UPDATE
  //==================================================

  /// 既存データをSQLiteへ更新
  ///
  /// 編集モード専用。
  Future<void> _updateIncomeRecord() async {
    final originalRecord =
        widget.record;

    if (originalRecord == null) {
      throw StateError(
        '編集対象の収支データがありません。',
      );
    }

    if (originalRecord.id == null) {
      throw StateError(
        '編集対象の収支データにIDがありません。',
      );
    }

    final now = DateTime.now();

    final updatedRecord =
        IncomeRecord(
      id: originalRecord.id,
      date: _selectedDate
          .toIso8601String()
          .split('T')
          .first,
      hall:
          _hallController.text.trim(),
      machine:
          _machineController.text.trim(),
      medalInvest:
          _parseAmountText(
        _medalInvestController,
      ),
      cashInvest:
          _parseAmountText(
        _cashInvestController,
      ),
      medalReturn:
          _parseAmountText(
        _medalReturnController,
      ),
      cashReturn:
          _parseAmountText(
        _cashReturnController,
      ),
      profit: _profit,
      memo: _memoController.text,
      // 作成日時は元データを維持する。
      createdAt:
          originalRecord.createdAt,
      // 更新日時だけ現在時刻へ変更する。
      updatedAt:
          now.toIso8601String(),
    );

    await DatabaseService.instance
        .updateIncomeRecord(
      updatedRecord,
    );
  }

  //==================================================
  // 保存
  //==================================================

  /// 保存ボタン
  ///
  /// 新規モード：
  /// INSERT
  ///
  /// 編集モード：
  /// UPDATE
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final result =
        await DialogService.showConfirm(
      context: context,
      title: _isEditMode
          ? '更新しますか？'
          : '保存しますか？',
      message: _isEditMode
          ? '変更内容を保存します。'
          : '入力内容を保存します。',
      confirmText:
          _isEditMode
              ? '更新'
              : '保存',
    );

    if (!mounted) {
      return;
    }

    if (!result) {
      return;
    }

    try {
      // ==========================================================
      // 新規 / 編集を分離
      // ==========================================================

      if (_isEditMode) {
        // --------------------------------------------------------
        // 編集
        // SQLite UPDATE
        // --------------------------------------------------------

        await _updateIncomeRecord();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              '更新しました',
            ),
          ),
        );

        // 編集完了後は詳細画面へ戻る。
        Navigator.of(context).pop(true);
      } else {
        // --------------------------------------------------------
        // 新規
        // SQLite INSERT
        // --------------------------------------------------------

        await _insertIncomeRecord();

        if (!mounted) {
          return;
        }

        // SQLite保存成功後に
        // 下書きを削除して画面を初期化する。
        await _resetAfterSave();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              '保存しました',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? '更新に失敗しました。もう一度お試しください。'
                : '保存に失敗しました。もう一度お試しください。',
          ),
        ),
      );
    }
  }

  //==================================================
  // UI
  //==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? '編集'
              : '入力',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 日付
                    // ==========================================

                    DateField(
                      selectedDate:
                          _selectedDate,
                      onTap:
                          _selectDate,
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.lg,
                    ),

                    // ==========================================
                    // ホール名
                    // ==========================================

                    TextInputField(
                      label: 'ホール名',
                      controller:
                          _hallController,
                      hintText:
                          '例：マルハン○○店',
                      validator:
                          (value) =>
                              InputValidators
                                  .required(
                        value,
                        fieldName:
                            'ホール名',
                      ),
                    ),

                    // ==========================================
                    // 機種名
                    // ==========================================

                    TextInputField(
                      label: '機種名',
                      controller:
                          _machineController,
                      hintText:
                          '例：L北斗の拳',
                      validator:
                          (value) =>
                              InputValidators
                                  .required(
                        value,
                        fieldName:
                            '機種名',
                      ),
                    ),

                    // ==========================================
                    // 貯メダル投資
                    // ==========================================

                    AmountField(
                      label:
                          '貯メダル投資（円）',
                      controller:
                          _medalInvestController,
                      validator:
                          InputValidators
                              .amount,
                    ),

                    // ==========================================
                    // 現金投資
                    // ==========================================

                    AmountField(
                      label:
                          '現金投資（円）',
                      controller:
                          _cashInvestController,
                      validator:
                          InputValidators
                              .amount,
                    ),

                    // ==========================================
                    // 貯メダル回収
                    // ==========================================

                    AmountField(
                      label:
                          '貯メダル回収（円）',
                      controller:
                          _medalReturnController,
                      validator:
                          InputValidators
                              .amount,
                    ),

                    // ==========================================
                    // 現金回収
                    // ==========================================

                    AmountField(
                      label:
                          '現金回収（円）',
                      controller:
                          _cashReturnController,
                      validator:
                          InputValidators
                              .amount,
                    ),

                    const SizedBox(
                      height:
                          AppSpacing.lg,
                    ),

                    // ==========================================
                    // 収支
                    // ==========================================

                    ProfitCard(
                      profit: _profit,
                    ),

                    // ==========================================
                    // メモ
                    // ==========================================

                    MemoField(
                      controller:
                          _memoController,
                      hintText:
                          '自由にメモを入力できます',
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height:
                    AppSpacing.xl,
              ),

              // ==========================================
              // 保存 / 更新
              // ==========================================

              PrimaryButton(
                text: _isEditMode
                    ? '更新'
                    : '保存',
                onPressed:
                    _onSavePressed,
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}