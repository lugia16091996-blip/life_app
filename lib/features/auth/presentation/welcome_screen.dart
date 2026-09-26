import 'package:life_app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import GoogleAuthService chính chủ
import 'package:life_app/core/services/google_auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  // Hàm xử lý Đăng nhập Google & Tạo Sổ chính chủ
  Future<void> _handleCreateWorkspace() async {
    final ownerName = _nameController.text.trim();
    if (ownerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên của bạn hoặc tên cặp đôi!'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Gọi GoogleAuthService thực hiện Đăng nhập Gmail & Tạo file trên Google Drive cá nhân
    final sheetId = await GoogleAuthService.createLifeWorkspaceInUserDrive(
      ownerName,
    );

    setState(() {
      _isLoading = false;
    });

    if (sheetId != null) {
      // Lưu Spreadsheet ID vào bộ nhớ điện thoại
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('spreadsheet_id', sheetId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tạo sổ thành công trên Google Drive! ID: $sheetId'),
        ),
      );

      // 🚀 ĐIỀU HƯỚNG THẲNG SANG MÀN HÌNH CHÍNH NGAY LẬP TỨC (Không cần F5)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập hoặc tạo sổ thất bại. Vui lòng thử lại!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chào mừng đến với Life Management')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Thiết lập Sổ Quản Lý Chính Chủ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Đăng nhập tài khoản Google để tự động khởi tạo file Sổ Quản Lý nằm trực tiếp trên Google Drive cá nhân của bạn.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên của bạn (hoặc tên chung cặp đôi)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _handleCreateWorkspace,
                    icon: const Icon(Icons.login),
                    label: const Text('Đăng nhập Google & Tạo Sổ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
