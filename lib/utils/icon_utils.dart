import 'package:flutter/material.dart';

/// 图标工具类
class IconUtils {
  /// 根据图标名称获取IconData
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'icon_smoking':
        return Icons.smoking_rooms;
      case 'icon_drinking':
        return Icons.local_drink;
      case 'icon_caffeine':
        return Icons.coffee;
      case 'icon_junk_food':
        return Icons.fastfood;
      case 'icon_procrastination':
        return Icons.access_time;
      default:
        return Icons.check_circle;
    }
  }
}