import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'models/schedule_model.dart';
import 'services/schedule_service.dart';
import 'widgets/timeline_view.dart';
import 'widgets/schedule_dialogs.dart';
import 'utils/schedule_utils.dart';
import '../schedule_creation/schedule_creation_page.dart'; // ✅ 修正：使用新的行程創建頁面

class DailySchedulePage extends StatefulWidget {
  final DateTime selectedDate;
  final String? initialScheduleId; // 新增：初始要顯示的行程 ID

  const DailySchedulePage({
    super.key, 
    required this.selectedDate,
    this.initialScheduleId, // 可選參數
  });

  @override
  State<DailySchedulePage> createState() => _DailySchedulePageState();
}

class _DailySchedulePageState extends State<DailySchedulePage> {
  List<ScheduleModel> scheduleList = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  late final ScheduleService _scheduleService;
  late final ScheduleDialogs _dialogs;

  @override
  void initState() {
    super.initState();
    _scheduleService = ScheduleService();
    _dialogs = ScheduleDialogs(context);
    _loadDaySchedules();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDaySchedules() async {
    setState(() {
      isLoading = true;
    });

    try {
      final schedules = await _scheduleService.loadDaySchedules(
        ScheduleUtils.formatDate(widget.selectedDate), // 傳入 String 類型的日期
        widget.selectedDate, // 傳入 DateTime
      );

      setState(() {
        scheduleList = schedules;
        isLoading = false;
      });

      developer.log('✅ 載入完成，共 ${scheduleList.length} 筆日行程');
      for (int i = 0; i < scheduleList.length; i++) {
        final schedule = scheduleList[i];
        developer.log('  [$i] ${schedule.name.isEmpty ? schedule.description : schedule.name}');
        developer.log('      時間: ${schedule.timeRange}');
        developer.log('      開始: ${schedule.startTime}');
        developer.log('      結束: ${schedule.endTime}');
        developer.log('      持續: ${schedule.startTime != null && schedule.endTime != null ? schedule.endTime!.difference(schedule.startTime!).inMinutes : 0} 分鐘');
        developer.log('      有重疊: ${schedule.hasOverlap}');
      }

      if (scheduleList.isNotEmpty) {
        _scrollToTargetSchedule();
      }
    } catch (e) {
      developer.log('❌ 載入日行程失敗：$e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollToTargetSchedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || scheduleList.isEmpty) return;

      // 如果指定了初始行程 ID，嘗試定位到該行程
      int targetIndex = 0;
      if (widget.initialScheduleId != null) {
        final targetScheduleIndex = scheduleList.indexWhere(
          (schedule) => schedule.id == widget.initialScheduleId,
        );
        if (targetScheduleIndex != -1) {
          targetIndex = targetScheduleIndex;
          developer.log('🎯 定位到指定行程：${scheduleList[targetIndex].name}');
        } else {
          developer.log('⚠️ 未找到指定行程 ID: ${widget.initialScheduleId}，將定位到第一個行程');
        }
      }

      final targetSchedule = scheduleList[targetIndex];
      final targetHour = targetSchedule.startTime?.hour;
      
      if (targetHour != null) {
        final double itemHeight = 65.0;
        final double targetOffset = targetHour * itemHeight;
        final double scrollOffset = (targetOffset - 100).clamp(
          0.0,
          double.infinity,
        );

        _scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      developer.log('🏗️ 準備建構 TimelineView，傳入資料：');
      for (final schedule in scheduleList) {
        developer.log('  - ${schedule.description}: ${schedule.timeRange} (${schedule.endTime!.difference(schedule.startTime!).inMinutes}分鐘)');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${ScheduleUtils.formatDate(widget.selectedDate)} 行程'),
        backgroundColor: Colors.lightBlue.shade50,
        foregroundColor: Colors.lightBlue.shade800,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.first_page, color: Colors.lightBlue.shade600),
            onPressed: scheduleList.isNotEmpty ? _scrollToTargetSchedule : null,
            tooltip: '跳到第一筆行程',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.lightBlue.shade600),
            onPressed: _loadDaySchedules,
            tooltip: '重新整理',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TimelineView(
              scheduleList: scheduleList,
              scrollController: _scrollController,
              selectedDate: widget.selectedDate,
              onEditSchedule: _editSchedule,
              onDeleteSchedule: _deleteSchedule,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // ✅ 修正：使用新的行程創建頁面
              builder: (context) => ScheduleCreationPage(selectedDay: widget.selectedDate),
            ),
          );
        },
        backgroundColor: Colors.lightBlue.shade400,
        foregroundColor: Colors.white,
        tooltip: '新增行程',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editSchedule(ScheduleModel schedule) {
    _dialogs.showEditScheduleDialog(
      schedule,
      onSaved: _loadDaySchedules,
    );
  }

  void _deleteSchedule(ScheduleModel schedule) {
    _dialogs.showDeleteScheduleDialog(
      schedule,
      onConfirmed: () async {
        try {
          await _scheduleService.deleteSchedule(
            ScheduleUtils.formatDate(widget.selectedDate),
            widget.selectedDate,
            schedule.id,
          );
          _loadDaySchedules();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('行程已刪除')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('刪除失敗，請稍後再試')),
            );
          }
        }
      },
    );
  }
}
