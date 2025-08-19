import 'package:flutter/material.dart';
import '../models/schedule_item.dart';
import '../../daily_schedule/daily_schedule_page.dart';

/// 行程列表顯示組件
class ScheduleListWidget extends StatelessWidget {
  final DateTime selectedDay;
  final List<ScheduleItem> scheduleList;
  final bool isLoading;

  const ScheduleListWidget({
    super.key,
    required this.selectedDay,
    required this.scheduleList,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // 過濾掉空資料的行程
    final filteredList = scheduleList.where((item) =>
      (item.desc.trim().isNotEmpty) &&
      (item.time.trim().isNotEmpty)
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${selectedDay.toLocal().toString().split(' ')[0]} 的行程',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        // 載入中指示器
        if (isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )

        // 顯示過濾後的行程列表
        else if (filteredList.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _ScheduleListItem(
                  item: item,
                  selectedDay: selectedDay,
                );
              },
            ),
          )

        // 無行程時顯示
        else
          const Expanded(
            child: _EmptyScheduleWidget(),
          ),
      ],
    );
  }
}

/// 行程列表項組件
class _ScheduleListItem extends StatelessWidget {
  final ScheduleItem item;
  final DateTime selectedDay;

  const _ScheduleListItem({
    required this.item,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 12,
      ),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(item.desc),
        subtitle: Text(item.time),
        trailing: const Icon(Icons.cloud_done, color: Colors.green),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailySchedulePage(
                selectedDate: selectedDay,
                initialScheduleId: item.id, // 傳遞要定位的行程 ID
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 無行程時的空狀態組件
class _EmptyScheduleWidget extends StatelessWidget {
  const _EmptyScheduleWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '此天尚無行程',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
