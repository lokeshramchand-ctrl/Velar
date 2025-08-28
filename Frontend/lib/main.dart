// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/login.dart';
import 'package:monarch/testing_pages/speech.dart';
import 'package:monarch/support/add.dart';
import 'package:monarch/main_pages/Statistics/Budget/update_budget.dart';
import 'package:monarch/main_pages/HomePage/homepage.dart';
import 'package:monarch/main_pages/Statistics/statistics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),

      // home: const SpeechInputPage(),
    );
  }
}
