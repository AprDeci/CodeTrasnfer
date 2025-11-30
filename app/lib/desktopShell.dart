// windowContainer.dart  （全新替换你原来的内容）
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DesktopShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DesktopShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              // 关键：用 goBranch 切换分支，不会丢失每个 tab 的导航栈
              navigationShell.goBranch(
                index,
                // 第一次点这个 tab 时才跳到初始页面，防止已经 push 了很多层时被重置
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Business'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                label: Text('School'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // 内容区：自动显示当前分支的页面
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
