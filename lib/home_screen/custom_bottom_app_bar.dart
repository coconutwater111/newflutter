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
              onPressed: () async {
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

                final selected = await showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx,
                    position.dy - 8, // 微調讓選單貼齊 BottomAppBar 上方
                    position.dx + button.size.width,
                    position.dy + button.size.height,
                  ),
                  items: [
                    PopupMenuItem(
                      value: 'settings',
                      child: ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('設定'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'chart',
                      child: ListTile(
                        leading: const Icon(Icons.show_chart),
                        title: const Text('疲勞度繪圖'),
                      ),
                    ),
                  ],
                );

                if (!context.mounted) return;

                if (selected == 'settings') {
                  // 處理設定
                } else if (selected == 'chart') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Flchartfristpage(),
                    ),
                  );
                }
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
                color: Colors.blue.shade600, // ✅ 統一圖標顏色
              ),
              onPressed: () {
                Navigator.of(
                  context,
                ).popUntil((route) => route.isFirst); // 回到首頁
              },
            ),
          ],
        ),
      ),
    );
  }
}
