import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'calculator_controller.dart';
import 'calculator_panel.dart';

class CalculatorBottomSheet extends StatelessWidget {
  const CalculatorBottomSheet({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onClose,
  });

  /// 電卓コントローラー
  final CalculatorController controller;

  /// 表示状態
  final bool isVisible;

  /// 閉じる
  final VoidCallback onClose;

  /// BottomSheet高さ
  static const double height = 150;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(
          milliseconds: 250,
        ),
        curve: Curves.easeOutCubic,
        offset: isVisible
            ? Offset.zero
            : const Offset(0, 1),
        child: Material(
          elevation: 12,
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(
              AppRadius.lg,
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: height,
              child: Column(
                children: [
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius:
                          BorderRadius.circular(
                        999,
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Center(
                            child: Text(
                              '電卓',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        IconButton(
                          tooltip: '閉じる',
                          onPressed: onClose,
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 1,
                  ),

                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      child: CalculatorPanel(
                        controller: controller,
                      ),
                    ),
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