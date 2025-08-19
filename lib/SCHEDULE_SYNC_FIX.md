# 行程列表統一與跳轉定位修復

## 🎯 修復的問題

### 1. **主頁面與每日行程頁面排序不一致**
- **問題**：主頁面行程列表按 `index` 排序，每日行程頁面也按 `index` 排序，但沒有統一按時間排序
- **影響**：兩個頁面顯示的行程順序可能不一致

### 2. **點擊單筆行程無法定位到對應行程**
- **問題**：從主頁面點擊行程跳轉到每日行程頁面時，總是定位到第一筆行程
- **影響**：用戶需要手動滾動找到想查看的行程

## ✨ 解決方案

### 1. **統一時間排序邏輯**

#### **主頁面 (Calendar)**：
```dart
// Firebase 查詢
.orderBy('startTime') // 按時間排序

// 客戶端智能排序
list.sort((a, b) {
  if (aTime != null && bTime != null) {
    return aTime.compareTo(bTime);
  }
  if (aTime != null) return -1;
  if (bTime != null) return 1;
  return a.index.compareTo(b.index);
});
```

#### **每日行程頁面 (DailySchedulePage)**：
```dart
// Firebase 查詢（保持一致）
.orderBy('startTime') // 改為按時間排序

// 客戶端排序（相同邏輯）
schedules.sort((a, b) {
  if (a.startTime != null && b.startTime != null) {
    return a.startTime!.compareTo(b.startTime!);
  }
  if (a.startTime != null) return -1;
  if (b.startTime != null) return 1;
  return a.index.compareTo(b.index);
});
```

### 2. **智能行程定位功能**

#### **數據模型增強**：
```dart
class ScheduleItem {
  final String id;  // 新增：行程 ID
  // ... 其他欄位
}
```

#### **跳轉邏輯改進**：
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DailySchedulePage(
      selectedDate: selectedDay,
      initialScheduleId: item.id,  // 傳遞目標行程 ID
    ),
  ),
);
```

#### **智能定位方法**：
```dart
void _scrollToTargetSchedule() {
  // 1. 如果指定了行程 ID，定位到該行程
  if (widget.initialScheduleId != null) {
    final targetIndex = scheduleList.indexWhere(
      (schedule) => schedule.id == widget.initialScheduleId,
    );
    if (targetIndex != -1) {
      // 找到了，滾動到該行程
    }
  }
  
  // 2. 否則定位到第一個行程（原有邏輯）
}
```

## 📋 修改的文件

### **主頁面相關**：
1. `home_screen/models/schedule_item.dart` - 新增 ID 欄位
2. `home_screen/services/calendar_firebase_service.dart` - 統一排序邏輯
3. `home_screen/widgets/schedule_list_widget.dart` - 改進跳轉邏輯

### **每日行程頁面相關**：
4. `daily_schedule/daily_schedule_page.dart` - 支持初始行程定位
5. `daily_schedule/services/schedule_service.dart` - 統一排序邏輯

## 🎯 改進效果

### **排序統一性**：
- ✅ 主頁面和每日行程頁面現在都按相同的時間順序排列
- ✅ 雙重保障：Firebase 查詢排序 + 客戶端智能排序
- ✅ 處理各種時間格式和缺失時間的情況

### **精確定位**：
- ✅ 點擊特定行程會直接跳轉並定位到該行程
- ✅ 智能滾動動畫，提升用戶體驗
- ✅ 容錯處理：找不到指定行程時回退到第一個行程

### **用戶體驗提升**：
- 🚀 **無縫銜接**：兩個頁面顯示順序完全一致
- 🎯 **精確導航**：點擊哪個行程就跳轉到哪個行程
- ⚡ **快速定位**：自動滾動到目標行程，無需手動搜尋
- 🛡️ **穩定可靠**：多重排序邏輯確保顯示正確

## 🧪 測試建議

建議測試以下場景：
- [ ] 創建多個不同時間的行程，檢查兩個頁面排序是否一致
- [ ] 從主頁面點擊不同行程，確認是否正確定位
- [ ] 測試邊緣情況：缺少時間的行程、混合時間格式
- [ ] 確認滾動動畫效果和用戶體驗
