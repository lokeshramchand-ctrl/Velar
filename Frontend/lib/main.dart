// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/login.dart';
import 'package:monarch/speech.dart';
import 'package:monarch/support/add.dart';
import 'package:monarch/main_pages/Statistics/update_budget.dart';
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

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final baseUrl = dotenv.env['BASE_URL'];

  Future<void> addTransaction() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/transaction/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'description': descriptionController.text,
          'amount': double.tryParse(amountController.text),
        }),
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final predictedCategory = responseData['data']['category'];

        // Clear the input fields
        descriptionController.clear();
        amountController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Transaction added and categorized as: $predictedCategory',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add transaction: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Statistics()),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: addTransaction, child: Text('Submit')),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Statistics()),
                );
              },
              child: const Text('NextPage'),
            ),
          ],
        ),
      ),
    );
  }
}
