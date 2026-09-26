
import 'package:flutter/material.dart';

class EqTab extends StatelessWidget {
  const EqTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology, size: 64, color: Colors.purple),
          SizedBox(height: 16),
          Text('Quản lý Cảm Xúc (EQ)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Ghi chép tâm trạng và bài học nội tâm', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}