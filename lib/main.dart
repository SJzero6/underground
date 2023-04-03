import 'package:flutter/material.dart';
import 'package:underground/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Dot(radius: 30, color: Colors.white));
  }
}
