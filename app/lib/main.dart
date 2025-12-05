import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:code_transfer/desktopShell.dart';
import 'package:code_transfer/router.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      primarySwatch: Colors.blue,
      textTheme: const TextTheme().useSystemChineseFont(Brightness.light),
    );

    return MaterialApp.router(
      title: 'Code Transfer',
      theme: theme,
      routerConfig: router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return DesktopShell(child: content);
      },
    );
  }
}
