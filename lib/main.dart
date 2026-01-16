import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/habit_provider.dart';
import 'router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: MaterialApp.router(
        title: 'QuitDay',
        debugShowCheckedModeBanner: false, // 去除debug标记
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        routerConfig: AppRouter.createRouter(),
      ),
    );
  }
}