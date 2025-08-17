import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String name;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final int index;
  bool hasOverlap;

  ScheduleModel({
    required this.id,
    required this.name,
    required this.description,
    this.startTime,
    this.endTime,
    required this.index,
    this.hasOverlap = false,
  });

  factory ScheduleModel.fromFirestore(DocumentSnapshot doc, DateTime baseDate) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ScheduleModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['desc'] ?? data['name'] ?? '未知行程',
      startTime: _parseTime(data['startTime'], baseDate),
      endTime: _parseTime(data['endTime'], baseDate),
      index: data['index'] ?? 0,
    );
  }

  static DateTime? _parseTime(dynamic timeData, DateTime baseDate) {
    if (timeData == null) return null;
    
    try {
      if (timeData is Timestamp) {
        return timeData.toDate();
      } else if (timeData is String && timeData.contains(':')) {
        final parts = timeData.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
        }
      }
    } catch (e) {
      // 處理解析錯誤
    }
    
    return null;
  }

  String get timeRange {
    if (startTime == null || endTime == null) {
      return '時間未設定';
    }
    
    final start = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
    final end = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
    
    return '$start - $end';
  }

  String get startTimeString {
    if (startTime == null) return '';
    return '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
  }

  String get endTimeString {
    if (endTime == null) return '';
    return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
  }

  bool overlapsWith(ScheduleModel other) {
    if (startTime == null || endTime == null || other.startTime == null || other.endTime == null) {
      return false;
    }

    final thisStartMinutes = startTime!.hour * 60 + startTime!.minute;
    final thisEndMinutes = endTime!.hour * 60 + endTime!.minute;
    final otherStartMinutes = other.startTime!.hour * 60 + other.startTime!.minute;
    final otherEndMinutes = other.endTime!.hour * 60 + other.endTime!.minute;

    return (thisStartMinutes < otherEndMinutes && otherStartMinutes < thisEndMinutes);
  }
}