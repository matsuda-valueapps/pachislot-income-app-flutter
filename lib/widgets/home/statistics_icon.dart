import 'package:flutter/material.dart';

/// ホーム画面・統計欄専用アイコン
///
/// assets/images/statistics/ に配置した
/// 専用3D PNGアイコンを表示する。
class StatisticsIcon extends StatelessWidget {
  const StatisticsIcon({
    super.key,
    required this.assetPath,
    this.size = 40,
  });

  /// 統計アイコンのアセットパス
  ///
  /// 例：
  /// assets/images/statistics/play_count.png
  final String assetPath;

  /// アイコン表示サイズ
  ///
  /// 512×512pxのPNGを、
  /// ホーム画面では約40pxで表示する。
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}