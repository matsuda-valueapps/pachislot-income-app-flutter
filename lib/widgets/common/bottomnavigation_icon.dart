import 'package:flutter/material.dart';

/// BottomNavigationで使用するアイコンの種類
enum BottomNavigationIconType {
  home,
  input,
  memo,
  counter,
  search,
}

/// BottomNavigation専用の共通アイコンWidget
///
/// assets/images/bottomnavigation/ に配置した
/// 5種類のアイコンを共通の仕様で表示する。
class BottomNavigationIcon extends StatelessWidget {
  /// 表示するアイコンの種類
  final BottomNavigationIconType type;

  /// アイコンサイズ
  final double size;

  const BottomNavigationIcon({
    super.key,
    required this.type,
    this.size = 38.0,
  });

  /// アイコンのアセットパスを取得
  String get _assetPath {
    switch (type) {
      case BottomNavigationIconType.home:
        return 'assets/images/bottomnavigation/home.png';

      case BottomNavigationIconType.input:
        return 'assets/images/bottomnavigation/input.png';

      case BottomNavigationIconType.memo:
        return 'assets/images/bottomnavigation/memo.png';

      case BottomNavigationIconType.counter:
        return 'assets/images/bottomnavigation/counter.png';

      case BottomNavigationIconType.search:
        return 'assets/images/bottomnavigation/search.png';
    }
  }

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