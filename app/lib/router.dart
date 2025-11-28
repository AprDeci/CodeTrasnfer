import 'package:go_router/go_router.dart';
import 'package:code_transfer/page/counterPage.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const CounterPage()),
  ],
);
