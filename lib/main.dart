import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widget.dart';
import 'home_screen/calendar.dart';
import 'home_screen/custom_bottom_app_bar.dart';
import 'daily_schedule/daily_schedule_page.dart';
import 'daily_schedule/utils/schedule_utils.dart'; // ✅ 新增這個 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    developer.log("🚀 開始初始化 Firebase...", name: 'Firebase');
    await Firebase.initializeApp();
    developer.log("✅ Firebase 初始化成功！", name: 'Firebase');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    developer.log(
      "❌ Firebase 初始化失敗",
      name: 'Firebase',
      error: e,
      stackTrace: stackTrace,
    );
    
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
    final url = Uri.parse('https://420fe75aab26.ngrok-free.app/api/submit');
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
          developer.log("成功送出：${response.body}");
          setState(() {
            isReconnecting = false;
            responseMsg = '✅ 成功送出：${response.body}';
          });
          return;
        } else {
          developer.log("錯誤：狀態碼 ${response.statusCode}");
          setState(() {
            responseMsg = '❌ 錯誤：狀態碼 ${response.statusCode}';
          });
        }
      } catch (e) {
        developer.log("連線失敗：$e");
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

  // ✅ 修正：使用與 daily_schedule 相同的資料結構
  Future<List<Map<String, dynamic>>> getSchedules(DateTime selectedDate) async {
    try {
      // 使用與 daily_schedule 相同的路徑格式
      final docPath = ScheduleUtils.formatDateKey(selectedDate);
      
      developer.log('🔍 載入行程列表：$docPath');
      
      final snapshot = await FirebaseFirestore.instance
          .doc(docPath)
          .collection('task_list')
          .orderBy('index')
          .get();

      final schedules = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'desc': data['desc'] ?? data['name'] ?? '未知行程',
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'index': data['index'] ?? 0,
        };
      }).toList();

      developer.log('✅ 成功載入 ${schedules.length} 筆行程');
      return schedules;

    } catch (e) {
      developer.log('❌ 載入行程失敗：$e');
      return [];
    }
  }

  // ✅ 格式化時間顯示
  String _formatScheduleTime(dynamic startTime, dynamic endTime) {
    try {
      if (startTime == null || endTime == null) return '時間未設定';
      
      String start = '';
      String end = '';
      
      if (startTime is Timestamp) {
        final startDate = startTime.toDate();
        start = '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';
      } else if (startTime is String && startTime.contains(':')) {
        start = startTime;
      }
      
      if (endTime is Timestamp) {
        final endDate = endTime.toDate();
        end = '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';
      } else if (endTime is String && endTime.contains(':')) {
        end = endTime;
      }
      
      if (start.isNotEmpty && end.isNotEmpty) {
        return '$start - $end';
      }
      
      return start.isNotEmpty ? start : '時間未設定';
    } catch (e) {
      return '時間未設定';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("今天有什麼行程？"),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
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
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 16
                  ),
                ),
              const SizedBox(height: 10),
              if (responseMsg.isNotEmpty)
                Text(
                  responseMsg,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14
                  ),
                ),
              const SizedBox(height: 20),
              // ✅ 修正：行程列表區域
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getSchedules(widget.selectedDay ?? DateTime.now()), // ✅ 傳遞 DateTime
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      color: Colors.blue.shade600,
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      '讀取失敗：${snapshot.error}',
                      style: TextStyle(color: Colors.red.shade600),
                    );
                  } else {
                    final scheduleList = snapshot.data ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '行程列表',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${ScheduleUtils.formatDate(widget.selectedDay ?? DateTime.now())})', // ✅ 顯示日期
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...scheduleList.map(
                          (item) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(
                                Icons.event,
                                color: Colors.blue.shade600,
                              ),
                              title: Text(
                                item['name']?.isNotEmpty == true 
                                    ? item['name'] 
                                    : (item['desc'] ?? '未知行程'), // ✅ 優先顯示 name
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                _formatScheduleTime(item['startTime'], item['endTime']), // ✅ 格式化時間
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: scheduleList.isNotEmpty 
                                  ? Icon(
                                      Icons.cloud_done, 
                                      color: Colors.green.shade600,
                                    )
                                  : Icon(
                                      Icons.info_outline, 
                                      color: Colors.grey.shade500,
                                    ),
                              onTap: () {
                                if (widget.selectedDay != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DailySchedulePage(
                                        selectedDate: widget.selectedDay!,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        if (scheduleList.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${ScheduleUtils.formatDate(widget.selectedDay ?? DateTime.now())} 沒有行程',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }
                },
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
