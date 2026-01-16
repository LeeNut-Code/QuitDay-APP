import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/habit_provider.dart';
import '../widget/habit_card.dart';

/// 主屏幕（戒断仪表盘）
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // 加载习惯数据
    Provider.of<HabitProvider>(context, listen: false).loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuitDay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_backup_restore),
            onPressed: () {
              context.pushNamed('backup');
            },
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          if (habitProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = habitProvider.habits;

          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('还没有添加习惯，开始添加第一个习惯吧！'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.pushNamed('add_habit');
                    },
                    child: const Text('添加习惯'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitCard(habit: habit);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('add_habit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}