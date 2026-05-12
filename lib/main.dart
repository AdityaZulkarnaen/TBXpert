import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const TBXpertApp());
}

class TBXpertApp extends StatelessWidget {
  const TBXpertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBXpert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}
