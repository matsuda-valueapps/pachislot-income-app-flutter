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
      children: [
        _buildRow([
          _numberButton('7'),
          _numberButton('8'),
          _numberButton('9'),
          _operatorButton('÷'),
        ]),
        _buildRow([
          _numberButton('4'),
          _numberButton('5'),
          _numberButton('6'),
          _operatorButton('×'),
        ]),
        _buildRow([
          _numberButton('1'),
          _numberButton('2'),
          _numberButton('3'),
          _operatorButton('-'),
        ]),
        _buildRow([
          _numberButton('0'),
          _decimalButton(),
          _equalButton(),
          _operatorButton('+'),
        ]),
        _buildRow([
          _clearButton(),
          _backspaceButton(),
        ]),
      ],
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children,
    );
  }

  Widget _numberButton(String value) {
    return CalculatorButton(
      text: value,
      onPressed: () {
        controller.inputNumber(value);
      },
    );
  }

  Widget _operatorButton(String value) {
    return CalculatorButton(
      text: value,
      onPressed: () {
        controller.inputOperator(value);
      },
    );
  }

  Widget _decimalButton() {
    return CalculatorButton(
      text: '.',
      onPressed: controller.inputDecimal,
    );
  }

  Widget _equalButton() {
    return CalculatorButton(
      text: '=',
      onPressed: controller.calculate,
    );
  }

  Widget _clearButton() {
    return CalculatorButton(
      text: 'C',
      flex: 2,
      onPressed: controller.clear,
    );
  }

  Widget _backspaceButton() {
    return CalculatorButton(
      text: '⌫',
      flex: 2,
      onPressed: controller.backspace,
    );
  }
}