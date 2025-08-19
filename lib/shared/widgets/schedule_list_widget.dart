
import 'package:flutter/material.dart';
import '../../home_screen/models/schedule_item.dart';
import '../../daily_schedule/daily_schedule_page.dart';
import '../../shared/utils/schedule_filters.dart';

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
    final filteredList = filterValidSchedules(scheduleList);
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
        if (isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
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
        else
          const Expanded(
            child: _EmptyScheduleWidget(),
          ),
      ],
    );
  }
}

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
                initialScheduleId: item.id,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyScheduleWidget extends StatelessWidget {
  const _EmptyScheduleWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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
