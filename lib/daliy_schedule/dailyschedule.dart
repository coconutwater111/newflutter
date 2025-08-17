import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class DailySchedulePage extends StatefulWidget {
  final DateTime selectedDate;

  const DailySchedulePage({super.key, required this.selectedDate});

  @override
  State<DailySchedulePage> createState() => _DailySchedulePageState();
}

class _DailySchedulePageState extends State<DailySchedulePage> {
  List<Map<String, dynamic>> scheduleList = [];
  bool isLoading = true;

  // 加入 Scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDaySchedules();
  }

  // 加入 dispose 方法來釋放 ScrollController
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 將 _parseDateTime 方法移到這裡
  DateTime? _parseDateTime(dynamic value, DateTime baseDate) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      // 假設格式為 "HH:mm" 或 "HH:mm:ss"
      final parts = value.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
      }
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatDateKey(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'tasks/$year/$month/$day';
  }


  // 加入 _getSchedulesAtHour 方法
  List<Map<String, dynamic>> _getSchedulesAtHour(int hour) {
    return scheduleList.where((schedule) {
      if (schedule['startTime'] == null || schedule['endTime'] == null) {
        return false;
      }

      try {
        // 直接處理 "14:10" 格式
        final startTimeStr = schedule['startTime'].toString();
        final endTimeStr = schedule['endTime'].toString();
        
        if (startTimeStr.contains(':') && endTimeStr.contains(':')) {
          final startHour = int.parse(startTimeStr.split(':')[0]);
          final endHour = int.parse(endTimeStr.split(':')[0]);
          
          // 檢查行程是否在這個小時內
          return (startHour <= hour && endHour >= hour) || (startHour == hour);
        }
        
        return false;
      } catch (e) {
        developer.log('❌ 解析時間格式失敗：$e');
        return false;
      }
    }).toList();
  }

  Future<void> _loadDaySchedules() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docPath = _formatDateKey(widget.selectedDate);

      developer.log('🔍 載入日行程：$docPath');

      final snapshot = await FirebaseFirestore.instance
          .doc(docPath)
          .collection('task_list')
          .orderBy('index')
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // 修正這些 log 語句
        developer.log('📋 行程資料：$data');
        developer.log('📋 startTime 類型：${data['startTime'].runtimeType}');
        developer.log('📋 endTime 類型：${data['endTime'].runtimeType}');
        
        return {
          'id': doc.id,
          'desc': data['desc'] ?? data['name'] ?? '未知行程',
          'name': data['name'] ?? '',
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'index': data['index'] ?? 0,
        };
      }).toList();

      setState(() {
        scheduleList = list;
        isLoading = false;
      });

      developer.log('✅ 載入完成，共 ${list.length} 筆日行程');

      // 載入完成後自動滾動到第一筆行程
      if (list.isNotEmpty) {
        _scrollToFirstSchedule();
      }

    } catch (e) {
      developer.log('❌ 載入日行程失敗：$e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 新增滾動到第一筆行程的方法
  void _scrollToFirstSchedule() {
    // 等待一下讓 UI 完全構建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      // 尋找第一筆行程的時間
      int? firstScheduleHour;
      
      for (var schedule in scheduleList) {
        final startTime = _parseDateTime(schedule['startTime'], widget.selectedDate);
        if (startTime != null) {
          firstScheduleHour = startTime.hour;
          break;
        }
      }

      if (firstScheduleHour != null) {
        // 計算滾動位置
        // 每個時間槽大約 60-80 pixels（包含間距）
        final double itemHeight = 65.0; // 估算每個時間槽的高度
        final double targetOffset = firstScheduleHour * itemHeight;
        
        // 滾動到目標位置，留一些上方空間
        final double scrollOffset = (targetOffset - 100).clamp(0.0, double.infinity);

        developer.log('📍 自動滾動到第一筆行程：$firstScheduleHour:00，偏移量：$scrollOffset');

        _scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // 可選：加入手動滾動到現在時間的功能
  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    if (_scrollController.hasClients) {
      final double itemHeight = 65.0;
      final double targetOffset = currentHour * itemHeight;
      final double scrollOffset = (targetOffset - 100).clamp(0.0, double.infinity);

      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_formatDate(widget.selectedDate)} 行程'),
        backgroundColor: Colors.blue.shade50,
        elevation: 1,
        actions: [
          // 滾動到現在時間的按鈕
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: _scrollToCurrentTime,
            tooltip: '跳到現在時間',
          ),
          // 滾動到第一筆行程的按鈕
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: scheduleList.isNotEmpty ? _scrollToFirstSchedule : null,
            tooltip: '跳到第一筆行程',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDaySchedules,
            tooltip: '重新整理',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTimelineView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        tooltip: '新增行程',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimelineView() {
    return ListView.separated(
      controller: _scrollController, // 加入這行
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 24, // 24小時
      separatorBuilder: (context, index) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        final hour = index;
        final schedulesAtThisHour = _getSchedulesAtHour(hour);
        final hasSchedule = schedulesAtThisHour.isNotEmpty;

        return _buildTimeSlot(
          hour: hour,
          hasSchedule: hasSchedule,
          schedules: schedulesAtThisHour,
        );
      },
    );
  }

  Widget _buildTimeSlot({
    required int hour,
    required bool hasSchedule,
    required List<Map<String, dynamic>> schedules,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          // 時間顯示區域
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: 16,
                fontWeight: hasSchedule ? FontWeight.w600 : FontWeight.w400,
                color: hasSchedule ? Colors.blue.shade700 : Colors.grey.shade600,
              ),
            ),
          ),

          // 時間軸線和螢光條
          SizedBox(
            width: 20,
            height: hasSchedule ? 60 : 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 垂直時間軸線
                Container(
                  width: 2,
                  height: double.infinity,
                  color: Colors.grey.shade300,
                ),

                // 時間點圓點
                Container(
                  width: hasSchedule ? 12 : 8,
                  height: hasSchedule ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasSchedule ? Colors.blue.shade500 : Colors.grey.shade400,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),

                // 螢光條記號（有行程時顯示）
                if (hasSchedule)
                  Positioned(
                    right: -8,
                    child: Container(
                      width: 6,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade400,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.shade200,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 行程內容區域
          Expanded(
            child: hasSchedule ? _buildScheduleContent(schedules) : _buildEmptyTimeSlot(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(List<Map<String, dynamic>> schedules) {
    return Column(
      children: schedules.map((schedule) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: Colors.blue.shade400, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule['name'] ?? schedule['desc'] ?? '未知行程',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                PopupMenuButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('編輯'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('刪除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editSchedule(schedule);
                    } else if (value == 'delete') {
                      _deleteSchedule(schedule);
                    }
                  },
                ),
              ],
            ),

            if (schedule['desc'] != null && schedule['desc'] != schedule['name']) ...[
              const SizedBox(height: 4),
              Text(
                schedule['desc'],
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatScheduleTime(schedule),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyTimeSlot() {
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      child: Text(
        '',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      ),
    );
  }

  // 修改 _formatScheduleTime 方法
  String _formatScheduleTime(Map<String, dynamic> schedule) {
    if (schedule['startTime'] == null || schedule['endTime'] == null) {
      return '時間未設定';
    }

    final startTime = schedule['startTime'].toString();
    final endTime = schedule['endTime'].toString();
    
    return '$startTime - $endTime';
  }

  void _showAddScheduleDialog() {
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

  void _editSchedule(Map<String, dynamic> item) {
    developer.log('編輯行程: ${item['id']}');
  }

  void _deleteSchedule(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除行程'),
        content: Text('確定要刪除「${item['name']}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDelete(item);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Map<String, dynamic> item) async {
    try {
      final docPath = _formatDateKey(widget.selectedDate);
      await FirebaseFirestore.instance
          .doc(docPath)
          .collection('task_list')
          .doc(item['id'])
          .delete();

      developer.log('✅ 刪除行程成功');
      _loadDaySchedules();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('行程已刪除')),
        );
      }
    } catch (e) {
      developer.log('❌ 刪除行程失敗：$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('刪除失敗，請稍後再試')),
        );
      }
    }
  }
}
