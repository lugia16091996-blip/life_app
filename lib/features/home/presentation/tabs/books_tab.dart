
import 'package:flutter/material.dart';

class BooksTab extends StatelessWidget {
  const BooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('Tủ Sách & Tri Thức', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Theo dõi tiến độ đọc sách và ghi chú', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}