import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';
import '../services/dialog_service.dart';
import '../services/memo_draft_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import '../widgets/memo/calculator_bottom_sheet.dart';
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

  @override
  void initState() {
    super.initState();

    _loadDraft();

    _titleController.addListener(_saveDraft);

    _memoController.addListener(_saveDraft);
  }

  @override
  void dispose() {
    _titleController.removeListener(_saveDraft);
    _memoController.removeListener(_saveDraft);

    _titleController.dispose();
    _memoController.dispose();

    super.dispose();
  }

  /// 下書き読込
  Future<void> _loadDraft() async {
    final draft =
        await MemoDraftService.loadDraft();

    if (!mounted) return;

    final title = draft['title'] ?? '';
    final body = draft['body'] ?? '';

    _titleController.text = title.isNotEmpty
        ? title
        : DateFormat(
            'yyyy/MM/dd',
          ).format(DateTime.now());

    _memoController.text = body;
  }

  /// 下書き保存
  Future<void> _saveDraft() async {
    await MemoDraftService.saveDraft(
      title: _titleController.text,
      body: _memoController.text,
    );
  }

  /// 保存（SQLite実装予定）
  Future<void> _saveMemo() async {
    final result =
        await DialogService.showConfirm(
      context: context,
      title: '保存しますか？',
      message: 'メモ内容を保存します。',
      confirmText: '保存',
    );

    if (!mounted) {
  return;
    }

    if (!result) {
      return;
    }

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
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, child) {
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
                        (calculator.isVisible
                            ? CalculatorBottomSheet.height +
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

                            const CalculatorToggle(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CalculatorBottomSheet(),
              ),
            ],
          ),
        );
      },
    );
  }
}