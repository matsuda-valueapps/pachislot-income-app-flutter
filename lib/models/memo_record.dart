class MemoRecord {
  final int? id;
  final String date;
  final String title;
  final String body;
  final String createdAt;
  final String updatedAt;

  const MemoRecord({
    this.id,
    required this.date,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  /// SQLiteへ保存するためのMapへ変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'body': body,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// SQLiteから取得したMapをMemoRecordへ変換
  factory MemoRecord.fromMap(
    Map<String, dynamic> map,
  ) {
    return MemoRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}