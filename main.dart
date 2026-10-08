import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_screen.dart'; // Изменили импорт на main_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Supabase (ВСТАВЬТЕ СВОИ ДАННЫЕ)
  await Supabase.initialize(
    url: 'https://fbbkuyhnapnvtkzddyxr.supabase.co',
    anonKey: 'sb_publishable_f4SZ-MXOwec8aIv0p4kh6Q_Yx_1ZFRk',
  );

  runApp(const FoodRescueApp());
}

class FoodRescueApp extends StatelessWidget {
  const FoodRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Rescue',
      theme: ThemeData(
        primaryColor: const Color(0xFF005C4B), // Наш темно-зеленый
        scaffoldBackgroundColor: const Color(0xFFF9F8F3), // Бежевый фон
        fontFamily: 'Poppins', // Или любой округлый шрифт
      ),
      home: const MainScreen(), // Заменили HomeScreen на MainScreen
    );
  }
}