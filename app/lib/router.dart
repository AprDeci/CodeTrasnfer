import 'package:code_transfer/bloc/cubit/counter_cubit.dart';
import 'package:code_transfer/bloc/discovery/discovery_bloc.dart';
import 'package:code_transfer/bloc/server/server_bloc.dart';
import 'package:code_transfer/bloc/sync/sync_bloc.dart';
import 'package:code_transfer/core/core_repository.dart';
import 'package:code_transfer/page/homePage.dart';
import 'package:code_transfer/page/settingPage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:code_transfer/page/counterPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => RepositoryProvider(
        create: (context) => CoreRepository(),
        dispose: (repository) {
          repository.dispose();
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => DiscoveryBloc(
                context.read<CoreRepository>(),
              )..add(const DiscoveryStarted()),
            ),
            BlocProvider(
              create: (context) =>
                  ServerBloc(context.read<CoreRepository>())..add(
                    const ServerStarted(),
                  ),
            ),
            BlocProvider(
              create: (context) => SyncBloc(context.read<CoreRepository>()),
            ),
          ],
          child: const HomePage(),
        ),
      ),
      routes: [
        GoRoute(
          path: '/counter',
          builder: (context, state) => BlocProvider(
            create: (context) => CounterCubit(),
            child: const CounterPage(),
          ),
        ),
        GoRoute(path: '/setting',
        builder: (context, state) => const SettingPage())
      ],
    ),
    GoRoute(
      path: '/business',
      builder: (context, state) => const Center(
        child: Text('Business'),
      ),
    ),
    GoRoute(
      path: '/school',
      builder: (context, state) => const Center(
        child: Text('School'),
      ),
    ),
  ],
);
