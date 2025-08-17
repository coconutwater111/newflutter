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
    schedules.sort((a, b) {
      final startTimeA = a['startTime'];
      final startTimeB = b['startTime'];
      
      if (startTimeA == null && startTimeB == null) return 0;
      if (startTimeA == null) return 1;
      if (startTimeB == null) return -1;
      
      if (startTimeA is Timestamp && startTimeB is Timestamp) {
        return startTimeA.compareTo(startTimeB);
      }
      
      try {
        DateTime dateA = startTimeA is Timestamp 
            ? startTimeA.toDate() 
            : DateTime.parse(startTimeA.toString());
        DateTime dateB = startTimeB is Timestamp 
            ? startTimeB.toDate() 
            : DateTime.parse(startTimeB.toString());
        return dateA.compareTo(dateB);
      } catch (e) {
        developer.log('⚠️ 時間比較失敗，維持原順序：$e');
        return 0;
      }
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