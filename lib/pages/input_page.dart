import 'package:flutter/material.dart';

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
final _memoController = TextEditingController();

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
  }

  /// 収支計算
  void _calculateProfit() {
    final medalInvest =
        int.tryParse(_medalInvestController.text) ?? 0;

    final cashInvest =
        int.tryParse(_cashInvestController.text) ?? 0;

    final medalReturn =
        int.tryParse(_medalReturnController.text) ?? 0;

    final cashReturn =
        int.tryParse(_cashReturnController.text) ?? 0;

    final newProfit =
        (medalReturn + cashReturn) -
        (medalInvest + cashInvest);

    if (_profit != newProfit) {
      setState(() {
        _profit = newProfit;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _medalInvestController.addListener(_calculateProfit);
    _cashInvestController.addListener(_calculateProfit);
    _medalReturnController.addListener(_calculateProfit);
    _cashReturnController.addListener(_calculateProfit);

    // 初期表示時にも収支を計算
    _calculateProfit();
  }

  @override
  void dispose() {
    _medalInvestController.removeListener(_calculateProfit);
    _cashInvestController.removeListener(_calculateProfit);
    _medalReturnController.removeListener(_calculateProfit);
    _cashReturnController.removeListener(_calculateProfit);

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    DateField(
                      selectedDate: _selectedDate,
                      onTap: _selectDate,
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    TextInputField(
                      label: 'ホール名',
                      controller: _hallController,
                      hintText: '例：マルハン○○店',
                      validator: (value) =>
                          InputValidators.required(
                            value,
                            fieldName: 'ホール名',
                          ),
                    ),

                    TextInputField(
                      label: '機種名',
                      controller: _machineController,
                      hintText: '例：L北斗の拳',
                      validator: (value) =>
                          InputValidators.required(
                            value,
                            fieldName: '機種名',
                          ),
                    ),

                    AmountField(
                      label: '貯メダル投資（円）',
                      controller: _medalInvestController,
                      validator: InputValidators.amount,
                    ),

                    AmountField(
                      label: '現金投資（円）',
                      controller: _cashInvestController,
                      validator: InputValidators.amount,
                    ),

                    AmountField(
                      label: '貯メダル回収（円）',
                      controller: _medalReturnController,
                      validator: InputValidators.amount,
                    ),

                    AmountField(
                      label: '現金回収（円）',
                      controller: _cashReturnController,
                      validator: InputValidators.amount,
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    ProfitCard(
                      profit: _profit,
                    ),
                    MemoField(
                      controller: _memoController,
                      hintText: '自由にメモを入力できます',
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              PrimaryButton(
                text: '保存する',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Step7(SQLite)で実装
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}