import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // 匯入你要跳轉到的頁面 MyHomePage
import 'custom_bottom_app_bar.dart'; // 匯入自定義的底部應用欄

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> scheduleList = [];
  bool isLoading = false; // 新增載入狀態

  // 範例資料（作為備用）
  final Map<String, List<Map<String, String>>> _scheduleData = {
    '2025-08-13': [
      {'desc': '範例會議', 'time': '09:00-10:00'},
      {'desc': '範例健身房', 'time': '18:00-19:00'},
    ],
  };

  String _dateToKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  // 從 Firebase 取得行程
  Future<void> _loadSchedules() async {
    if (_selectedDay == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // 將日期轉換為 Firebase 路徑格式
      final date = _selectedDay!;
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      
      // 建構文檔路徑到 task_list：tasks/2025/08/04
      final basePath = 'tasks/$year/$month/$day';
      
      print('🔍 正在載入路徑：$basePath/task_list 的所有行程');
      
      // 讀取 task_list subcollection
      final snapshot = await FirebaseFirestore.instance
          .doc(basePath)
          .collection('task_list')
          .orderBy('index') // 按照 index 排序
          .get();
    
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) {
          final data = doc.data();
          print('📄 找到行程 ID: ${doc.id}');
          print('📋 行程內容：$data');
          
          // 轉換資料格式以符合現有的 UI
          return {
            'desc': data['desc'] ?? data['name'] ?? '未知行程',
            'time': _formatTime(data['startTime'], data['endTime']),
            'name': data['name'] ?? '',
            'startTime': data['startTime'] ?? '',
            'endTime': data['endTime'] ?? '',
            'index': data['index'] ?? 0,
          };
        }).toList();
        
        setState(() {
          scheduleList = list;
          isLoading = false;
        });
        
        print('✅ 載入完成，共 ${list.length} 筆行程');
        print('📋 所有行程：$list');
        
      } else {
        print('⚠️ 沒有找到該日期的行程：$basePath/task_list');
        setState(() {
          scheduleList = [];
          isLoading = false;
        });
      }
      
    } catch (e) {
      print('❌ 載入行程時發生錯誤：$e');
      print('🔧 錯誤詳情：${e.runtimeType}');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 新增行程到 Firebase
  Future<void> addScheduleToFirebase(String name, String desc, DateTime startTime, DateTime endTime) async {
    if (_selectedDay == null) return;
    
    try {
      final date = _selectedDay!;
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      
      final basePath = 'tasks/$year/$month/$day';
      
      // 先取得目前的行程數量來決定 index
      final existingTasks = await FirebaseFirestore.instance
          .doc(basePath)
          .collection('task_list')
          .get();
    
      final newIndex = existingTasks.docs.length;
      
      // 新增行程
      await FirebaseFirestore.instance
          .doc(basePath)
          .collection('task_list')
          .add({
        'name': name,
        'desc': desc,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'index': newIndex,
      });
      
      print('✅ 成功新增行程到 $basePath/task_list');
      
      // 重新載入行程
      _loadSchedules();
      
    } catch (e) {
      print('❌ 新增行程失敗：$e');
    }
  }

  // 輔助方法：格式化時間顯示
  String _formatTime(dynamic startTime, dynamic endTime) {
    String start = '';
    String end = '';
    
    // 處理可能的時間格式
    if (startTime != null) {
      if (startTime is Timestamp) {
        start = _timestampToTimeString(startTime);
      } else {
        start = startTime.toString();
      }
    }
    
    if (endTime != null) {
      if (endTime is Timestamp) {
        end = _timestampToTimeString(endTime);
      } else {
        end = endTime.toString();
      }
    }
    
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start - $end';
    } else if (start.isNotEmpty) {
      return '開始：$start';
    } else if (end.isNotEmpty) {
      return '結束：$end';
    } else {
      return '時間未設定';
    }
  }

  // 輔助方法：將 Timestamp 轉換為時間字串
  String _timestampToTimeString(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // 測試 Firebase 結構
  Future<void> _testFirebaseStructure() async {
    try {
      print('🔍 開始檢查 Firebase 結構...');
      
      // 檢查 tasks collection 是否存在
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .limit(5)
          .get();
    
      print('📂 tasks collection 找到 ${tasksSnapshot.docs.length} 個文檔');
      
      for (var doc in tasksSnapshot.docs) {
        print('📄 tasks collection 文檔 ID: ${doc.id}');
        print('📄 tasks collection 文檔內容: ${doc.data()}');
      }
      
      // 檢查特定路徑是否存在
      final specificPath = await FirebaseFirestore.instance
          .doc('tasks/2025')
          .get();
    
      print('📋 tasks/2025 文檔存在: ${specificPath.exists}');
      if (specificPath.exists) {
        print('📋 tasks/2025 內容: ${specificPath.data()}');
      }
      
      // 檢查更深層的路徑
      final deeperPath = await FirebaseFirestore.instance
          .doc('tasks/2025/08/04')
          .get();
    
      print('📋 tasks/2025/08/04 文檔存在: ${deeperPath.exists}');
      if (deeperPath.exists) {
        print('📋 tasks/2025/08/04 內容: ${deeperPath.data()}');
      }
      
      // 直接檢查 task_list subcollection
      print('🔍 檢查 task_list subcollection...');
      final taskListSnapshot = await FirebaseFirestore.instance
          .doc('tasks/2025/08/04')
          .collection('task_list')
          .get();
          
      print('📋 tasks/2025/08/04/task_list 找到 ${taskListSnapshot.docs.length} 個文檔');
      
      for (var doc in taskListSnapshot.docs) {
        print('📄 task_list 文檔 ID: ${doc.id}');
        print('📄 task_list 文檔內容: ${doc.data()}');
      }
    
      // 如果沒有資料，建立測試資料
      if (taskListSnapshot.docs.isEmpty) {
        print('📝 沒有找到資料，正在建立測試資料...');
        
        // 建立測試資料：tasks/2025/08/04/task_list
        await FirebaseFirestore.instance
            .doc('tasks/2025/08/04')
            .collection('task_list')
            .add({
          'desc': '測試會議',
          'endTime': Timestamp.fromDate(DateTime(2025, 8, 4, 10, 0)),
          'index': 0,
          'name': '重要會議',
          'startTime': Timestamp.fromDate(DateTime(2025, 8, 4, 9, 0)),
        });
        
        await FirebaseFirestore.instance
            .doc('tasks/2025/08/04')
            .collection('task_list')
            .add({
          'desc': '午餐約會',
          'endTime': Timestamp.fromDate(DateTime(2025, 8, 4, 13, 0)),
          'index': 1,
          'name': '與朋友午餐',
          'startTime': Timestamp.fromDate(DateTime(2025, 8, 4, 12, 0)),
        });
        
        print('✅ 測試資料建立完成！');
        
        // 重新檢查建立後的資料
        final newTaskListSnapshot = await FirebaseFirestore.instance
            .doc('tasks/2025/08/04')
            .collection('task_list')
            .get();
            
        print('📋 測試資料建立後，tasks/2025/08/04/task_list 現在有 ${newTaskListSnapshot.docs.length} 個文檔');
      }
      
    } catch (e) {
      print('❌ 檢查 Firebase 結構時發生錯誤: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // 在頁面載入時檢查 Firebase 結構
    Future.delayed(Duration(seconds: 1), () {
      _testFirebaseStructure();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateStr = _selectedDay == null ? '' : _dateToKey(_selectedDay!);
    
    // 優先顯示 Firebase 資料，沒有資料時才顯示範例資料
    final displayList = scheduleList.isNotEmpty 
        ? scheduleList 
        : (_scheduleData[selectedDateStr] ?? []);

    return Scaffold(
      appBar: AppBar(title: const Text('行事曆')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                scheduleList.clear(); // 清除舊資料
              });
              _loadSchedules(); // 載入新資料
            },
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${_selectedDay!.toLocal().toString().split(' ')[0]} 的行程',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // 載入中指示器
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  
                  // 行程列表
                  else if (displayList.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final item = displayList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 12,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.event),
                              title: Text(item['name'] ?? item['desc'] ?? '未知行程'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item['desc'] != null && item['desc'] != item['name'])
                                    Text('描述：${item['desc']}'),
                                  Text('時間：${item['time']}'),
                                ],
                              ),
                              trailing: scheduleList.isNotEmpty 
                                  ? const Icon(Icons.cloud_done, color: Colors.green)
                                  : const Icon(Icons.info_outline, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    )
                  
                  // 無行程時顯示
                  else
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              '此天尚無行程',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedDay == null ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(selectedDay: _selectedDay),
            ),
          );
        },
        tooltip: '新增行程',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const CustomBottomAppBar(
        color: Colors.transparent,
        fabLocation: FloatingActionButtonLocation.endDocked,
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}
