import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/schedule_model.dart';
import 'schedule_content_adaptive.dart';
import 'schedule_options_dialog.dart';
import '../utils/timeline_utils.dart';

class ScheduleBar extends StatelessWidget {
  final ScheduleModel schedule;
  final int index;
  final Function(ScheduleModel) onEditSchedule;
  final Function(ScheduleModel) onDeleteSchedule;

  const ScheduleBar({
    super.key,
    required this.schedule,
    required this.index,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    
    final color = colors[index % colors.length];
    final scheduleHeight = TimelineUtils.getScheduleHeight(schedule, 80.0);
    
    return GestureDetector(
      // ✅ 修改：單次點擊就顯示選項對話框
      onTap: () {
        HapticFeedback.lightImpact();
        ScheduleOptionsDialog.show(context, schedule, onEditSchedule, onDeleteSchedule);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.shade200.withValues(alpha: 0.8),
              color.shade300.withValues(alpha: 0.9),
              color.shade200.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.shade200.withValues(alpha: 0.6),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            ),
          ],
          border: Border.all(
            color: color.shade300.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            // ✅ 修改：單次點擊顯示選項
            onTap: () {
              HapticFeedback.lightImpact();
              ScheduleOptionsDialog.show(context, schedule, onEditSchedule, onDeleteSchedule);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ScheduleContentAdaptive(
                schedule: schedule,
                color: color,
                availableHeight: scheduleHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}