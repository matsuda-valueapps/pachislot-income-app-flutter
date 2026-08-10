import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/memo_record.dart';
import '../providers/calculator_provider.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../services/memo_draft_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import '../widgets/memo/calculator_bottom_sheet.dart';
import '../widgets/memo/calculator_toggle.dart';
import '../widgets/memo/memo_date_field.dart';
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
  /// 日付
  DateTime _selectedDate = DateTime.now();

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

  /// 日付選択
  ///
  /// 入力画面と同じカレンダーを表示
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

    await _saveDraft();
  }

  /// 下書き読込
  Future<void> _loadDraft() async {
    final draft = await MemoDraftService.loadDraft();

    if (!mounted) {
      return;
    }

    final dateString = draft['date'] ?? '';

    if (dateString.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(dateString);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
    } else {
      _selectedDate = DateTime.now();
    }

    _titleController.text = draft['title'] ?? '';

    _memoController.text = draft['body'] ?? '';

    setState(() {});
  }

  /// 下書き保存
  Future<void> _saveDraft() async {
    await MemoDraftService.saveDraft(
      date: _selectedDate,
      title: _titleController.text,
      body: _memoController.text,
    );
  }

  /// SQLiteへ正式保存
  Future<void> _saveMemoToDatabase() async {
    final now = DateTime.now();

    final record = MemoRecord(
      date: _selectedDate.toIso8601String().split('T').first,
      title: _titleController.text,
      body: _memoController.text,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );

    await DatabaseService.instance.insertMemoRecord(
      record,
    );
  }

  /// 保存
  Future<void> _saveMemo() async {
    final result = await DialogService.showConfirm(
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

    try {
      // ==========================================
      // SQLiteへ正式保存
      // ==========================================

      await _saveMemoToDatabase();

      if (!mounted) {
        return;
      }

      // ==========================================
      // SQLite保存成功後に下書きを削除
      // ==========================================

      await MemoDraftService.clearDraft();

      if (!mounted) {
        return;
      }

      // ==========================================
      // 保存後は初期状態へ戻す
      // ==========================================

      setState(() {
        _selectedDate = DateTime.now();

        _titleController.clear();

        _memoController.clear();
      });

      // ==========================================
      // 保存完了
      // ==========================================

      ScaffoldMessenger.of(context).showSnackBar(
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

      // ==========================================
      // SQLite保存失敗
      // ==========================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '保存に失敗しました。もう一度お試しください。',
          ),
        ),
      );
    }
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
                            // ==========================================
                            // 日付
                            // ==========================================

                            MemoDateField(
                              selectedDate: _selectedDate,
                              onTap: _selectDate,
                            ),

                            // ==========================================
                            // タイトル
                            // ==========================================

                            MemoTitleField(
                              controller: _titleController,
                            ),

                            // ==========================================
                            // 本文
                            // ==========================================

                            MemoEditor(
                              controller: _memoController,
                            ),

                            // ==========================================
                            // クイック入力
                            // ==========================================

                            QuickInputBar(
                              controller: _memoController,
                            ),

                            // ==========================================
                            // 保存
                            // ==========================================

                            MemoSaveButton(
                              onPressed: _saveMemo,
                            ),

                            // ==========================================
                            // 電卓表示切替
                            // ==========================================

                            const CalculatorToggle(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // 電卓
              // ==========================================

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