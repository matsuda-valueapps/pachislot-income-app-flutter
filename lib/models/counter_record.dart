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

  //==================================================
  // ゲーム数
  //==================================================

  /// 開始ゲーム数
  final int startGame;

  /// 現在ゲーム数
  final int currentGame;

  //==================================================
  // 小役カウント
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
    required this.startGame,
    required this.currentGame,
    required this.cherry,
    required this.bell,
    required this.suika,
    required this.grape,
    required this.chance,
    required this.createdAt,
    required this.updatedAt,
  });

  //==================================================
  // SQLite
  //==================================================

  /// SQLiteへ保存するためのMapへ変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'start_game': startGame,
      'current_game': currentGame,
      'cherry': cherry,
      'bell': bell,
      'suika': suika,
      'grape': grape,
      'chance': chance,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// SQLiteから取得したMapをCounterRecordへ変換
  factory CounterRecord.fromMap(
    Map<String, dynamic> map,
  ) {
    return CounterRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      title: map['title'] as String,
      startGame:
          map['start_game'] as int,
      currentGame:
          map['current_game'] as int,
      cherry:
          map['cherry'] as int,
      bell:
          map['bell'] as int,
      suika:
          map['suika'] as int,
      grape:
          map['grape'] as int,
      chance:
          map['chance'] as int,
      createdAt:
          map['created_at'] as String,
      updatedAt:
          map['updated_at'] as String,
    );
  }
}