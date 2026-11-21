import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/expense_repository.dart';
import 'providers/expense_controller.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final repository = await ExpenseRepository.init();
  final controller = ExpenseController(repository);

  runApp(LuxeSpendApp(controller: controller));
}

class LuxeSpendApp extends StatelessWidget {
  final ExpenseController controller;

  const LuxeSpendApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final currentTheme = controller.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        return MaterialApp(
          title: 'LuxeSpend',
          debugShowCheckedModeBanner: false,
          themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeAnimationDuration: const Duration(milliseconds: 350),
          themeAnimationCurve: Curves.easeInOutCubic,
          home: AnimatedTheme(
            data: currentTheme,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            child: MainNavigationScreen(controller: controller),
          ),
        );
      },
    );
  }
}
