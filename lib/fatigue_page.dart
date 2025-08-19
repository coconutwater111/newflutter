import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_transmit/fatigue_chart.dart';

// ================== FatiguePage (編輯與儲存) ==================
class FatiguePage extends StatefulWidget {
  final String intelligenceType; // 傳入對應的智能類型，如 "linguistic"
  const FatiguePage({super.key, required this.intelligenceType});

  @override
  State<FatiguePage> createState() => _FatiguePageState();
}

class _FatiguePageState extends State<FatiguePage> {
  List<double> fatigueData = List.filled(24, 0.0);
  final String userId = 'testUser';

  // 新增 GlobalKey
  final GlobalKey<FatigueChartState> chartKey = GlobalKey<FatigueChartState>();

  String get docId => 'fatigue_${widget.intelligenceType}';

  // 讀取疲勞度資料
  Future<void> loadFatigueData() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fatigue_logs')
          .doc(docId)
          .get();

      if (query.exists) {
        final data = query.data();
        final List<dynamic> values = data?['values'] ?? [];
        setState(() {
          fatigueData = values.map((e) => (e as num).toDouble()).toList();
        });
      }
    } catch (e) {
      // print('讀取錯誤: $e');
      showMessage('讀取錯誤: $e');
    }
  }

  // 儲存疲勞度資料
  Future<void> saveFatigueData() async {
    try {
      List<double> validFatigueData =
          fatigueData.map((e) => e.toDouble()).toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fatigue_logs')
          .doc(docId)
          .set({
        'values': validFatigueData,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      showMessage('儲存失敗：$e');
    }
  }

  // 刪除疲勞度資料
  Future<void> deleteFatigueData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('fatigue_logs')
        .doc(docId)
        .delete();

    setState(() {
      fatigueData = List.filled(24, 0.0);
    });
  }

  // 顯示訊息
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    loadFatigueData(); // 載入資料
  }

  // 更新疲勞度資料
  void updateFatigueData(List<double> newFatigueData) {
    setState(() {
      fatigueData = newFatigueData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.intelligenceType} 疲勞度')),
      body: Column(
        children: [
          // FatigueChart 傳入 key
          Expanded(
            child: FatigueChart(
              key: chartKey,
              onFatigueValuesChanged: updateFatigueData,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '疲勞值 (24 小時)：\n${fatigueData.map((v) => v.toStringAsFixed(1)).join(', ')}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(onPressed: saveFatigueData, child: const Text('儲存')),
              ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('確定刪除？'),
                      content: const Text('這會刪除所有疲勞資料'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('刪除'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await deleteFatigueData();
                    chartKey.currentState?.resetChart(); // ← 刪除時重置圖形
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('刪除'),
              ),
              // 👉 新增「查看數據」按鈕
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FatigueDisplayPage(
                        intelligenceType: widget.intelligenceType,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('查看數據'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ================== FatigueDisplayPage (顯示數據) ==================
class FatigueDisplayPage extends StatefulWidget {
  final String intelligenceType; // 接收智能類型參數

  const FatigueDisplayPage({super.key, required this.intelligenceType});

  @override
  FatigueDisplayPageState createState() => FatigueDisplayPageState();
}

class FatigueDisplayPageState extends State<FatigueDisplayPage> {
  List<double> fatigueData = List.filled(24, 0.0);
  final String userId = 'testUser';

  Future<void> loadFatigueData() async {
    try {
      String docId = 'fatigue_${widget.intelligenceType}'; // 根據智能類型組成文檔 ID

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fatigue_logs')
          .doc(docId)
          .get();

      if (doc.exists) {
        final List<dynamic> values = doc.data()?['values'] ?? [];
        setState(() {
          fatigueData = values.map((e) => (e as num).toDouble()).toList();
        });
      } else {
        // print('❌ 找不到 ${widget.intelligenceType} 對應的 fatigue 資料');
      }
    } catch (e) {
      // print('❌ 讀取資料錯誤: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadFatigueData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.intelligenceType} 疲勞度數值'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                double value = fatigueData[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 50, child: Text('$index:00')),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(value.toStringAsFixed(1)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

