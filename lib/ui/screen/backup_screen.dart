import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/backup/csv_backup_manager.dart';
import '../../data/backup/webdav_backup_manager.dart';

/// 备份屏幕
class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _csvManager = CsvBackupManager();
  final _webDavManager = WebDavBackupManager();
  
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isWebDavLoading = false;
  bool _isWebDavConfigured = false;
  
  // WebDAV配置
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  List<String> _backupFiles = [];

  /// 导出CSV备份
  Future<void> _exportCsv() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final file = await _csvManager.exportHabits();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份已导出到: ${file.path}')),
      );
    } catch (e) {
      print('Error exporting CSV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导出失败，请重试')),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  /// 导入CSV备份
  Future<void> _importCsv() async {
    setState(() {
      _isImporting = true;
    });

    try {
      // 这里简化处理，实际应用中应该使用文件选择器
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().where((file) => file.path.endsWith('.csv')).toList();
      
      if (files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有找到CSV备份文件')),
        );
        return;
      }
      
      // 选择最新的备份文件
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      final file = files.first;
      
      final habits = await _csvManager.importHabits(File(file.path));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功导入 ${habits.length} 个习惯')),
      );
    } catch (e) {
      print('Error importing CSV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导入失败，请重试')),
      );
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  /// 配置WebDAV
  Future<void> _configureWebDav() async {
    if (_urlController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写URL和用户名')),
      );
      return;
    }

    setState(() {
      _isWebDavLoading = true;
    });

    try {
      await _webDavManager.initialize(
        url: _urlController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
      _isWebDavConfigured = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WebDAV配置成功')),
      );
    } catch (e) {
      print('Error configuring WebDAV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WebDAV配置失败，请检查设置')),
      );
    } finally {
      setState(() {
        _isWebDavLoading = false;
      });
    }
  }

  /// 上传到WebDAV
  Future<void> _uploadToWebDav() async {
    if (!_isWebDavConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置WebDAV')),
      );
      return;
    }

    setState(() {
      _isWebDavLoading = true;
    });

    try {
      await _webDavManager.uploadBackup();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('备份已上传到WebDAV')),
      );
    } catch (e) {
      print('Error uploading to WebDAV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('上传失败，请重试')),
      );
    } finally {
      setState(() {
        _isWebDavLoading = false;
      });
    }
  }

  /// 从WebDAV下载
  Future<void> _downloadFromWebDav() async {
    if (!_isWebDavConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置WebDAV')),
      );
      return;
    }

    setState(() {
      _isWebDavLoading = true;
    });

    try {
      _backupFiles = await _webDavManager.getBackupFiles();
      
      if (_backupFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WebDAV上没有备份文件')),
        );
        return;
      }
      
      // 选择最新的备份文件
      _backupFiles.sort((a, b) => b.compareTo(a));
      final file = await _webDavManager.downloadBackup(_backupFiles.first);
      
      final habits = await _csvManager.importHabits(file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功从WebDAV导入 ${habits.length} 个习惯')),
      );
    } catch (e) {
      print('Error downloading from WebDAV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('下载失败，请重试')),
      );
    } finally {
      setState(() {
        _isWebDavLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('备份与恢复'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // CSV备份
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CSV备份', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isExporting ? null : _exportCsv,
                            child: _isExporting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('导出备份'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isImporting ? null : _importCsv,
                            child: _isImporting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('导入备份'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // WebDAV备份
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WebDAV备份', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    // WebDAV配置
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'WebDAV服务器URL',
                        hintText: '例如：https://example.com/webdav',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: '密码',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isWebDavLoading ? null : _configureWebDav,
                      child: _isWebDavLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('配置WebDAV'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_isWebDavLoading || !_isWebDavConfigured) ? null : _uploadToWebDav,
                            child: const Text('上传到WebDAV'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: (_isWebDavLoading || !_isWebDavConfigured) ? null : _downloadFromWebDav,
                            child: const Text('从WebDAV下载'),
                          ),
                        ),
                      ],
                    ),
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