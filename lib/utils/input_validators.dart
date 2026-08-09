class InputValidators {
  const InputValidators._();

  /// 必須入力チェック
  static String? required(
    String? value, {
    String fieldName = '入力項目',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldNameを入力して下さい';
    }

    return null;
  }

  /// 金額チェック
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '金額を入力して下さい';
    }

    final amount = int.tryParse(
      value.replaceAll(',', ''),
    );

    if (amount == null) {
      return '数値を入力して下さい';
    }

    if (amount < 0) {
      return '0以上の数値を入力して下さい';
    }

    return null;
  }
}