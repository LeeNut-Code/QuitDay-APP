import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/database/app_database.dart';
import '../data/model/habit.dart';

/// 习惯状态管理类
class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;

  /// 获取所有习惯
  List<Habit> get habits => _habits;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 加载所有习惯
  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await AppDatabase.instance.getAllHabits();
    } catch (e) {
      print('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加习惯
  Future<void> addHabit(Habit habit) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await AppDatabase.instance.insertHabit(habit);
      final newHabit = habit.copyWith(id: id);
      _habits.add(newHabit);
      
      // 对于Web平台，AppDatabase已经处理了webHabits的更新
    } catch (e) {
      print('Error adding habit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新习惯
  Future<void> updateHabit(Habit habit) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AppDatabase.instance.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
      }
    } catch (e) {
      print('Error updating habit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 删除习惯
  Future<void> deleteHabit(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AppDatabase.instance.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
    } catch (e) {
      print('Error deleting habit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 重置习惯
  Future<void> resetHabit(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AppDatabase.instance.resetHabit(id);
      await loadHabits(); // 重新加载所有习惯以更新状态
    } catch (e) {
      print('Error resetting habit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}