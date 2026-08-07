import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialog_service.dart';

/// 外部サイト起動サービス
class UrlLauncherService {
  UrlLauncherService._();

  /// 確認ダイアログ付きで外部サイトを開く
  static Future<void> open(
    BuildContext context,
    String serviceName,
    String url,
  ) async {
    final result = await DialogService.showConfirm(
      context: context,
      title: '『$serviceName』を開きますか？',
      message: '外部サイトへ移動します。',
      cancelText: 'キャンセル',
      confirmText: '開く',
    );

    if (!result) {
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