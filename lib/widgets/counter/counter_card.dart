import 'package:flutter/material.dart';

import '../../models/counter_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
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
  KoyakuType _getKoyakuType(
    String id,
  ) {
    switch (id) {
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

      default:
        return KoyakuType.cherry;
    }
  }

  //==================================================
  // Build
  //==================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
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
        children: [
          Row(
            children: [
              //================================================
              // 小役アイコン
              //================================================

              KoyakuIcon(
                type: _getKoyakuType(
                  item.id,
                ),
                size: 36,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              //================================================
              // 小役名
              //================================================

              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              //================================================
              // －ボタン
              //================================================

              CounterButton(
                icon: Icons.remove,
                onPressed: onDecrement,
              ),

              //================================================
              // カウント
              //================================================

              SizedBox(
                width: 52,
                child: Center(
                  child: Text(
                    '${item.count}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              //================================================
              // ＋ボタン
              //================================================

              CounterButton(
                icon: Icons.add,
                onPressed: onIncrement,
              ),
            ],
          ),

          const SizedBox(
            height: 4,
          ),

          //==================================================
          // 確率
          //==================================================

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              probability,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}