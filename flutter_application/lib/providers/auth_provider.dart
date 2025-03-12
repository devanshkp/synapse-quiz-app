import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/pages/auth/login.dart';
import 'package:flutter_application/pages/auth/username.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends StatelessWidget {
  const AuthProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CustomCircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data;

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

              if (userDocSnapshot.hasData && !userDocSnapshot.data!.exists) {
                return const UsernamePage();
              }

              // User is authenticated and has a document
              Provider.of<UserProvider>(context, listen: false);
              Provider.of<TriviaProvider>(context, listen: false);
              return const BottomNavBar();
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
