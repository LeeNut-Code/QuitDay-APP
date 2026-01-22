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
  DateTime _currentDate = DateTime.now();
  List<MarkedDay> _markedDays = [];
  
  // 时间范围配置（天数）
  final List<int> _timeRanges = [7, 30, 90, 180, 365];
  
  // 模拟重置记录
  final List<DateTime> _resetHistory = [];
  int _resetCount = 0;

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
      if (_habit != null) {
        // 加载标记日期
        _markedDays = await AppDatabase.instance.getMarkedDaysByHabitId(widget.habitId);
        // 模拟重置记录
        _resetCount = 5; // 模拟重置次数
      }
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
        title: const Text('标记当前时间'),
        content: const Text('确定要标记当前时间吗？这将更新计时。'),
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
      // 标记当前时间
      final now = DateTime.now();
      final newMark = MarkedDay(
        habitId: widget.habitId,
        date: now,
        note: '重置计数',
        createdAt: now,
        updatedAt: now,
      );
      final markId = await AppDatabase.instance.insertMarkedDay(newMark);
      final savedMark = newMark.copyWith(id: markId);
      
      // 更新界面显示
      setState(() {
        _markedDays.add(savedMark);
        _resetCount++;
        _resetHistory.add(now);
      });
    }
  }



  /// 绘制时间轮盘
  Widget _buildTimeWheel() {
    if (_habit == null) return const SizedBox();

    final habit = _habit!;
    // 计算最近的标记日期到今天的时间差
    final duration = _getDurationSinceLastMark();
    
    // 计算天、小时、分钟
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    // 格式化时间显示
    String timeDisplay;
    if (days > 0) {
      timeDisplay = '$days天${hours > 0 ? '$hours小时' : ''}${minutes > 0 ? '$minutes分' : ''}';
    } else if (hours > 0) {
      timeDisplay = '$hours小时${minutes > 0 ? '$minutes分' : ''}';
    } else {
      timeDisplay = '$minutes分';
    }
    
    // 计算最近的不超过已坚持时间的时间刻度
    int selectedRange = 7;
    final totalDays = duration.inDays.toDouble();
    for (int range in _timeRanges) {
      if (totalDays >= range) {
        selectedRange = range;
      }
    }
    
    // 设置时间范围显示
    String rangeDisplay;
    if (selectedRange == 7) {
      rangeDisplay = '7天';
    } else if (selectedRange == 30) {
      rangeDisplay = '30天';
    } else if (selectedRange == 90) {
      rangeDisplay = '90天';
    } else if (selectedRange == 180) {
      rangeDisplay = '180天';
    } else {
      rangeDisplay = '365天';
    }
    
    // 如果超过了所有时间范围，使用最大的时间范围（365天）
    if (totalDays > selectedRange) {
      selectedRange = _timeRanges.last;
      rangeDisplay = '365天';
    }
    
    // 计算进度
    final progress = (totalDays / selectedRange).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 轮盘背景
          SizedBox(
            width: 300,
            height: 300,
            child: CustomPaint(
              painter: TimeWheelPainter(
                progress: progress,
                color: Color(habit.color),
                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.3),
              ),
            ),
          ),
          // 中心文字
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeDisplay,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '/ $rangeDisplay',
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
              Text(
                '已坚持',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 绘制日历
  Widget _buildCalendar() {
    if (_habit == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 月份选择
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, size: 24, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  // 切换到上个月
                  setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
                  });
                },
              ),
              Text(
                '${_currentDate.year}年${_currentDate.month}月',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 24, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  // 切换到下个月，但不能超过当前月份
                  final nextMonth = DateTime(_currentDate.year, _currentDate.month + 1, 1);
                  final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
                  
                  if (nextMonth.isBefore(currentMonth) || _isSameDay(nextMonth, currentMonth)) {
                    setState(() {
                      _currentDate = nextMonth;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 星期标题
          Row(
            children: ['日', '一', '二', '三', '四', '五', '六'].map((day) => 
              Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
                ),
              )
            ).toList(),
          ),
          const SizedBox(height: 10),
          // 日历网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _getCalendarDaysCount(),
            itemBuilder: (context, index) {
              final date = _getDateFromIndex(index);
              
              if (date == null) {
                return const SizedBox();
              }
              
              // 检查日期类型
              final isToday = _isSameDay(date, DateTime.now());
              final isStartDate = _isSameDay(date, _habit!.startDate);
              final isMarkedDay = _isMarkedDay(date);
              final isFutureDay = date.isAfter(DateTime.now());
              
              // 确定日期背景颜色
              Color? backgroundColor;
              if (isToday) {
                backgroundColor = Color(_habit!.color);
              } else if (isStartDate) {
                backgroundColor = Colors.blue;
              } else if (isMarkedDay) {
                backgroundColor = Color(_habit!.color).withOpacity(0.3);
              } else if (isFutureDay) {
                backgroundColor = Theme.of(context).colorScheme.surface.withOpacity(0.7);
              }
              
              return GestureDetector(
                onTap: isFutureDay ? null : () => _onDateTap(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday 
                            ? Colors.white 
                            : isFutureDay 
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) 
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isToday || isStartDate ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // 重置按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _resetHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(_habit!.color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text('标记当前时间', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取所有标记日期（包括开始日期）
  List<DateTime> _getAllMarkedDates() {
    if (_habit == null) return [];
    
    final allMarks = [..._markedDays.map((md) => md.date)];
    allMarks.add(_habit!.startDate);
    // 按时间排序
    allMarks.sort((a, b) => a.compareTo(b));
    return allMarks;
  }

  /// 格式化持续时间
  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '$days天${hours > 0 ? '$hours小时' : ''}${minutes > 0 ? '$minutes分钟' : ''}';
    } else if (hours > 0) {
      return '$hours小时${minutes > 0 ? '$minutes分钟' : ''}';
    } else {
      return '$minutes分钟';
    }
  }

  /// 计算所有习惯间隔
  List<Duration> _calculateIntervals() {
    final allDates = _getAllMarkedDates();
    final intervals = <Duration>[];
    
    for (int i = 1; i < allDates.length; i++) {
      final interval = allDates[i].difference(allDates[i - 1]);
      intervals.add(interval);
    }
    
    return intervals;
  }

  /// 绘制统计模块
  Widget _buildStatistics() {
    if (_habit == null) return const SizedBox();

    final habit = _habit!;
    final allDates = _getAllMarkedDates();
    final intervals = _calculateIntervals();
    
    // 开始时间：最早的标记时间
    final startTime = allDates.isNotEmpty ? allDates.first : habit.startDate;
    final startTimeText = '${startTime.toLocal().toString().split(' ')[0]} ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} ${_getWeekday(startTime.weekday)}';
    
    // 习惯间隔计算
    String longestInterval = '无数据';
    String shortestInterval = '无数据';
    String averageInterval = '无数据';
    String lastInterval = '无数据';
    
    if (intervals.isNotEmpty) {
      // 最长习惯间隔
      final maxInterval = intervals.reduce((a, b) => a > b ? a : b);
      longestInterval = _formatDuration(maxInterval);
      
      // 最短习惯间隔
      final minInterval = intervals.reduce((a, b) => a < b ? a : b);
      shortestInterval = _formatDuration(minInterval);
      
      // 平均习惯间隔
      final totalDuration = intervals.fold(Duration.zero, (sum, interval) => sum + interval);
      final avgDuration = Duration(microseconds: totalDuration.inMicroseconds ~/ intervals.length);
      averageInterval = _formatDuration(avgDuration);
      
      // 上一次的习惯间隔：计算倒数第一次标记和倒数第二次标记的间隔时间
      if (intervals.length >= 1) {
        final lastInt = intervals[intervals.length - 1];
        lastInterval = _formatDuration(lastInt);
      }
    }
    
    // 计数器重置次数：所有标记时间的数量
    final resetCount = _markedDays.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('统计数据', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 24),
          
          // 开始日期
          _buildStatRow('开始时间', startTimeText),
          const SizedBox(height: 16),
          
          // 最长间隔
          _buildStatRow('最长习惯间隔', longestInterval),
          const SizedBox(height: 16),
          
          // 最短间隔
          _buildStatRow('最短习惯间隔', shortestInterval),
          const SizedBox(height: 16),
          
          // 平均间隔
          _buildStatRow('平均习惯间隔', averageInterval),
          const SizedBox(height: 16),
          
          // 上一次间隔
          _buildStatRow('上一次的习惯间隔', lastInterval),
          const SizedBox(height: 16),
          
          // 重置次数
          _buildStatRow('计数器重置次数', '$resetCount'),
        ],
      ),
    );
  }
  /// 构建统计行
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
  /// 获取星期几
  String _getWeekday(int weekday) {
    final weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    return weekdays[weekday % 7];
  }

  /// 计算日历显示的总天数
  int _getCalendarDaysCount() {
    // 计算当月第一天是星期几
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;
    
    // 计算当月的天数
    final daysInMonth = _getDaysInMonth(_currentDate.year, _currentDate.month);
    
    // 计算日历需要显示的总天数（包括上个月和下个月的填充天数）
    return firstDayWeekday + daysInMonth + (7 - (firstDayWeekday + daysInMonth) % 7) % 7;
  }

  /// 获取指定月份的天数
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 根据索引获取对应的日期
  DateTime? _getDateFromIndex(int index) {
    // 计算当月第一天是星期几
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;
    
    // 计算索引对应的日期
    final dayOffset = index - firstDayWeekday + 1;
    
    if (dayOffset < 1) {
      // 上个月的日期
      final prevMonth = _currentDate.month == 1 ? 12 : _currentDate.month - 1;
      final prevYear = _currentDate.month == 1 ? _currentDate.year - 1 : _currentDate.year;
      final daysInPrevMonth = _getDaysInMonth(prevYear, prevMonth);
      final prevMonthDay = daysInPrevMonth + dayOffset;
      return DateTime(prevYear, prevMonth, prevMonthDay);
    }
    
    final daysInMonth = _getDaysInMonth(_currentDate.year, _currentDate.month);
    if (dayOffset > daysInMonth) {
      // 下个月的日期
      final nextMonth = _currentDate.month == 12 ? 1 : _currentDate.month + 1;
      final nextYear = _currentDate.month == 12 ? _currentDate.year + 1 : _currentDate.year;
      final nextMonthDay = dayOffset - daysInMonth;
      return DateTime(nextYear, nextMonth, nextMonthDay);
    }
    
    // 当月的日期
    return DateTime(_currentDate.year, _currentDate.month, dayOffset);
  }

  /// 比较两个日期是否是同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  /// 检查日期是否被标记
  bool _isMarkedDay(DateTime date) {
    return _markedDays.any((markedDay) => _isSameDay(markedDay.date, date));
  }

  /// 处理日期点击事件
  void _onDateTap(DateTime date) {
    // 查找是否已经存在标记
    final existingMark = _markedDays.firstWhere(
      (markedDay) => _isSameDay(markedDay.date, date),
      orElse: () => MarkedDay(
        id: null,
        habitId: widget.habitId,
        date: DateTime.now(),
        note: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    // 弹出添加标记的界面
    showDialog(
      context: context,
      builder: (context) {
        String note = existingMark.note;
        TimeOfDay selectedTime = TimeOfDay.fromDateTime(existingMark.date);
        
        return AlertDialog(
          title: Text('添加标记 - ${date.year}年${date.month}月${date.day}日'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 时间选择器
              ListTile(
                title: const Text('时间'),
                subtitle: Text('${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null) {
                    selectedTime = pickedTime;
                  }
                },
              ),
              // 备注输入
              TextField(
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '记录该习惯在这一天的事件',
                ),
                maxLines: 3,
                controller: TextEditingController(text: note),
                onChanged: (value) {
                  note = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final now = DateTime.now();
                final isExisting = existingMark.id != null;
                
                // 组合日期和时间
                final selectedDateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                
                if (isExisting) {
                  // 更新现有标记
                  final updatedMark = existingMark.copyWith(
                    date: selectedDateTime,
                    note: note,
                    updatedAt: now,
                  );
                  await AppDatabase.instance.updateMarkedDay(updatedMark);
                  setState(() {
                    final index = _markedDays.indexWhere((md) => md.id == updatedMark.id);
                    if (index != -1) {
                      _markedDays[index] = updatedMark;
                    }
                  });
                } else {
                  // 创建新标记
                  final newMark = MarkedDay(
                    habitId: widget.habitId,
                    date: selectedDateTime,
                    note: note,
                    createdAt: now,
                    updatedAt: now,
                  );
                  final markId = await AppDatabase.instance.insertMarkedDay(newMark);
                  final savedMark = newMark.copyWith(id: markId);
                  setState(() {
                    _markedDays.add(savedMark);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 计算最近的标记日期到今天的距离
  Duration _getDurationSinceLastMark() {
    // 找到所有标记日期（包括开始日期作为第一个标记）
    final allMarks = [..._markedDays];
    if (_habit != null) {
      allMarks.add(MarkedDay(
        habitId: widget.habitId,
        date: _habit!.startDate,
        note: '开始时间',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    
    if (allMarks.isEmpty) {
      return Duration.zero;
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
    return now.difference(latestMarkedDay);
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 编辑习惯 - 与主页面重命名按钮功能一致
              context.pushNamed('edit_habit', pathParameters: {'id': widget.habitId.toString()});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // 删除习惯
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
                // 执行删除操作
                await AppDatabase.instance.deleteHabit(widget.habitId);
                await AppDatabase.instance.deleteMarkedDaysByHabitId(widget.habitId);
                // 导航回主页并更新主页条目
                context.pushReplacement('/');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 时间轮盘
            _buildTimeWheel(),
            
            // 日历模块
            _buildCalendar(),
            
            const SizedBox(height: 30),
            

            
            // 统计模块
            _buildStatistics(),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

/// 时间轮盘绘制器
class TimeWheelPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  TimeWheelPainter({required this.progress, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // 绘制背景圆环
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 绘制进度圆环
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    
    final startAngle = -90 * (3.1415926535 / 180);
    final sweepAngle = 2 * 3.1415926535 * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}