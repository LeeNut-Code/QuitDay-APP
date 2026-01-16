import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import '../model/habit.dart';
import '../database/app_database.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

/// CSV备份管理器
class CsvBackupManager {
  /// 导出所有习惯数据到CSV文件
  Future<io.File> exportHabits() async {
    if (kIsWeb) {
      throw UnsupportedError('CSV export is not supported on web platform');
    }
    
    final habits = await AppDatabase.instance.getAllHabits();
    
    // 准备CSV数据
    final csvData = [
      ['id', 'name', 'startDate', 'lastResetDate', 'moneyPerUnit', 'timePerUnit', 'notes', 'color', 'icon'],
      for (var habit in habits)
        [
          habit.id.toString(),
          habit.name,
          habit.startDate.toIso8601String(),
          habit.lastResetDate?.toIso8601String() ?? '',
          habit.moneyPerUnit.toString(),
          habit.timePerUnit.toString(),
          habit.notes,
          habit.color.toString(),
          habit.icon,
        ],
    ];
    
    // 转换为CSV字符串
    final csvString = const ListToCsvConverter().convert(csvData);
    
    // 创建文件
    final directory = await getApplicationDocumentsDirectory();
    final file = io.File('${directory.path}/quitday_backup_${DateTime.now().toIso8601String().split('T')[0]}.csv');
    
    // 写入数据
    await file.writeAsString(csvString);
    
    return file;
  }

  /// 从CSV文件导入习惯数据
  Future<List<Habit>> importHabits(io.File file) async {
    if (kIsWeb) {
      throw UnsupportedError('CSV import is not supported on web platform');
    }
    
    final csvString = await file.readAsString();
    
    // 解析CSV数据
    final csvData = const CsvToListConverter().convert(csvString);
    
    // 跳过表头
    final habitData = csvData.skip(1).toList();
    
    // 创建习惯实例
    final habits = <Habit>[];
    
    for (var data in habitData) {
      final habit = Habit(
        id: int.tryParse(data[0].toString()) ?? 0,
        name: data[1].toString(),
        startDate: DateTime.parse(data[2].toString()),
        lastResetDate: data[3].toString().isNotEmpty ? DateTime.parse(data[3].toString()) : null,
        moneyPerUnit: double.tryParse(data[4].toString()) ?? 0.0,
        timePerUnit: int.tryParse(data[5].toString()) ?? 0,
        notes: data[6].toString(),
        color: data.length > 7 ? int.tryParse(data[7].toString()) ?? 0xFF4CAF50 : 0xFF4CAF50,
        icon: data.length > 8 ? data[8].toString() : 'icon_default',
      );
      habits.add(habit);
    }
    
    // 保存到数据库
    for (var habit in habits) {
      await AppDatabase.instance.insertHabit(habit);
    }
    
    return habits;
  }
}