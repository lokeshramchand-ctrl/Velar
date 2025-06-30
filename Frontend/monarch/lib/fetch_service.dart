// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchRecentTransactions() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.9:3000/api/transactions/recent'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['data'];
    return List<Map<String, dynamic>>.from(data);
  } else {
    print('Failed to load recent transactions');
    return [];
  }
}
