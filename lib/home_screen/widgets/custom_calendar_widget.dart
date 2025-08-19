import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/calendar_styles.dart';

/// 自定義日曆組件
class CustomCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;

  const CustomCalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      
      // 格式切換控制
      calendarFormat: calendarFormat,
      availableCalendarFormats: CalendarStyles.availableCalendarFormats,
      
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      
      // 格式切換回調
      onFormatChanged: onFormatChanged,
      
      // 樣式配置
      calendarStyle: CalendarStyles.calendarStyle,
      headerStyle: CalendarStyles.headerStyle,
      calendarBuilders: CalendarStyles.calendarBuilders,
    );
  }
}
