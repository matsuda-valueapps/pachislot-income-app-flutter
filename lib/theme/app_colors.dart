import 'package:flutter/material.dart';

/// アプリ全体で使用するカラー定義
class AppColors {
  AppColors._();

  // ===========================
  // ブランドカラー
  // ===========================

  /// メインカラー
  static const Color primary = Color(0xFF1976D2);

  /// サブカラー
  static const Color secondary = Color(0xFF42A5F5);

  // ===========================
  // 背景
  // ===========================

  /// 画面背景
  static const Color background = Color(0xFFF5F5F5);

  /// カード背景
  static const Color card = Colors.white;

  /// ダイアログ等の背景
  static const Color surface = Colors.white;

  // ===========================
  // 文字
  // ===========================

  /// メイン文字色
  static const Color textPrimary = Color(0xFF212121);

  /// サブ文字色
  static const Color textSecondary = Color(0xFF757575);

  /// 無効状態の文字色
  static const Color textDisabled = Color(0xFFBDBDBD);

  // 互換性維持（既存コード用）
  static const Color text = textPrimary;
  static const Color subText = textSecondary;

  // ===========================
  // 枠線
  // ===========================

  /// 通常の枠線
  static const Color border = Color(0xFFE0E0E0);

  /// 薄い区切り線
  static const Color divider = Color(0xFFEEEEEE);

  // ===========================
  // ステータスカラー
  // ===========================

  /// 利益（プラス）
  static const Color profit = Color(0xFF2E7D32);

  /// 損失（マイナス）
  static const Color loss = Color(0xFFD32F2F);

  /// 成功
  static const Color success = Color(0xFF2E7D32);

  /// 警告
  static const Color warning = Color(0xFFFF9800);

  /// エラー
  static const Color error = Color(0xFFD32F2F);

  /// 情報
  static const Color info = Color(0xFF1976D2);

  // ===========================
  // アイコン
  // ===========================

  /// 通常アイコン
  static const Color icon = Color(0xFF616161);

  /// 無効アイコン
  static const Color iconDisabled = Color(0xFFBDBDBD);
}