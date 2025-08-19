import 'package:cloud_firestore/cloud_firestore.dart';

/// 行程項目數據模型
class ScheduleItem {
  final String id;              
  final String desc;
  final String time;
  final String name;
  final DateTime? startDateTime; 
  final DateTime? endDateTime;   
  final String startTime;        
  final String endTime;          
  final int index;

  const ScheduleItem({
    required this.id,
    required this.desc,
    required this.time,
    required this.name,
    required this.startDateTime,
    required this.endDateTime,
    required this.startTime,
    required this.endTime,
    required this.index,
  });

  /// 從 Firebase 文檔創建 ScheduleItem
  factory ScheduleItem.fromFirebaseDoc(Map<String, dynamic> data, String docId) {
    // 提取時間數據
    DateTime? startDateTime;
    DateTime? endDateTime;
    
    final startTimeData = data['startTime'];
    final endTimeData = data['endTime'];
    
    // 處理不同格式的時間數據
    if (startTimeData is Timestamp) {
      startDateTime = startTimeData.toDate();
    } else if (startTimeData is String) {
      startDateTime = _parseTimeString(startTimeData, DateTime.now());
    }
    
    if (endTimeData is Timestamp) {
      endDateTime = endTimeData.toDate();
    } else if (endTimeData is String) {
      endDateTime = _parseTimeString(endTimeData, DateTime.now());
    }
    
    return ScheduleItem(
      id: docId,
      desc: data['desc'] ?? data['name'] ?? '未知行程',
      time: _formatTime(startTimeData, endTimeData),
      name: data['name'] ?? data['desc'] ?? '',
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      startTime: startTimeData?.toString() ?? '',
      endTime: endTimeData?.toString() ?? '',
      index: data['index'] ?? 0,
    );
  }

  /// 轉換為 Map 格式（用於向後兼容）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'desc': desc,
      'time': time,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'index': index,
    };
  }

  /// 獲取用於排序的 DateTime，優先使用 startDateTime
  DateTime? get sortableDateTime => startDateTime ?? endDateTime;

  /// 解析時間字符串為 DateTime（如 "03:50" -> DateTime）
  static DateTime? _parseTimeString(String timeStr, DateTime baseDate) {
    try {
      // 解析 "HH:mm" 格式
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        return DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          hour,
          minute,
        );
      }
    } catch (e) {
      // 靜默處理解析錯誤
    }
    return null;
  }

  /// 格式化時間顯示的靜態方法
  static String _formatTime(dynamic startTime, dynamic endTime) {
    String start = '';
    String end = '';
    
    // 處理可能的時間格式
    if (startTime != null) {
      if (startTime is Timestamp) {
        start = _timestampToTimeString(startTime);
      } else if (startTime is String) {
        start = startTime; // 直接使用字符串格式
      } else {
        start = startTime.toString();
      }
    }
    
    if (endTime != null) {
      if (endTime is Timestamp) {
        end = _timestampToTimeString(endTime);
      } else if (endTime is String) {
        end = endTime; // 直接使用字符串格式
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
