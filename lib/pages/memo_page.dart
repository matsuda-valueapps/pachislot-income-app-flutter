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
import 'memo_list_page.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({
    super.key,
    this.record,
  });

  /// 編集する既存メモ。
  ///
  /// nullの場合：
  /// → 新規メモ
  ///
  /// nullではない場合：
  /// → 既存メモの編集
  final MemoRecord? record;

  @override
  State<MemoPage> createState() =>
      _MemoPageState();
}

class _MemoPageState
    extends State<MemoPage> {
  //==================================================
  // メモ入力
  //==================================================

  /// 日付
  DateTime _selectedDate =
      DateTime.now();

  /// メモタイトル
  final TextEditingController
      _titleController =
      TextEditingController();

  /// メモ本文
  final TextEditingController
      _memoController =
      TextEditingController();

  //==================================================
  // 編集モード
  //==================================================

  /// 既存メモを編集しているかどうか。
  ///
  /// recordが指定されている場合：
  /// → 編集モード
  ///
  /// recordがnullの場合：
  /// → 新規作成モード
  bool get _isEditMode =>
      widget.record != null;

  //==================================================
  // Init / Dispose
  //==================================================

  @override
  void initState() {
    super.initState();

    //================================================
    // 編集モード
    //================================================
    //
    // 既存メモの内容をそのまま入力欄へセットする。
    //
    // 編集モードでは下書き機能を使用しない。
    //================================================

    if (_isEditMode) {
      _loadRecordForEdit();

      return;
    }

    //================================================
    // 新規作成モード
    //================================================
    //
    // 従来どおり下書きを読み込む。
    //================================================

    _loadDraft();

    _titleController.addListener(
      _saveDraft,
    );

    _memoController.addListener(
      _saveDraft,
    );
  }

  @override
  void dispose() {
    //================================================
    // 新規作成モードの場合のみ
    // 下書き保存Listenerを解除する。
    //================================================

    if (!_isEditMode) {
      _titleController.removeListener(
        _saveDraft,
      );

      _memoController.removeListener(
        _saveDraft,
      );
    }

    _titleController.dispose();
    _memoController.dispose();

    super.dispose();
  }

  //==================================================
  // 編集データ読込
  //==================================================

  /// 既存メモを編集画面へ読み込む。
  void _loadRecordForEdit() {
    final record =
        widget.record;

    if (record == null) {
      return;
    }

    //================================================
    // 日付
    //================================================

    try {
      _selectedDate =
          DateTime.parse(
        record.date,
      );
    } catch (_) {
      _selectedDate =
          DateTime.now();
    }

    //================================================
    // タイトル
    //================================================

    _titleController.text =
        record.title;

    //================================================
    // 本文
    //================================================

    _memoController.text =
        record.body;
  }

  //==================================================
  // 日付選択
  //==================================================

  /// 日付選択
  ///
  /// 入力画面と同じカレンダーを表示。
  Future<void> _selectDate() async {
    final pickedDate =
        await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale(
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

    //================================================
    // 新規作成モードの場合のみ
    // 下書きを更新する。
    //================================================

    if (!_isEditMode) {
      await _saveDraft();
    }
  }

  //==================================================
  // 下書き読込
  //==================================================

  /// 新規メモ用の下書きを読み込む。
  ///
  /// 編集モードでは使用しない。
  Future<void> _loadDraft() async {
    final draft =
        await MemoDraftService.loadDraft();

    if (!mounted) {
      return;
    }

    final dateString =
        draft['date'] ?? '';

    if (dateString.isNotEmpty) {
      try {
        _selectedDate =
            DateTime.parse(
          dateString,
        );
      } catch (_) {
        _selectedDate =
            DateTime.now();
      }
    } else {
      _selectedDate =
          DateTime.now();
    }

    _titleController.text =
        draft['title'] ?? '';

    _memoController.text =
        draft['body'] ?? '';

    setState(() {});
  }

  //==================================================
  // 下書き保存
  //==================================================

  /// 新規メモの下書きを保存する。
  ///
  /// 編集モードでは何もしない。
  Future<void> _saveDraft() async {
    if (_isEditMode) {
      return;
    }

    await MemoDraftService.saveDraft(
      date: _selectedDate,
      title:
          _titleController.text,
      body:
          _memoController.text,
    );
  }

  //==================================================
  // SQLite正式保存
  //==================================================

  /// 新規メモをSQLiteへ正式保存する。
  Future<void>
      _saveMemoToDatabase() async {
    final now =
        DateTime.now();

    final record =
        MemoRecord(
      date: _selectedDate
          .toIso8601String()
          .split('T')
          .first,
      title:
          _titleController.text,
      body:
          _memoController.text,
      createdAt:
          now.toIso8601String(),
      updatedAt:
          now.toIso8601String(),
    );

    await DatabaseService
        .instance
        .insertMemoRecord(
      record,
    );
  }

  //==================================================
  // SQLite更新
  //==================================================

  /// 編集中の既存メモをSQLiteへ更新する。
  Future<void>
      _updateMemoInDatabase() async {
    final record =
        widget.record;

    //================================================
    // 編集対象が存在しない場合
    //================================================

    if (record == null) {
      throw StateError(
        '編集対象のメモが存在しません。',
      );
    }

    //================================================
    // ID確認
    //================================================
    //
    // SQLiteの更新にはIDが必要。
    //================================================

    if (record.id == null) {
      throw StateError(
        '編集対象のメモIDが存在しません。',
      );
    }

    final now =
        DateTime.now();

    //================================================
    // 更新用MemoRecord
    //================================================
    //
    // id：
    // → 既存IDを維持
    //
    // date：
    // → 編集画面で選択した日付
    //
    // title：
    // → 編集後のタイトル
    //
    // body：
    // → 編集後の本文
    //
    // createdAt：
    // → 元の作成日時を維持
    //
    // updatedAt：
    // → 現在日時へ更新
    //================================================

    final updatedRecord =
        MemoRecord(
      id: record.id,
      date: _selectedDate
          .toIso8601String()
          .split('T')
          .first,
      title:
          _titleController.text,
      body:
          _memoController.text,
      createdAt:
          record.createdAt,
      updatedAt:
          now.toIso8601String(),
    );

    await DatabaseService
        .instance
        .updateMemoRecord(
      updatedRecord,
    );
  }

  //==================================================
  // 保存
  //==================================================

  /// メモ保存
  ///
  /// 新規作成：
  /// → SQLiteへINSERT
  /// → 下書き削除
  /// → 入力欄を初期化
  ///
  /// 編集：
  /// → SQLiteをUPDATE
  /// → trueを返して詳細画面へ戻る
  Future<void> _saveMemo() async {
    final result =
        await DialogService
            .showConfirm(
      context: context,
      title: _isEditMode
          ? '更新しますか？'
          : '保存しますか？',
      message: _isEditMode
          ? 'メモ内容を更新します。'
          : 'メモ内容を保存します。',
      confirmText:
          _isEditMode
              ? '更新'
              : '保存',
    );

    if (!mounted) {
      return;
    }

    //================================================
    // キャンセル
    //================================================

    if (!result) {
      return;
    }

    try {
      //================================================
      // 編集モード
      //================================================

      if (_isEditMode) {
        await _updateMemoInDatabase();

        if (!mounted) {
          return;
        }

        //================================================
        // 編集完了
        //================================================
        //
        // trueを返すことで、
        //
        // MemoPage
        // ↓
        // MemoDetailPage
        //
        // の戻り値として伝える。
        //
        // MemoDetailPage側では、
        // 編集成功を受け取って自身も閉じ、
        // MemoListPageへ戻る。
        //================================================

        Navigator.of(
          context,
        ).pop(true);

        return;
      }

      //================================================
      // 新規作成モード
      //================================================

      await _saveMemoToDatabase();

      if (!mounted) {
        return;
      }

      //================================================
      // SQLite保存成功後に下書きを削除
      //================================================

      await MemoDraftService
          .clearDraft();

      if (!mounted) {
        return;
      }

      //================================================
      // 保存後は初期状態へ戻す
      //================================================

      setState(() {
        _selectedDate =
            DateTime.now();

        _titleController.clear();

        _memoController.clear();
      });

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
      // SQLite保存・更新失敗
      //================================================

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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
  // メモ一覧
  //==================================================

  /// 保存済みメモ一覧を開く。
  ///
  /// MainPageの「メモ」タブ専用Navigator内で
  /// pushするため、BottomNavigationは
  /// そのまま表示される。
  Future<void>
      _openMemoList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MemoListPage(),
      ),
    );
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer<CalculatorProvider>(
      builder: (
        context,
        calculator,
        child,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isEditMode
                  ? 'メモ編集'
                  : 'メモ',
            ),
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
                        (calculator
                                .isVisible
                            ? CalculatorBottomSheet
                                    .height +
                                AppSpacing.lg
                            : 0),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: [
                      //==========================================
                      // メモ入力
                      //==========================================

                      AppCard(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            //==========================================
                            // 日付
                            //==========================================

                            MemoDateField(
                              selectedDate:
                                  _selectedDate,
                              onTap:
                                  _selectDate,
                            ),

                            //==========================================
                            // タイトル
                            //==========================================

                            MemoTitleField(
                              controller:
                                  _titleController,
                            ),

                            //==========================================
                            // 本文
                            //==========================================

                            MemoEditor(
                              controller:
                                  _memoController,
                            ),

                            //==========================================
                            // クイック入力
                            //==========================================

                            QuickInputBar(
                              controller:
                                  _memoController,
                            ),

                            //==========================================
                            // 保存・更新
                            //==========================================

                            MemoSaveButton(
                              onPressed:
                                  _saveMemo,
                              label:
                                  _isEditMode
                                      ? '更新'
                                      : '保存',
                            ),

                            //==========================================
                            // 電卓表示切替
                            //==========================================

                            const CalculatorToggle(),
                          ],
                        ),
                      ),

                      //==========================================
                      // 保存済みメモ一覧
                      //==========================================
                      //
                      // 編集モードでは、
                      // 「保存したメモを見る」は表示しない。
                      //
                      // 編集画面から一覧へ戻るには、
                      // Android戻るまたは画面戻るを使用する。
                      //==========================================

                      if (!_isEditMode) ...[
                        const SizedBox(
                          height:
                              AppSpacing.lg,
                        ),

                        OutlinedButton.icon(
                          onPressed:
                              _openMemoList,
                          icon: const Icon(
                            Icons
                                .format_list_bulleted,
                          ),
                          label: const Text(
                            '保存したメモを見る',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              //==========================================
              // 電卓
              //==========================================

              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child:
                    CalculatorBottomSheet(),
              ),
            ],
          ),
        );
      },
    );
  }
}