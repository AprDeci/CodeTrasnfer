import 'package:code_transfer/desktopShell.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:code_transfer/page/counterPage.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, child) {
        return DesktopShell(navigationShell: child);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Text('Home'),
            ),
          ],
        ),
      ],
    ),
  ],
);
