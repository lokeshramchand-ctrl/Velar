// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/testing_pages/speech.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/other_pages/enviroment.dart';

extension ResponsiveExtension on BuildContext {
  double responsiveWidth(double size) {
    return size * (MediaQuery.of(this).size.width / 375);
  }

  double responsiveHeight(double size) {
    return size * (MediaQuery.of(this).size.height / 812);
  }

  double responsiveText(double size) {
    final width = MediaQuery.of(this).size.width;
    if (width < 350) return size * 0.9;
    if (width > 600) return size * 1.2;
    return size;
  }
}

class VoiceTransactionDialog extends StatefulWidget {
  const VoiceTransactionDialog({super.key});

  @override
  _VoiceTransactionDialogState createState() => _VoiceTransactionDialogState();
}

class _VoiceTransactionDialogState extends State<VoiceTransactionDialog>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';
  bool _processing = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Initialize animation controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initialize animations
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start initial animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
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
            _waveController.stop();
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
            isError: true,
          );
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _spokenText = '';
        });

        _pulseController.repeat(reverse: true);
        _waveController.repeat();

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
      _waveController.stop();
      _speech.stop();
    }
  }

  Future<void> _sendToBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      final response = await http.post(
        Uri.parse('${Environment.baseUrl}/api/transactions/voice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'voiceInput': _spokenText}),
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
      } else {
        throw Exception('Save failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _showCustomSnackBar(message: 'Error: ${e.toString()}', isError: true);
    }
  }

  void _showCustomSnackBar({required String message, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: context.responsiveWidth(20),
            ),
            SizedBox(width: context.responsiveWidth(12)),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: context.responsiveText(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFFF6B6B) : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveWidth(16)),
        ),
        margin: EdgeInsets.all(context.responsiveWidth(16)),
      ),
    );
  }

  Widget _buildWaveIndicator() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final delay = index * 0.2;
            final animValue = (_waveAnimation.value - delay).clamp(0.0, 1.0);
            final height = 4 + (animValue * 20);

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: context.responsiveWidth(2),
              ),
              width: context.responsiveWidth(4),
              height: context.responsiveHeight(height),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(context.responsiveWidth(2)),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: context.responsiveHeight(680),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.responsiveWidth(32)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: context.responsiveWidth(40),
                    offset: Offset(0, -context.responsiveHeight(8)),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle Bar
                  Container(
                    width: context.responsiveWidth(48),
                    height: context.responsiveHeight(4),
                    margin: EdgeInsets.only(
                      top: context.responsiveHeight(20),
                      bottom: context.responsiveHeight(8),
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        context.responsiveWidth(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.responsiveWidth(24),
                      context.responsiveHeight(20),
                      context.responsiveWidth(24),
                      context.responsiveHeight(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: context.responsiveWidth(56),
                          height: context.responsiveWidth(56),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveWidth(18),
                            ),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.mic_outlined,
                            color: accentColor,
                            size: context.responsiveWidth(28),
                          ),
                        ),
                        SizedBox(width: context.responsiveWidth(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voice Transaction',
                                style: GoogleFonts.inter(
                                  color: primaryColor,
                                  fontSize: context.responsiveText(22),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: context.responsiveHeight(6)),
                              Text(
                                'Speak naturally to record your transaction',
                                style: GoogleFonts.inter(
                                  color: primaryColor.withOpacity(0.65),
                                  fontSize: context.responsiveText(14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveWidth(24),
                        vertical: context.responsiveHeight(8),
                      ),
                      child: Column(
                        children: [
                          // Voice Input Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                              context.responsiveWidth(24),
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  _isListening
                                      ? LinearGradient(
                                        colors: [
                                          accentColor.withOpacity(0.05),
                                          accentColor.withOpacity(0.12),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                      : LinearGradient(
                                        colors: [
                                          backgroundColor,
                                          backgroundColor.withOpacity(0.8),
                                        ],
                                      ),
                              borderRadius: BorderRadius.circular(
                                context.responsiveWidth(24),
                              ),
                              border: Border.all(
                                color:
                                    _isListening
                                        ? accentColor.withOpacity(0.3)
                                        : primaryColor.withOpacity(0.08),
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
                                      scale:
                                          _isListening
                                              ? _pulseAnimation.value
                                              : 1.0,
                                      child: GestureDetector(
                                        onTap: _processing ? null : _listen,
                                        child: Container(
                                          width: context.responsiveWidth(96),
                                          height: context.responsiveWidth(96),
                                          decoration: BoxDecoration(
                                            gradient:
                                                _isListening
                                                    ? RadialGradient(
                                                      colors: [
                                                        accentColor.withOpacity(
                                                          0.2,
                                                        ),
                                                        accentColor.withOpacity(
                                                          0.05,
                                                        ),
                                                      ],
                                                    )
                                                    : RadialGradient(
                                                      colors: [
                                                        primaryColor
                                                            .withOpacity(0.08),
                                                        primaryColor
                                                            .withOpacity(0.02),
                                                      ],
                                                    ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  _isListening
                                                      ? accentColor.withOpacity(
                                                        0.4,
                                                      )
                                                      : primaryColor
                                                          .withOpacity(0.2),
                                              width: 2.5,
                                            ),
                                            boxShadow:
                                                _isListening
                                                    ? [
                                                      BoxShadow(
                                                        color: accentColor
                                                            .withOpacity(0.3),
                                                        blurRadius: context
                                                            .responsiveWidth(
                                                              24,
                                                            ),
                                                        spreadRadius: 0,
                                                      ),
                                                    ]
                                                    : [
                                                      BoxShadow(
                                                        color: primaryColor
                                                            .withOpacity(0.1),
                                                        blurRadius: context
                                                            .responsiveWidth(
                                                              12,
                                                            ),
                                                        offset: Offset(
                                                          0,
                                                          context
                                                              .responsiveHeight(
                                                                4,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                          ),
                                          child:
                                              _processing
                                                  ? SizedBox(
                                                    width: context
                                                        .responsiveWidth(32),
                                                    height: context
                                                        .responsiveWidth(32),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(accentColor),
                                                    ),
                                                  )
                                                  : Icon(
                                                    _isListening
                                                        ? Icons.mic
                                                        : Icons.mic_none,
                                                    size: context
                                                        .responsiveWidth(42),
                                                    color:
                                                        _isListening
                                                            ? accentColor
                                                            : primaryColor
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                  ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: context.responsiveHeight(20)),

                                // Wave Indicator (only when listening)
                                if (_isListening) ...[
                                  _buildWaveIndicator(),
                                  SizedBox(
                                    height: context.responsiveHeight(16),
                                  ),
                                ],

                                // Status Text
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _processing
                                        ? 'Processing your request...'
                                        : _isListening
                                        ? 'Listening... Tap to stop'
                                        : 'Tap microphone to start recording',
                                    key: ValueKey(
                                      _processing
                                          ? 'processing'
                                          : _isListening
                                          ? 'listening'
                                          : 'idle',
                                    ),
                                    style: GoogleFonts.inter(
                                      color:
                                          _isListening || _processing
                                              ? accentColor
                                              : primaryColor.withOpacity(0.7),
                                      fontSize: context.responsiveText(16),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: context.responsiveHeight(24)),

                          // Transcript Display
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            height: _spokenText.isNotEmpty ? null : 0,
                            child:
                                _spokenText.isNotEmpty
                                    ? Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(
                                        context.responsiveWidth(20),
                                      ),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(
                                          context.responsiveWidth(20),
                                        ),
                                        border: Border.all(
                                          color: accentColor.withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentColor.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: context.responsiveWidth(
                                              16,
                                            ),
                                            offset: Offset(
                                              0,
                                              context.responsiveHeight(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.transcribe_outlined,
                                                color: accentColor,
                                                size: context.responsiveWidth(
                                                  18,
                                                ),
                                              ),
                                              SizedBox(
                                                width: context.responsiveWidth(
                                                  8,
                                                ),
                                              ),
                                              Text(
                                                'Transcript',
                                                style: GoogleFonts.inter(
                                                  color: accentColor,
                                                  fontSize: context
                                                      .responsiveText(13),
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: context.responsiveHeight(
                                              12,
                                            ),
                                          ),
                                          Text(
                                            _spokenText,
                                            style: GoogleFonts.inter(
                                              color: primaryColor,
                                              fontSize: context.responsiveText(
                                                15,
                                              ),
                                              fontWeight: FontWeight.w500,
                                              height: 1.5,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),

                          SizedBox(height: context.responsiveHeight(32)),

                          // Close Button
                          Container(
                            width: double.infinity,
                            height: context.responsiveHeight(56),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.06),
                                  primaryColor.withOpacity(0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                context.responsiveWidth(16),
                              ),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                context.responsiveWidth(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  context.responsiveWidth(16),
                                ),
                                onTap: () => Navigator.pop(context),
                                child: Center(
                                  child: Text(
                                    'Close',
                                    style: GoogleFonts.inter(
                                      color: primaryColor.withOpacity(0.8),
                                      fontSize: context.responsiveText(16),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: context.responsiveHeight(20)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
