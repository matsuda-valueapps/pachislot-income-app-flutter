import 'package:flutter/material.dart';

/// アプリ全体で使用する余白
class AppSpacing {
  AppSpacing._();

  // 基本余白
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  // Padding
  static const EdgeInsets screen =
      EdgeInsets.symmetric(horizontal: md, vertical: md);

  static const EdgeInsets card =
      EdgeInsets.all(md);

  static const EdgeInsets page =
      EdgeInsets.all(md);

  // SizedBox用
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
}