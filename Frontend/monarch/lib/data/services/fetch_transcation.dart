// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:monarch/data/models/transcation.dart';
import 'package:monarch/utils/custom_snack_bar.dart';

class TransactionApi {
  static List<Transaction> transactions = [];
  static Map<String, double> totalAmountPerCategory = {};
  static bool isLoading = false;

  static Future<void> fetchTransactions({String category = 'All', required BuildContext context}) async {
    isLoading = true;
    try {
      final uri = Uri.parse('http://192.168.1.9:3000/api/transactions').replace(
        queryParameters: category == 'All' ? null : {'category': category},
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['data'];
        final fetched = list.map((json) => Transaction.fromJson(json)).toList();
        final totals = <String, double>{};
        for (var tx in fetched) {
          totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
        }
        transactions = fetched;
        totalAmountPerCategory = totals;
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'Error fetching transactions',
        icon: Icons.data_exploration_rounded,
        backgroundColor: const Color(0xFFFF9F43),
        iconColor: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading = false;
    }
  }
}
