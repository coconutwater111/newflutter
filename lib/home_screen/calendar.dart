import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'custom_bottom_app_bar.dart';
import '../schedule_creation/schedule_creation_page.dart';
import 'models/schedule_item.dart';
import 'services/calendar_firebase_service.dart';
import 'widgets/custom_calendar_widget.dart';
import '../../shared/widgets/schedule_list_widget.dart';
import 'package:data_transmit/recommed/chatbotpage.dart'; // 新增的頁面

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
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // 機器人按鈕位置
  Offset _robotButtonOffset = const Offset(300, 500);

  Future<void> _loadSchedules() async {
    if (_selectedDay == null) return;
    setState(() => isLoading = true);
    try {
      final schedules = await CalendarFirebaseService.loadSchedules(
        _selectedDay!,
      );
      setState(() {
        scheduleList = schedules;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        scheduleList = [];
        isLoading = false;
      });
    }
  }

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
      _loadSchedules();
    } catch (e) {
      print('新增行程失敗：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('行事曆')),
      body: Stack(
        children: [
          Column(
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
                  setState(() => _calendarFormat = format);
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

          // 可拖移的機器人按鈕
          Positioned(
            left: _robotButtonOffset.dx,
            top: _robotButtonOffset.dy,
            child: Draggable(
              feedback: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.blue,
                child: const Icon(Icons.smart_toy, size: 30),
              ),
              childWhenDragging: const SizedBox(),
              onDragEnd: (details) {
                setState(() {
                  _robotButtonOffset = details.offset;
                });
              },
              child: FloatingActionButton(
                onPressed: () {
                  // 點擊跳轉到 ChatbotPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatbotPage(),
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.smart_toy, size: 30),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedDay == null
              ? null
              : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ScheduleCreationPage(selectedDay: _selectedDay),
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
