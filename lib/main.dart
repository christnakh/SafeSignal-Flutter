import 'package:flutter/material.dart';
import 'package:senior_proj/login_page.dart';
import 'package:senior_proj/register_page.dart';
import 'package:senior_proj/user_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: RegisterPage());
  }
}
