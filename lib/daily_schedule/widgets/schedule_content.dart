import 'package:flutter/material.dart';

import '../models/schedule_model.dart';

class ScheduleContentWidget extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final Function(ScheduleModel) onEditSchedule;
  final Function(ScheduleModel) onDeleteSchedule;

  const ScheduleContentWidget({
    super.key,
    required this.schedules,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
  });

  void _showScheduleMenu(BuildContext context, ScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue.shade600),
              title: Text(schedule.name.isNotEmpty ? schedule.name : schedule.description),
              subtitle: Text(schedule.timeRange),
              onTap: () {
                Navigator.pop(context);
                _showScheduleDetail(context, schedule);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.edit, color: Colors.orange.shade600),
              title: const Text('編輯行程'),
              onTap: () {
                Navigator.pop(context);
                onEditSchedule(schedule);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('刪除行程'),
              onTap: () {
                Navigator.pop(context);
                onDeleteSchedule(schedule);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showScheduleDetail(BuildContext context, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.event,
              color: schedule.hasOverlap 
                  ? Colors.orange.shade600 
                  : Colors.blue.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                schedule.name.isNotEmpty ? schedule.name : schedule.description,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (schedule.description.isNotEmpty && schedule.description != schedule.name) ...[
              const Text('📝 描述：', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(schedule.description),
              const SizedBox(height: 12),
            ],
            
            const Text('⏰ 時間：', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(schedule.timeRange),
            
            if (schedule.hasOverlap) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, 
                         color: Colors.orange.shade600, 
                         size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '此行程與其他行程時間重疊',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEditSchedule(schedule);
            },
            child: const Text('編輯'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: schedules.asMap().entries.map((entry) {
        final index = entry.key;
        final schedule = entry.value;
        final scheduleHasOverlap = schedule.hasOverlap;
        
        return Container(
          margin: EdgeInsets.only(
            bottom: 4,
            top: index * 2.0, // 多個事件時稍微錯開
          ),
          child: Row(
            children: [
              // 事件開始時間標記
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheduleHasOverlap 
                      ? Colors.deepOrange.shade500       // 重疊：中橙色
                      : Colors.lightBlue.shade600,       // ✅ 主色：深淺藍色
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: scheduleHasOverlap 
                          ? Colors.deepOrange.shade200
                          : Colors.lightBlue.shade200,   // ✅ 主色：淺藍陰影
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  schedule.startTimeString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 事件描述
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheduleHasOverlap 
                        ? Colors.deepOrange.shade300.withValues(alpha: 0.9)  // 重疊：淺橙色
                        : Colors.lightBlue.shade300.withValues(alpha: 0.9),  // ✅ 主色：中淺藍色
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: scheduleHasOverlap 
                            ? Colors.deepOrange.shade100
                            : Colors.lightBlue.shade100,   // ✅ 主色：極淺藍陰影
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 重疊標示圖標
                      if (scheduleHasOverlap) ...[
                        const Icon(
                          Icons.warning_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                      ],
                      
                      // 事件名稱
                      Flexible(
                        child: Text(
                          schedule.name.isNotEmpty ? schedule.name : schedule.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0.5, 0.5),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // 結束時間
                      const SizedBox(width: 4),
                      Text(
                        '→${schedule.endTimeString}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      // 選單按鈕
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _showScheduleMenu(context, schedule),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.more_horiz,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}