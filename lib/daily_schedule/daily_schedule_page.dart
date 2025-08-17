import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'models/schedule_model.dart';
import 'services/schedule_service.dart';
import 'widgets/timeline_view.dart';
import 'widgets/schedule_dialogs.dart';
import 'utils/schedule_utils.dart';

class DailySchedulePage extends StatefulWidget {
  final DateTime selectedDate;

  const DailySchedulePage({super.key, required this.selectedDate});

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
      final schedules = await _scheduleService.loadDaySchedules(widget.selectedDate);
      
      setState(() {
        scheduleList = schedules;
        isLoading = false;
      });

      if (schedules.isNotEmpty) {
        _scrollToFirstSchedule();
      }
    } catch (e) {
      developer.log('❌ 載入日行程失敗：$e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollToFirstSchedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || scheduleList.isEmpty) return;

      final firstScheduleHour = scheduleList.first.startTime?.hour;
      if (firstScheduleHour != null) {
        final double itemHeight = 65.0;
        final double targetOffset = firstScheduleHour * itemHeight;
        final double scrollOffset = (targetOffset - 100).clamp(0.0, double.infinity);

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
    return Scaffold(
      appBar: AppBar(
        title: Text('${ScheduleUtils.formatDate(widget.selectedDate)} '),
        backgroundColor: Colors.lightBlue.shade50,
        foregroundColor: Colors.lightBlue.shade800,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.first_page, color: Colors.lightBlue.shade600),
            onPressed: scheduleList.isNotEmpty ? _scrollToFirstSchedule : null,
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
        onPressed: _showAddScheduleDialog,
        backgroundColor: Colors.lightBlue.shade400,
        foregroundColor: Colors.white,
        tooltip: '新增行程',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddScheduleDialog() {
    _dialogs.showAddScheduleDialog();
  }

  void _editSchedule(ScheduleModel schedule) {
    _dialogs.showEditScheduleDialog(schedule);
  }

  void _deleteSchedule(ScheduleModel schedule) {
    _dialogs.showDeleteScheduleDialog(
      schedule,
      onConfirmed: () async {
        try {
          await _scheduleService.deleteSchedule(widget.selectedDate, schedule);
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