import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class SearchCategory extends StatelessWidget {
  const SearchCategory({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  /// カテゴリ名
  final String title;

  /// 左アイコン
  final IconData icon;

  /// カテゴリ内Widget
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: Theme.of(context).primaryColor,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          ...children,
        ],
      ),
    );
  }
}