import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/fatigue_chart.dart';

// ================== FatiguePage (編輯與儲存) ==================
class FatiguePage extends StatefulWidget {
  final String intelligenceType; // 傳入對應的智能類型，如 "linguistic"
  const FatiguePage({super.key, required this.intelligenceType});

  @override
  State<FatiguePage> createState() => _FatiguePageState();
}

class _FatiguePageState extends State<FatiguePage> {
  Widget buildActionButton({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        style: color != null
            ? ElevatedButton.styleFrom(backgroundColor: color)
            : null,
        child: Text(label),
      ),
    );
  }
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

  // 重畫（清空繪圖區與數據，並同步雲端歸零）
  Future<void> redrawFatigueChart() async {
    setState(() {
      fatigueData = List.filled(24, 0.0);
    });
    chartKey.currentState?.resetChart();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fatigue_logs')
          .doc(docId)
          .set({
        'values': List.filled(24, 0.0),
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      showMessage('雲端歸零失敗：$e');
    }
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final actionButtons = [
      buildActionButton(label: '儲存', onPressed: saveFatigueData),
      buildActionButton(
        label: '重畫',
        onPressed: () async => await redrawFatigueChart(),
        color: Colors.orange,
      ),
      buildActionButton(
        label: '查看數據',
        onPressed: () async {
          final result = await Navigator.push<List<double>>(
            context,
            MaterialPageRoute(
              builder: (context) => FatigueDisplayPage(
                intelligenceType: widget.intelligenceType,
                initialFatigueData: List<double>.from(fatigueData),
              ),
            ),
          );
          if (result != null) {
            setState(() {
              fatigueData = result;
            });
          }
        },
        color: Colors.blue,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.intelligenceType} 疲勞度'),
        actions: isLandscape ? actionButtons : null,
      ),
      body: Column(
        children: [
              Expanded(
                child: FatigueChart(
                  key: chartKey,
                  onFatigueValuesChanged: updateFatigueData,
                  initialFatigueValues: fatigueData,
                ),
              ),
              const Divider(),
              Builder(
                builder: (context) {
                  return Column(
                    children: [
                      if (isLandscape) const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '疲勞值 (24 小時)：\n${fatigueData.map((v) => v.toStringAsFixed(1)).join(', ')}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
              if (!isLandscape)
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: actionButtons,
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
  final List<double>? initialFatigueData;

  const FatigueDisplayPage({super.key, required this.intelligenceType, this.initialFatigueData});

  @override
  FatigueDisplayPageState createState() => FatigueDisplayPageState();
}

class FatigueDisplayPageState extends State<FatigueDisplayPage> {
  // 新增：即時儲存到 Firebase
  Future<void> saveFatigueData() async {
    try {
      String docId = 'fatigue_${widget.intelligenceType}';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fatigue_logs')
          .doc(docId)
          .set({
        'values': fatigueData,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // 可選：顯示錯誤訊息
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('儲存失敗: $e')));
    }
  }
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
  fatigueData = widget.initialFatigueData != null
    ? List<double>.from(widget.initialFatigueData!)
    : List.filled(24, 0.0);
  loadFatigueData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.intelligenceType} 疲勞度數值'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, fatigueData); // 返回時回傳最新數據
          },
        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 50, child: Text('$index:00')),
                      Expanded(
                        child: Slider(
                          value: value,
                          min: 0,
                          max: 10,
                          divisions: 100,
                          label: value.toStringAsFixed(1),
                          onChanged: (newValue) async {
                            setState(() {
                              fatigueData[index] = newValue;
                            });
                            await saveFatigueData(); // 即時同步儲存
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          value.toStringAsFixed(1),
                          textAlign: TextAlign.right,
                        ),
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
