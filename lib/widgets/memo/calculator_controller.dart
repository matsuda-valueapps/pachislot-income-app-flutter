import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class CalculatorController extends ChangeNotifier {
  final NumberFormat _formatter = NumberFormat('#,###.########');

  String _display = '0';

  double? _previousValue;

  String? _currentOperator;

  bool _waitingForOperand = false;

  /// 表示文字列
  String get display => _display;

  //==================================================
  // 数字入力
  //==================================================

  void inputNumber(String value) {
    if (_waitingForOperand) {
      _display = value;
      _waitingForOperand = false;
    } else {
      final raw = _display.replaceAll(',', '');

      if (raw == '0') {
        _display = value;
      } else {
        _display = raw + value;
      }
    }

    _formatDisplay();

    notifyListeners();
  }

  //==================================================
  // 小数点
  //==================================================

  void inputDecimal() {
    if (_waitingForOperand) {
      _display = '0.';
      _waitingForOperand = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }

    notifyListeners();
  }

  //==================================================
  // 演算子
  //==================================================

  void inputOperator(String operator) {
    final current = _currentValue;

    if (_previousValue == null) {
      _previousValue = current;
    } else if (!_waitingForOperand) {
      _previousValue = _calculate(
        _previousValue!,
        current,
        _currentOperator!,
      );

      _display = _formatNumber(_previousValue!);
    }

    _currentOperator = operator;
    _waitingForOperand = true;

    notifyListeners();
  }

  //==================================================
  // =
  //==================================================

  void calculate() {
    if (_previousValue == null ||
        _currentOperator == null ||
        _waitingForOperand) {
      return;
    }

    final result = _calculate(
      _previousValue!,
      _currentValue,
      _currentOperator!,
    );

    _display = _formatNumber(result);

    _previousValue = null;
    _currentOperator = null;
    _waitingForOperand = true;

    notifyListeners();
  }

  //==================================================
  // C
  //==================================================

  void clear() {
    _display = '0';
    _previousValue = null;
    _currentOperator = null;
    _waitingForOperand = false;

    notifyListeners();
  }

  //==================================================
  // ⌫
  //==================================================

  void backspace() {
    if (_waitingForOperand) {
      return;
    }

    final raw = _display.replaceAll(',', '');

    if (raw.length <= 1) {
      _display = '0';
    } else {
      _display = raw.substring(0, raw.length - 1);
      _formatDisplay();
    }

    notifyListeners();
  }

  //==================================================
  // 内部
  //==================================================

  double get _currentValue =>
      double.tryParse(_display.replaceAll(',', '')) ?? 0;

  double _calculate(
    double left,
    double right,
    String operator,
  ) {
    switch (operator) {
      case '+':
        return left + right;

      case '-':
        return left - right;

      case '×':
        return left * right;

      case '÷':
        if (right == 0) {
          return left;
        }
        return left / right;

      default:
        return right;
    }
  }

  void _formatDisplay() {
    final value = double.tryParse(
      _display.replaceAll(',', ''),
    );

    if (value != null) {
      _display = _formatNumber(value);
    }
  }

  String _formatNumber(double value) {
    if (value == value.toInt()) {
      return _formatter.format(value.toInt());
    }

    return _formatter.format(value);
  }
}