// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/main_pages/HomePage/homepage.dart';
import 'dart:convert';

import 'package:monarch/other_pages/enviroment.dart';

class AutoSyncEmailsScreen extends StatefulWidget {
  final String accessToken;
  final String userId; // userId now required by backend

  const AutoSyncEmailsScreen({
    super.key,
    required this.accessToken,
    required this.userId,
  });

  @override
  State<AutoSyncEmailsScreen> createState() => _AutoSyncEmailsScreenState();
}

class _AutoSyncEmailsScreenState extends State<AutoSyncEmailsScreen> {
  bool _loading = false;
  String? _status;
  int _syncedCount = 0;

  @override
  void initState() {
    super.initState();
    _autoSyncEmails();
  }

  Future<void> _autoSyncEmails() async {
    setState(() {
      _loading = true;
      _status = "Syncing your bank emails...";
      _syncedCount = 0;
    });

    try {
      final response = await http.post(
        Uri.parse("${Environment.baseUrl}/api/sync-gmail"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "accessToken": widget.accessToken,
          "userId": widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['count'] != null) {
          setState(() {
            _loading = false;
            _syncedCount = data['count'];
            _status = "✅ Synced $_syncedCount transactions successfully!";
          });

          // Optional: navigate back or to another screen after a delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FinTrackHomePage()),
            );
          });
        } else {
          setState(() {
            _loading = false;
            _status = "❌ Sync failed: Unexpected response format";
          });
        }
      } else {
        setState(() {
          _loading = false;
          _status = "❌ Backend error: ${response.body}";
        });
      }
    } catch (error) {
      setState(() {
        _loading = false;
        _status = "⚠️ Network or unexpected error: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auto Sync Emails")),
      body: Center(
        child:
            _loading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(_status ?? "Processing..."),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _status ?? "Done",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      onPressed: _autoSyncEmails,
                    ),
                  ],
                ),
      ),
    );
  }
}
