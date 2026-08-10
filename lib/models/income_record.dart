class IncomeRecord {
  final int? id;
  final String date;
  final String hall;
  final String machine;
  final int medalInvest;
  final int cashInvest;
  final int medalReturn;
  final int cashReturn;
  final int profit;
  final String memo;
  final String createdAt;
  final String updatedAt;

  const IncomeRecord({
    this.id,
    required this.date,
    required this.hall,
    required this.machine,
    required this.medalInvest,
    required this.cashInvest,
    required this.medalReturn,
    required this.cashReturn,
    required this.profit,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// SQLiteへ保存するためのMapへ変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'hall': hall,
      'machine': machine,
      'medal_invest': medalInvest,
      'cash_invest': cashInvest,
      'medal_return': medalReturn,
      'cash_return': cashReturn,
      'profit': profit,
      'memo': memo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// SQLiteから取得したMapをIncomeRecordへ変換
  factory IncomeRecord.fromMap(Map<String, dynamic> map) {
    return IncomeRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      hall: map['hall'] as String,
      machine: map['machine'] as String,
      medalInvest: map['medal_invest'] as int,
      cashInvest: map['cash_invest'] as int,
      medalReturn: map['medal_return'] as int,
      cashReturn: map['cash_return'] as int,
      profit: map['profit'] as int,
      memo: map['memo'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}