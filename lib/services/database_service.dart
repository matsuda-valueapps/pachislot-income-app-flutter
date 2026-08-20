import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/counter_record.dart';
import '../models/income_record.dart';
import '../models/memo_record.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance =
      DatabaseService._();

  //==================================================
  // Database
  //==================================================

  static const String _databaseName =
      'pachislot_income.db';

  /// データベースバージョン
  ///
  /// Version 1：
  /// income_recordsテーブル追加
  ///
  /// Version 2：
  /// memo_recordsテーブル追加
  ///
  /// Version 3：
  /// counter_recordsテーブル追加
  ///
  /// Version 4：
  /// counter_recordsへ
  /// date・titleカラム追加
  static const int _databaseVersion = 4;

  //==================================================
  // Table
  //==================================================

  static const String _incomeTable =
      'income_records';

  static const String _memoTable =
      'memo_records';

  static const String _counterTable =
      'counter_records';

  //==================================================
  // Database instance
  //==================================================

  Database? _database;

  //==================================================
  // SQLiteデータベースを取得
  //==================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database =
        await _initDatabase();

    return _database!;
  }

  //==================================================
  // SQLiteデータベースを初期化
  //==================================================

  Future<Database> _initDatabase() async {
    final databasePath =
        await getDatabasesPath();

    final path = join(
      databasePath,
      _databaseName,
    );

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  //==================================================
  // 初回データベース作成
  //==================================================

  /// 初回データベース作成時に
  /// 必要なテーブルをすべて作成する。
  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    //================================================
    // 入力画面
    //================================================

    await db.execute('''
      CREATE TABLE $_incomeTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        hall TEXT NOT NULL,
        machine TEXT NOT NULL,
        medal_invest INTEGER NOT NULL DEFAULT 0,
        cash_invest INTEGER NOT NULL DEFAULT 0,
        medal_return INTEGER NOT NULL DEFAULT 0,
        cash_return INTEGER NOT NULL DEFAULT 0,
        profit INTEGER NOT NULL DEFAULT 0,
        memo TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    //================================================
    // メモ画面
    //================================================

    await db.execute('''
      CREATE TABLE $_memoTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    //================================================
    // 小役カウンター
    //================================================
    //
    // 新規インストールの場合は、
    // 最初からdate・titleを含めて作成する。
    //================================================

    await db.execute('''
      CREATE TABLE $_counterTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL DEFAULT '',
        title TEXT NOT NULL DEFAULT '',
        start_game INTEGER NOT NULL DEFAULT 0,
        current_game INTEGER NOT NULL DEFAULT 0,
        cherry INTEGER NOT NULL DEFAULT 0,
        bell INTEGER NOT NULL DEFAULT 0,
        suika INTEGER NOT NULL DEFAULT 0,
        grape INTEGER NOT NULL DEFAULT 0,
        chance INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  //==================================================
  // データベースバージョンアップ
  //==================================================

  /// データベースのバージョンアップ処理
  ///
  /// 既存ユーザーのデータを残したまま、
  /// 新しいテーブルやカラムを追加する。
  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    //================================================
    // Version 2
    //================================================
    //
    // memo_recordsテーブル追加
    //================================================

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $_memoTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }

    //================================================
    // Version 3
    //================================================
    //
    // counter_recordsテーブル追加
    //
    // この時点ではdate・titleは存在しない。
    //================================================

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $_counterTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_game INTEGER NOT NULL DEFAULT 0,
          current_game INTEGER NOT NULL DEFAULT 0,
          cherry INTEGER NOT NULL DEFAULT 0,
          bell INTEGER NOT NULL DEFAULT 0,
          suika INTEGER NOT NULL DEFAULT 0,
          grape INTEGER NOT NULL DEFAULT 0,
          chance INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }

    //================================================
    // Version 4
    //================================================
    //
    // counter_recordsへ
    // date・titleを追加する。
    //
    // 既存のカウンターデータは削除しない。
    //
    // 既存データには、
    //
    // date  → ''
    // title → ''
    //
    // が設定される。
    //================================================

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE $_counterTable
        ADD COLUMN date TEXT NOT NULL DEFAULT ''
      ''');

      await db.execute('''
        ALTER TABLE $_counterTable
        ADD COLUMN title TEXT NOT NULL DEFAULT ''
      ''');
    }
  }

  //==================================================
  // 入力画面（income_records）
  //==================================================

  /// 入力データをSQLiteへ正式保存
  ///
  /// 戻り値：
  /// 保存されたレコードのID
  Future<int> insertIncomeRecord(
    IncomeRecord record,
  ) async {
    final db =
        await database;

    return db.insert(
      _incomeTable,
      record.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.abort,
    );
  }

  /// 保存済みの収支データをすべて取得
  ///
  /// 日付の新しい順、
  /// 同日の場合はIDの新しい順。
  Future<List<IncomeRecord>>
      getIncomeRecords() async {
    final db =
        await database;

    final maps =
        await db.query(
      _incomeTable,
      orderBy:
          'date DESC, id DESC',
    );

    return maps
        .map(
          IncomeRecord.fromMap,
        )
        .toList();
  }

  /// IDを指定して収支データを1件取得
  Future<IncomeRecord?>
      getIncomeRecord(
    int id,
  ) async {
    final db =
        await database;

    final maps =
        await db.query(
      _incomeTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return IncomeRecord.fromMap(
      maps.first,
    );
  }

  /// 収支データを更新
  Future<int> updateIncomeRecord(
    IncomeRecord record,
  ) async {
    if (record.id == null) {
      throw ArgumentError(
        '更新にはidが必要です。',
      );
    }

    final db =
        await database;

    return db.update(
      _incomeTable,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// 収支データを削除
  Future<int> deleteIncomeRecord(
    int id,
  ) async {
    final db =
        await database;

    return db.delete(
      _incomeTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// すべての収支データを削除
  ///
  /// 将来的な
  /// 「データ初期化」機能などで使用する。
  Future<int> deleteAllIncomeRecords()
      async {
    final db =
        await database;

    return db.delete(
      _incomeTable,
    );
  }

  //==================================================
  // メモ画面（memo_records）
  //==================================================

  /// メモをSQLiteへ正式保存
  ///
  /// 戻り値：
  /// 保存されたメモのID
  Future<int> insertMemoRecord(
    MemoRecord record,
  ) async {
    final db =
        await database;

    return db.insert(
      _memoTable,
      record.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.abort,
    );
  }

  /// 保存済みのメモをすべて取得
  ///
  /// 日付の新しい順、
  /// 同日の場合はIDの新しい順。
  Future<List<MemoRecord>>
      getMemoRecords() async {
    final db =
        await database;

    final maps =
        await db.query(
      _memoTable,
      orderBy:
          'date DESC, id DESC',
    );

    return maps
        .map(
          MemoRecord.fromMap,
        )
        .toList();
  }

  /// IDを指定してメモを1件取得
  Future<MemoRecord?>
      getMemoRecord(
    int id,
  ) async {
    final db =
        await database;

    final maps =
        await db.query(
      _memoTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return MemoRecord.fromMap(
      maps.first,
    );
  }

  /// メモを更新
  Future<int> updateMemoRecord(
    MemoRecord record,
  ) async {
    if (record.id == null) {
      throw ArgumentError(
        '更新にはidが必要です。',
      );
    }

    final db =
        await database;

    return db.update(
      _memoTable,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// メモを削除
  Future<int> deleteMemoRecord(
    int id,
  ) async {
    final db =
        await database;

    return db.delete(
      _memoTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// すべてのメモを削除
  ///
  /// 将来的な
  /// 「メモデータ初期化」機能などで使用する。
  Future<int> deleteAllMemoRecords()
      async {
    final db =
        await database;

    return db.delete(
      _memoTable,
    );
  }

  //==================================================
  // 小役カウンター（counter_records）
  //==================================================

  /// 小役カウンターをSQLiteへ正式保存
  ///
  /// date・titleを含めて保存する。
  ///
  /// 戻り値：
  /// 保存されたレコードのID
  Future<int> insertCounterRecord(
    CounterRecord record,
  ) async {
    final db =
        await database;

    return db.insert(
      _counterTable,
      record.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.abort,
    );
  }

  /// 保存済みの小役カウンターをすべて取得
  ///
  /// 日付の新しい順、
  /// 同日の場合はIDの新しい順。
  ///
  /// date・titleも取得される。
  Future<List<CounterRecord>>
      getCounterRecords() async {
    final db =
        await database;

    final maps =
        await db.query(
      _counterTable,
      orderBy:
          'date DESC, id DESC',
    );

    return maps
        .map(
          CounterRecord.fromMap,
        )
        .toList();
  }

  /// IDを指定して小役カウンターを1件取得
  Future<CounterRecord?>
      getCounterRecord(
    int id,
  ) async {
    final db =
        await database;

    final maps =
        await db.query(
      _counterTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return CounterRecord.fromMap(
      maps.first,
    );
  }

  /// 小役カウンターを更新
  ///
  /// date・titleを含めて更新する。
  Future<int> updateCounterRecord(
    CounterRecord record,
  ) async {
    if (record.id == null) {
      throw ArgumentError(
        '更新にはidが必要です。',
      );
    }

    final db =
        await database;

    return db.update(
      _counterTable,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// 小役カウンターを削除
  Future<int> deleteCounterRecord(
    int id,
  ) async {
    final db =
        await database;

    return db.delete(
      _counterTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// すべての小役カウンターを削除
  ///
  /// 将来的な
  /// 「カウンターデータ初期化」機能などで使用する。
  Future<int> deleteAllCounterRecords()
      async {
    final db =
        await database;

    return db.delete(
      _counterTable,
    );
  }

  //==================================================
  // データベース
  //==================================================

  /// データベースを閉じる
  ///
  /// 通常のアプリ操作では
  /// 呼び出す必要はありません。
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();

      _database = null;
    }
  }
}