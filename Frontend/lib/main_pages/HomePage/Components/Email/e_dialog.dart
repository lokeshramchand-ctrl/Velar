// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/main_pages/HomePage/homepage.dart';
import 'dart:convert';

import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/other_pages/enviroment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailTransactionDialog extends StatefulWidget {
  const EmailTransactionDialog({super.key});

  @override
  State<EmailTransactionDialog> createState() => _EmailTransactionDialogState();
}

class _EmailTransactionDialogState extends State<EmailTransactionDialog> {
  final List<dynamic> _emails = [];
  bool _loading = true;
  String? _status;
  int _syncedCount = 0;
  String? _error;
  String? _userId;
  String? _accessToken;
  @override
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
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final accessToken = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse("${Environment.baseUrl}/api/sync-gmail"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"accessToken": accessToken, "userId": userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['count'] != null) {
          setState(() {
            _loading = false;
            _syncedCount = data['count'];
            _status = "✅ Synced $_syncedCount transactions successfully!";
          });

          // // Optional: navigate back or to another screen after a delay
          // Future.delayed(const Duration(seconds: 2), () {
          //   Navigator.pushReplacement(
          //     context,
          // //     MaterialPageRoute(builder: (_) => const FinTrackHomePage()),
          //  );
          // });
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top drag handle
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(top: 16, bottom: 24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.mail_outline, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Transactions',
                      style: GoogleFonts.inter(
                        color: primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Forward receipts to auto-add transactions',
                      style: GoogleFonts.inter(
                        color: primaryColor.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh, color: accentColor),
                  onPressed: _autoSyncEmails,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Body (loading / error / empty / list)
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    : _emails.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: primaryColor.withOpacity(0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No transactions found",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Forward your receipts to see them here.",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: primaryColor.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: _emails.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            color: primaryColor.withOpacity(0.1),
                          ),
                      itemBuilder: (context, index) {
                        final email = _emails[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: accentColor,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            email['subject'] ?? "No Subject",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            email['snippet'] ?? "No details available",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: primaryColor.withOpacity(0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: primaryColor.withOpacity(0.4),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
