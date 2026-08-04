import 'package:flutter/foundation.dart';

import '../widgets/memo/calculator_controller.dart';

/// アプリ全体で共有する電卓状態
class CalculatorProvider extends ChangeNotifier {
  CalculatorProvider();

  /// 電卓本体
  final CalculatorController controller = CalculatorController();

  /// BottomSheet表示状態
  bool _isVisible = false;

  /// 表示状態
  bool get isVisible => _isVisible;

  /// 表示
  void open() {
    if (_isVisible) {
      return;
    }

    _isVisible = true;
    notifyListeners();
  }

  /// 非表示
  void close() {
    if (!_isVisible) {
      return;
    }

    _isVisible = false;
    notifyListeners();
  }

  /// 開閉切替
  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  /// 電卓をリセット
  void clearCalculator() {
    controller.clear();
    notifyListeners();
  }
}