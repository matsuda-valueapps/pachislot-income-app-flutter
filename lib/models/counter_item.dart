import 'package:flutter/material.dart';

/// 小役カウンター1項目
class CounterItem {
  const CounterItem({
    required this.id,
    required this.name,
    required this.color,
    this.count = 0,
  });

  /// 一意のID
  final String id;

  /// 表示名
  final String name;

  /// カード色
  final Color color;

  /// カウント数
  final int count;

  /// 値更新用
  CounterItem copyWith({
    String? id,
    String? name,
    Color? color,
    int? count,
  }) {
    return CounterItem(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      count: count ?? this.count,
    );
  }
}