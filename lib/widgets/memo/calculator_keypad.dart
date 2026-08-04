import 'package:flutter/material.dart';

import 'calculator_button.dart';
import 'calculator_controller.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({
    super.key,
    required this.controller,
  });

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _numberButton('0'),
            _numberButton('1'),
            _numberButton('2'),
            _numberButton('3'),
            _numberButton('4'),
            _numberButton('5'),
            _numberButton('6'),
            _numberButton('7'),
            _numberButton('8'),
            _numberButton('9'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _operatorButton('+'),
            _operatorButton('-'),
            _operatorButton('×'),
            _operatorButton('÷'),
            _equalButton(),
            _decimalButton(),
            _backspaceButton(),
            _clearButton(),
          ],
        ),
      ],
    );
  }

  Widget _numberButton(String value) {
    return Expanded(
      child: CalculatorButton(
        label: value,
        onPressed: () => controller.inputNumber(value),
      ),
    );
  }

  Widget _operatorButton(String value) {
    return Expanded(
      child: CalculatorButton(
        label: value,
        onPressed: () => controller.inputOperator(value),
      ),
    );
  }

  Widget _decimalButton() {
    return Expanded(
      child: CalculatorButton(
        label: '.',
        onPressed: controller.inputDecimal,
      ),
    );
  }

  Widget _equalButton() {
    return Expanded(
      child: CalculatorButton(
        label: '=',
        onPressed: controller.calculate,
      ),
    );
  }

  Widget _clearButton() {
    return Expanded(
      child: CalculatorButton(
        label: 'C',
        onPressed: controller.clear,
      ),
    );
  }

  Widget _backspaceButton() {
    return Expanded(
      child: CalculatorButton(
        label: '⌫',
        onPressed: controller.backspace,
      ),
    );
  }
}