import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Guard',
      home: Scaffold(
        backgroundColor: Color(0xFF0D0D1A),
        body: Center(
          child: Text(
            '🔐 Security Guard',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
