import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widget.dart';
import 'home_screen/calendar.dart';
import 'home_screen/custom_bottom_app_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("🚀 開始初始化 Firebase...");
    await Firebase.initializeApp();
    print("✅ Firebase 初始化成功！");
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print("❌ Firebase 初始化失敗:");
    print("錯誤: $e");
    print("堆疊追蹤: $stackTrace");
    
    // 執行沒有 Firebase 的版本
    runApp(MyAppWithoutFirebase(error: e.toString()));
  }
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

// 診斷用的備用 App
class MyAppWithoutFirebase extends StatelessWidget {
  final String error;
  
  const MyAppWithoutFirebase({super.key, required this.error});

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
              const SizedBox(height: 16),
              const Text(
                '請檢查:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text('• GoogleService-Info.plist 是否在正確位置'),
              const Text('• Bundle ID 是否一致'),
              const Text('• iOS 部署目標是否 >= 15.0'),
              const Text('• 網路連線是否正常'),
            ],
          ),
        ),
      ),
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

  // 新增資料
  Future<void> addSchedule(String date, String desc, String time) async {
    await FirebaseFirestore.instance.collection('schedules').add({
      'date': date,
      'desc': desc,
      'time': time,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 讀取資料
  Future<List<Map<String, dynamic>>> getSchedules(String date) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('date', isEqualTo: date)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
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
