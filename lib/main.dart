import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_app/features/auth/presentation/welcome_screen.dart';

// 1. Import màn hình chính chứa 4 tab vào đây
import 'package:life_app/features/home/presentation/home_screen.dart';

void main() async {
  // Bắt buộc khởi động các binding của Flutter trước khi dùng SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra xem trong máy đã lưu spreadsheet_id chưa
  final prefs = await SharedPreferences.getInstance();
  final savedSheetId = prefs.getString('spreadsheet_id');

  runApp(
    MyApp(hasExistingSheet: savedSheetId != null && savedSheetId.isNotEmpty),
  );
}

class MyApp extends StatelessWidget {
  final bool hasExistingSheet;

  const MyApp({super.key, required this.hasExistingSheet});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 2. Nếu đã có sheet -> Vào thẳng HomeScreen (4 tab)
      // Nếu chưa có -> Vào WelcomeScreen để tạo mới
      home: hasExistingSheet ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}
