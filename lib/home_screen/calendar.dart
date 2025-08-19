// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'custom_bottom_app_bar.dart';
import '../schedule_creation/schedule_creation_page.dart';

// 導入分離的組件
import 'models/schedule_item.dart';
import 'services/calendar_firebase_service.dart';
import 'widgets/custom_calendar_widget.dart';
import 'widgets/schedule_list_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ScheduleItem> scheduleList = [];
  bool isLoading = false;
  
  // 格式狀態控制
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // 從 Firebase 取得行程
  Future<void> _loadSchedules() async {
    if (_selectedDay == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final schedules = await CalendarFirebaseService.loadSchedules(_selectedDay!);
      setState(() {
        scheduleList = schedules;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        scheduleList = [];
      });
    }
  }

  // 新增行程到 Firebase
  Future<void> addScheduleToFirebase(
    String name, 
    String desc, 
    DateTime startTime, 
    DateTime endTime,
  ) async {
    if (_selectedDay == null) return;
    
    try {
      await CalendarFirebaseService.addSchedule(
        selectedDay: _selectedDay!,
        name: name,
        desc: desc,
        startTime: startTime,
        endTime: endTime,
      );
      
      // 重新載入行程
      _loadSchedules();
      
    } catch (e) {
      // 錯誤處理可以在這裡添加用戶提示
      print('新增行程失敗：$e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('行事曆')),
      body: Column(
        children: [
          CustomCalendarWidget(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                scheduleList.clear();
              });
              _loadSchedules();
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null)
            Expanded(
              child: ScheduleListWidget(
                selectedDay: _selectedDay!,
                scheduleList: scheduleList,
                isLoading: isLoading,
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
