/// 习惯数据模型
class Habit {
  /// 习惯ID
  final int id;
  
  /// 习惯名称
  final String name;
  
  /// 戒断开始日期
  final DateTime startDate;
  
  /// 上次重置日期
  final DateTime? lastResetDate;
  
  /// 每次消耗的金钱
  final double moneyPerUnit;
  
  /// 每次消耗的时间（分钟）
  final int timePerUnit;
  
  /// 备注
  final String notes;
  
  /// 习惯颜色
  final int color;
  
  /// 习惯图标
  final String icon;

  /// 构造函数
  Habit({
    required this.id,
    required this.name,
    required this.startDate,
    this.lastResetDate,
    this.moneyPerUnit = 0.0,
    this.timePerUnit = 0,
    this.notes = '',
    this.color = 0xFF4CAF50, // 默认绿色
    this.icon = 'icon_default', // 默认图标
  });

  /// 从Map创建Habit实例
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      lastResetDate: map['lastResetDate'] != null ? DateTime.parse(map['lastResetDate']) : null,
      moneyPerUnit: map['moneyPerUnit'] ?? 0.0,
      timePerUnit: map['timePerUnit'] ?? 0,
      notes: map['notes'] ?? '',
      color: map['color'] ?? 0xFF4CAF50,
      icon: map['icon'] ?? 'icon_default',
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'lastResetDate': lastResetDate?.toIso8601String(),
      'moneyPerUnit': moneyPerUnit,
      'timePerUnit': timePerUnit,
      'notes': notes,
      'color': color,
      'icon': icon,
    };
  }
  /// 计算当前已坚持的天数
  int get daysSinceStart {
    final now = DateTime.now();
    final start = lastResetDate ?? startDate;
    return now.difference(start).inDays;
  }

  /// 计算当前已坚持的小时数
  int get hoursSinceStart {
    final now = DateTime.now();
    final start = lastResetDate ?? startDate;
    return now.difference(start).inHours;
  }

  /// 计算当前已坚持的分钟数
  int get minutesSinceStart {
    final now = DateTime.now();
    final start = lastResetDate ?? startDate;
    return now.difference(start).inMinutes;
  }

  /// 获取已坚持的完整时间差
  Duration get timeSinceStart {
    final now = DateTime.now();
    final start = lastResetDate ?? startDate;
    return now.difference(start);
  }

  /// 获取格式化的已坚持时间
  String get formattedTimeSinceStart {
    final duration = timeSinceStart;
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
  /// 计算节省的金钱
  double get moneySaved {
    final days = daysSinceStart;
    return days * moneyPerUnit;
  }

  /// 计算节省的时间（分钟）
  int get timeSaved {
    final days = daysSinceStart;
    return days * timePerUnit;
  }

  /// 创建一个新的Habit实例，更新指定的属性
  Habit copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? lastResetDate,
    double? moneyPerUnit,
    int? timePerUnit,
    String? notes,
    int? color,
    String? icon,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      moneyPerUnit: moneyPerUnit ?? this.moneyPerUnit,
      timePerUnit: timePerUnit ?? this.timePerUnit,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

/// 标记日期数据模型
class MarkedDay {
  /// 标记ID
  final int? id;
  
  /// 习惯ID
  final int habitId;
  
  /// 标记日期
  final DateTime date;
  
  /// 备注
  final String note;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;

  /// 构造函数
  MarkedDay({
    this.id,
    required this.habitId,
    required this.date,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从Map创建MarkedDay实例
  factory MarkedDay.fromMap(Map<String, dynamic> map) {
    return MarkedDay(
      id: map['id'],
      habitId: map['habit_id'],
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 创建一个新的MarkedDay实例，更新指定的属性
  MarkedDay copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarkedDay(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}