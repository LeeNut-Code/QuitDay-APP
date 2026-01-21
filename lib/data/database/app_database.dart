import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../model/habit.dart';
import 'dart:html' if (dart.library.io) 'dart:io';

/// 应用数据库管理类
class AppDatabase {
  static Database? _database;
  static final AppDatabase instance = AppDatabase._privateConstructor();
  
  // Web平台的本地存储键
  static const String _webHabitsKey = 'quitday_web_habits';
  static const String _webNextIdKey = 'quitday_web_next_id';
  static const String _webMarkedDaysKey = 'quitday_web_marked_days';

  // 构造函数
  AppDatabase._privateConstructor();

  /// 获取数据库实例
  Future<Database> get database async {
    if (kIsWeb) {
      // Web平台不使用sqflite，直接抛出异常
      throw UnsupportedError('Sqflite is not supported on web platform');
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 从localStorage获取习惯数据
  List<Habit> _getWebHabits() {
    if (!kIsWeb) return [];
    
    try {
      final storage = window.localStorage;
      final habitsJson = storage[_webHabitsKey];
      if (habitsJson == null) return [];
      
      final habitsList = jsonDecode(habitsJson) as List<dynamic>;
      return habitsList.map((habitJson) => Habit.fromMap(habitJson as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting web habits: $e');
      return [];
    }
  }

  /// 保存习惯数据到localStorage
  void _saveWebHabits(List<Habit> habits) {
    if (!kIsWeb) return;
    
    try {
      final storage = window.localStorage;
      final habitsJson = jsonEncode(habits.map((habit) => habit.toMap()).toList());
      storage[_webHabitsKey] = habitsJson;
    } catch (e) {
      print('Error saving web habits: $e');
    }
  }

  /// 从localStorage获取下一个ID
  int _getWebNextId() {
    if (!kIsWeb) return 1;
    
    try {
      final storage = window.localStorage;
      final nextIdStr = storage[_webNextIdKey];
      if (nextIdStr == null) return 1;
      
      return int.tryParse(nextIdStr) ?? 1;
    } catch (e) {
      print('Error getting web next id: $e');
      return 1;
    }
  }

  /// 保存下一个ID到localStorage
  void _saveWebNextId(int nextId) {
    if (!kIsWeb) return;
    
    try {
      final storage = window.localStorage;
      storage[_webNextIdKey] = nextId.toString();
    } catch (e) {
      print('Error saving web next id: $e');
    }
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'quitday.db');
    
    return await openDatabase(
      path,
      version: 3, // 增加版本号
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase, // 添加升级回调
    );
  }

  /// 创建数据库表
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startDate TEXT NOT NULL,
        lastResetDate TEXT,
        moneyPerUnit REAL DEFAULT 0,
        timePerUnit INTEGER DEFAULT 0,
        notes TEXT DEFAULT '',
        color INTEGER DEFAULT 0xFF4CAF50,
        icon TEXT DEFAULT 'icon_default'
      )
    ''');
    
    await db.execute('''
      CREATE TABLE marked_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
      )
    ''');
  }
  
  /// 升级数据库表
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加color和icon字段
      await db.execute('ALTER TABLE habits ADD COLUMN color INTEGER DEFAULT 0xFF4CAF50');
      await db.execute('ALTER TABLE habits ADD COLUMN icon TEXT DEFAULT \'icon_default\'');
    }
    
    if (oldVersion < 3) {
      // 添加marked_days表
      await db.execute('''
        CREATE TABLE marked_days (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          note TEXT DEFAULT '',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  /// 插入习惯
  Future<int> insertHabit(Habit habit) async {
    if (kIsWeb) {
      // Web平台使用localStorage存储
      final habits = _getWebHabits();
      final nextId = _getWebNextId();
      final newHabit = habit.copyWith(id: nextId);
      habits.add(newHabit);
      _saveWebHabits(habits);
      _saveWebNextId(nextId + 1);
      return nextId;
    }
    
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  /// 获取所有习惯
  Future<List<Habit>> getAllHabits() async {
    if (kIsWeb) {
      // Web平台返回localStorage存储的习惯
      return _getWebHabits();
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  /// 获取单个习惯
  Future<Habit?> getHabit(int id) async {
    if (kIsWeb) {
      // Web平台从localStorage存储中查找
      final habits = _getWebHabits();
      final habit = habits.firstWhere(
        (habit) => habit.id == id,
        orElse: () => Habit(
          id: 0,
          name: '',
          startDate: DateTime.now(),
        ),
      );
      return habit.id == 0 ? null : habit;
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  /// 更新习惯
  Future<int> updateHabit(Habit habit) async {
    if (kIsWeb) {
      // Web平台更新localStorage存储
      final habits = _getWebHabits();
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        habits[index] = habit;
        _saveWebHabits(habits);
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// 删除习惯
  Future<int> deleteHabit(int id) async {
    if (kIsWeb) {
      // Web平台从localStorage存储中删除
      final habits = _getWebHabits();
      final initialLength = habits.length;
      habits.removeWhere((h) => h.id == id);
      _saveWebHabits(habits);
      return initialLength - habits.length;
    }
    
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 重置习惯（更新lastResetDate为当前时间）
  Future<int> resetHabit(int id) async {
    if (kIsWeb) {
      // Web平台更新localStorage存储
      final habits = _getWebHabits();
      final index = habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        habits[index] = habits[index].copyWith(lastResetDate: DateTime.now());
        _saveWebHabits(habits);
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db.update(
      'habits',
      {'lastResetDate': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 从localStorage获取标记日期数据
  List<MarkedDay> _getWebMarkedDays() {
    if (!kIsWeb) return [];
    
    try {
      final storage = window.localStorage;
      final markedDaysJson = storage[_webMarkedDaysKey];
      if (markedDaysJson == null) return [];
      
      final markedDaysList = jsonDecode(markedDaysJson) as List<dynamic>;
      return markedDaysList.map((markedDayJson) => MarkedDay.fromMap(markedDayJson as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting web marked days: $e');
      return [];
    }
  }

  /// 保存标记日期数据到localStorage
  void _saveWebMarkedDays(List<MarkedDay> markedDays) {
    if (!kIsWeb) return;
    
    try {
      final storage = window.localStorage;
      final markedDaysJson = jsonEncode(markedDays.map((markedDay) => markedDay.toMap()).toList());
      storage[_webMarkedDaysKey] = markedDaysJson;
    } catch (e) {
      print('Error saving web marked days: $e');
    }
  }

  /// 插入标记日期
  Future<int> insertMarkedDay(MarkedDay markedDay) async {
    if (kIsWeb) {
      // Web平台使用localStorage存储
      final markedDays = _getWebMarkedDays();
      final newMarkedDay = markedDay.copyWith(
        id: markedDays.isNotEmpty ? markedDays.last.id! + 1 : 1,
      );
      markedDays.add(newMarkedDay);
      _saveWebMarkedDays(markedDays);
      return newMarkedDay.id!;
    }
    
    final db = await database;
    return await db.insert('marked_days', markedDay.toMap());
  }

  /// 获取习惯的所有标记日期
  Future<List<MarkedDay>> getMarkedDaysByHabitId(int habitId) async {
    if (kIsWeb) {
      // Web平台从localStorage存储中查找
      final markedDays = _getWebMarkedDays();
      return markedDays.where((markedDay) => markedDay.habitId == habitId).toList();
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'marked_days',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => MarkedDay.fromMap(maps[i]));
  }

  /// 更新标记日期
  Future<int> updateMarkedDay(MarkedDay markedDay) async {
    if (kIsWeb) {
      // Web平台更新localStorage存储
      final markedDays = _getWebMarkedDays();
      final index = markedDays.indexWhere((md) => md.id == markedDay.id);
      if (index != -1) {
        markedDays[index] = markedDay;
        _saveWebMarkedDays(markedDays);
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db.update(
      'marked_days',
      markedDay.toMap(),
      where: 'id = ?',
      whereArgs: [markedDay.id],
    );
  }

  /// 删除标记日期
  Future<int> deleteMarkedDay(int id) async {
    if (kIsWeb) {
      // Web平台从localStorage存储中删除
      final markedDays = _getWebMarkedDays();
      final initialLength = markedDays.length;
      markedDays.removeWhere((md) => md.id == id);
      _saveWebMarkedDays(markedDays);
      return initialLength - markedDays.length;
    }
    
    final db = await database;
    return await db.delete(
      'marked_days',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除习惯的所有标记日期
  Future<int> deleteMarkedDaysByHabitId(int habitId) async {
    if (kIsWeb) {
      // Web平台从localStorage存储中删除
      final markedDays = _getWebMarkedDays();
      final initialLength = markedDays.length;
      markedDays.removeWhere((md) => md.habitId == habitId);
      _saveWebMarkedDays(markedDays);
      return initialLength - markedDays.length;
    }
    
    final db = await database;
    return await db.delete(
      'marked_days',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
  }
}