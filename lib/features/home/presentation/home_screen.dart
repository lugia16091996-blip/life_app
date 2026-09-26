import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_app/features/auth/presentation/welcome_screen.dart';

import 'tabs/finance_tab.dart';
import 'tabs/books_tab.dart';
import 'tabs/eq_tab.dart';
import 'tabs/quotes_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const FinanceTab(),
    const BooksTab(),
    const EqTab(),
    const QuotesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ Quản Lý Cá Nhân'),
        actions: [
          // Nút menu phụ (Ví dụ: Đổi sổ / Đăng xuất)
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('spreadsheet_id');
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Đăng xuất / Xóa bộ nhớ sổ'),
              ),
            ],
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType
            .fixed, // Cố định để hiển thị đủ 4 tab mượt mà
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Tài Chính',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Sách'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'EQ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
        ],
      ),
    );
  }
}
