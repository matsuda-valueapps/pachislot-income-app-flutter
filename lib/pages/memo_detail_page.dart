import 'package:flutter/material.dart';

import '../models/memo_record.dart';
import '../services/database_service.dart';
import '../services/dialog_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/primary_button.dart';
import 'memo_page.dart';

class MemoDetailPage extends StatelessWidget {
  const MemoDetailPage({
    super.key,
    required this.record,
  });

  /// 表示するメモデータ
  final MemoRecord record;

  //==================================================
  // 日付表示
  //==================================================

  /// SQLiteに保存されている
  /// YYYY-MM-DD形式の日付を
  /// YYYY年M月D日(曜日)形式へ変換する。
  String _formatDate(String date) {
    try {
      final parsedDate =
          DateTime.parse(date);

      const weekdays = [
        '月',
        '火',
        '水',
        '木',
        '金',
        '土',
        '日',
      ];

      final weekday =
          weekdays[parsedDate.weekday - 1];

      return '${parsedDate.year}年'
          '${parsedDate.month}月'
          '${parsedDate.day}日'
          '($weekday)';
    } catch (_) {
      return date;
    }
  }

  //==================================================
  // タイトル表示
  //==================================================

  /// タイトルが空の場合は「無題」と表示する。
  String _displayTitle() {
    final title =
        record.title.trim();

    if (title.isEmpty) {
      return '無題';
    }

    return title;
  }

  //==================================================
  // 編集
  //==================================================

  /// メモ編集画面を開く。
  ///
  /// 編集が正常に完了した場合は、
  /// 詳細画面を閉じてメモ一覧へ戻す。
  Future<void> _openEditPage(
    BuildContext context,
  ) async {
    final result =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MemoPage(
          record: record,
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

    //================================================
    // 編集完了
    //================================================
    //
    // MemoPage側からtrueが返された場合、
    // 詳細画面に古いデータを残さないため、
    // 詳細画面も閉じて一覧へ戻す。
    //================================================

    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  //==================================================
  // 削除
  //==================================================

  /// 保存済みメモを削除する。
  Future<void> _onDelete(
    BuildContext context,
  ) async {
    //================================================
    // ID確認
    //================================================
    //
    // SQLiteの更新・削除にはIDが必要。
    //================================================

    if (record.id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '削除できませんでした。',
          ),
        ),
      );

      return;
    }

    //================================================
    // 削除確認ダイアログ
    //================================================

    final result =
        await DialogService.showConfirm(
      context: context,
      title: '削除しますか？',
      message:
          'このメモを本当に削除しますか？',
      confirmText: '削除',
    );

    if (!context.mounted) {
      return;
    }

    //================================================
    // キャンセル
    //================================================

    if (!result) {
      return;
    }

    //================================================
    // SQLiteから削除
    //================================================

    try {
      await DatabaseService.instance
          .deleteMemoRecord(
        record.id!,
      );

      if (!context.mounted) {
        return;
      }

      //================================================
      // メモ一覧へ戻る
      //================================================

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '削除に失敗しました。もう一度お試しください。',
          ),
        ),
      );
    }
  }

  //==================================================
  // 本文表示
  //==================================================

  Widget _buildBodyCard(
    BuildContext context,
  ) {
    final body =
        record.body.trim();

    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          //================================================
          // 本文
          //================================================

          Text(
            '本文',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            body.isEmpty
                ? '本文はありません。'
                : record.body,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  height: 1.7,
                ),
          ),
        ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'メモ詳細',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
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
                    //================================================
                    // 日付
                    //================================================

                    Text(
                      _formatDate(
                        record.date,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    //================================================
                    // タイトル
                    //================================================

                    Text(
                      _displayTitle(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              //================================================
              // 本文
              //================================================

              _buildBodyCard(context),

              AppSpacing.gapLg,

              //================================================
              // 編集ボタン
              //================================================

              PrimaryButton(
                text: '編集',
                onPressed: () {
                  _openEditPage(context);
                },
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              //================================================
              // 削除ボタン
              //================================================

              PrimaryButton(
                text: '削除',
                backgroundColor:
                    Colors.red.shade700,
                onPressed: () {
                  _onDelete(context);
                },
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),
            ],
          ),
        ),
      ),
    );
  }
}