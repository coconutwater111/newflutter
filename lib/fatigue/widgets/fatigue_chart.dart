import 'package:flutter/material.dart';

class FatigueChart extends StatefulWidget {
  final void Function(List<double>) onFatigueValuesChanged;

  const FatigueChart({super.key, required this.onFatigueValuesChanged});

  @override
  State<FatigueChart> createState() => FatigueChartState();
}

// 將 State 類別公開
class FatigueChartState extends State<FatigueChart> {
  List<Offset> points = [];
  List<double> fatigueValues = List.filled(24, 0.0);

  void resetChart() {
    setState(() {
      points.clear();
      fatigueValues = List.filled(24, 0.0);
      widget.onFatigueValuesChanged(fatigueValues);
    });
  }

  void _calculateFatigueValues(Size size) {
    fatigueValues = List.filled(24, 0.0);
    if (points.isEmpty) return;

    for (int hour = 0; hour < 24; hour++) {
      double targetX = size.width / 24 * hour;
      Offset? nearest = _findNearestX(targetX);

      if (nearest != null) {
        double diff = (nearest.dx - targetX).abs();
        double maxAllowableDiff = size.width / 24 / 2;

        if (diff <= maxAllowableDiff) {
          double fatigue = 10 - (nearest.dy / size.height) * 9;
          fatigueValues[hour] = fatigue.clamp(1.0, 10.0);
        } else {
          fatigueValues[hour] = 0.0;
        }
      }
    }

    widget.onFatigueValuesChanged(fatigueValues);
  }

  Offset? _findNearestX(double x) {
    Offset? nearest;
    double minDiff = double.infinity;
    for (Offset p in points) {
      double diff = (p.dx - x).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = p;
      }
    }
    return nearest;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Size canvasSize = constraints.biggest;

      return GestureDetector(
        onPanUpdate: (details) {
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset local = box.globalToLocal(details.globalPosition);

          if (local.dx >= 0 &&
              local.dy >= 0 &&
              local.dx <= canvasSize.width &&
              local.dy <= canvasSize.height) {
            if (points.isEmpty || local.dx > points.last.dx) {
              setState(() {
                points.add(local);
                _calculateFatigueValues(canvasSize);
              });
            }
          }
        },
        onPanEnd: (_) {
          _calculateFatigueValues(canvasSize);
        },
        child: CustomPaint(
          size: canvasSize,
          painter: FatiguePainter(points: points),
        ),
      );
    });
  }
}

class FatiguePainter extends CustomPainter {
  final List<Offset> points;

  FatiguePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // 畫橫線（疲勞度）
    for (int i = 1; i <= 10; i++) {
      double y = size.height / 10 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 畫直線（24小時）
    for (int i = 1; i < 24; i++) {
      double x = size.width / 24 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 畫使用者畫的線
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
