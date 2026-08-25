import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class SearchCard extends StatelessWidget {
  const SearchCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  /// タイトル
  final String title;

  /// 説明
  final String subtitle;

  /// 左アイコン
  ///
  /// 3Dサービスアイコンなど、任意のWidgetを指定できます。
  final Widget icon;

  /// タップ
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppRadius.md,
          ),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  //========================================
                  // サービスアイコン
                  //========================================

                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: icon,
                    ),
                  ),

                  const SizedBox(
                    width: AppSpacing.md,
                  ),

                  //========================================
                  // タイトル・説明
                  //========================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  //========================================
                  // 右矢印
                  //========================================

                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade500,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}