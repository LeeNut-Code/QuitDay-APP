import 'package:go_router/go_router.dart';
import '../ui/screen/main_screen.dart';
import '../ui/screen/habit_detail_screen.dart';
import '../ui/screen/add_habit_screen.dart';
import '../ui/screen/backup_screen.dart';

/// 应用路由管理
class AppRouter {
  /// 创建路由配置
  static GoRouter createRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MainScreen(),
          name: 'main',
        ),
        GoRoute(
          path: '/habit/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return HabitDetailScreen(habitId: id);
          },
          name: 'habit_detail',
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => const AddHabitScreen(),
          name: 'add_habit',
        ),
        GoRoute(
          path: '/edit/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return AddHabitScreen(habitId: id);
          },
          name: 'edit_habit',
        ),
        GoRoute(
          path: '/backup',
          builder: (context, state) => const BackupScreen(),
          name: 'backup',
        ),
      ],
    );
  }
}