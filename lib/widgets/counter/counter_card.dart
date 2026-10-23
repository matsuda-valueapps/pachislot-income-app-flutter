import 'package:flutter/material.dart';

import '../../models/counter_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import 'counter_button.dart';
import 'koyaku_icon.dart';

class CounterCard extends StatelessWidget {
  const CounterCard({
    super.key,
    required this.item,
    required this.probability,
    required this.onIncrement,
    required this.onDecrement,
  });

  /// 小役
  final CounterItem item;

  /// 確率表示
  final String probability;

  /// ＋
  final VoidCallback onIncrement;

  /// －
  final VoidCallback onDecrement;

  //==================================================
  // 小役アイコン種類
  //==================================================

  /// CounterItemのIDを
  /// KoyakuIconで使用するKoyakuTypeへ変換する。
  KoyakuType _getKoyakuType(String id) {
    switch (id) {
      //================================================
      // Aタイプ
      //================================================

      case 'cherry':
        return KoyakuType.cherry;

      case 'bell':
        return KoyakuType.bell;

      case 'suika':
        return KoyakuType.watermelon;

      case 'grape':
        return KoyakuType.grape;

      case 'chance':
        return KoyakuType.chance;

      //================================================
      // ATタイプ
      //================================================

      case 'strong_cherry':
      case 'weak_cherry':
        return KoyakuType.cherry;

      case 'strong_bell':
      case 'weak_bell':
        return KoyakuType.bell;

      case 'strong_suika':
      case 'weak_suika':
        return KoyakuType.watermelon;

      case 'strong_grape':
      case 'weak_grape':
        return KoyakuType.grape;

      case 'strong_chance':
      case 'weak_chance':
        return KoyakuType.chance;

      //================================================
      // その他
      //================================================

      default:
        return KoyakuType.cherry;
    }
  }

  //==================================================
  // Aタイプ判定
  //==================================================

  /// Aタイプの小役IDかどうかを判定する。
  bool get _isAType {
    return const [
      'cherry',
      'suika',
      'chance',
      'bell',
      'grape',
    ].contains(item.id);
  }

  //==================================================
  // 小役アイコンサイズ
  //==================================================

  /// 小役IDに応じてアイコンサイズを変更する。
  ///
  /// ・Aタイプ：30px
  /// ・ATタイプ「強」：28px
  /// ・ATタイプ「弱」：23px
  double _getIconSize(String id) {
    if (id.startsWith('weak_')) {
      return 23;
    }

    if (_isAType) {
      return 30;
    }

    return 28;
  }

  //==================================================
  // 小役アイコン
  //==================================================

  Widget _buildKoyakuIcon({
    required double size,
  }) {
    return SizedBox(
      width: size + 2,
      height: size + 2,
      child: Center(
        child: KoyakuIcon(
          type: _getKoyakuType(item.id),
          size: size,
        ),
      ),
    );
  }

  //==================================================
  // 小役名
  //==================================================

  Widget _buildKoyakuName({
    required double fontSize,
  }) {
    return Text(
      item.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  //==================================================
  // カウント数
  //==================================================

  Widget _buildCount({
    required double fontSize,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '${item.count}',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //==================================================
  // 確率
  //==================================================

  Widget _buildProbability({
    required double fontSize,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          probability,
          maxLines: 1,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  //==================================================
  // Aタイプカード
  //==================================================

  /// 修正前に近い横長カード。
  ///
  /// カード内の上下の余白を縮小し、
  /// 小役名・ボタン・カウント数を横方向に配置する。
  Widget _buildATypeCard() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildKoyakuIcon(
                size: 30,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildKoyakuName(
                  fontSize: 15,
                ),
              ),
              CounterButton(
                icon: Icons.remove,
                onPressed: onDecrement,
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 38,
                child: Center(
                  child: _buildCount(
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              CounterButton(
                icon: Icons.add,
                onPressed: onIncrement,
              ),
            ],
          ),
          const SizedBox(height: 1),
          _buildProbability(
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  //==================================================
  // ATタイプカード
  //==================================================

  /// 2列表示向けのコンパクトカード。
  ///
  /// カード内部の高さを抑えつつ、
  /// ボタンと確率表示の領域を確保する。
  Widget _buildAtTypeCard() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 1,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 小役アイコン・小役名
          SizedBox(
            height: 30,
            child: Row(
              children: [
                _buildKoyakuIcon(
                  size: _getIconSize(item.id),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: _buildKoyakuName(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // －ボタン・カウント・＋ボタン
          SizedBox(
            height: 42,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CounterButton(
                        icon: Icons.remove,
                        onPressed: onDecrement,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildCount(
                      fontSize: 19,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CounterButton(
                        icon: Icons.add,
                        onPressed: onIncrement,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 1),

          // 確率
          SizedBox(
            height: 14,
            child: _buildProbability(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    // Aタイプは横長カード、
    // ATタイプは2列向けのコンパクトカード。
    if (_isAType) {
      return _buildATypeCard();
    }

    return _buildAtTypeCard();
  }
}