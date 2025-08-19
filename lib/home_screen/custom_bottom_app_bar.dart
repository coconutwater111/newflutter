import 'package:flutter/material.dart';
import 'package:data_transmit/fatigue/pages/flchart_fristpage.dart';

class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar({
    this.fabLocation = FloatingActionButtonLocation.endDocked,
    this.shape = const CircularNotchedRectangle(),
    this.color = Colors.blue, // 預設顏色
    super.key,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final Color color; // 新增

  static final List<FloatingActionButtonLocation> centerLocations = [
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: shape,
      // color: Colors.blue.shade50,        // ✅ 如果有背景色，統一使用系統色
      elevation: 8,
      child: IconTheme(
        data: IconThemeData(color: Colors.black), // 使用傳入顏色的黑色版本
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              tooltip: 'Open navigation menu',
              icon: const Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('首頁'),
                        onTap: () {
                          Navigator.pop(context); // 關閉 bottom sheet
                          Navigator.of(context).popUntil((route) => route.isFirst); // 回到首頁
                          // 不要再用 Future.delayed + context
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('設定'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.show_chart),
                        title: const Text('疲勞度繪圖'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Flchartfristpage(),
                            ),
                          );
                        },
                      ),
                      // 可以繼續加入更多選單項目
                    ],
                  ),
                );
              },
            ),
            /*if (centerLocations.contains(fabLocation)) const Spacer(),
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Favorite',
              icon: const Icon(Icons.favorite),
              onPressed: () {},
            ),*/
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.blue.shade600,   // ✅ 統一圖標顏色
              ),
              onPressed: () {
                // 導航邏輯
              },
            ),
          ],
        ),
      ),
    );
  }
}
