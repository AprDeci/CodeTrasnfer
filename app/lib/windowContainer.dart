import 'package:flutter/material.dart';

class WindowContainer extends StatelessWidget {
  const WindowContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Transfer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: const Center(child: Text('Window Container'))),
    );
  }
}
