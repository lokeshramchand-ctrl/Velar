// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/speech.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/other_pages/enviroment.dart';

class VoiceTransactionDialog extends StatefulWidget {
  const VoiceTransactionDialog({super.key});

  @override
  _VoiceTransactionDialogState createState() => _VoiceTransactionDialogState();
}

class _VoiceTransactionDialogState extends State<VoiceTransactionDialog>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';
  bool _processing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) async {
          if (val == 'done') {
            setState(() {
              _isListening = false;
              _processing = true;
            });
            _pulseController.stop();
            await _speech.stop();
            if (_spokenText.isNotEmpty) {
              await _sendToBackend();
            }
            setState(() {
              _processing = false;
            });
          }
        },
        onError: (val) {
          _showCustomSnackBar(
            message: 'Speech recognition error: $val',
            icon: Icons.mic_off,
            backgroundColor: const Color(0xFFFF6B6B),
            iconColor: Colors.white,
            duration: const Duration(seconds: 3),
          );
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _spokenText = '';
        });
        _pulseController.repeat(reverse: true);

        _speech.listen(
          onResult: (val) {
            setState(() {
              _spokenText = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _processing = true;
      });
      _pulseController.stop();
      _speech.stop();
    }
  }

  Future<void> _sendToBackend() async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.baseUrl}/api/transactions/voice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'voiceInput': _spokenText}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final transactionData = responseData['data'];

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmTransactionPage(data: transactionData),
          ),
        );

        _showCustomSnackBar(
          message: 'Transaction processed successfully!',
          icon: Icons.check_circle,
          backgroundColor: const Color(0xFF4CAF50),
          iconColor: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Failed to process transaction');
      }
    } catch (e) {
      _showCustomSnackBar(
        message: 'Error processing transaction: ${e.toString()}',
        icon: Icons.error_outline,
        backgroundColor: const Color(0xFFFF6B6B),
        iconColor: Colors.white,
        duration: const Duration(seconds: 4),
      );
      setState(() {
        _processing = false;
      });
    }
  }

  void _showCustomSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Reduced height
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              16,
              24,
              16,
            ), // Added bottom padding
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(Icons.mic_outlined, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice Transaction',
                        style: GoogleFonts.inter(
                          color: primaryColor,
                          fontSize: 20, // Reduced font size
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4), // Added spacing
                      Text(
                        'Speak naturally to record your transaction',
                        style: GoogleFonts.inter(
                          color: primaryColor.withOpacity(0.6),
                          fontSize: 12, // Reduced font size
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content with SingleChildScrollView to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          _isListening
                              ? accentColor.withOpacity(0.08)
                              : backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            _isListening
                                ? accentColor.withOpacity(0.2)
                                : primaryColor.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Microphone Button
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isListening ? _pulseAnimation.value : 1.0,
                              child: GestureDetector(
                                onTap: _processing ? null : _listen,
                                child: Container(
                                  width: 80, // Reduced size
                                  height: 80, // Reduced size
                                  decoration: BoxDecoration(
                                    color:
                                        _isListening
                                            ? accentColor.withOpacity(0.15)
                                            : primaryColor.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          _isListening
                                              ? accentColor.withOpacity(0.4)
                                              : primaryColor.withOpacity(0.15),
                                      width: 2.5,
                                    ),
                                    boxShadow:
                                        _isListening
                                            ? [
                                              BoxShadow(
                                                color: accentColor.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 20,
                                                spreadRadius: 0,
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child:
                                      _processing
                                          ? const CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.blue,
                                                ),
                                          )
                                          : Icon(
                                            _isListening
                                                ? Icons.mic
                                                : Icons.mic_none,
                                            size: 36, // Reduced size
                                            color:
                                                _isListening
                                                    ? accentColor
                                                    : primaryColor.withOpacity(
                                                      0.6,
                                                    ),
                                          ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16), // Reduced spacing
                        // Status Text
                        Text(
                          _processing
                              ? 'Processing your request...'
                              : _isListening
                              ? 'Listening... Tap to stop'
                              : 'Tap microphone to start recording',
                          style: GoogleFonts.inter(
                            color:
                                _isListening || _processing
                                    ? accentColor
                                    : primaryColor.withOpacity(0.7),
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20), // Reduced spacing
                  // Spoken Text Display
                  if (_spokenText.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16), // Reduced padding
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Reduced radius
                        border: Border.all(
                          color: accentColor.withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.05),
                            blurRadius: 8, // Reduced blur
                            offset: const Offset(0, 2), // Reduced offset
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.email, color: accentColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Transcript',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _spokenText,
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: 14, // Reduced font size
                              fontWeight: FontWeight.w500,
                              height: 1.4, // Reduced line height
                            ),
                            maxLines: 5, // Limit lines
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // Reduced spacing
                  ],

                  // Action Button
                  Container(
                    width: double.infinity,
                    height: 50, // Reduced height
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12), // Reduced radius
                      border: Border.all(
                        color: primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: Center(
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              color: primaryColor.withOpacity(0.8),
                              fontSize: 14, // Reduced font size
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16), // Added bottom spacing for safety
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
