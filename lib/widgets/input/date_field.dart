import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

import '../search/service_icon.dart';

import 'input_label.dart';

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    //==================================================
    // 日付表示
    //==================================================
    //
    // 例：
    // 2026年8月17日(月)
    //
    // 「M」を使用することで月の先頭に
    // 0を付けない表示にする。
    //
    // 「E」は日本語環境では
    // 月・火・水・木・金・土・日
    // と表示される。
    //==================================================

    final formattedDate =
        DateFormat('yyyy年M月d日(E)', 'ja_JP')
            .format(selectedDate);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        //================================================
        // ラベル
        //================================================

        const InputLabel(
          text: '日付',
        ),

        //================================================
        // 日付選択
        //================================================

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(
              AppRadius.md,
            ),
            child: Ink(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    AppSpacing.md,
                vertical:
                    AppSpacing.md,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.md,
                ),
                border: Border.all(
                  color:
                      AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  //========================================
                  // Googleカレンダー 3Dアイコン
                  //========================================

                  const ServiceIcon(
                    icon: 'google_calendar',
                    size: 38,
                  ),

                  const SizedBox(
                    width:
                        AppSpacing.md,
                  ),

                  //========================================
                  // 日付
                  //========================================

                  Expanded(
                    child: Text(
                      formattedDate,
                      style:
                          AppTextStyles.body,
                    ),
                  ),

                  //========================================
                  // プルダウンアイコン
                  //========================================

                  const Icon(
                    Icons
                        .arrow_drop_down_rounded,
                    color:
                        AppColors
                            .iconDisabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}