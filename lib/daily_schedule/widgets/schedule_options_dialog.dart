import 'package:flutter/material.dart';

import '../models/schedule_model.dart';

class ScheduleOptionsDialog {
  static void show(
    BuildContext context,
    ScheduleModel schedule,
    Function(ScheduleModel) onEditSchedule,
    Function(ScheduleModel) onDeleteSchedule,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.35,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildTitle(schedule),
              _buildTimeInfo(schedule),
              const SizedBox(height: 8),
              _buildEditOption(context, schedule, onEditSchedule),
              _buildDeleteOption(context, schedule, onDeleteSchedule),
              _buildCopyOption(context, schedule),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  static Widget _buildTitle(ScheduleModel schedule) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Text(
        schedule.name.isNotEmpty ? schedule.name : schedule.description,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static Widget _buildTimeInfo(ScheduleModel schedule) {
    return Text(
      schedule.timeRange,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
    );
  }

  static Widget _buildEditOption(
    BuildContext context,
    ScheduleModel schedule,
    Function(ScheduleModel) onEditSchedule,
  ) {
    return _buildOption(
      icon: Icons.edit,
      title: '編輯行程',
      color: Colors.blue,
      onTap: () {
        Navigator.pop(context);
        onEditSchedule(schedule);
      },
    );
  }

  static Widget _buildDeleteOption(
    BuildContext context,
    ScheduleModel schedule,
    Function(ScheduleModel) onDeleteSchedule,
  ) {
    return _buildOption(
      icon: Icons.delete,
      title: '刪除行程',
      color: Colors.red,
      onTap: () {
        Navigator.pop(context);
        onDeleteSchedule(schedule);
      },
    );
  }

  static Widget _buildCopyOption(BuildContext context, ScheduleModel schedule) {
    return _buildOption(
      icon: Icons.copy,
      title: '複製行程',
      color: Colors.green,
      onTap: () {
        Navigator.pop(context);
        _duplicateSchedule(context, schedule);
      },
    );
  }

  static Widget _buildOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  static void _duplicateSchedule(BuildContext context, ScheduleModel schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('複製功能將在後續實作'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}