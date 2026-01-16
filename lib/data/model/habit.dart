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

  /// 构造函数
  Habit({
    required this.id,
    required this.name,
    required this.startDate,
    this.lastResetDate,
    this.moneyPerUnit = 0.0,
    this.timePerUnit = 0,
    this.notes = '',
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
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      moneyPerUnit: moneyPerUnit ?? this.moneyPerUnit,
      timePerUnit: timePerUnit ?? this.timePerUnit,
      notes: notes ?? this.notes,
    );
  }
}