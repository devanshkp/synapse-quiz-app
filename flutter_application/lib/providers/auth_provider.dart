import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/pages/auth/email_verification.dart';
import 'package:flutter_application/pages/auth/username.dart';
import 'package:flutter_application/pages/landing.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends StatefulWidget {
  const AuthProvider({super.key});

  @override
  State<AuthProvider> createState() => _AuthProviderState();
}

class _AuthProviderState extends State<AuthProvider> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Force refresh the current user when the widget initializes
    _refreshCurrentUser();
  }

  // Helper method to refresh the current user
  Future<void> _refreshCurrentUser() async {
    if (_auth.currentUser != null) {
      try {
        await _auth.currentUser!.reload();
      } catch (e) {
        debugPrint('Error refreshing user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CustomCircularProgressIndicator()),
          );
        }

        // User is authenticated
        if (snapshot.hasData) {
          final user = snapshot.data;

          // Force refresh user data to ensure we have the latest state
          _refreshCurrentUser();

          // Check if email is verified
          if (user != null &&
              user.providerData[0].providerId == 'password' &&
              !user.emailVerified) {
            // If email is not verified, redirect to email verification page
            return const EmailVerificationPage();
          }

          // Check if user has a Firestore document (profile setup)
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CustomCircularProgressIndicator()),
                );
              }

              // If user doesn't have a document, they need to set up their username
              if (userDocSnapshot.hasData && !userDocSnapshot.data!.exists) {
                return const UsernamePage();
              }

              // Initialize providers and show the main app interface
              Provider.of<UserProvider>(context, listen: false);
              Provider.of<TriviaProvider>(context, listen: false);
              return const BottomNavBar();
            },
          );
        } else {
          // User is not authenticated, show landing page
          return const LandingPage();
        }
      },
    );
  }
}
