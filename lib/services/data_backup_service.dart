import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// パチスロ収支の
/// JSONバックアップ・復元サービス。
///
/// 対象データ：
///
/// ・income_records
/// ・memo_records
/// ・counter_records
///
/// SQLiteのDBファイルそのものではなく、
/// バージョン管理されたJSON形式で
/// バックアップ・復元を行う。
class DataBackupService {
  DataBackupService._();

  static final DataBackupService instance = DataBackupService._();

  //==================================================
  // Backup Format
  //==================================================

  /// バックアップ形式の識別子
  static const String _backupFormat = 'pachislot_income_backup';

  /// バックアップ形式のバージョン
  ///
  /// DB Versionとは別管理する。
  static const int _backupVersion = 1;

  /// 現在のSQLite DB Version
  ///
  /// DatabaseServiceと同じVersion 4。
  static const int _databaseVersion = 4;

  //==================================================
  // Table
  //==================================================

  static const String _incomeTable = 'income_records';

  static const String _memoTable = 'memo_records';

  static const String _counterTable = 'counter_records';

  //==================================================
  // Backup
  //==================================================

  /// 現在のSQLiteデータから
  /// JSONバックアップ文字列を作成する。
  ///
  /// 返り値：
  /// JSON形式のString
  Future<String> createBackupJson() async {
    final db = await DatabaseService.instance.database;

    //================================================
    // SQLiteから全データ取得
    //================================================

    final incomeRecords = await db.query(_incomeTable, orderBy: 'id ASC');

    final memoRecords = await db.query(_memoTable, orderBy: 'id ASC');

    final counterRecords = await db.query(_counterTable, orderBy: 'id ASC');

    //================================================
    // バックアップデータ作成
    //================================================

    final backupData = <String, dynamic>{
      'format': _backupFormat,
      'version': _backupVersion,
      'databaseVersion': _databaseVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'incomeRecords': incomeRecords,
      'memoRecords': memoRecords,
      'counterRecords': counterRecords,
    };

    //================================================
    // JSON化
    //================================================

    const encoder = JsonEncoder.withIndent('  ');

    return encoder.convert(backupData);
  }

  //==================================================
  // Save Backup
  //==================================================

  /// 現在のSQLiteデータを
  /// JSONファイルとして書き出す。
  ///
  /// 戻り値：
  ///
  /// ・保存成功 → 保存先URI文字列
  /// ・キャンセル → null
  Future<String?> saveBackup() async {
    final json = await createBackupJson();

    final bytes = Uint8List.fromList(utf8.encode(json));

    final fileName = _createBackupFileName();

    //================================================
    // 保存先選択
    //================================================

    final outputUri = await FilePicker.saveFile(
      dialogTitle: 'バックアップファイルを保存',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    if (outputUri == null) {
      return null;
    }

    return outputUri.toString();
  }

  //==================================================
  // Pick Backup
  //==================================================

  /// バックアップJSONファイルを
  /// ファイル選択画面から読み込む。
  ///
  /// 戻り値：
  ///
  /// ・選択されたJSON文字列
  /// ・キャンセル → null
  Future<String?> pickBackupJson() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'バックアップファイルを選択',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (file == null) {
      return null;
    }

    //================================================
    // ファイル内容を読み込む
    //================================================

    final bytes = await file.readAsBytes();

    return utf8.decode(bytes, allowMalformed: false);
  }

  //==================================================
  // Restore
  //==================================================

