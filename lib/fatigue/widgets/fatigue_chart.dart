import 'package:flutter/material.dart';
import 'fatigue_chart_layout.dart';

class FatigueChart extends StatefulWidget {
  final void Function(List<double>) onFatigueValuesChanged;
  final List<double>? initialFatigueValues;

  const FatigueChart({super.key, required this.onFatigueValuesChanged, this.initialFatigueValues});

  @override
  State<FatigueChart> createState() => FatigueChartState();
}

// 將 State 類別公開
class FatigueChartState extends State<FatigueChart> {
  List<Offset> points = [];

  List<double> get fatigueValues => widget.initialFatigueValues ?? List.filled(24, 0.0);

  void resetChart() {
    setState(() {
      points.clear();
      widget.onFatigueValuesChanged(List.filled(24, 0.0));
    });
  }

  void _calculateFatigueValues(Size size) {
    List<double> newValues = List.filled(24, 0.0);
    if (points.isEmpty) {
      widget.onFatigueValuesChanged(newValues);
      return;
    }

    double gridWidth = size.width / 24;
    double gridHeight = size.height;

    for (int i = 0; i < 24; i++) {
      double left = gridWidth * i;
      double right = gridWidth * (i + 1);
      // 取該縱格內所有點的平均疲勞值
      List<Offset> pointsInGrid = points.where((p) => p.dx >= left && p.dx < right).toList();
      if (pointsInGrid.isNotEmpty) {
        double avgY = pointsInGrid.map((p) => p.dy).reduce((a, b) => a + b) / pointsInGrid.length;
        double value = ((gridHeight - avgY) / gridHeight) * 10.0;
        value = value.clamp(0.0, 10.0);
        newValues[i] = value;
      } else {
        newValues[i] = 0.0;
      }
    }
    widget.onFatigueValuesChanged(newValues);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = FatigueChartLayout.isLandscape(context);
    final leftPadding = FatigueChartLayout.leftPadding(context);
    final rightPadding = FatigueChartLayout.rightPadding(context);
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 左側數值顯示
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  11,
                  (index) => Text(
                    (10 - index).toStringAsFixed(1), // 10.0 ~ 0.0
                    style: TextStyle(fontSize: FatigueChartLayout.chartLabelFontSize(context), color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(width: 8), // 數值與圖表間距
              // 繪圖區域（加上右側 padding）
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: FatigueChartLayout.rightPadding(context),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLandscape = FatigueChartLayout.isLandscape(context);
                      // 設定長度（寬度）
                      final chartWidth = isLandscape ? constraints.maxWidth * 1.5 : constraints.maxWidth;
                      final canvasSize = Size(chartWidth, constraints.maxHeight);

                      return Center(
                        child: SizedBox(
                          width: chartWidth,
                          height: constraints.maxHeight,
                          child: GestureDetector(
                            onTapDown: (_) {
                              // 點擊繪圖區時只清空 points，不清空 fatigueValues，紅線會保留
                              setState(() {
                                points.clear();
                              });
                            },
                            onPanUpdate: (details) {
                              RenderBox box = context.findRenderObject() as RenderBox;
                              Offset local = box.globalToLocal(details.globalPosition);
                              // 嚴格檢查 local 是否為合法座標
                              if (local.dx >= 0 &&
                                  local.dy >= 0 &&
                                  local.dx <= canvasSize.width &&
                                  local.dy <= canvasSize.height &&
                                  !local.dx.isNaN && !local.dy.isNaN &&
                                  local.dx.isFinite && local.dy.isFinite) {
                                if (points.isEmpty || (local.dx > points.last.dx && local.dx.isFinite && local.dy.isFinite)) {
                                  setState(() {
                                    points.add(local);
                                    _calculateFatigueValues(canvasSize);
                                  });
                                }
                              }
                            },
                            onPanEnd: (_) {
                              // 畫完後藍線消失，紅線持續顯示
                              setState(() {
                                points.clear();
                              });
                              // _calculateFatigueValues(canvasSize); // 不需再算一次，已於最後一筆 update 時算過
                            },
                            child: CustomPaint(
                              size: Size(chartWidth, constraints.maxHeight),
                              painter: FatiguePainter(
                                points: points,
                                fatigueValues: fatigueValues,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // 下方小時標籤
        if (isLandscape)
          SizedBox(height: FatigueChartLayout.bottomLabelSpace(context)),
        Padding(
          padding: EdgeInsets.only(left: leftPadding, right: rightPadding), // 左右 padding 動態調整
          child: Row(
            children: List.generate(
              24,
              (i) => Expanded(
                child: Text(
                  '$i',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: FatigueChartLayout.chartLabelFontSize(context), color: Colors.black54),
                ),
              ),
            ),
          ),
        ),
        if (isLandscape)
          SizedBox(height: 16), // landscape 再多一點底部空間
      ],
    );
  }
}

class FatiguePainter extends CustomPainter {
  final List<Offset> points;
  final List<double> fatigueValues;

  FatiguePainter({required this.points, required this.fatigueValues});

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

    // 畫四周邊框
    final borderPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // 畫使用者畫的線（藍色）
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final mid = Offset(
          (p1.dx + p2.dx) / 2,
          (p1.dy + p2.dy) / 2,
        );
        path.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
      }
      // 最後一段直接連到最後一點
      if (points.length > 2) {
        path.lineTo(points.last.dx, points.last.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // 畫平滑曲線（紅色，根據 fatigueValues）
    if (fatigueValues.isNotEmpty && fatigueValues.length == 24) {
      final smoothPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final smoothPath = Path();
      double gridWidth = size.width / 24;
      // 先找到第一個有數值的點
      int firstIdx = fatigueValues.indexWhere((v) => v > 0);
      if (firstIdx != -1) {
        double x0 = gridWidth * firstIdx + gridWidth / 2;
        double y0 = size.height - (fatigueValues[firstIdx] / 10) * size.height;
        smoothPath.moveTo(x0, y0);
        for (int i = firstIdx + 1; i < 24; i++) {
          double x = gridWidth * i + gridWidth / 2;
          double y = size.height - (fatigueValues[i] / 10) * size.height;
          // 用中點法平滑
          double prevX = gridWidth * (i - 1) + gridWidth / 2;
          double prevY = size.height - (fatigueValues[i - 1] / 10) * size.height;
          double midX = (prevX + x) / 2;
          double midY = (prevY + y) / 2;
          smoothPath.quadraticBezierTo(prevX, prevY, midX, midY);
        }
        // 最後一段直接連到最後一點
        double lastX = gridWidth * 23 + gridWidth / 2;
        double lastY = size.height - (fatigueValues[23] / 10) * size.height;
        smoothPath.lineTo(lastX, lastY);
        canvas.drawPath(smoothPath, smoothPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
