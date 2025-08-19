// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_item.dart';

/// Firebase 行程管理服務
class CalendarFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 從 Firebase 載入指定日期的行程
  static Future<List<ScheduleItem>> loadSchedules(DateTime selectedDay) async {
    try {
      // 將日期轉換為 Firebase 路徑格式
      final year = selectedDay.year.toString();
      final month = selectedDay.month.toString().padLeft(2, '0');
      final day = selectedDay.day.toString().padLeft(2, '0');
      
      // 建構文檔路徑到 task_list：tasks/2025/08/04
      final basePath = 'tasks/$year/$month/$day';
      
      // 讀取 task_list subcollection
      final snapshot = await _firestore
          .doc(basePath)
          .collection('task_list')
          .get();
    
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) {
          final data = doc.data();
          return ScheduleItem.fromFirebaseDoc(data, doc.id);
        }).toList();
        
        // 客戶端智能排序
        list.sort((a, b) {
          final aTime = a.sortableDateTime;
          final bTime = b.sortableDateTime;
          
          // 如果都有解析成功的時間，按時間排序
          if (aTime != null && bTime != null) {
            return aTime.compareTo(bTime);
          }
          
          // 如果時間解析失敗，嘗試按字符串排序
          if (a.startTime.isNotEmpty && b.startTime.isNotEmpty) {
            return a.startTime.compareTo(b.startTime);
          }
          
          // 如果只有一個有時間，有時間的排在前面
          if (aTime != null || a.startTime.isNotEmpty) return -1;
          if (bTime != null || b.startTime.isNotEmpty) return 1;
          
          // 最後按 index 排序
          return a.index.compareTo(b.index);
        });
        
        return list;
        
      } else {
        return [];
      }
      
    } catch (e) {
      rethrow;
    }
  }

  /// 新增行程到 Firebase
  static Future<void> addSchedule({
    required DateTime selectedDay,
    required String name,
    required String desc,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final year = selectedDay.year.toString();
      final month = selectedDay.month.toString().padLeft(2, '0');
      final day = selectedDay.day.toString().padLeft(2, '0');
      
      final basePath = 'tasks/$year/$month/$day';
      
      // 先取得目前的行程數量來決定 index
      final existingTasks = await _firestore
          .doc(basePath)
          .collection('task_list')
          .get();
    
      final newIndex = existingTasks.docs.length;
      
      // 新增行程
      await _firestore
          .doc(basePath)
          .collection('task_list')
          .add({
        'name': name,
        'desc': desc,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'index': newIndex,
      });
      
    } catch (e) {
      rethrow;
    }
  }

  /// 生成日期路徑字符串
  static String generateDatePath(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'tasks/$year/$month/$day';
  }
}