  /// JSONバックアップを
  /// SQLiteへ完全復元する。
  ///
  /// 復元前にJSONを検証する。
  ///
  /// 復元方法：
  ///
  /// 1. バックアップ検証
  /// 2. SQLiteトランザクション開始
  /// 3. 現在データ削除
  /// 4. バックアップデータ登録
  /// 5. トランザクション確定
  ///
  /// 途中でエラーが発生した場合は、
  /// SQLiteトランザクションにより
  /// 途中までの復元結果を確定しない。
  Future<DataBackupRestoreResult> restoreFromJson(String json) async {
    //================================================
    // JSON解析
    //================================================

    final decoded = jsonDecode(json);

    if (decoded is! Map<String, dynamic>) {
      throw FormatException('バックアップ形式が正しくありません。');
    }

    //================================================
    // バックアップ検証
    //================================================

    _validateBackup(decoded);

    //================================================
    // データ取得
    //================================================

    final incomeRecords = _toMapList(
      decoded['incomeRecords'],
      fieldName: 'incomeRecords',
    );

    final memoRecords = _toMapList(
      decoded['memoRecords'],
      fieldName: 'memoRecords',
    );

    final counterRecords = _toMapList(
      decoded['counterRecords'],
      fieldName: 'counterRecords',
    );

    //================================================
    // ID重複チェック
    //================================================

    _validateIds(incomeRecords, fieldName: 'incomeRecords');

    _validateIds(memoRecords, fieldName: 'memoRecords');

    _validateIds(counterRecords, fieldName: 'counterRecords');

    //================================================
    // SQLite取得
    //================================================

    final db = await DatabaseService.instance.database;

    //================================================
    // トランザクション
    //================================================

    await db.transaction((txn) async {
      //==============================================
      // 現在データを削除
      //==============================================

      await txn.delete(_incomeTable);

      await txn.delete(_memoTable);

      await txn.delete(_counterTable);

      //==============================================
      // 収支データ復元
      //==============================================

      for (final record in incomeRecords) {
        await txn.insert(
          _incomeTable,
          record,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }

      //==============================================
      // メモデータ復元
      //==============================================

      for (final record in memoRecords) {
        await txn.insert(
          _memoTable,
          record,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }

      //==============================================
      // カウンターデータ復元
      //==============================================

      for (final record in counterRecords) {
        await txn.insert(
          _counterTable,
          record,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });

    //================================================
    // 復元結果
    //================================================

    return DataBackupRestoreResult(
      incomeCount: incomeRecords.length,
      memoCount: memoRecords.length,
      counterCount: counterRecords.length,
    );
  }

  //==================================================
  // Restore From File
  //==================================================

  /// ファイル選択画面から
  /// JSONバックアップを選択して復元する。
  ///
  /// キャンセルされた場合はnull。
  Future<DataBackupRestoreResult?> pickAndRestore() async {
    final json = await pickBackupJson();

    if (json == null) {
      return null;
    }

    return restoreFromJson(json);
  }

  //==================================================
  // Validation
  //==================================================

  /// バックアップ全体を検証する。
  void _validateBackup(Map<String, dynamic> backup) {
    //================================================
    // format
    //================================================

    if (backup['format'] != _backupFormat) {
      throw FormatException('「パチスロ収支」のバックアップファイルではありません。');
    }

    //================================================
    // version
    //================================================

    final version = backup['version'];

    if (version is! int) {
      throw FormatException('バックアップバージョンが不正です。');
    }

    if (version != _backupVersion) {
      throw FormatException(
        '対応していないバックアップバージョンです。'
        '\n'
        'バックアップVersion: $version'
        '\n'
        '対応Version: $_backupVersion',
      );
    }

    //================================================
    // databaseVersion
    //================================================

    final databaseVersion = backup['databaseVersion'];

    if (databaseVersion is! int) {
      throw FormatException('データベースバージョンが不正です。');
    }

    if (databaseVersion > _databaseVersion) {
      throw FormatException(
        'このバックアップは、'
        '現在のアプリより新しいデータベース形式です。',
      );
    }

    //================================================
    // Arrays
    //================================================

    _toMapList(backup['incomeRecords'], fieldName: 'incomeRecords');

    _toMapList(backup['memoRecords'], fieldName: 'memoRecords');

    _toMapList(backup['counterRecords'], fieldName: 'counterRecords');
  }

  /// JSONの配列を
  /// `List<Map<String, dynamic>>`へ変換する。
  List<Map<String, dynamic>> _toMapList(
    dynamic value, {
    required String fieldName,
  }) {
    if (value is! List) {
      throw FormatException('$fieldName が配列ではありません。');
    }

    return value.map<Map<String, dynamic>>((item) {
      if (item is! Map<String, dynamic>) {
        throw FormatException('$fieldName に不正なデータが含まれています。');
      }

      return Map<String, dynamic>.from(item);
    }).toList();
  }

  /// 各テーブル内のID重複を確認する。
  void _validateIds(
    List<Map<String, dynamic>> records, {
    required String fieldName,
  }) {
    final ids = <int>{};

    for (final record in records) {
      final id = record['id'];

      if (id == null) {
        throw FormatException('$fieldName にIDなしのデータがあります。');
      }

      if (id is! int) {
        throw FormatException('$fieldName のIDが不正です。');
      }

      if (!ids.add(id)) {
        throw FormatException('$fieldName に同じIDのデータがあります。');
      }
    }
  }

  //==================================================
  // File Name
  //==================================================

  /// バックアップファイル名を作成する。
  String _createBackupFileName() {
    final now = DateTime.now();

    final year = now.year.toString();

    final month = now.month.toString().padLeft(2, '0');

    final day = now.day.toString().padLeft(2, '0');

    final hour = now.hour.toString().padLeft(2, '0');

    final minute = now.minute.toString().padLeft(2, '0');

    final second = now.second.toString().padLeft(2, '0');

    return 'pachislot_income_backup_'
        '$year$month$day'
        '_$hour$minute$second'
        '.json';
  }
}

//==================================================
// Restore Result
//==================================================

/// JSONバックアップ復元結果。
class DataBackupRestoreResult {
  /// 復元した収支データ件数
  final int incomeCount;

  /// 復元したメモ件数
  final int memoCount;

  /// 復元したカウンターデータ件数
  final int counterCount;

  const DataBackupRestoreResult({
    required this.incomeCount,
    required this.memoCount,
    required this.counterCount,
  });

  /// 復元した全データ件数
  int get totalCount {
    return incomeCount + memoCount + counterCount;
  }
}
