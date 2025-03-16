import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    // Check if the user exists and if verification email was already sent
    final user = _auth.currentUser;
    if (user != null) {
      // Check email verification status immediately
      _checkEmailVerified();

      // Set up a timer to periodically check email verification status
      _checkEmailTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _checkEmailVerified();
      });
    } else {
      // If no user is found, navigate back to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkEmailTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Refresh user info
        final freshUser = _auth.currentUser; // Get fresh user data after reload

        setState(() {
          _isEmailVerified = freshUser?.emailVerified ?? false;
        });

        if (_isEmailVerified) {
          _checkEmailTimer?.cancel();
          if (mounted) {
            // Check if user has a username set
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (!userDoc.exists) {
              // If user doesn't have a profile, go to username page
              Navigator.pushReplacementNamed(context, '/username-dialog');
            } else {
              // If user has a profile, go to home
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking email verification status: $e');
    }
  }

  void _startResendTimer() {
    setState(() {
      _canResendEmail = false;
      _resendTimer = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResendEmail = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        if (!_canResendEmail) {
          if (mounted) {
            floatingSnackBar(
                context: context,
                message:
                    'Please wait $_resendTimer seconds before requesting another email.');
          }
          return;
        }

        await user.sendEmailVerification();
        _startResendTimer();

        if (mounted) {
          floatingSnackBar(
              context: context, message: 'Verification email sent!');
        }
      } else if (user?.emailVerified == true) {
        floatingSnackBar(
            context: context, message: 'Email is already verified!');
      }
    } catch (e) {
      debugPrint('Error sending verification email: $e');
      if (mounted) {
        floatingSnackBar(context: context, message: 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _manualCheckEmailVerified() async {
    if (_isCheckingEmail) return;

    setState(() {
      _isCheckingEmail = true;
    });

    try {
      await _checkEmailVerified();

      // If we're still mounted and email is not verified, show a message
      if (mounted && !_isEmailVerified) {
        floatingSnackBar(
          context: context,
          message:
              'Your email is not verified yet. Please check your inbox and click the verification link.',
        );
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
    final user = _auth.currentUser;
    final email = user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: backgroundPageColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/shapes.png'),
            opacity: 0.15,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Email icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: purpleAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 80,
                      color: purpleAccent,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Header with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      "Verify Your Email",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'We\'ve sent a verification email to',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Check your inbox and click the verification link to continue.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
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
                      await sendVerificationEmail();
                    },
                    isEnabled: _canResendEmail,
                    backgroundColor: Colors.transparent,
                    showBorder: true,
                    borderColor: Colors.white.withOpacity(0.5),
                    textColor: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  // Sign out option
                  TextButton(
                    onPressed: () async {
                      // Use the AuthService's signOut method for proper cleanup
                      if (mounted) {
                        await _authService.signOut(context);
                      }
                    },
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
