import 'package:flutter/material.dart';

/// 小役アイコンの種類
enum KoyakuType {
  /// チェリー
  cherry,

  /// ベル
  bell,

  /// スイカ
  watermelon,

  /// ブドウ
  grape,

  /// チャンス目
  chance,
}

/// 小役カウンターで使用する
/// 小役専用アイコンWidget。
///
/// 各小役のPNG画像を共通のデザイン・サイズ感で表示する。
class KoyakuIcon extends StatelessWidget {
  const KoyakuIcon({
    super.key,
    required this.type,
    this.size = 40,
  });

  /// 表示する小役の種類
  final KoyakuType type;

  /// アイコンの表示サイズ
  ///
  /// デフォルトは40px。
  final double size;

  //==================================================
  // 画像パス
  //==================================================

  /// 小役の種類に対応する画像パスを取得する。
  String get _assetPath {
    switch (type) {
      case KoyakuType.cherry:
        return 'assets/images/koyaku/cherry.png';

      case KoyakuType.bell:
        return 'assets/images/koyaku/bell.png';

      case KoyakuType.watermelon:
        return 'assets/images/koyaku/watermelon.png';

      case KoyakuType.grape:
        return 'assets/images/koyaku/grape.png';

      case KoyakuType.chance:
        return 'assets/images/koyaku/chance.png';
    }
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        _assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}