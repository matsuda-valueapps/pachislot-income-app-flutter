import 'package:flutter/material.dart';

import '../../models/counter_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'counter_button.dart';

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
              /// 小役カラー
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              CounterButton(
                icon: Icons.remove,
                onPressed: onDecrement,
              ),

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

              CounterButton(
                icon: Icons.add,
                onPressed: onIncrement,
              ),
            ],
          ),

          const SizedBox(
            height: 4,
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              probability,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}