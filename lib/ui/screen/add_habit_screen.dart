import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/habit_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/model/habit.dart';

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
  final _moneyController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  bool _isLoading = false;
  bool _isEditing = false;

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
        _moneyController.text = habit.moneyPerUnit.toString();
        _timeController.text = habit.timePerUnit.toString();
        _notesController.text = habit.notes;
        _startDate = habit.startDate;
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
        moneyPerUnit: double.tryParse(_moneyController.text) ?? 0.0,
        timePerUnit: int.tryParse(_timeController.text) ?? 0,
        notes: _notesController.text.trim(),
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

  /// 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
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
              // 开始日期
              Row(
                children: [
                  const Expanded(
                    child: Text('开始日期'),
                  ),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(_startDate.toLocal().toString().split(' ')[0]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 每次消耗的金钱
              TextFormField(
                controller: _moneyController,
                decoration: const InputDecoration(
                  labelText: '每次消耗的金钱',
                  hintText: '例如：10.0',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // 每次消耗的时间
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: '每次消耗的时间（分钟）',
                  hintText: '例如：30',
                ),
                keyboardType: TextInputType.number,
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