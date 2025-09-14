import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../models/schedule_model.dart';
import '../utils/schedule_utils.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 更新行程
  Future<void> updateSchedule(String uid, DateTime date, ScheduleModel schedule) async {
    try {
      final dateKey = ScheduleUtils.formatDateKey(date);
      await _firestore
          .collection('Tasks')
          .doc(uid)
          .collection('task_list')
          .doc(dateKey)
          .collection('tasks')
          .doc(schedule.id)
          .update({
        'desc': schedule.description,
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
        'index': schedule.index,
      });
      developer.log('✅ 更新行程成功');
    } catch (e) {
      developer.log('❌ 更新行程失敗：$e');
      rethrow;
    }
  }

  /// 讀取某天所有行程
  Future<List<ScheduleModel>> loadDaySchedules(String uid, DateTime selectedDate) async {
    try {
      final dateKey = ScheduleUtils.formatDateKey(selectedDate);
      developer.log('🔍 載入日行程：$dateKey');
      final snapshot = await _firestore
          .collection('Tasks')
          .doc(uid)
          .collection('task_list')
          .doc(dateKey)
          .collection('tasks')
          .orderBy('startTime')
          .get();

      final schedules = snapshot.docs.map((doc) {
        return ScheduleModel.fromFirestore(doc, selectedDate);
      }).toList();

      // 客戶端再次排序
      schedules.sort((a, b) {
        if (a.startTime != null && b.startTime != null) {
          return a.startTime!.compareTo(b.startTime!);
        }
        if (a.startTime != null) return -1;
        if (b.startTime != null) return 1;
        return a.index.compareTo(b.index);
      });

      _checkForOverlaps(schedules);

      developer.log('✅ 載入完成，共 ${schedules.length} 筆日行程');
      return schedules;
    } catch (e) {
      developer.log('❌ 載入日行程失敗：$e');
      rethrow;
    }
  }

  /// 刪除行程
  Future<void> deleteSchedule(String uid, DateTime date, String scheduleId) async {
    try {
      final dateKey = ScheduleUtils.formatDateKey(date);
      await _firestore
          .collection('Tasks')
          .doc(uid)
          .collection('task_list')
          .doc(dateKey)
          .collection('tasks')
          .doc(scheduleId)
          .delete();
      developer.log('✅ 刪除行程成功');
    } catch (e) {
      developer.log('❌ 刪除行程失敗：$e');
      rethrow;
    }
  }

  void _checkForOverlaps(List<ScheduleModel> schedules) {
    for (int i = 0; i < schedules.length; i++) {
      schedules[i].hasOverlap = false;
      for (int j = 0; j < schedules.length; j++) {
        if (i != j && schedules[i].overlapsWith(schedules[j])) {
          schedules[i].hasOverlap = true;
          break;
        }
      }
    }
  }
}