import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  int _resendTimer = 60;
  Timer? _timer;
  Timer? _checkEmailTimer;
  bool _isCheckingEmail = false;
  String _errorMessage = '';
  String _alertMessage = '';

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkEmailTimer?.cancel();
    super.dispose();
  }

  void setErrorMessage(String errorMessage) {
    if (mounted) {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  void setAlertMessage(String alertMessage) {
    if (mounted) {
      setState(() {
        _alertMessage = alertMessage;
      });
    }
  }

  void _startEmailVerificationCheck() {
    _checkEmailVerified();

    _checkEmailTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    try {
      final isVerified = await _authService.checkEmailVerified();
      if (mounted) {
        setState(() {
          _isEmailVerified = isVerified;
        });
      }

      if (_isEmailVerified) {
        _checkEmailTimer?.cancel();
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      setErrorMessage('Error checking email verification status: $e');
    }
  }

  void _startResendTimer() {
    if (mounted) {
      setState(() {
        _canResendEmail = false;
        _resendTimer = 60;
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResendEmail = true;
            timer.cancel();
          }
        });
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    try {
      if (!_canResendEmail) {
        setErrorMessage(
            'Please wait $_resendTimer seconds before requesting another email.');
        return;
      }

      await _authService.sendVerificationEmail();
      _startResendTimer();

      setAlertMessage('Verification email sent!');
    } catch (e) {
      setErrorMessage('Error: ${e.toString()}');
    }
  }

  Future<void> _manualCheckEmailVerified() async {
    if (_isCheckingEmail) return;
    if (mounted) {
      setState(() {
        _isCheckingEmail = true;
      });
    }

    try {
      await _checkEmailVerified();

      // If we're still mounted and email is not verified, show a message
      if (mounted && !_isEmailVerified) {
        setErrorMessage('Email not verified yet. Please check your inbox.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    double extraPadding = 0;
    if (screenWidth < 800) {
      extraPadding = screenWidth * 0.075;
    } else if (screenWidth < 850) {
      extraPadding = screenWidth * 0.125;
    } else if (screenWidth < 1000) {
      extraPadding = screenWidth * .15;
    } else {
      extraPadding = screenWidth * .2;
    }
    final user = _auth.currentUser;
    final email = user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: backgroundPageColor,
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: isTablet ? extraPadding : 25.0),
          child: Stack(
            children: [
              if (_errorMessage.isNotEmpty || _alertMessage.isNotEmpty)
                Positioned(
                  top: 15,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if (_errorMessage.isNotEmpty)
                        AlertBanner(
                          message: _errorMessage,
                          onDismiss: () => setErrorMessage(''),
                          isError: true,
                        ),
                      if (_alertMessage.isNotEmpty)
                        AlertBanner(
                          message: _alertMessage,
                          onDismiss: () => setAlertMessage(''),
                          isError: false,
                        ),
                    ],
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Email icon
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 1, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Header with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      "Verify Your Email",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'We\'ve sent a verification email to',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Check your inbox and click the verification link to continue.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Check email status button
                  LoadingStateButton(
                    label: 'I\'ve Verified My Email',
                    onPressed: () async {
                      await _manualCheckEmailVerified();
                    },
                    isEnabled: !_isCheckingEmail,
                    backgroundColor: purpleAccent,
                    textColor: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  // Resend email button
                  LoadingStateButton(
                    label: _canResendEmail
                        ? 'Resend Verification Email'
                        : 'Resend in $_resendTimer seconds',
                    onPressed: () async {
                      await _sendVerificationEmail();
                    },
                    isEnabled: _canResendEmail,
                    backgroundColor: Colors.transparent,
                    showBorder: true,
                    borderColor: Colors.white.withValues(alpha: 0.5),
                    textColor: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  // Sign out option
                  TextButton(
                    onPressed: () async {
                      // Use the AuthService's signOut method for proper cleanup
                      if (mounted) {
                        await FirebaseAuth.instance.signOut();
                      }
                    },
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
