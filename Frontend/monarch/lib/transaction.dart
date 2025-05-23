// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Transaction {
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Transaction({
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Transaction> transactions = [];
  bool isLoading = false;

  final List<String> categories = [
    'All',
    'Food',
    'Shopping',
    'Bills',
    'Travel',
    'Entertainment',
    'Other',
  ];

  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions({String category = 'All'}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse(
        'http://192.168.172.140:3000/api/transactions',
      ).replace(
        queryParameters: category == 'All' ? null : {'category': category},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['data'];

        setState(() {
          transactions =
              list.map((json) => Transaction.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading transactions: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children:
            categories.map((cat) {
              final bool isSelected = cat == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFF00221F),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedCategory = cat;
                      });
                      fetchTransactions(category: cat);
                    }
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildTransactionCard(Transaction tx) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00221F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        title: Text(
          tx.description,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${tx.category} • ${tx.date.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          '₹${tx.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFFFABF02),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001815),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00221F),
        title: const Text('Transactions'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          buildCategoryChips(),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : transactions.isEmpty
                    ? const Center(
                      child: Text(
                        'No transactions found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder:
                          (context, index) =>
                              buildTransactionCard(transactions[index]),
                    ),
          ),
        ],
      ),
    );
  }
}
