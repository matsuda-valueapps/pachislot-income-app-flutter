import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import '../widgets/memo/calculator_bottom_sheet.dart';
import '../widgets/memo/calculator_controller.dart';
import '../widgets/memo/calculator_toggle.dart';
import '../widgets/memo/memo_editor.dart';
import '../widgets/memo/memo_save_button.dart';
import '../widgets/memo/memo_title_field.dart';
import '../widgets/memo/quick_input_bar.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  /// メモタイトル
  final TextEditingController _titleController =
      TextEditingController();

  /// メモ本文
  final TextEditingController _memoController =
      TextEditingController();

  /// 電卓コントローラー
  late final CalculatorController
      _calculatorController;

  /// 電卓表示
  bool _calculatorVisible = false;

  @override
  void initState() {
    super.initState();

    _titleController.text = DateFormat(
      'yyyy/MM/dd',
    ).format(DateTime.now());

    _calculatorController =
        CalculatorController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _calculatorController.dispose();

    super.dispose();
  }

  /// 電卓表示
  void _openCalculator() {
    setState(() {
      _calculatorVisible = true;
    });
  }

  /// 電卓非表示
  void _closeCalculator() {
    setState(() {
      _calculatorVisible = false;
    });
  }

  /// 保存
  void _saveMemo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'SQLite実装時に保存処理を追加します',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.page.left,
                AppSpacing.page.top,
                AppSpacing.page.right,
                AppSpacing.page.bottom +
                    (_calculatorVisible
                        ? CalculatorBottomSheet
                                .height +
                            AppSpacing.lg
                        : 0),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        MemoTitleField(
                          controller:
                              _titleController,
                        ),

                        MemoEditor(
                          controller:
                              _memoController,
                        ),

                        QuickInputBar(
                          controller:
                              _memoController,
                        ),

                        MemoSaveButton(
                          onPressed: _saveMemo,
                        ),

                        CalculatorToggle(
                          isOpen:
                              _calculatorVisible,
                          onPressed:
                              _calculatorVisible
                                  ? _closeCalculator
                                  : _openCalculator,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CalculatorBottomSheet(
              controller:
                  _calculatorController,
              isVisible:
                  _calculatorVisible,
              onClose: _closeCalculator,
            ),
          ),
        ],
      ),
    );
  }
}