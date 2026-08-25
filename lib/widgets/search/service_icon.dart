import 'package:flutter/material.dart';

/// 検索画面で使用するサービス用3Dアイコン。
///
/// 対応アイコン:
/// - p_world
/// - dmm_pachitown
/// - ichigeki
/// - pachi7
/// - x
/// - google_map
/// - google_calendar
/// - youtube
class ServiceIcon extends StatelessWidget {
  const ServiceIcon({
    super.key,
    required this.icon,
    this.size = 80.0,
    this.fit = BoxFit.contain,
  });

  /// 表示するサービスアイコン名。
  ///
  /// 例:
  /// ```dart
  /// ServiceIcon(
  ///   icon: 'p_world',
  /// )
  /// ```
  final String icon;

  /// アイコンの幅・高さ。
  final double size;

  /// 画像の表示方法。
  final BoxFit fit;

  /// サービスアイコンのAssetパスを取得する。
  static const Map<String, String> _assets = {
    'p_world': 'assets/images/servicez/p_world.png',
    'dmm_pachitown': 'assets/images/servicez/dmm_pachitown.png',
    'ichigeki': 'assets/images/servicez/ichigeki.png',
    'pachi7': 'assets/images/servicez/pachi7.png',
    'x': 'assets/images/servicez/x.png',
    'google_map': 'assets/images/servicez/google_map.png',
    'google_calendar': 'assets/images/servicez/google_calendar.png',
    'youtube': 'assets/images/servicez/youtube.png',
  };

  @override
  Widget build(BuildContext context) {
    final String? assetPath = _assets[icon];

    // 未登録のアイコン名が指定された場合は、
    // アプリをクラッシュさせず、指定サイズの空領域を返す。
    if (assetPath == null) {
      return SizedBox(
        width: size,
        height: size,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      ),
    );
  }
}