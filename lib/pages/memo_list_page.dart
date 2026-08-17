import 'package:flutter/material.dart';

import '../models/memo_record.dart';
import '../services/database_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import 'memo_detail_page.dart';

class MemoListPage extends StatefulWidget {
  const MemoListPage({
    super.key,
  });

  @override
  State<MemoListPage> createState() =>
      _MemoListPageState();
}

class _MemoListPageState
    extends State<MemoListPage> {
  //==================================================
  // 保存済みメモ
  //==================================================

  List<MemoRecord> _memoRecords = [];

  /// 読み込み中かどうか
  bool _isLoading = true;

  //==================================================
  // 初期化
  //==================================================

  @override
  void initState() {
    super.initState();

    _loadMemoRecords();
  }

  //==================================================
  // メモ一覧取得
  //==================================================

  /// SQLiteから保存済みメモを取得する。
  Future<void> _loadMemoRecords() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final records =
          await DatabaseService.instance
              .getMemoRecords();

      if (!mounted) {
        return;
      }

      setState(() {
        _memoRecords = records;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _memoRecords = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'メモの読み込みに失敗しました。',
          ),
        ),
      );
    }
  }

  //==================================================
  // 日付表示
  //==================================================

  /// SQLiteに保存されている
  /// YYYY-MM-DD形式の日付を
  /// YYYY年M月D日(曜日)形式へ変換する。
  ///
  /// 例：
  ///
  /// 2026-08-14
  /// ↓
  /// 2026年8月14日(金)
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
  String _displayTitle(
    MemoRecord record,
  ) {
    final title =
        record.title.trim();

    if (title.isEmpty) {
      return '無題';
    }

    return title;
  }

  //==================================================
  // メモ詳細画面
  //==================================================

  /// 選択したメモの詳細画面を開く。
  ///
  /// 詳細画面では、
  ///
  /// ・メモ内容の確認
  /// ・メモの編集
  /// ・メモの削除
  ///
  /// を行う。
  ///
  /// 詳細画面から戻ってきた際には、
  /// SQLiteから最新のメモ一覧を再取得する。
  Future<void> _openMemoDetail(
    MemoRecord record,
  ) async {
    //================================================
    // メモ詳細画面を開く
    //================================================

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MemoDetailPage(
          record: record,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    //================================================
    // 詳細画面から戻ってきた
    //================================================
    //
    // 詳細画面で、
    //
    // ・編集
    // ・削除
    //
    // が行われている可能性があるため、
    // SQLiteから最新データを再取得する。
    //================================================

    await _loadMemoRecords();
  }

  //==================================================
  // メモカード
  //==================================================

  Widget _buildMemoCard(
    MemoRecord record,
  ) {
    final body =
        record.body.trim();

    return AppCard(
      onTap: () {
        _openMemoDetail(record);
      },
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          //================================================
          // 日付
          //================================================

          Text(
            _formatDate(record.date),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //================================================
          // タイトル
          //================================================

          Text(
            _displayTitle(record),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //================================================
          // 本文
          //================================================

          Text(
            body.isEmpty
                ? '本文はありません。'
                : body,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          //================================================
          // 詳細表示案内
          //================================================

          Align(
            alignment:
                Alignment.centerRight,
            child: Text(
              'タップして詳細を見る',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
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
          '保存メモ一覧',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  //==================================================
  // Body
  //==================================================

  Widget _buildBody() {
    //================================================
    // 読み込み中
    //================================================

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    //================================================
    // メモなし
    //================================================

    if (_memoRecords.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadMemoRecords,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.page,
          children: const [
            SizedBox(
              height: 160,
            ),

            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey,
            ),

            SizedBox(
              height: AppSpacing.md,
            ),

            Center(
              child: Text(
                '保存されたメモはありません。',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    //================================================
    // メモ一覧
    //================================================

    return RefreshIndicator(
      onRefresh: _loadMemoRecords,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.page,
        itemCount: _memoRecords.length,
        itemBuilder: (
          context,
          index,
        ) {
          final record =
              _memoRecords[index];

          return _buildMemoCard(record);
        },
      ),
    );
  }
}