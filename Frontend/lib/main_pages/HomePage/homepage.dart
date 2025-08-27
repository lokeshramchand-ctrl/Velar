// ignore_for_file: deprecated_member_use, unused_local_variable, use_super_parameters, avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/main_pages/HomePage/navbar.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/support/fetch_service.dart';
import 'package:monarch/main_pages/HomePage/hero_card.dart';
import 'package:monarch/main_pages/HomePage/quick_actions.dart';
import 'package:monarch/support/transcations_recent.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:monarch/other_pages/enviroment.dart';

class FinTrackHomePage extends StatefulWidget {
  const FinTrackHomePage({Key? key}) : super(key: key);

  @override
  State<FinTrackHomePage> createState() => _FinTrackHomePageState();
}

class _FinTrackHomePageState extends State<FinTrackHomePage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Navigation State
  int _selectedIndex = 0;

  // Time-based greeting data
  String _greetingText = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
    _updateGreeting();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Initialize data fetching
  void _initializeData() {
    fetchRecentTransactions().then((transactions) {
      // Handle transactions data
    });
  }

  // Update greeting based on current time
  void _updateGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      _greetingText = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      _greetingText = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      _greetingText = 'Good Evening';
    } else {
      _greetingText = 'Good Night';
    }
  }

  // Setup enhanced animation controllers
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Staggered animation start
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  // Enhanced greeting header with time-based content
  Widget _buildGreetingHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Greeting Section
          Expanded(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main greeting with emoji
                      Row(
                        children: [
                          Text(
                            '$_greetingText ',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Enhanced sub-greeting
                      const SizedBox(height: 8),
                      // Date indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getFormattedDate(),
                          style: GoogleFonts.inter(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Enhanced notification button
          _buildTransactionButtons(),
        ],
      ),
    );
  }

  // Get formatted date string
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  // Enhanced Transaction Entry Buttons with perfect UX
  Widget _buildTransactionButtons() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Row(
            children: [
              // Gmail Transaction Button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: accentColor.withOpacity(0.08),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _showTransactionEntryDialog('email');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.mail_outline,
                        color: accentColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Voice Transaction Button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: accentColor.withOpacity(0.08),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _showTransactionEntryDialog('voice');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.mic_outlined,
                        color: accentColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Transaction Entry Dialog with voice functionality
  void _showTransactionEntryDialog(String type) {
    if (type == 'voice') {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => VoiceTransactionDialog(),
      );
    } else {
      // Email dialog (unchanged)
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder:
            (context) => Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
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
                  // Handle Bar
                  Container(
                    width: 48,
                    height: 4,
                    margin: const EdgeInsets.only(top: 16, bottom: 24),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Dialog Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
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
                                child: Icon(
                                  Icons.mail_outline,
                                  color: accentColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email Transaction',
                                    style: GoogleFonts.inter(
                                      color: primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Forward receipts to add transactions',
                                    style: GoogleFonts.inter(
                                      color: primaryColor.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Placeholder content
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 64,
                                    color: accentColor.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Email integration coming soon!',
                                    style: GoogleFonts.inter(
                                      color: primaryColor.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      );
    }
  }

  // Enhanced main content with better spacing
  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance Card Section with staggered animation
        _buildAnimatedSection(
          delay: 600,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: const BalanceCardPage(),
          ),
        ),

        // Quick Actions Section with staggered animation
        _buildAnimatedSection(
          delay: 800,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: QuickActionsPage(),
          ),
        ),

        // Recent Transactions Section with staggered animation
        _buildAnimatedSection(
          delay: 1000,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: RecentTransactionsWidget(
              recentTransactions: fetchRecentTransactions(),
            ),
          ),
        ),

        // Bottom spacing for FAB and navigation
        const SizedBox(height: 120),
      ],
    );
  }

  // Helper method for staggered animations
  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Opacity(opacity: 0, child: child);
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset:
                snapshot.connectionState == ConnectionState.done
                    ? Offset.zero
                    : const Offset(0, 0.1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                // Add refresh functionality
                _initializeData();
                _updateGreeting();
                setState(() {});
              },
              color: accentColor,
              backgroundColor: cardColor,
              strokeWidth: 2.5,
              displacement: 60,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            backgroundColor,
                            backgroundColor.withOpacity(0.95),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGreetingHeader(),
                            _buildMainContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: backgroundColor,
        accentColor: accentColor,
        primaryColor: primaryColor,
        cardColor: cardColor,
      ),
    );
  }
}

// Voice Transaction Dialog Widget
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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) async {
          print('Status: $val');
          if (val == 'done') {
            setState(() {
              _isListening = false;
              _processing = true;
            });
            await _speech.stop();
            if (_spokenText.isNotEmpty) {
              await _sendToBackend();
            }
            setState(() {
              _processing = false;
            });
          }
        },
        onError: (val) => print('Error: $val'),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _spokenText = '';
        });
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

        // Close the bottom sheet
        Navigator.pop(context);

        // Show confirmation page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmTransactionPage(data: transactionData),
          ),
        );
      } else {
        throw Exception('❌ Failed to process transaction');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).colorScheme.secondary;

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
          // Handle Bar
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(top: 16, bottom: 24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Dialog Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
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
                        child: Icon(
                          Icons.mic_outlined,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice Transaction',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Speak to record your transaction',
                            style: GoogleFonts.inter(
                              color: primaryColor.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Voice input content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_processing)
                          Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accentColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Processing your request...',
                                style: GoogleFonts.inter(
                                  color: primaryColor.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              // Animated microphone button
                              ScaleTransition(
                                scale:
                                    _isListening
                                        ? _scaleAnimation
                                        : AlwaysStoppedAnimation(1.0),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color:
                                        _isListening
                                            ? accentColor.withOpacity(0.2)
                                            : accentColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          _isListening
                                              ? accentColor
                                              : accentColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      size: 40,
                                      color:
                                          _isListening
                                              ? accentColor
                                              : primaryColor.withOpacity(0.6),
                                    ),
                                    onPressed: _listen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Status text
                              Text(
                                _isListening
                                    ? 'Listening...'
                                    : 'Tap the microphone to start',
                                style: GoogleFonts.inter(
                                  color: primaryColor.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Speech text with smooth appearance
                              AnimatedOpacity(
                                opacity: _spokenText.isNotEmpty ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _spokenText,
                                    style: GoogleFonts.inter(
                                      color: primaryColor,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Confirm Transaction Page
class ConfirmTransactionPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ConfirmTransactionPage({super.key, required this.data});

  Future<void> _saveTransaction(BuildContext context) async {
    const String saveUrl = '${Environment.baseUrl}/api/transaction/add';

    try {
      final response = await http.post(
        Uri.parse(saveUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': data['description'],
          'amount': data['amount'],
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Transaction Saved!')));
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        throw Exception('❌ Save failed');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = data['amount'];
    final description = data['description'];
    final category = data['category'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Transaction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "💬 Description: $description",
              style: const TextStyle(fontSize: 18),
            ),
            Text("💰 Amount: ₹$amount", style: const TextStyle(fontSize: 18)),
            Text(
              "📂 Category: $category",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Confirm & Save'),
              onPressed: () => _saveTransaction(context),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Edit or Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
