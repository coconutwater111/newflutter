import 'package:flutter/material.dart';

import '../models/schedule_model.dart';
import 'schedule_content.dart';

class TimeSlotWidget extends StatelessWidget {
  final int hour;
  final List<ScheduleModel> schedules;
  final Function(ScheduleModel) onEditSchedule;
  final Function(ScheduleModel) onDeleteSchedule;
  final Function(ScheduleModel)? scheduleStatusProvider;

  const TimeSlotWidget({
    super.key,
    required this.hour,
    required this.schedules,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    this.scheduleStatusProvider,
  });

  // ✅ 判斷行程在當前小時的狀態
  String _getScheduleStatus(ScheduleModel schedule) {
    if (schedule.startTime == null || schedule.endTime == null) return 'single';
    
    final startHour = schedule.startTime!.hour;
    final endHour = schedule.endTime!.hour;
    final endMinute = schedule.endTime!.minute;
    
    if (startHour == hour && endHour == hour) {
      return 'single'; // 在該小時內完成
    } else if (startHour == hour) {
      return 'start'; // 開始小時
    } else if (endHour == hour && endMinute > 0) {
      return 'end'; // 結束小時
    } else if (endHour == hour && endMinute == 0) {
      return 'continue'; // 整點結束視為延續
    } else {
      return 'continue'; // 中間小時
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSchedule = schedules.isNotEmpty;
    final hasOverlapSchedule = schedules.any((schedule) => schedule.hasOverlap);

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          // 時間顯示區域
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: 16,
                fontWeight: hasSchedule ? FontWeight.w600 : FontWeight.w400,
                color: hasSchedule
                    ? (hasOverlapSchedule 
                        ? Colors.deepOrange.shade700
                        : Colors.lightBlue.shade800)
                    : Colors.grey.shade600,
              ),
            ),
          ),

          // 擴展的螢光區域
          Expanded(
            child: Row(
              children: [
                // 左側時間軸點和連接線
                SizedBox(
                  width: 20,
                  height: hasSchedule ? 60 : 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 垂直時間軸線
                      Container(
                        width: 2,
                        height: double.infinity,
                        color: Colors.grey.shade300,
                      ),
                      // 時間點圓點
                      Container(
                        width: hasSchedule ? 12 : 8,
                        height: hasSchedule ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasSchedule
                              ? (hasOverlapSchedule 
                                  ? Colors.deepOrange.shade400
                                  : Colors.lightBlue.shade400)
                              : Colors.grey.shade400,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ✅ 螢光條區域 - 支援連續顯示
                if (hasSchedule)
                  Expanded(
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.only(left: 8),
                      child: Stack(
                        children: [
                          // ✅ 為每個行程繪製連續的螢光條
                          ...schedules.asMap().entries.map((entry) {
                            final index = entry.key;
                            final schedule = entry.value;
                            final status = _getScheduleStatus(schedule);
                            
                            return Positioned(
                              top: 20 + (index * 12), // 多個行程垂直錯開
                              left: 0,
                              right: 0,
                              child: _buildConnectedGlowBar(schedule, status, hasOverlapSchedule),
                            );
                          }),
                          
                          // 事件內容顯示
                          ScheduleContentWidget(
                            schedules: schedules,
                            onEditSchedule: onEditSchedule,
                            onDeleteSchedule: onDeleteSchedule,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                // 空白時間槽
                if (!hasSchedule)
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(left: 16),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 新增：建立連續的螢光條
  Widget _buildConnectedGlowBar(ScheduleModel schedule, String status, bool hasOverlap) {
    Color barColor = hasOverlap 
        ? Colors.deepOrange.shade200
        : Colors.lightBlue.shade100;
    
    BorderRadius borderRadius;
    
    switch (status) {
      case 'start':
        // 開始小時：左側圓角，右側直角
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        );
        break;
      case 'end':
        // 結束小時：右側圓角，左側直角
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
        break;
      case 'continue':
        // 中間小時：無圓角，完全連接
        borderRadius = BorderRadius.zero;
        break;
      case 'single':
      default:
        // 單一小時：四角圓角
        borderRadius = BorderRadius.circular(8);
        break;
    }

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: barColor.withValues(alpha: 0.8),
        borderRadius: borderRadius,
        // ✅ 添加發光效果
        boxShadow: [
          BoxShadow(
            color: barColor.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      // ✅ 添加漸變效果讓連接更自然
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            colors: [
              barColor.withValues(alpha: 0.6),
              barColor.withValues(alpha: 0.9),
              barColor.withValues(alpha: 0.6),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}