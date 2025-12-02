import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:code_transfer/mobileContainer.dart';
import 'package:code_transfer/page/homePage.dart';
// import 'package:code_transfer/rust/frb_generated.dart';
import 'package:code_transfer/router.dart';
import 'package:code_transfer/rust/frb_generated.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return UniversalPlatform.isDesktop || UniversalPlatform.isWeb
        ? MaterialApp.router(
            title: 'Code Transfer',
            theme: ThemeData(primarySwatch: Colors.blue,
              textTheme: const TextTheme().useSystemChineseFont(Brightness.light)),
            routerConfig: router, // ← 重点！！！
          )
        : const HomePage();
  }
}
