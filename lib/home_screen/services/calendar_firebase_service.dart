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
      
      print('🔍 正在載入路徑：$basePath/task_list 的所有行程');
      
      // 讀取 task_list subcollection
      final snapshot = await _firestore
          .doc(basePath)
          .collection('task_list')
          .orderBy('index') // 按照 index 排序
          .get();
    
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) {
          final data = doc.data();
          print('📄 找到行程 ID: ${doc.id}');
          print('📋 行程內容：$data');
          
          return ScheduleItem.fromFirebaseDoc(data);
        }).toList();
        
        print('✅ 載入完成，共 ${list.length} 筆行程');
        return list;
        
      } else {
        print('⚠️ 沒有找到該日期的行程：$basePath/task_list');
        return [];
      }
      
    } catch (e) {
      print('❌ 載入行程時發生錯誤：$e');
      print('🔧 錯誤詳情：${e.runtimeType}');
      rethrow; // 重新拋出錯誤讓調用方處理
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
      
      print('✅ 成功新增行程到 $basePath/task_list');
      
    } catch (e) {
      print('❌ 新增行程失敗：$e');
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
