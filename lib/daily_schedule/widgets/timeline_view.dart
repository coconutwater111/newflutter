import 'package:flutter/material.dart';

import '../models/schedule_model.dart';
import 'time_slot_widget.dart';

class TimelineView extends StatelessWidget {
  final List<ScheduleModel> scheduleList;
  final ScrollController scrollController;
  final DateTime selectedDate;
  final Function(ScheduleModel) onEditSchedule;
  final Function(ScheduleModel) onDeleteSchedule;

  const TimelineView({
    super.key,
    required this.scheduleList,
    required this.scrollController,
    required this.selectedDate,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
  });

  List<ScheduleModel> _getSchedulesAtHour(int hour) {
    final schedulesInHour = scheduleList.where((schedule) {
      if (schedule.startTime == null || schedule.endTime == null) return false;
      
      final startHour = schedule.startTime!.hour;
      final endHour = schedule.endTime!.hour;
      
      return (startHour <= hour && endHour >= hour) || (startHour == hour);
    }).toList();

    // 將有重複的行程排在前面
    schedulesInHour.sort((a, b) {
      if (a.hasOverlap && !b.hasOverlap) return -1;
      if (!a.hasOverlap && b.hasOverlap) return 1;
      return 0;
    });

    return schedulesInHour;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 24,
      separatorBuilder: (context, index) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        final hour = index;
        final schedulesAtThisHour = _getSchedulesAtHour(hour);

        return TimeSlotWidget(
          hour: hour,
          schedules: schedulesAtThisHour,
          onEditSchedule: onEditSchedule,
          onDeleteSchedule: onDeleteSchedule,
        );
      },
    );
  }
}