import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailsScreen extends StatefulWidget {
  final String accessToken;
  final String userId;

  const EmailsScreen({
    super.key,
    required this.accessToken,
    required this.userId,
  });

  @override
  State<EmailsScreen> createState() => _EmailsScreenState();
}

class _EmailsScreenState extends State<EmailsScreen> {
  List<dynamic> _emails = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchEmails();
  }

  Future<void> fetchEmails() async {
    try {
      final uri = Uri.parse("http://192.168.1.10:3000/api/sync-gmail");

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"accessToken": widget.accessToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _emails = data['emails'] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Backend error: ${res.body}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "⚠ Error fetching emails: $e";
        _loading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Emails"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchEmails),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _emails.isEmpty
              ? const Center(child: Text("No bank-related emails found."))
              : ListView.builder(
                itemCount: _emails.length,
                itemBuilder: (context, index) {
                  final email = _emails[index];
                  return ListTile(
                    title: Text(email['subject'] ?? "No subject"),
                    subtitle: Text(email['snippet'] ?? ""),
                    leading: const Icon(Icons.email),
                  );
                },
              ),
    );
  }
}
