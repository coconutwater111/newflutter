import 'package:flutter/material.dart';

class ErrorHandler extends StatelessWidget {
  final String error;
  
  const ErrorHandler({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase 診斷'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Firebase 初始化失敗',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildErrorDetails(),
              const SizedBox(height: 16),
              _buildCheckList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '錯誤詳情:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            error,
            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckList() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '請檢查:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text('• GoogleService-Info.plist 是否在正確位置'),
        Text('• Bundle ID 是否一致'),
        Text('• iOS 部署目標是否 >= 15.0'),
        Text('• 網路連線是否正常'),
      ],
    );
  }
}