import 'package:flutter/material.dart';

import '../models/schedule_model.dart';
import '../utils/timeline_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    const double hourHeight = 80.0;
    const double timelineWidth = 80.0;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 24 * hourHeight,
            child: Stack(
              children: [
                TimelineUtils.buildTimeGrid(hourHeight, timelineWidth),
                ...TimelineUtils.buildContinuousScheduleBars(
                  scheduleList,
                  hourHeight,
                  timelineWidth,
                  context,
                  onEditSchedule,
                  onDeleteSchedule,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
