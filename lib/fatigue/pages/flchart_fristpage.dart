import 'package:flutter/material.dart';
import 'fatigue_page.dart';

class Flchartfristpage extends StatelessWidget {
  const Flchartfristpage({super.key});

  // 顯示名稱對應 Firebase 專用 key（你儲存時使用的）
  final List<Map<String, String>> miTypes = const [
    {'name': '語文智能', 'key': 'linguistic'},
    {'name': '邏輯數學智能', 'key': 'logical'},
    {'name': '空間智能', 'key': 'spatial'},
    {'name': '音樂智能', 'key': 'musical'},
    {'name': '肢體動覺智能', 'key': 'bodily_kinesthetic'},
    {'name': '人際智能', 'key': 'interpersonal'},
    {'name': '內省智能', 'key': 'intrapersonal'},
    {'name': '自然觀察智能', 'key': 'naturalistic'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("多元智能與疲勞度")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '根據 Howard Gardner 的多元智能理論（Multiple Intelligences Theory），'
              '每個人擁有不同形式的智能優勢，如語文、邏輯、空間等。這些智能會影響人在一天中不同時間的表現與疲勞程度。例如，一位音樂智能較強的人，可能在早晨學習音樂時感到更輕鬆；'
              '而邏輯數學智能強者，則可能在深夜分析數據更得心應手。本系統將透過圖表協助你探索這些關聯。',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),

            const Text(
              '請選擇一種智能以查看其 24 小時疲勞變化：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 按鈕區域
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
                children: miTypes.map((type) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FatiguePage(
                            intelligenceType: type['key']!, // 傳入對應的 Firebase key
                          ),
                        ),
                      );
                    },
                    child: Text(type['name']!),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
