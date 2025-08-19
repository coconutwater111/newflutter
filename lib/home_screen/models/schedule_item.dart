import 'package:cloud_firestore/cloud_firestore.dart';

/// 行程項目數據模型
class ScheduleItem {
  final String desc;
  final String time;
  final String name;
  final String startTime;
  final String endTime;
  final int index;

  const ScheduleItem({
    required this.desc,
    required this.time,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.index,
  });

  /// 從 Firebase 文檔創建 ScheduleItem
  factory ScheduleItem.fromFirebaseDoc(Map<String, dynamic> data) {
    return ScheduleItem(
      desc: data['desc'] ?? data['name'] ?? '未知行程',
      time: _formatTime(data['startTime'], data['endTime']),
      name: data['name'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      index: data['index'] ?? 0,
    );
  }

  /// 轉換為 Map 格式（用於向後兼容）
  Map<String, dynamic> toMap() {
    return {
      'desc': desc,
      'time': time,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'index': index,
    };
  }

  /// 格式化時間顯示的靜態方法
  static String _formatTime(dynamic startTime, dynamic endTime) {
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

  /// 將 Timestamp 轉換為時間字串的靜態方法
  static String _timestampToTimeString(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
