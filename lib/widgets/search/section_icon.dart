import 'package:flutter/material.dart';

/// 検索画面で使用するセクション用3Dアイコン。
///
/// 対応アイコン:
/// - hall_search
/// - model_analysis
/// - event_search
/// - useful_tools
/// - watch_video
class SectionIcon extends StatelessWidget {
  const SectionIcon({
    super.key,
    required this.icon,
    this.size = 80.0,
    this.fit = BoxFit.contain,
  });

  /// 表示するアイコン名。
  ///
  /// 例:
  /// ```dart
  /// SectionIcon(
  ///   icon: 'hall_search',
  /// )
  /// ```
  final String icon;

  /// アイコンの幅・高さ。
  final double size;

  /// 画像の表示方法。
  final BoxFit fit;

  /// セクションアイコンのAssetパスを取得する。
  static const Map<String, String> _assets = {
    'hall_search': 'assets/images/sections/hall_search.png',
    'model_analysis': 'assets/images/sections/model_analysis.png',
    'event_search': 'assets/images/sections/event_search.png',
    'useful_tools': 'assets/images/sections/useful_tools.png',
    'watch_video': 'assets/images/sections/watch_video.png',
  };

  @override
  Widget build(BuildContext context) {
    final String? assetPath = _assets[icon];

    // 未登録のアイコン名が指定された場合は、
    // アプリをクラッシュさせず、何も表示しない。
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