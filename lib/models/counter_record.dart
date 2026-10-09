/// 小役カウンターの正式保存データ
class CounterRecord {
  final int? id;

  //==================================================
  // 基本情報
  //==================================================

  /// 日付
  final String date;

  /// タイトル
  final String title;

  /// 機種タイプ（Aタイプ / ATタイプ）
  final String machineType;

  //==================================================
  // ゲーム数
  //==================================================

  /// 開始ゲーム数
  final int startGame;

  /// 現在ゲーム数
  final int currentGame;

  //==================================================
  // 小役カウント（Aタイプ）
  //==================================================

  /// チェリー回数
  final int cherry;

  /// ベル回数
  final int bell;

  /// スイカ回数
  final int suika;

  /// ブドウ回数
  final int grape;

  /// チャンス目回数
  final int chance;

  //==================================================
  // 小役カウント（ATタイプ）
  //==================================================

  /// 強チェリー回数
  final int strongCherry;

  /// 弱チェリー回数
  final int weakCherry;

  /// 強ベル回数
  final int strongBell;

  /// 弱ベル回数
  final int weakBell;

  /// 強スイカ回数
  final int strongSuika;

  /// 弱スイカ回数
  final int weakSuika;

  /// 強ブドウ回数
  final int strongGrape;

  /// 弱ブドウ回数
  final int weakGrape;

  /// 強チャンス目回数
  final int strongChance;

  /// 弱チャンス目回数
  final int weakChance;

  //==================================================
  // 日時
  //==================================================

  /// 作成日時
  final String createdAt;

  /// 更新日時
  final String updatedAt;

  //==================================================
  // Constructor
  //==================================================

  const CounterRecord({
    this.id,
    required this.date,
    required this.title,
    this.machineType = 'Aタイプ',
    required this.startGame,
    required this.currentGame,
    required this.cherry,
    required this.bell,
    required this.suika,
    required this.grape,
    required this.chance,
    this.strongCherry = 0,
    this.weakCherry = 0,
    this.strongBell = 0,
    this.weakBell = 0,
    this.strongSuika = 0,
    this.weakSuika = 0,
    this.strongGrape = 0,
    this.weakGrape = 0,
    this.strongChance = 0,
    this.weakChance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  //==================================================
  // 合計カウント
  //==================================================

  /// 機種タイプに応じた小役カウント合計
  int get totalCount {
    if (machineType == 'ATタイプ') {
      return strongCherry +
          weakCherry +
          strongBell +
          weakBell +
          strongSuika +
          weakSuika +
          strongGrape +
          weakGrape +
          strongChance +
          weakChance;
    }

    return cherry + bell + suika + grape + chance;
  }

  //==================================================
  // SQLite
  //==================================================

  /// SQLiteへ保存するためのMapへ変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'machine_type': machineType,
      'start_game': startGame,
      'current_game': currentGame,
      'cherry': cherry,
      'bell': bell,
      'suika': suika,
      'grape': grape,
      'chance': chance,
      'strong_cherry': strongCherry,
      'weak_cherry': weakCherry,
      'strong_bell': strongBell,
      'weak_bell': weakBell,
      'strong_suika': strongSuika,
      'weak_suika': weakSuika,
      'strong_grape': strongGrape,
      'weak_grape': weakGrape,
      'strong_chance': strongChance,
      'weak_chance': weakChance,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// SQLiteから取得したMapをCounterRecordへ変換
  ///
  /// 新しいカラムが存在しない旧データにも対応する。
  /// 旧データはAタイプとして扱い、追加カウントは0にする。
  factory CounterRecord.fromMap(
    Map<String, dynamic> map,
  ) {
    return CounterRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      title: map['title'] as String,
      machineType:
          map['machine_type'] as String? ?? 'Aタイプ',
      startGame: map['start_game'] as int,
      currentGame: map['current_game'] as int,
      cherry: map['cherry'] as int,
      bell: map['bell'] as int,
      suika: map['suika'] as int,
      grape: map['grape'] as int,
      chance: map['chance'] as int,
      strongCherry:
          map['strong_cherry'] as int? ?? 0,
      weakCherry:
          map['weak_cherry'] as int? ?? 0,
      strongBell:
          map['strong_bell'] as int? ?? 0,
      weakBell:
          map['weak_bell'] as int? ?? 0,
      strongSuika:
          map['strong_suika'] as int? ?? 0,
      weakSuika:
          map['weak_suika'] as int? ?? 0,
      strongGrape:
          map['strong_grape'] as int? ?? 0,
      weakGrape:
          map['weak_grape'] as int? ?? 0,
      strongChance:
          map['strong_chance'] as int? ?? 0,
      weakChance:
          map['weak_chance'] as int? ?? 0,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}