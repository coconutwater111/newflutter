import 'package:flutter/material.dart';
import 'dart:developer' as developer;

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

  void showEditScheduleDialog(ScheduleModel schedule) {
    developer.log('編輯行程: ${schedule.id}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('編輯行程'),
        content: const Text('編輯行程功能開發中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
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