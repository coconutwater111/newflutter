import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
// import 'package:firebase_core/firebase_core.dart'; // 暫時註解

import 'widget.dart';
import 'home_screen/calendar.dart';
import 'home_screen/custom_bottom_app_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // 暫時註解
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const CalendarScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final DateTime? selectedDay;// 接收從 CalendarScreen 傳來的 selectedDay
  const MyHomePage({super.key, this.selectedDay});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isReconnecting = false;
  int retryCount = 0;
  String responseMsg = '';

  Future<void> _sendToBackend(Map<String, dynamic> data) async {
    final url = Uri.parse('https://941009b92a2b.ngrok-free.app/api/submit');
    int maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      setState(() {
        isReconnecting = true;
        retryCount = attempt;
      });

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          log("成功送出：${response.body}");
          setState(() {
            isReconnecting = false;
            responseMsg = '✅ 成功送出：${response.body}';
          });
          return;
        } else {
          log("錯誤：狀態碼 ${response.statusCode}");
          setState(() {
            responseMsg = '❌ 錯誤：狀態碼 ${response.statusCode}';
          });
        }
      } catch (e) {
        log("連線失敗：$e");
        setState(() {
          responseMsg = "⚠️ 第 $attempt 次連線失敗：$e";
        });
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // 若三次都失敗
    setState(() {
      isReconnecting = false;
      responseMsg += '\n🚫 無法連線伺服器，請稍後再試。';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("輸入行程")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( // ← 建議加這行避免內容超出
          child: Column(
            children: [
              InputSection(
                onSubmit: _sendToBackend,
                selectedDay: widget.selectedDay ?? DateTime.now(),
              ),
              const SizedBox(height: 20),
              if (isReconnecting)
                Text(
                  "🔄 正在重新連接... 第 $retryCount 次",
                  style: const TextStyle(color: Colors.orange, fontSize: 16),
                ),
              const SizedBox(height: 10),
              if (responseMsg.isNotEmpty)
                Text(
                  responseMsg,
                  style: const TextStyle(color: Colors.blue, fontSize: 14),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(
        color: Colors.transparent,
        fabLocation: FloatingActionButtonLocation.endDocked,
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}
