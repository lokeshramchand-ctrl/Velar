// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/colors.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> recentTransactions;

  const RecentTransactionsWidget({super.key, required this.recentTransactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: GoogleFonts.inter(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: recentTransactions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No recent transactions.');
              } else {
                return Column(
                  children: snapshot.data!.map(
                    (transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.shopping_bag, // You can customize based on category
                              color: accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction['description'] ?? '',
                                  style: GoogleFonts.inter(
                                    color: primaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${transaction['category']} • ${DateTime.parse(transaction['date']).toLocal().toString().split(' ')[0]}',
                                  style: GoogleFonts.inter(
                                    color: textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${transaction['amount'].toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              color: transaction['amount'] >= 0 ? accentColor : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
