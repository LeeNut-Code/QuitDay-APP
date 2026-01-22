import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/theme_provider.dart';

/// 设置屏幕
class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  /// 切换主题模式
  void _changeThemeMode(ThemeMode mode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setThemeMode(mode);
    // 这里可以添加主题持久化逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('主题已切换到${_getThemeName(mode)}')),
    );
  }

  /// 获取主题名称
  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '设备默认';
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
      default:
        return '设备默认';
    }
  }

  /// 打开Github链接
  Future<void> _openGithub() async {
    final url = Uri.parse('https://github.com/LeeNut-Code/QuitDay-APP');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开Github链接')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 主题设置
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('主题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Column(
                          children: [
                            RadioListTile<ThemeMode>(
                              title: const Text('设备默认（跟随系统）'),
                              value: ThemeMode.system,
                              groupValue: themeProvider.themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  _changeThemeMode(value);
                                }
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('浅色'),
                              value: ThemeMode.light,
                              groupValue: themeProvider.themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  _changeThemeMode(value);
                                }
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('深色'),
                              value: ThemeMode.dark,
                              groupValue: themeProvider.themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  _changeThemeMode(value);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Github地址
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Github地址', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.code, color: Theme.of(context).colorScheme.onSurface),
                      title: Text('QuitDay', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: Text('https://github.com/LeeNut-Code/QuitDay-APP', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      onTap: _openGithub,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 关于
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('关于', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text('QuitDay v1.0.0', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text('一个简单实用的习惯追踪应用', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}