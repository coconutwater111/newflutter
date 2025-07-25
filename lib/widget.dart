import 'package:flutter/material.dart';

class InputSection extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;

  const InputSection({super.key, required this.onSubmit});

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  TimeOfDay? _ts;
  TimeOfDay? _te;
  final _nController = TextEditingController();

  int _taskCount = 0;
  List<double> _kValues = [];

  void _updateSliders(int count) {
    setState(() {
      _taskCount = count;
      _kValues = List<double>.filled(count, 30.0); // 預設30分鐘
    });
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_ts ?? TimeOfDay.now()) : (_te ?? TimeOfDay.now()),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("請正確填寫開始時間、結束時間與任務個數")),
      );
      return;
    }

    String formatTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final data = {
      "Ts": formatTime(_ts!),
      "Te": formatTime(_te!),
      "n": n,
      "k": _kValues.map((v) => v.toInt()).toList(),
    };

    widget.onSubmit(data);

    // 清除輸入
    _nController.clear();
    setState(() {
      _ts = null;
      _te = null;
      _taskCount = 0;
      _kValues = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final tsDisplay = _ts == null
        ? '選擇開始時間 Ts'
        : '開始時間 Ts：${_ts!.format(context)}';
    final teDisplay = _te == null
        ? '選擇結束時間 Te'
        : '結束時間 Te：${_te!.format(context)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _pickTime(context, true),
            child: Text(tsDisplay),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _pickTime(context, false),
            child: Text(teDisplay),
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
          for (int i = 0; i < _taskCount; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('確認送出'),
          ),
        ],
      ),
    );
  }
}
