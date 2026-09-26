import 'package:flutter/material.dart';

class QuotesTab extends StatelessWidget {
  const QuotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.format_quote, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Kho Tàng Quotes & Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Những câu nói hay và ký hiệu âm nhạc yêu thích',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
