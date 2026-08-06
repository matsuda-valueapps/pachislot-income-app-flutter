import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 外部サイト起動サービス
class UrlLauncherService {
  UrlLauncherService._();

  /// 確認ダイアログ付きで外部サイトを開く
  static Future<void> open(
    BuildContext context,
    String serviceName,
    String url,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            '$serviceNameを開きますか？',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '外部サイトへ移動します。',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(
                height: 28,
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
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'キャンセル',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontSize: 15,
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
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        '開く',
                        style: TextStyle(
                          fontSize: 15,
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

    if (result != true) {
      return;
    }

    final uri = Uri.parse(url);

    final success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ページを開けませんでした。',
          ),
        ),
      );
    }
  }
}