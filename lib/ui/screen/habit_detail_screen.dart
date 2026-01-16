import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/habit_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/model/habit.dart';

/// 习惯详情屏幕
class HabitDetailScreen extends StatefulWidget {
  final int habitId;

  const HabitDetailScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  Habit? _habit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  /// 加载习惯详情
  Future<void> _loadHabit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _habit = await AppDatabase.instance.getHabit(widget.habitId);
    } catch (e) {
      print('Error loading habit: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 重置习惯
  Future<void> _resetHabit() async {
    if (_habit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置习惯'),
        content: const Text('确定要重置这个习惯吗？这将重新开始计时。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<HabitProvider>(context, listen: false).resetHabit(widget.habitId);
      await _loadHabit();
    }
  }

  /// 删除习惯
  Future<void> _deleteHabit() async {
    if (_habit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除习惯'),
        content: const Text('确定要删除这个习惯吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<HabitProvider>(context, listen: false).deleteHabit(widget.habitId);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_habit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('习惯详情'),
        ),
        body: const Center(
          child: Text('习惯不存在'),
        ),
      );
    }

    final habit = _habit!;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed('edit_habit', pathParameters: {'id': habit.id.toString()});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteHabit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 戒断时长
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('戒断时长'),
                    const SizedBox(height: 8),
                    Text(
                      '${habit.daysSinceStart} 天 ${habit.hoursSinceStart % 24} 小时 ${habit.minutesSinceStart % 60} 分钟',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 节省的资源
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('节省的资源'),
                    const SizedBox(height: 16),
                    if (habit.moneyPerUnit > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('金钱'),
                          Text(
                            '¥${(habit.moneySaved).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    if (habit.timePerUnit > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('时间'),
                          Text(
                            '${(habit.timeSaved / 60).toStringAsFixed(1)} 小时',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 习惯详情
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('习惯详情'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('开始日期'),
                        Text(habit.startDate.toLocal().toString().split(' ')[0]),
                      ],
                    ),
                    if (habit.lastResetDate != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('上次重置日期'),
                          Text(habit.lastResetDate!.toLocal().toString().split(' ')[0]),
                        ],
                      ),
                    if (habit.notes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text('备注'),
                          Text(habit.notes),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetHabit,
                    child: const Text('重置习惯'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 标记今天已坚持
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('今天已坚持！')),
                      );
                    },
                    child: const Text('今天坚持住了'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}