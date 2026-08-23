import 'package:flutter/material.dart';

/// パチスロ収支管理アプリで使用する
/// 共通操作アイコンWidget。
///
/// 対応アイコン：
/// - 保存
/// - 編集
/// - 更新
/// - 一覧
/// - 削除
/// - 絞り込み
/// - 電卓
///
/// Assetは以下のディレクトリに配置：
/// assets/images/buttons/
///
/// 使用例：
/// ActionButtonIcon.save()
/// ActionButtonIcon.edit()
/// ActionButtonIcon.update()
/// ActionButtonIcon.list()
/// ActionButtonIcon.delete()
/// ActionButtonIcon.filter()
/// ActionButtonIcon.calculator()
class ActionButtonIcon extends StatelessWidget {
  /// 表示する操作アイコンの種類
  final ActionButtonType type;

  /// アイコンの表示サイズ
  ///
  /// 縦横同じサイズで表示されます。
  final double size;

  /// 画像のフィット方法
  final BoxFit fit;

  /// 画像の品質
  final FilterQuality filterQuality;

  const ActionButtonIcon({
    super.key,
    required this.type,
    this.size = 32.0,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
  });

  /// 保存アイコン
  const ActionButtonIcon.save({
    super.key,
    this.size = 32.0,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
  }) : type = ActionButtonType.save;

  /// 編集アイコン
  const ActionButtonIcon.edit({
    super.key,
    this.size = 32.0,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
  }) : type = ActionButtonType.edit;

  /// 更新アイコン
  const ActionButtonIcon.update({
    super.key,
    this.size = 32.0,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
  }) : type = ActionButtonType.update;

  /// 一覧アイコン
  const ActionButtonIcon.list({
    super.key,
    this.size = 32.0,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
  }) : type = ActionButtonType.list;

  /// 削除アイコン
  const ActionButtonIcon.delete({
    super.key,
    this.size = 32.0,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
  }) : type = ActionButtonType.delete;

  /// 絞り込みアイコン
  const ActionButtonIcon.filter({
    super.key,
    this.size = 32.0,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
  }) : type = ActionButtonType.filter;

  /// 電卓アイコン
  const ActionButtonIcon.calculator({
    super.key,
    this.size = 32.0,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
  }) : type = ActionButtonType.calculator;

  /// 操作アイコンのAssetパスを取得
  String get _assetPath {
    switch (type) {
      case ActionButtonType.save:
        return 'assets/images/buttons/save_button.png';

      case ActionButtonType.edit:
        return 'assets/images/buttons/edit_button.png';

      case ActionButtonType.update:
        return 'assets/images/buttons/update_button.png';

      case ActionButtonType.list:
        return 'assets/images/buttons/list_button.png';

      case ActionButtonType.delete:
        return 'assets/images/buttons/delete_button.png';

      case ActionButtonType.filter:
        return 'assets/images/buttons/filter_button.png';

      case ActionButtonType.calculator:
        return 'assets/images/buttons/calculator_button.png';
    }
  }

  /// アクセシビリティ用ラベル
  String get _semanticLabel {
    switch (type) {
      case ActionButtonType.save:
        return '保存';

      case ActionButtonType.edit:
        return '編集';

      case ActionButtonType.update:
        return '更新';

      case ActionButtonType.list:
        return '一覧';

      case ActionButtonType.delete:
        return '削除';

      case ActionButtonType.filter:
        return '絞り込み';

      case ActionButtonType.calculator:
        return '電卓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _semanticLabel,
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          _assetPath,
          width: size,
          height: size,
          fit: fit,
          filterQuality: filterQuality,
        ),
      ),
    );
  }
}

/// 操作アイコンの種類
enum ActionButtonType {
  save,
  edit,
  update,
  list,
  delete,
  filter,
  calculator,
}