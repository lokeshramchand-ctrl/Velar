import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:monarch/other_pages/enviroment.dart';

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
      final uri = Uri.parse("${Environment.baseUrl}/api/sync-gmail");

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
        title: const Text("Bank Transactions"),
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
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      leading: Icon(
                        email['type'] == 'debit'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color:
                            email['type'] == 'debit'
                                ? Colors.red
                                : Colors.green,
                      ),
                      title: Text(
                        "₹${(email['amount'] is num) ? (email['amount'] as num).toStringAsFixed(2) : email['amount'] ?? '---'}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (email['vendor'] ?? "Unknown Vendor")
                                .replaceAll(
                                  RegExp(
                                    r'[a-z0-9._%+-]+@[a-z0-9.-]+',
                                    caseSensitive: false,
                                  ),
                                  '',
                                )
                                .trim(),
                          ),
                          Text(
                            "Date: ${email['date'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Text(
                        email['type']?.toUpperCase() ?? "",
                        style: TextStyle(
                          color:
                              email['type'] == 'debit'
                                  ? Colors.red
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
