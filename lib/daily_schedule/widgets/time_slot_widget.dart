import 'package:flutter/material.dart';

import '../models/schedule_model.dart';
import 'schedule_content.dart';

class TimeSlotWidget extends StatelessWidget {
  final int hour;
  final List<ScheduleModel> schedules;
  final Function(ScheduleModel) onEditSchedule;
  final Function(ScheduleModel) onDeleteSchedule;

  const TimeSlotWidget({
    super.key,
    required this.hour,
    required this.schedules,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
  });

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
                        ? Colors.deepOrange.shade700   // 重疊：深橙色
                        : Colors.lightBlue.shade800)   // ✅ 主色：深淺藍色
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
                                  ? Colors.deepOrange.shade400   // 重疊：中橙色
                                  : Colors.lightBlue.shade400)   // ✅ 主色：中淺藍色
                              : Colors.grey.shade400,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 螢光條區域延伸
                if (hasSchedule)
                  Expanded(
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.only(left: 8),
                      child: Stack(
                        children: [
                          // 背景螢光條
                          Container(
                            height: 8,
                            margin: const EdgeInsets.only(top: 26), // 垂直置中
                            decoration: BoxDecoration(
                              color: (hasOverlapSchedule 
                                  ? Colors.deepOrange.shade200      // 重疊：淺橙色
                                  : Colors.lightBlue.shade100).withValues(alpha: 0.6), // ✅ 主色：極淺藍色
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // 事件內容顯示在螢光條上
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
}