import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 日曆樣式配置工具類
class CalendarStyles {
  
  /// 獲取日曆樣式配置
  static CalendarStyle get calendarStyle => CalendarStyle(
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
  );

  /// 獲取標題欄樣式配置
  static HeaderStyle get headerStyle => HeaderStyle(
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
  );

  /// 獲取可用的日曆格式
  static Map<CalendarFormat, String> get availableCalendarFormats => const {
    CalendarFormat.month: '週',
    CalendarFormat.twoWeeks: '月',
    CalendarFormat.week: '兩週',
  };

  /// 日曆建構器
  static CalendarBuilders get calendarBuilders => CalendarBuilders(
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
  );
}
