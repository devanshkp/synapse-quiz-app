import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut(); // Sign out from Firebase
      
      // Check if the widget is still mounted before accessing context
      if (!context.mounted) return;

      // Clear user data in UserProvider
      Provider.of<UserProvider>(context, listen: false).clearUserData();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }
}
