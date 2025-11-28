import 'package:code_transfer/rust/frb_generated.dart';
import 'package:code_transfer/router.dart';
import 'package:flutter/material.dart';

void main() {
  RustLib.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
