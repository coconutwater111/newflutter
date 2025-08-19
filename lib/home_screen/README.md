# Calendar.dart 重構說明

## 重構目標
將原本臃腫的 `calendar.dart` 文件（403 行）分解為更小、更易維護的組件，提高代碼的可讀性和可維護性。

## 新的文件結構

```
lib/home_screen/
├── calendar.dart                    # 主要組件 (140行，減少 65%)
├── calendar_exports.dart           # 統一導出文件
├── models/
│   └── schedule_item.dart          # 行程數據模型
├── services/
│   └── calendar_firebase_service.dart  # Firebase 服務層
├── utils/
│   └── calendar_styles.dart        # 樣式配置工具類
└── widgets/
    ├── custom_calendar_widget.dart    # 自定義日曆組件
    └── schedule_list_widget.dart      # 行程列表組件
```

## 各文件職責

### 1. **models/schedule_item.dart**
- 定義行程項目的數據模型
- 提供 Firebase 文檔轉換方法
- 包含時間格式化邏輯

### 2. **services/calendar_firebase_service.dart**
- 封裝所有 Firebase 相關操作
- 提供載入和新增行程的方法
- 集中處理路徑生成和錯誤處理

### 3. **utils/calendar_styles.dart**
- 集中管理日曆的樣式配置
- 包含日曆樣式、標題樣式、格式選項
- 提供日曆建構器配置

### 4. **widgets/custom_calendar_widget.dart**
- 封裝 TableCalendar 組件
- 提供清晰的接口給父組件
- 集中日曆相關的配置

### 5. **widgets/schedule_list_widget.dart**
- 管理行程列表的顯示
- 包含行程項目組件和空狀態組件
- 處理列表項的點擊事件

### 6. **calendar.dart** (主文件)
- 僅保留狀態管理和組件協調邏輯
- 從 403 行減少到 140 行（減少 65%）
- 更清晰的結構和責任劃分

## 重構優勢

### ✅ **提高可讀性**
- 每個文件職責單一，代碼更易理解
- 主文件邏輯清晰，專注於狀態管理

### ✅ **提高可維護性**
- 修改樣式只需編輯 `calendar_styles.dart`
- Firebase 邏輯變更只影響 `calendar_firebase_service.dart`
- 組件獨立，易於測試和重用

### ✅ **提高可重用性**
- 各組件可以在其他地方重用
- 服務層可以被其他頁面使用

### ✅ **更好的關注點分離**
- UI 組件與業務邏輯分離
- 數據處理與顯示邏輯分離

## 向後兼容性
- 保持所有原有 UI 邏輯不變
- API 介面保持一致
- 不影響其他文件的導入

## 使用方式

### 導入整個模組：
```dart
import 'package:your_app/home_screen/calendar_exports.dart';
```

### 或單獨導入需要的組件：
```dart
import 'package:your_app/home_screen/models/schedule_item.dart';
import 'package:your_app/home_screen/services/calendar_firebase_service.dart';
```

## 未來優化建議
1. 可以考慮使用狀態管理解決方案（如 Provider 或 Riverpod）
2. 添加單元測試覆蓋各個組件
3. 考慮添加錯誤處理的 UI 提示組件
4. 可以進一步優化 Firebase 查詢性能
