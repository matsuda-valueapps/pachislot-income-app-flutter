import 'package:flutter/material.dart';

/// アプリ全体で使用する角丸
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;

  static const BorderRadius card =
      BorderRadius.all(Radius.circular(lg));

  static const BorderRadius button =
      BorderRadius.all(Radius.circular(14));

  static const BorderRadius dialog =
      BorderRadius.all(Radius.circular(20));

  static const BorderRadius bottomSheet =
      BorderRadius.vertical(
    top: Radius.circular(24),
  );
}