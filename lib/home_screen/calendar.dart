// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_bottom_app_bar.dart';
import '../daily_schedule/daily_schedule_page.dart';
import '../schedule_creation/schedule_creation_page.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> scheduleList = [];
  bool isLoading = false;
  
  // ✅ 加入格式狀態控制
  CalendarFormat _calendarFormat = CalendarFormat.month;



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
        scheduleList = []; // ✅ 確保錯誤時清空列表
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

  @override
  void initState() {
    super.initState();
    // 在頁面載入時檢查 Firebase 結構
    Future.delayed(Duration(seconds: 1), () {
      //_testFirebaseStructure();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ❌ 移除範例資料邏輯，只顯示 Firebase 資料
    final displayList = scheduleList;

    return Scaffold(
      appBar: AppBar(title: const Text('行事曆')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            
            // ✅ 格式切換控制
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.month: '月檢視',
              CalendarFormat.twoWeeks: '兩週檢視',
              CalendarFormat.week: '週檢視',
            },
            
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                scheduleList.clear();
              });
              _loadSchedules();
            },
            
            // ✅ 格式切換回調
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade400,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.blue.shade700,
              ),
              defaultTextStyle: TextStyle(
                color: Colors.grey.shade800,
              ),
              outsideTextStyle: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
            
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Colors.blue.shade600,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Colors.blue.shade600,
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.blue.shade700,
              ),
              formatButtonDecoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue.shade300,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.take(3).map((event) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return null;
              },
            ),
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
                  
                  // ✅ 只顯示 Firebase 行程列表
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
                              title: Text(item['desc'] ?? item['name'] ?? '未知行程'),
                              subtitle: Text(item['time'] ?? '時間未設定'),
                              // ✅ 移除範例資料的區別，都顯示雲朵圖標
                              trailing: const Icon(Icons.cloud_done, color: Colors.green),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DailySchedulePage(
                                      selectedDate: _selectedDay!,
                                    ),
                                  ),
                                );
                              },
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
              builder: (context) => ScheduleCreationPage(selectedDay: _selectedDay),
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
