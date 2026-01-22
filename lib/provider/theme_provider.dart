import 'package:flutter/material.dart';

/// 主题提供者
class ThemeProvider extends ChangeNotifier {
  /// 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;

  /// 获取当前主题模式
  ThemeMode get themeMode => _themeMode;

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// 获取当前主题
  ThemeData getTheme(BuildContext context) {
    if (_themeMode == ThemeMode.dark) {
      return darkTheme;
    } else if (_themeMode == ThemeMode.light) {
      return lightTheme;
    } else {
      // 跟随系统
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }

  /// 浅色主题
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
  );

  /// 深色主题
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}
