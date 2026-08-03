import 'package:flutter/foundation.dart';

class CalculatorController extends ChangeNotifier {
  String _display = '0';

  double? _leftValue;
  String? _operator;

  bool _startNewInput = true;

  /// 現在の表示
  String get display => _display;

  /// 数値入力
  void inputNumber(String number) {
    if (_startNewInput) {
      _display = number;
      _startNewInput = false;
    } else {
      if (_display == '0') {
        _display = number;
      } else {
        _display += number;
      }
    }

    notifyListeners();
  }

  /// 小数点
  void inputDecimal() {
    if (_startNewInput) {
      _display = '0.';
      _startNewInput = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }

    notifyListeners();
  }

  /// 演算子
  void inputOperator(String operator) {
    final current =
        double.tryParse(_display) ?? 0;

    if (_leftValue == null) {
      _leftValue = current;
    } else if (_operator != null) {
      _leftValue = _calculate(
        _leftValue!,
        current,
        _operator!,
      );
    }

    _display = _format(_leftValue!);

    _operator = operator;

    _startNewInput = true;

    notifyListeners();
  }

  /// =
  void calculate() {
    if (_leftValue == null || _operator == null) {
      return;
    }

    final right =
        double.tryParse(_display) ?? 0;

    final result = _calculate(
      _leftValue!,
      right,
      _operator!,
    );

    _display = _format(result);

    _leftValue = null;
    _operator = null;

    _startNewInput = true;

    notifyListeners();
  }

  /// C
  void clear() {
    _display = '0';

    _leftValue = null;

    _operator = null;

    _startNewInput = true;

    notifyListeners();
  }

  /// ⌫
  void backspace() {
    if (_startNewInput) {
      return;
    }

    if (_display.length <= 1) {
      _display = '0';
      _startNewInput = true;
    } else {
      _display = _display.substring(
        0,
        _display.length - 1,
      );
    }

    notifyListeners();
  }

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

  String _format(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}