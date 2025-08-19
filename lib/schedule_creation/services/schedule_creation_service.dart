import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../daily_schedule/daily_schedule_page.dart';
import '../../daily_schedule/utils/schedule_utils.dart';

class ScheduleCreationService {
  // ✅ 格式化時間顯示
  String formatScheduleTime(dynamic startTime, dynamic endTime) {
    try {
      if (startTime == null || endTime == null) return '時間未設定';
      
      String start = '';
      String end = '';
      
      if (startTime is Timestamp) {
        final startDate = startTime.toDate();
        start = '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';
      } else if (startTime is String && startTime.contains(':')) {
        start = startTime;
      }
      
      if (endTime is Timestamp) {
        final endDate = endTime.toDate();
        end = '${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';
      } else if (endTime is String && endTime.contains(':')) {
        end = endTime;
      }
      
      if (start.isNotEmpty && end.isNotEmpty) {
        return '$start - $end';
      }
      
      return start.isNotEmpty ? start : '時間未設定';
    } catch (e) {
      return '時間未設定';
    }
  }

  // ✅ 建立行程列表 Widget（包含自動排序）
  Widget buildScheduleListWidget(
    List<Map<String, dynamic>> scheduleList,
    DateTime selectedDate,
    BuildContext context,
  ) {
    // 自動排序行程列表
    final sortedList = scheduleList.isNotEmpty ? sortScheduleList(scheduleList) : scheduleList;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(selectedDate),
        const SizedBox(height: 10),
        if (sortedList.isNotEmpty)
          ...sortedList.map((item) => _buildScheduleCard(item, selectedDate, context))
        else
          _buildEmptyState(selectedDate),
      ],
    );
  }

  Widget _buildHeader(DateTime selectedDate) {
    return Row(
      children: [
        Text(
          '行程列表',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${ScheduleUtils.formatDate(selectedDate)})',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(
    Map<String, dynamic> item,
    DateTime selectedDate,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          Icons.event,
          color: Colors.blue.shade600,
        ),
        title: Text(
          item['name']?.isNotEmpty == true 
              ? item['name'] 
              : (item['desc'] ?? '未知行程'),
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          formatScheduleTime(item['startTime'], item['endTime']),
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.cloud_done,
          color: Colors.green.shade600,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailySchedulePage(
                selectedDate: selectedDate,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_busy,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            '${ScheduleUtils.formatDate(selectedDate)} 沒有行程',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 修正：安全的時間比較方法
  int compareScheduleTimes(Map<String, dynamic> a, Map<String, dynamic> b) {
    try {
      final timeA = _parseTimeForComparison(a['startTime']);
      final timeB = _parseTimeForComparison(b['startTime']);
      
      // 詳細的 debug 訊息
      developer.log("比較時間: ${a['startTime']} ($timeA) vs ${b['startTime']} ($timeB)", 
                   name: 'TimeComparison');
      
      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;
      
      return timeA.compareTo(timeB);
    } catch (e) {
      developer.log("❌ 時間比較異常：$e", name: 'TimeComparison');
      return 0;
    }
  }

  // ✅ 修正：解析時間用於比較（使用分鐘數）
  int? _parseTimeForComparison(dynamic timeValue) {
    if (timeValue == null) return null;
    
    try {
      // 處理 Timestamp 類型
      if (timeValue is Timestamp) {
        final date = timeValue.toDate();
        final minutes = date.hour * 60 + date.minute;
        developer.log("解析 Timestamp: $timeValue -> $minutes 分鐘", name: 'TimeParser');
        return minutes;
      } 
      // 處理字串類型 (HH:mm)
      else if (timeValue is String) {
        final cleanTime = timeValue.trim();
        if (cleanTime.contains(':')) {
          final parts = cleanTime.split(':');
          if (parts.length >= 2) {
            final hour = int.tryParse(parts[0].trim());
            final minute = int.tryParse(parts[1].trim());
            
            if (hour != null && minute != null && 
                hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
              final minutes = hour * 60 + minute;
              developer.log("解析字串: '$cleanTime' -> $minutes 分鐘", name: 'TimeParser');
              return minutes;
            }
          }
        }
        developer.log("⚠️ 無效時間格式: '$cleanTime'", name: 'TimeParser');
        return null;
      }
    } catch (e) {
      developer.log("❌ 時間解析錯誤: $timeValue -> $e", name: 'TimeParser');
    }
    
    return null;
  }

  // ✅ 修改：安全的列表排序
  List<Map<String, dynamic>> sortScheduleList(List<Map<String, dynamic>> scheduleList) {
    if (scheduleList.isEmpty) {
      developer.log("📋 空列表，跳過排序", name: 'ScheduleSort');
      return scheduleList;
    }

    try {
      developer.log("🔄 開始排序 ${scheduleList.length} 筆行程", name: 'ScheduleSort');
      
      final sortedList = List<Map<String, dynamic>>.from(scheduleList);
      sortedList.sort(compareScheduleTimes);
      
      // 顯示排序結果
      developer.log("✅ 排序完成:", name: 'ScheduleSort');
      for (int i = 0; i < sortedList.length; i++) {
        final item = sortedList[i];
        final timeDisplay = formatScheduleTime(item['startTime'], item['endTime']);
        developer.log("  [$i] ${item['desc'] ?? '未知'} - $timeDisplay", name: 'ScheduleSort');
      }
      
      return sortedList;
    } catch (e) {
      developer.log("❌ 排序失敗，返回原列表: $e", name: 'ScheduleSort');
      return scheduleList;
    }
  }
}