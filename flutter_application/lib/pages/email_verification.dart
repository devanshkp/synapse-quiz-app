import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
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

  Future<void> _checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Refresh user info
        setState(() {
          _isEmailVerified = user.emailVerified;
        });

        if (_isEmailVerified) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        } else {
          if (mounted) {
            floatingSnackBar(
                context: context,
                message: 'Email not verified. Please check your inbox.');
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking email verification status: $e');
      if (mounted) {
        floatingSnackBar(context: context, message: 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          floatingSnackBar(
              context: context, message: 'Verification email sent again!');
        }
      } else {
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
    return Scaffold(
      backgroundColor: backgroundPageColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            const Text(
              "Email Verification",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please check your inbox for the verification email.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            // Check email status button
            CustomAuthButton(
              label: 'Already Verified',
              onPressed: _checkEmailVerified,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            const Spacer(),
            AuthRedirectText(
                regularText: 'Haven\'t recived?',
                highlightedText: 'Resend email',
                onTap: sendVerificationEmail),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
