import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_app/features/auth/presentation/welcome_screen.dart';

void main() async {
  // Bắt buộc khởi động các binding của Flutter trước khi dùng SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra xem trong máy đã lưu spreadsheet_id chưa
  final prefs = await SharedPreferences.getInstance();
  final savedSheetId = prefs.getString('spreadsheet_id');

  final bool hasSheet = savedSheetId != null && savedSheetId.isNotEmpty;

  runApp(MyApp(hasExistingSheet: hasSheet));
}

class MyApp extends StatelessWidget {
  // Thêm giá trị mặc định (= false) để tránh lỗi thiếu tham số
  final bool hasExistingSheet;

  const MyApp({super.key, this.hasExistingSheet = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Nếu đã có sheet rồi -> Vào thẳng màn hình chính (Placeholder)
      // Nếu chưa có -> Vào WelcomeScreen để tạo mới
      home: hasExistingSheet
          ? const PlaceholderHomeScreen()
          : const WelcomeScreen(),
    );
  }
}

// Màn hình tạm thời thay thế cho HomeScreen khi đã có sẵn Sổ
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ Quản Lý Life App')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Đã tìm thấy Sổ Quản Lý trên Google Drive của bạn!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Nút xóa bộ nhớ để test lại màn hình chào mừng từ đầu
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('spreadsheet_id');
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  );
                },
                child: const Text('Đăng xuất / Tạo lại sổ mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
