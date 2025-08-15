// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/other_pages/enviroment.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monarch/main_pages/HomePage/homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GoogleSignIn instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId: '${Environment.serverClientId}',
  );

  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // Step 1: Trigger the sign-in flow
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // User cancelled
        setState(() => _isLoading = false);
        return;
      }

      // Step 2: Get authentication tokens
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        debugPrint("❌ Failed to get ID token");
        return;
      }

      // Step 3: Send token to backend
      final uri = Uri.parse("http://192.168.1.10:3000/auth/google/token");
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          debugPrint("✅ User logged in: ${data['user']}");
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', data['user']['_id']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FinTrackHomePage()),
          );
        } else {
          debugPrint("❌ Login failed: ${data['error']}");
        }
      } else {
        debugPrint("❌ Backend error: ${res.body}");
      }
    } catch (e) {
      debugPrint("⚠ Google Sign-In error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),

                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: _handleGoogleSignIn,
                ),
      ),
    );
  }
}
