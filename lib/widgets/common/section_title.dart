import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// セクションタイトル
///
/// 使用例:
///
/// SectionTitle(title: '今月収支')
///
/// SectionTitle(
///   title: '統計',
///   trailing: TextButton(
///     onPressed: () {},
///     child: const Text('もっと見る'),
///   ),
/// )
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.only(
      bottom: AppSpacing.sm,
    ),
  });

  /// タイトル
  final String title;

  /// 右側Widget（任意）
  final Widget? trailing;

  /// 外側余白
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (trailing case Widget widget) widget,
        ],
      ),
    );
  }
}