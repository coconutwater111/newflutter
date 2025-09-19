import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  String? recommendation;
  Map<String, dynamic>? planJson;
  bool isLoading = false;
  List<Map<String, dynamic>> selectedTasks = [];

  // 🔹 改成跟 FatiguePage 一樣統一抓 UID
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? 'unknownUser';

  /// 從後端抓計畫
  Future<void> fetchPlan(String question) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse("https://1b39113ffc61.ngrok-free.app/dick/ask");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"question": question}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        recommendation = data["recommendation"];
        planJson = data["result"];
        isLoading = false;
      });
    } else {
      setState(() {
        recommendation = "伺服器錯誤: ${response.statusCode}";
        planJson = null;
        isLoading = false;
      });
    }
  }

  /// 確認送出所有勾選的行程
  /// 確認送出所有勾選的行程
  Future<void> submitAllSelectedTasks() async {
    if (planJson == null || selectedTasks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("沒有可送出的行程")));
      return;
    }

    // 直接使用 FirebaseAuth 的 UID
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final resultJson = {
      "計畫名稱": planJson?["計畫名稱"],
      "使用者UID": uid, // 🔹 這裡放 UID
      "已選行程": selectedTasks,
    };

    final url = Uri.parse("https://1b39113ffc61.ngrok-free.app/dick/submit");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(resultJson),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ 所有行程已送出")));
      setState(() {
        selectedTasks.clear();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("送出失敗: ${response.statusCode}")));
    }
  }

  /// 選擇或修改開始和結束時間
  Future<void> selectTaskTime(
    BuildContext context,
    Map<String, dynamic> task, {
    int? existingIndex,
  }) async {
    final duration = task["持續時間"] ?? 30;

    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: "選擇開始時間",
    );
    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: "選擇結束時間",
    );
    if (endTime == null) return;

    final startDateTime = DateTime(
      2025,
      task["月份"],
      task["日期"],
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      2025,
      task["月份"],
      task["日期"],
      endTime.hour,
      endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("結束時間必須晚於開始時間")));
      return;
    }

    final startTimeStr =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
    final endTimeStr =
        "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";

    final updatedTask = Map<String, dynamic>.from(task);
    updatedTask["開始時間"] = startTimeStr;
    updatedTask["結束時間"] = endTimeStr;
    updatedTask["持續時間"] = duration;

    // 🔹 加上 UID
    updatedTask["uid"] = userId;

    setState(() {
      if (existingIndex != null) {
        selectedTasks[existingIndex] = updatedTask;
      } else {
        selectedTasks.add(updatedTask);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "已${existingIndex != null ? '更新' : '加入'} ${task["事件"]} (等待確認送出)",
        ),
      ),
    );
  }

  /// 移除已選擇的任務
  void removeTask(int index) {
    setState(() {
      selectedTasks.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("已移除行程")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("行程規劃助手"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "輸入需求",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchPlan(_controller.text),
              child: const Text("送出"),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (recommendation != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "推薦理由：$recommendation",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 10),
            if (planJson != null) ...[
              Text(
                "計畫名稱: ${planJson!["計畫名稱"]}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (selectedTasks.isNotEmpty) ...[
                const Text(
                  "已選擇的行程：",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = selectedTasks[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(task["事件"]),
                          subtitle: Text(
                            "${task["年分"]}-${task["月份"].toString().padLeft(2, '0')}-${task["日期"].toString().padLeft(2, '0')} "
                            "${task["開始時間"]} ~ ${task["結束時間"]}\n"
                            "持續時間: ${task["持續時間"]} 分鐘\n"
                            "多元智慧領域: ${task["多元智慧領域"]}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    () => selectTaskTime(
                                      context,
                                      task,
                                      existingIndex: index,
                                    ),
                                tooltip: "修改時間",
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => removeTask(index),
                                tooltip: "移除",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: (planJson!["行程"] as List).length,
                  itemBuilder: (context, index) {
                    final task = planJson!["行程"][index];
                    final isSelected = selectedTasks.any(
                      (t) => t["事件"] == task["事件"],
                    );
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: Text(task["事件"]),
                        subtitle: Text(
                          "${task["年分"]}-${task["月份"].toString().padLeft(2, '0')}-${task["日期"].toString().padLeft(2, '0')} "
                          "${task["開始時間"] ?? "未設定"} ~ ${task["結束時間"] ?? "未設定"}\n"
                          "持續時間: ${task["持續時間"] ?? "未設定"} 分鐘\n"
                          "多元智慧領域: ${task["多元智慧領域"]}",
                        ),
                        value: isSelected,
                        onChanged: (val) {
                          if (val == true) {
                            selectTaskTime(context, task);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: submitAllSelectedTasks,
                icon: const Icon(Icons.send),
                label: const Text("確認送出所有勾選的行程"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
