import 'package:flutter/material.dart';

import 'services/schedule_creation_service.dart';
import '../widget.dart'; // 使用現有的 InputSection
import '../home_screen/custom_bottom_app_bar.dart';
import '../shared/services/firebase_service.dart';
import '../shared/services/network_service.dart';

class ScheduleCreationPage extends StatefulWidget {
  final DateTime? selectedDay;

  const ScheduleCreationPage({super.key, this.selectedDay});

  @override
  State<ScheduleCreationPage> createState() => _ScheduleCreationPageState();
}

class _ScheduleCreationPageState extends State<ScheduleCreationPage> {
  bool isReconnecting = false;
  int retryCount = 0;
  String responseMsg = '';
  
  late final ScheduleCreationService _scheduleService;
  late final NetworkService _networkService;

  @override
  void initState() {
    super.initState();
    _scheduleService = ScheduleCreationService();
    _networkService = NetworkService();
  }

  Future<void> _sendToBackend(Map<String, dynamic> data) async {
    setState(() {
      isReconnecting = true;
      retryCount = 0;
    });

    final result = await _networkService.sendData(data);
    
    setState(() {
      isReconnecting = false;
      retryCount = result['retryCount'] ?? 0;
      responseMsg = result['message'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = widget.selectedDay ?? DateTime.now();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("今天有什麼行程？"),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InputSection(
                onSubmit: _sendToBackend,
                selectedDay: selectedDate,
              ),
              const SizedBox(height: 20),
              _buildStatusSection(),
              const SizedBox(height: 20),
              _buildScheduleList(selectedDate),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(
        color: Colors.transparent,
        fabLocation: FloatingActionButtonLocation.endDocked,
        shape: CircularNotchedRectangle(),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      children: [
        if (isReconnecting)
          Text(
            "🔄 正在重新連接... 第 $retryCount 次",
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 16
            ),
          ),
        const SizedBox(height: 10),
        if (responseMsg.isNotEmpty)
          Text(
            responseMsg,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 14
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleList(DateTime selectedDate) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirebaseService.getSchedules(selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: Colors.blue.shade600,
          );
        } else if (snapshot.hasError) {
          return Text(
            '讀取失敗：${snapshot.error}',
            style: TextStyle(color: Colors.red.shade600),
          );
        }

        final scheduleList = snapshot.data ?? [];

        // 直接交給 service 處理 filter/sort
        return _scheduleService.buildScheduleListWidget(
          scheduleList,
          selectedDate,
          context,
        );
      },
    );
  }
}