import 'package:code_transfer/mobileContainer.dart';
// import 'package:code_transfer/rust/frb_generated.dart';
import 'package:code_transfer/router.dart';
import 'package:code_transfer/windowContainer.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

void main() {
  // RustLib.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Transfer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UniversalPlatform.isMobile ? MobileContainer() : WindowContainer(),
    );
  }
}
