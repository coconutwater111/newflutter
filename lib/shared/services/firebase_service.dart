import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../daily_schedule/utils/schedule_utils.dart';

class FirebaseService {
  static Future<List<Map<String, dynamic>>> getSchedules(DateTime selectedDate) async {
    try {
      final docPath = ScheduleUtils.formatDateKey(selectedDate);
      
      developer.log('🔍 載入行程列表：$docPath');
      
      final snapshot = await FirebaseFirestore.instance
          .doc(docPath)
          .collection('task_list')
          .get();

      final schedules = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'desc': data['desc'] ?? data['name'] ?? '未知行程',
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'index': data['index'] ?? 0,
        };
      }).toList();

      // ✅ 按照開始時間排序
      _sortSchedulesByTime(schedules);

      developer.log('✅ 成功載入並排序 ${schedules.length} 筆行程');
      return schedules;

    } catch (e) {
      developer.log('❌ 載入行程失敗：$e');
      return [];
    }
  }

  static void _sortSchedulesByTime(List<Map<String, dynamic>> schedules) {
    int parseMinutes(dynamic timeValue) {
      if (timeValue == null) return 0;
      if (timeValue is Timestamp) {
        final date = timeValue.toDate();
        return date.hour * 60 + date.minute;
      }
      if (timeValue is String && timeValue.contains(':')) {
        final parts = timeValue.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0].trim()) ?? 0;
          final minute = int.tryParse(parts[1].trim()) ?? 0;
          return hour * 60 + minute;
        }
      }
      return 0;
    }

    schedules.sort((a, b) {
      final aMin = parseMinutes(a['startTime']);
      final bMin = parseMinutes(b['startTime']);
      return aMin.compareTo(bMin);
    });
  }

  static Future<void> addSchedule(String date, String desc, String time) async {
    await FirebaseFirestore.instance.collection('schedules').add({
      'date': date,
      'desc': desc,
      'time': time,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}