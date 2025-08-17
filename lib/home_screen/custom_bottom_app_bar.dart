import 'package:flutter/material.dart';

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
                  builder:
                      (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.home),
                            title: const Text('首頁'),
                            onTap: () {
                              Navigator.pop(context); // 關閉 bottom sheet
                              Navigator.of(context).popUntil((route) => route.isFirst); // 回到首頁（CalendarScreen）
                              /*showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (dialogContext) => Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(
                                          (0.7 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      '首頁被點擊了',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ),
                              );*/
                              Future.delayed(const Duration(seconds: 1), () {
                                // 用 dialogContext 判斷是否還能 pop
                                // ignore: use_build_context_synchronously
                                if (Navigator.canPop(context)) {
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context, rootNavigator: true).pop();
                                }
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text('設定'),
                            onTap: () {
                              // 點擊後的動作
                              Navigator.pop(context);
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
