import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:floating_snackbar/floating_snackbar.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  int _resendTimer = 60;
  Timer? _timer;
  Timer? _checkEmailTimer;

  @override
  void initState() {
    super.initState();
    // Check email verification status immediately
    _checkEmailVerified();

    // Set up a timer to periodically check email verification status
    _checkEmailTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEmailVerified();
    });
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
        setState(() {
          _isEmailVerified = user.emailVerified;
        });

        if (_isEmailVerified) {
          _checkEmailTimer?.cancel();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
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

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final email = user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: backgroundPageColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread_outlined,
              size: 100,
              color: Colors.white70,
            ),
            const SizedBox(height: 30),
            const Text(
              "Verify your email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'We\'ve sent a verification email to\n$email',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Check your inbox and click the verification link to continue.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Check email status button
            CustomAuthButton(
              label: 'I\'ve Verified My Email',
              onPressed: _checkEmailVerified,
            ),
            const SizedBox(height: 20),

            // Resend email button
            TextButton(
              onPressed: _canResendEmail ? sendVerificationEmail : null,
              child: Text(
                _canResendEmail
                    ? 'Resend Verification Email'
                    : 'Resend Email in $_resendTimer seconds',
                style: TextStyle(
                  color: _canResendEmail ? Colors.white : Colors.white60,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sign out option
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
