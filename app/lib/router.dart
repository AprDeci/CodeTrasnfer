import 'package:code_transfer/bloc/cubit/counter_cubit.dart';
import 'package:code_transfer/desktopShell.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:code_transfer/page/counterPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            GoRoute(path: '/', builder: (context, state) => Text('Home')),
            GoRoute(
              path: '/counter',
              builder: (context, state) => BlocProvider(
                create: (context) => CounterCubit(),
                child: CounterPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/business',
              builder: (context, state) => Text('Business'),
            ),
            GoRoute(
              path: '/business/counter',
              builder: (context, state) => BlocProvider(
                create: (context) => CounterCubit(),
                child: CounterPage(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
