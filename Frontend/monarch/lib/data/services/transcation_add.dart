// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:monarch/utils/overall_colors.dart';
import 'package:monarch/utils/custom_snack_bar.dart';

class TransactionApi {
  static Future<void> addTransaction(
    BuildContext context,
    String description,
    String amount,
    Function onSuccess,
    Function onFailure,
  ) async {
    // Validation first
    if (description.trim().isEmpty || amount.trim().isEmpty) {
      showCustomSnackBar(
        context: context,
        message: 'Please fill in both name and amount',
        icon: Icons.warning_rounded,
        backgroundColor: const Color(0xFFFF6B6B),
        iconColor: Colors.white,
      );
      return;
    }

    // Show beautiful loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Processing transaction...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.9:3000/api/transaction/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'description': description,
          'amount': double.tryParse(amount),
        }),
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final predictedCategory = responseData['data']['category'];

        // Clear the input fields
        onSuccess();

        // Show success message
        showCustomSnackBar(
          context: context,
          message:
              'Transaction added successfully!\nCategorized as: $predictedCategory',
          icon: Icons.check_circle_rounded,
          backgroundColor: accentColor,
          iconColor: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate back to statistics page after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.of(context).pop(); // Go back to previous screen
          }
        });
      } else {
        onFailure();
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      onFailure();
    }
  }
}
