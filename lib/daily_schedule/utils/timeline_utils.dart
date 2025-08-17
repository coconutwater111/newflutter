import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/schedule_model.dart';
import '../widgets/schedule_bar.dart';

class TimelineUtils {
  // ✅ 計算時間在一天中的像素位置
  static double timeToPixel(DateTime time, double hourHeight) {
    final hour = time.hour;
    final minute = time.minute;
    return (hour * hourHeight) + (minute / 60.0 * hourHeight);
  }

  // ✅ 計算行程的高度（像素）
  static double getScheduleHeight(ScheduleModel schedule, double hourHeight) {
    if (schedule.startTime == null || schedule.endTime == null) return 40;
    
    final duration = schedule.endTime!.difference(schedule.startTime!);
    final hours = duration.inMinutes / 60.0;
    return math.max(hours * hourHeight, 30);
  }

  // ✅ 建立背景時間格線
  static Widget buildTimeGrid(double hourHeight, double timelineWidth) {
    return Stack(
      children: [
        // 時間標籤和格線
        ...List.generate(24, (hour) {
          return Positioned(
            top: hour * hourHeight,
            left: 0,
            right: 0,
            height: hourHeight,
            child: Row(
              children: [
                Container(
                  width: timelineWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        
        // 垂直時間軸
        Positioned(
          left: timelineWidth - 1,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  // ✅ 建立連續的行程螢光條
  static List<Widget> buildContinuousScheduleBars(
    List<ScheduleModel> scheduleList,
    double hourHeight,
    double timelineWidth,
    BuildContext context,
    Function(ScheduleModel) onEditSchedule,
    Function(ScheduleModel) onDeleteSchedule,
  ) {
    return scheduleList.asMap().entries.map((entry) {
      final index = entry.key;
      final schedule = entry.value;
      
      if (schedule.startTime == null || schedule.endTime == null) {
        return const SizedBox.shrink();
      }

      final startPixel = timeToPixel(schedule.startTime!, hourHeight);
      final scheduleHeight = getScheduleHeight(schedule, hourHeight);
      final leftOffset = timelineWidth + 20 + (index % 3) * 5;

      return Positioned(
        left: leftOffset,
        top: startPixel,
        right: 20,
        height: scheduleHeight,
        child: ScheduleBar(
          schedule: schedule,
          index: index,
          onEditSchedule: onEditSchedule,
          onDeleteSchedule: onDeleteSchedule,
        ),
      );
    }).toList();
  }
}