import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/calculator_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'calculator_panel.dart';

class CalculatorBottomSheet extends StatelessWidget {
  const CalculatorBottomSheet({
    super.key,
  });

  /// BottomSheet高さ
  static const double height = 270;

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, provider, child) {
        return IgnorePointer(
          ignoring: !provider.isVisible,
          child: AnimatedSlide(
            duration: const Duration(
              milliseconds: 250,
            ),
            curve: Curves.easeOutCubic,
            offset: provider.isVisible
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
                              onPressed: provider.close,
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

                      Padding(
                        padding:
                            const EdgeInsets.all(
                          AppSpacing.md,
                        ),
                        child: SizedBox(
                          height: 170,
                          child: CalculatorPanel(
                            controller:
                                provider.controller,
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
      },
    );
  }
}