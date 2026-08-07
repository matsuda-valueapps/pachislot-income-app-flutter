import 'package:flutter/material.dart';

/// 共通確認ダイアログサービス
class DialogService {
  DialogService._();

  /// 確認ダイアログ
  ///
  /// true  = OK
  /// false = キャンセル
  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'キャンセル',
    String confirmText = 'OK',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                          false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          48,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        cancelText,
                        maxLines: 1,
                        softWrap: false,
                        overflow:
                            TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                          true,
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          48,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        confirmText,
                        maxLines: 1,
                        softWrap: false,
                        overflow:
                            TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }
}