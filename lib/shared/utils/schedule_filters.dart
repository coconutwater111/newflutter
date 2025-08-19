import '../../home_screen/models/schedule_item.dart';

/// 判斷行程是否有效（desc 與 time 皆不為空）
bool isValidSchedule(ScheduleItem item) =>
    item.desc.trim().isNotEmpty &&
    item.time.trim().isNotEmpty;

/// 過濾有效行程
List<ScheduleItem> filterValidSchedules(List<ScheduleItem> list) =>
    list.where(isValidSchedule).toList();
