import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'section_icon.dart';

class SearchCategory extends StatelessWidget {
  const SearchCategory({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  /// カテゴリ名
  final String title;

  /// セクションアイコン名
  final String icon;

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
          //========================================
          // セクションタイトル
          //========================================

          Row(
            children: [
              SectionIcon(
                icon: icon,
                size: 38,
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

          //========================================
          // カテゴリ内コンテンツ
          //========================================

          ...children,
        ],
      ),
    );
  }
}