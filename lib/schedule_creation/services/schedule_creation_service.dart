import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // ✅ 建立行程列表 Widget
  Widget buildScheduleListWidget(
    List<Map<String, dynamic>> scheduleList,
    DateTime selectedDate,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(selectedDate),
        const SizedBox(height: 10),
        if (scheduleList.isNotEmpty)
          ...scheduleList.map((item) => _buildScheduleCard(item, selectedDate, context))
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
}