import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/model/habit.dart';

/// 习惯卡片组件
class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  habit.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    context.pushNamed('habit_detail', pathParameters: {'id': habit.id.toString()});
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 戒断时长
            Text(
              '已坚持 ${habit.daysSinceStart} 天',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // 节省的金钱和时间
            Row(
              children: [
                if (habit.moneyPerUnit > 0)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('节省金钱'),
                        Text(
                          '¥${(habit.moneyPerUnit * habit.daysSinceStart).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                if (habit.timePerUnit > 0)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('节省时间'),
                        Text(
                          '${(habit.timePerUnit * habit.daysSinceStart / 60).toStringAsFixed(1)} 小时',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
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