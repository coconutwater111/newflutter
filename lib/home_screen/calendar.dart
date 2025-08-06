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

  // 假設行程資料格式如下
  final Map<String, List<Map<String, String>>> _scheduleData = {
    // 範例資料
    '2025-08-07': [
      {'desc': '早上會議', 'time': '09:00-10:00'},
      {'desc': '健身房', 'time': '18:00-19:00'},
    ],
    // 其他日期...
  };

  String _dateToKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final selectedDateStr =
        _selectedDay == null ? '' : _dateToKey(_selectedDay!.toLocal());
    final scheduleList = _scheduleData[selectedDateStr] ?? [];

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Center(
                  child: Text(
                    '你選擇的日期是：${_selectedDay!.toLocal()}'.split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),*/
                // 新增：行程詳細內容
                if (scheduleList.isNotEmpty)
                  ...scheduleList.map(
                    (item) => Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      child: ListTile(
                        title: Text(item['desc'] ?? ''),
                        subtitle: Text(item['time'] ?? ''),
                      ),
                    ),
                  ),
                if (scheduleList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('此天尚無行程', style: TextStyle(color: Colors.grey)),
                  ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _selectedDay == null
                ? null
                : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MyHomePage(selectedDay: _selectedDay),
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
