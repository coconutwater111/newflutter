import 'package:flutter/material.dart';

import '../models/schedule_model.dart';

class ScheduleContentAdaptive extends StatelessWidget {
  final ScheduleModel schedule;
  final MaterialColor color;
  final double availableHeight;

  const ScheduleContentAdaptive({
    super.key,
    required this.schedule,
    required this.color,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleName = schedule.name.isNotEmpty ? schedule.name : schedule.description;
    
    if (availableHeight < 50) {
      return _buildMinimalContent(scheduleName);
    } else if (availableHeight < 80) {
      return _buildCompactContent(scheduleName);
    } else if (availableHeight < 120) {
      return _buildMediumContent(scheduleName, schedule.timeRange);
    } else {
      return _buildFullContent();
    }
  }

  Widget _buildMinimalContent(String name) {
    return Center(
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color.shade800,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCompactContent(String name) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.shade800,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // ✅ 改成更明顯的選項圖標
        Icon(
          Icons.more_vert,
          size: 14,
          color: color.shade600.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget _buildMediumContent(String name, String timeRange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.shade800,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ✅ 改成更明顯的選項圖標
            Icon(
              Icons.more_vert,
              size: 14,
              color: color.shade600.withValues(alpha: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          timeRange,
          style: TextStyle(
            fontSize: 11,
            color: color.shade700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                schedule.name.isNotEmpty ? schedule.name : schedule.description,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.shade800,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ✅ 改成更明顯的選項圖標
            Icon(
              Icons.more_vert,
              size: 16,
              color: color.shade600.withValues(alpha: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          schedule.timeRange,
          style: TextStyle(
            fontSize: 12,
            color: color.shade700,
          ),
        ),
        if (schedule.startTime != null && schedule.endTime != null)
          Text(
            '持續 ${schedule.endTime!.difference(schedule.startTime!).inMinutes} 分鐘',
            style: TextStyle(
              fontSize: 10,
              color: color.shade600.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}