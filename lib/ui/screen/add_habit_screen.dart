import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/habit_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/model/habit.dart';
import '../../utils/icon_utils.dart';

/// 添加/编辑习惯屏幕
class AddHabitScreen extends StatefulWidget {
  final int? habitId;

  const AddHabitScreen({Key? key, this.habitId}) : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  bool _isLoading = false;
  bool _isEditing = false;
  
  // 新增：颜色和图标
  int _selectedColor = 0xFF4CAF50; // 默认绿色
  String _selectedIcon = 'icon_default'; // 默认图标

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _isEditing = true;
      _loadHabit();
    }
  }

  /// 加载习惯数据
  Future<void> _loadHabit() async {
    if (widget.habitId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final habit = await AppDatabase.instance.getHabit(widget.habitId!);
      if (habit != null) {
        _nameController.text = habit.name;
        _notesController.text = habit.notes;
        _startDate = habit.startDate;
        _selectedColor = habit.color;
        _selectedIcon = habit.icon;
      }
    } catch (e) {
      print('Error loading habit: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 保存习惯
  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final habit = Habit(
        id: widget.habitId ?? 0,
        name: _nameController.text.trim(),
        startDate: _startDate,
        moneyPerUnit: 0.0,
        timePerUnit: 0,
        notes: _notesController.text.trim(),
        color: _selectedColor,
        icon: _selectedIcon,
      );

      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      if (_isEditing) {
        await habitProvider.updateHabit(habit);
      } else {
        await habitProvider.addHabit(habit);
      }

      context.pop();
    } catch (e) {
      print('Error saving habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 选择日期和时间
  Future<void> _selectDateTime(BuildContext context) async {
    // 选择日期
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate == null) return;
    
    // 选择时间
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    
    if (pickedTime == null) return;
    
    // 合并日期和时间
    setState(() {
      _startDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  /// 选择颜色
  Future<void> _selectColor(BuildContext context) async {
    // 颜色列表
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
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(color),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedColor == color ? Colors.black : Colors.transparent,
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

  /// 选择图标
  Future<void> _selectIcon(BuildContext context) async {
    // 图标列表
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
            onTap: () {
              setState(() {
                _selectedIcon = icon;
              });
              Navigator.of(context).pop();
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedIcon == icon ? Colors.black : Colors.transparent,
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



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑习惯' : '添加习惯'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 习惯名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '习惯名称',
                  hintText: '例如：吸烟、熬夜',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入习惯名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 开始时间
              Row(
                children: [
                  const Expanded(
                    child: Text('开始时间'),
                  ),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => _selectDateTime(context),
                      child: Text('${_startDate.toLocal().toString().split(' ')[0]} ${_startDate.hour.toString().padLeft(2, '0')}:${_startDate.minute.toString().padLeft(2, '0')}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 习惯颜色
              Row(
                children: [
                  const Expanded(
                    child: Text('习惯颜色'),
                  ),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => _selectColor(context),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Color(_selectedColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('选择颜色'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 习惯图标
              Row(
                children: [
                  const Expanded(
                    child: Text('习惯图标'),
                  ),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => _selectIcon(context),
                      child: Row(
                        children: [
                          Icon(IconUtils.getIconData(_selectedIcon)),
                          const SizedBox(width: 10),
                          const Text('选择图标'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 备注
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '添加一些备注信息',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              // 保存按钮
              ElevatedButton(
                onPressed: _saveHabit,
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}