import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/pages/login.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:provider/provider.dart';

class AuthProvider extends StatelessWidget {
  const AuthProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CustomCircularProgressIndicator()), // Loading state
          );
        }
        if (snapshot.hasData) {
          // User is authenticated, trigger refresh of user data
            Provider.of<UserProvider>(context, listen: false);
            Provider.of<TriviaProvider>(context, listen: false);
          
          return const BottomNavBar(); // User is signed in
        } else {
          return const LoginPage(); // User is not signed in
        }
      },
    );
  }
}
