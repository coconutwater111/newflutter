import 'package:flutter/material.dart';

class InputSection extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  final DateTime selectedDay;
  const InputSection({
    super.key,
    required this.onSubmit,
    required this.selectedDay,
  });


  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  TimeOfDay? _ts;
  TimeOfDay? _te;
  final _nController = TextEditingController();

  int _taskCount = 0;
  List<double> _kValues = [];
  List<TextEditingController> _descControllers = [];
  int _visibleTaskCount = 1;

  void _updateSliders(int count) {
    setState(() {
      _taskCount = count;
      _kValues = List<double>.filled(count, 30.0); // 預設30分鐘
      _descControllers = List.generate(
        count,
        (index) => TextEditingController(),
      ); // 初始化描述控制器
      _visibleTaskCount = count > 0 ? 1 : 0;
    });
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? (_ts ?? TimeOfDay.now()) : (_te ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _ts = picked;
        } else {
          _te = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    final n = int.tryParse(_nController.text.trim());

    if (_ts == null || _te == null || n == null || n <= 0 || n != _taskCount) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("請正確填寫開始時間、結束時間與任務個數")));
      return;
    }

    String formatTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final data = {
      "taskDate": widget.selectedDay.toIso8601String().split("T")[0],
      "Ts": formatTime(_ts!),
      "Te": formatTime(_te!),
      "n": n,
      "k": _kValues.map((v) => v.toInt()).toList(),
      "desc": _descControllers.map((c) => c.text.trim()).toList(),
    };

    widget.onSubmit(data);

    // 清除輸入
    _nController.clear();
    setState(() {
      _ts = null;
      _te = null;
      _taskCount = 0;
      _kValues = [];
      _descControllers = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final tsDisplay =
        _ts == null ? '選擇開始時間 Ts' : '開始時間 Ts：${_ts!.format(context)}';
    final teDisplay =
        _te == null ? '選擇結束時間 Te' : '結束時間 Te：${_te!.format(context)}';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () => _pickTime(context, true),
              child: Text(tsDisplay),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () => _pickTime(context, false),
              child: Text(teDisplay),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nController,
            decoration: const InputDecoration(
              labelText: '任務個數 n',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed > 0) {
                _updateSliders(parsed);
              } else {
                setState(() {
                  _taskCount = 0;
                  _kValues = [];
                });
              }
            },
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < _visibleTaskCount && i < _descControllers.length && i < _kValues.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _descControllers[i],
                    decoration: InputDecoration(
                      labelText: '任務 ${i + 1} 簡單描述活動名稱',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.trim().isNotEmpty &&
                          i == _visibleTaskCount - 1 &&
                          _visibleTaskCount < _taskCount) {
                        setState(() {
                          _visibleTaskCount++;
                        });
                      }
                    },
                  ),
                  Text('任務 ${i + 1} 持續時間 k（分鐘）：${_kValues[i].toInt()}'),
                  Slider(
                    value: _kValues[i],
                    min: 0,
                    max: 120,
                    divisions: 24,
                    label: _kValues[i].toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _kValues[i] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('確認送出'),
            ),
          ),
        ],
      ),
    );
  }
}
