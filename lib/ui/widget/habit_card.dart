import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/model/habit.dart';
import '../../provider/habit_provider.dart';
import '../../utils/icon_utils.dart';
import '../../data/database/app_database.dart';

/// 习惯卡片组件
class HabitCard extends StatefulWidget {
  final Habit habit;

  const HabitCard({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  List<MarkedDay> _markedDays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkedDays();
  }

  /// 加载标记日期
  Future<void> _loadMarkedDays() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _markedDays = await AppDatabase.instance.getMarkedDaysByHabitId(widget.habit.id);
    } catch (e) {
      print('Error loading marked days: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 计算已坚持时间
  String _getFormattedTimeSinceLastMark() {
    // 找到所有标记日期（包括开始日期作为第一个标记）
    final allMarks = [..._markedDays];
    allMarks.add(MarkedDay(
      habitId: widget.habit.id,
      date: widget.habit.startDate,
      note: '开始时间',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    
    if (allMarks.isEmpty) {
      return '0分';
    }
    
    // 找到最近的标记日期（最新的标记日期）
    DateTime latestMarkedDay = allMarks.first.date;
    for (MarkedDay markedDay in allMarks) {
      if (markedDay.date.isAfter(latestMarkedDay)) {
        latestMarkedDay = markedDay.date;
      }
    }
    
    // 计算从最近标记日期到今天的时间差
    final now = DateTime.now();
    final duration = now.difference(latestMarkedDay);
    
    // 格式化时间显示
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '$days天${hours > 0 ? '$hours小时' : ''}${minutes > 0 ? '$minutes分' : ''}';
    } else if (hours > 0) {
      return '$hours小时${minutes > 0 ? '$minutes分' : ''}';
    } else {
      return '$minutes分';
    }
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 导航到习惯详情页面
        context.pushNamed('habit_detail', pathParameters: {'id': widget.habit.id.toString()});
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(widget.habit.color).withOpacity(0.1),
                Color(widget.habit.color).withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // 习惯图标
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(widget.habit.color),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Icon(
                              IconUtils.getIconData(widget.habit.icon),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 习惯名称
                        Text(
                          widget.habit.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color(widget.habit.color),
                          ),
                        ),
                      ],
                    ),
                    // 菜单按钮
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        _handleMenuSelection(context, value);
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'color',
                          child: Text('更改颜色'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'icon',
                          child: Text('更改图标'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'rename',
                          child: Text('重命名'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('删除', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 戒断时长
                Text(
                  '已坚持 ${_getFormattedTimeSinceLastMark()}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                // 节省的金钱和时间
                Row(
                  children: [
                    if (widget.habit.moneyPerUnit > 0)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('节省金钱'),
                            Text(
                              '¥${(widget.habit.moneyPerUnit * widget.habit.daysSinceStart).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(widget.habit.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.habit.timePerUnit > 0)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('节省时间'),
                            Text(
                              '${(widget.habit.timePerUnit * widget.habit.daysSinceStart / 60).toStringAsFixed(1)} 小时',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(widget.habit.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 处理菜单选择
  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'color':
        // 实现更改颜色的逻辑
        _showColorPicker(context);
        break;
      case 'icon':
        // 实现更改图标的逻辑
        _showIconPicker(context);
        break;
      case 'rename':
        // 导航到编辑页面
        context.pushNamed('edit_habit', pathParameters: {'id': widget.habit.id.toString()});
        break;
      case 'delete':
        // 实现删除习惯的逻辑
        _confirmDelete(context);
        break;
    }
  }

  /// 显示颜色选择器
  void _showColorPicker(BuildContext context) {
    // 这里可以实现颜色选择器
    // 暂时使用简单的颜色列表
    final colors = [
      0xFF4CAF50, // 绿色
      0xFF2196F3, // 蓝色
      0xFFFF9800, // 橙色
      0xFFF44336, // 红色
      0xFF9C27B0, // 紫色
      0xFF00BCD4, // 青色
      0xFF795548, // 棕色
      0xFF607D8B, // 蓝灰色
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors.map((color) => GestureDetector(
            onTap: () async {
              // 更新习惯颜色
              final updatedHabit = widget.habit.copyWith(color: color);
              final habitProvider = Provider.of<HabitProvider>(context, listen: false);
              await habitProvider.updateHabit(updatedHabit);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(color),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.habit.color == color ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 显示图标选择器
  void _showIconPicker(BuildContext context) {
    // 这里可以实现图标选择器
    // 暂时使用简单的图标列表
    final icons = [
      'icon_smoking',
      'icon_drinking',
      'icon_caffeine',
      'icon_junk_food',
      'icon_procrastination',
      'icon_default',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图标'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: icons.map((icon) => GestureDetector(
            onTap: () async {
              // 更新习惯图标
              final updatedHabit = widget.habit.copyWith(icon: icon);
              final habitProvider = Provider.of<HabitProvider>(context, listen: false);
              await habitProvider.updateHabit(updatedHabit);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.habit.icon == icon ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(IconUtils.getIconData(icon)),
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 确认删除
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除习惯 "${widget.habit.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 删除习惯
              final habitProvider = Provider.of<HabitProvider>(context, listen: false);
              await habitProvider.deleteHabit(widget.habit.id);
              Navigator.of(context).pop();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


}