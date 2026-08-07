import 'package:flutter/material.dart';

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
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
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
  final _memoController =
      TextEditingController();

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

    setState(() {
      _selectedDate = pickedDate;
    });

    await _saveDraft();
  }

    /// 金額文字列を数値へ変換（カンマ除去）
    int _parseAmount(
      TextEditingController controller,
    ) {
      return int.tryParse(
            controller.text.replaceAll(',', ''),
          ) ??
          0;
    }

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
        setState(() {
          _profit = newProfit;
        });
      }
    }

    /// 下書き読込
    Future<void> _loadDraft() async {
      final draft =
          await InputDraftService.loadDraft();

      if (!mounted) return;

      setState(() {
        final dateString = draft['date'];

        if (dateString != null &&
            dateString.toString().isNotEmpty) {
          _selectedDate =
              DateTime.parse(dateString);
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
    Future<void> _saveDraft() async {
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

  @override
  void initState() {
    super.initState();
    _loadDraft();

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

  @override
  void dispose() {
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

    _hallController.dispose();
    _machineController.dispose();
    _memoController.dispose();

    _medalInvestController.dispose();
    _cashInvestController.dispose();
    _medalReturnController.dispose();
    _cashReturnController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('入力'),
        centerTitle: true,
      ),
      body: Form(
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
                    DateField(
                      selectedDate:
                          _selectedDate,
                      onTap: _selectDate,
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    TextInputField(
                      label: 'ホール名',
                      controller:
                          _hallController,
                      hintText:
                          '例：マルハン○○店',
                      validator: (value) =>
                          InputValidators
                              .required(
                            value,
                            fieldName:
                                'ホール名',
                          ),
                    ),

                    TextInputField(
                      label: '機種名',
                      controller:
                          _machineController,
                      hintText:
                          '例：L北斗の拳',
                      validator: (value) =>
                          InputValidators
                              .required(
                            value,
                            fieldName:
                                '機種名',
                          ),
                    ),

                    AmountField(
                      label:
                          '貯メダル投資（円）',
                      controller:
                          _medalInvestController,
                      validator:
                          InputValidators
                              .amount,
                    ),

                    AmountField(
                      label:
                          '現金投資（円）',
                      controller:
                          _cashInvestController,
                      validator:
                          InputValidators
                              .amount,
                    ),

                    AmountField(
                      label:
                          '貯メダル回収（円）',
                      controller:
                          _medalReturnController,
                      validator:
                          InputValidators
                              .amount,
                    ),

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
                      height: AppSpacing.lg,
                    ),

                    ProfitCard(
                      profit: _profit,
                    ),

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
                height: AppSpacing.xl,
              ),

              PrimaryButton(
                text: '保存',
                onPressed: () async {
                  if (!_formKey.currentState!
                      .validate()) {
                    return;
                  }

                  final result =
                      await DialogService
                          .showConfirm(
                    context: context,
                    title: '保存しますか？',
                    message:
                        '入力内容を保存します。',
                    confirmText: '保存',
                  );

                  if (!mounted) {
                    return;
                  }

                  if (!result) {
                    return;
                  }

                  // Step7(SQLite)で実装
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}