import 'package:code_transfer/bloc/cubit/counter_cubit.dart';
import 'package:code_transfer/desktopShell.dart';
import 'package:code_transfer/page/homePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:code_transfer/page/counterPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, child) {
        return DesktopShell(navigationShell: child);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => new HomePage(),
              routes: [
                GoRoute(
                  path: 'counter',
                  builder: (context, state) => BlocProvider(
                    create: (context) => CounterCubit(),
                    child: const CounterPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/business',
              builder: (context, state) => const Center(
                child: Text('Business'),
              ),
              routes: [
                GoRoute(
                  path: 'counter',
                  builder: (context, state) => BlocProvider(
                    create: (context) => CounterCubit(),
                    child: const CounterPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/school',
              builder: (context, state) => const Center(
                child: Text('School'),
              ),
              routes: [
                GoRoute(
                  path: 'counter',
                  builder: (context, state) => BlocProvider(
                    create: (context) => CounterCubit(),
                    child: const CounterPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
