import 'package:flutter/material.dart';

/// アプリ全体で使用する文字スタイル
class AppTextStyles {
  AppTextStyles._();

  // ----------------------------
  // ページタイトル
  // ----------------------------
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // ----------------------------
  // セクションタイトル
  // ----------------------------
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );

  // ----------------------------
  // カードタイトル
  // ----------------------------
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  // ----------------------------
  // 大きな金額表示
  // ----------------------------
  static const TextStyle amountLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // ----------------------------
  // 中くらいの金額表示
  // ----------------------------
  static const TextStyle amountMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // ----------------------------
  // 統計値
  // ----------------------------
  static const TextStyle statValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // ----------------------------
  // ラベル
  // ----------------------------
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

  // ----------------------------
  // 通常本文
  // ----------------------------
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  // ----------------------------
  // 補足説明
  // ----------------------------
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: Colors.black54,
  );

  // ----------------------------
  // ボタン
  // ----------------------------
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // ----------------------------
  // AppBarタイトル
  // ----------------------------
  static const TextStyle appBar = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}