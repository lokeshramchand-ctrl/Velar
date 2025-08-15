// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../other_pages/enviroment.dart';

Future<List<Map<String, dynamic>>> fetchRecentTransactions() async {
  try {
    // 1️⃣ Get userId from local storage
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      print('❌ User ID not found — please log in again.');
      return [];
    }

    // 2️⃣ Create URI with userId
    final uri = Uri.parse(
      '${Environment.baseUrl}/api/transactions/recent',
    ).replace(queryParameters: {'userId': userId});

    // 3️⃣ Make API request
    final response = await http.get(uri);

    print('📡 Fetching recent transactions from: $uri');
    print('Status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('❌ Failed to load recent transactions: ${response.body}');
      return [];
    }
  } catch (e) {
    print('⚠ Error fetching recent transactions: $e');
    return [];
  }
}
