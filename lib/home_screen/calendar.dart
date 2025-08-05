import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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

  @override
  Widget build(BuildContext context) {
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
              });
            },
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null)
            Column(
              children: [
                Text(
                  '你選擇的日期是：${_selectedDay!.toLocal()}'.split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedDay == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      selectedDay: _selectedDay,
                    ),
                  ),
                );
              },
        tooltip: '新增',
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
