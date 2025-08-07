// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/other_pages/enviroment.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechInputPage extends StatefulWidget {
  const SpeechInputPage({super.key});

  @override
  State<SpeechInputPage> createState() => _SpeechInputPageState();
}

class _SpeechInputPageState extends State<SpeechInputPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) async {
          print('Status: $val');
          if (val == 'done') {
            setState(() => _isListening = false);
            await _speech.stop();
            if (_spokenText.isNotEmpty) {
              _sendToBackend();
            }
          }
        },
        onError: (val) => print('Error: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _spokenText = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _sendToBackend() async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.baseUrl}/api/transactions/voice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'voiceInput': _spokenText}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final transactionData = responseData['data'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmTransactionPage(data: transactionData),
          ),
        );
      } else {
        throw Exception('❌ Failed to process transaction');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add via Voice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _spokenText.isEmpty ? '🎤 Say something...' : _spokenText,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _listen,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmTransactionPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ConfirmTransactionPage({super.key, required this.data});

  Future<void> _saveTransaction(BuildContext context) async {
    const String saveUrl =
        '${Environment.baseUrl}/api/transaction/add'; // Same backend save route

    try {
      final response = await http.post(
        Uri.parse(saveUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': data['description'],
          'amount': data['amount'],
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Transaction Saved!')));
        Navigator.popUntil(
          context,
          (route) => route.isFirst,
        ); // go back to home
      } else {
        throw Exception('❌ Save failed');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = data['amount'];
    final description = data['description'];
    final category = data['category'];

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "💬 Description: $description",
              style: const TextStyle(fontSize: 18),
            ),
            Text("💰 Amount: ₹$amount", style: const TextStyle(fontSize: 18)),
            Text(
              "📂 Category: $category",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Confirm & Save'),
              onPressed: () => _saveTransaction(context),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Edit or Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
