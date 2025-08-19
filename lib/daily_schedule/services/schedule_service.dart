import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../models/schedule_model.dart';
import '../utils/schedule_utils.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ScheduleModel>> loadDaySchedules(DateTime selectedDate) async {
    try {
      final docPath = ScheduleUtils.formatDateKey(selectedDate);
      
      developer.log('🔍 載入日行程：$docPath');
      
      final snapshot = await _firestore
          .doc(docPath)
          .collection('task_list')
          .orderBy('startTime') // 改為按照 startTime 排序，與主頁面一致
          .get();

      final schedules = snapshot.docs.map((doc) {
        return ScheduleModel.fromFirestore(doc, selectedDate);
      }).toList();

      // 客戶端再次排序，確保按時間順序顯示（與主頁面邏輯一致）
      schedules.sort((a, b) {
        if (a.startTime != null && b.startTime != null) {
          return a.startTime!.compareTo(b.startTime!);
        }
        if (a.startTime != null) return -1;
        if (b.startTime != null) return 1;
        return a.index.compareTo(b.index);
      });

      // 檢查時間重疊
      _checkForOverlaps(schedules);

      developer.log('✅ 載入完成，共 ${schedules.length} 筆日行程');
      return schedules;

    } catch (e) {
      developer.log('❌ 載入日行程失敗：$e');
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

  Future<void> deleteSchedule(DateTime selectedDate, ScheduleModel schedule) async {
    try {
      final docPath = ScheduleUtils.formatDateKey(selectedDate);
      await _firestore
          .doc(docPath)
          .collection('task_list')
          .doc(schedule.id)
          .delete();
      
      developer.log('✅ 刪除行程成功');
    } catch (e) {
      developer.log('❌ 刪除行程失敗：$e');
      rethrow;
    }
  }
}