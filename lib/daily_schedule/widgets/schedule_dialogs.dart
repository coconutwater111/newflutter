import 'package:flutter/material.dart';

import '../services/schedule_service.dart';

import '../models/schedule_model.dart';

class ScheduleDialogs {
  final BuildContext context;

  ScheduleDialogs(this.context);

  void showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增行程'),
        content: const Text('新增行程功能開發中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  void showEditScheduleDialog(ScheduleModel schedule, {VoidCallback? onSaved}) {
    final descController = TextEditingController(text: schedule.description);
    final startTimeController = TextEditingController(text: schedule.startTimeString);
    final endTimeController = TextEditingController(text: schedule.endTimeString);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('編輯行程'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: '描述'),
              ),
              TextField(
                controller: startTimeController,
                decoration: const InputDecoration(labelText: '開始時間 (HH:mm)'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: endTimeController,
                decoration: const InputDecoration(labelText: '結束時間 (HH:mm)'),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final startParts = startTimeController.text.split(':');
                final endParts = endTimeController.text.split(':');
                final now = DateTime.now();
                final startTime = (startParts.length == 2)
                    ? DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]))
                    : null;
                final endTime = (endParts.length == 2)
                    ? DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]))
                    : null;

                final updated = ScheduleModel(
                  id: schedule.id,
                  name: '',
                  description: descController.text,
                  startTime: startTime,
                  endTime: endTime,
                  index: schedule.index,
                  hasOverlap: schedule.hasOverlap,
                );

                final service = ScheduleService();
                await service.updateSchedule(
                  updated.id,
                  updated.startTime!,
                  updated,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  if (onSaved != null) onSaved();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('行程已更新')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新失敗，請檢查輸入')));
                }
              }
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }

  void showDeleteScheduleDialog(ScheduleModel schedule, {required VoidCallback onConfirmed}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除行程'),
        content: Text('確定要刪除「${schedule.name.isNotEmpty ? schedule.name : schedule.description}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirmed();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }
}