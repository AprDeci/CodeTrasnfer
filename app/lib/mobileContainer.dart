import 'package:flutter/material.dart';

class MobileContainer extends StatelessWidget {
  const MobileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Transfer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: const Center(child: Text('Mobile Container'))),
    );
  }
}
