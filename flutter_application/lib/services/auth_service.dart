import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/services/user_service.dart';
import 'package:floating_snackbar/floating_snackbar.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  Future<void> registerUser(
      {required BuildContext context,
      required String email,
      required String password,
      required String confirmPassword,
      required String userName,
      required String fullName}) async {
    try {
      if (email.isEmpty ||
          password.isEmpty ||
          userName.isEmpty ||
          fullName.isEmpty) {
        floatingSnackBar(
            message: 'Please fill in all fields.', context: context);
        return;
      }

      if (password != confirmPassword) {
        floatingSnackBar(message: 'Passwords do not match.', context: context);
        return;
      }

      // Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Store user details in Firestore
        await _userService.createUserProfile(
            user: user, userName: userName, fullName: fullName);

        // Navigate to the email verification screen
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/email-verification');
        }
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      if (context.mounted) {
        floatingSnackBar(message: 'Error: ${e.toString()}', context: context);
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists && context.mounted) {
          _showUsernameDialog(context, user);
        }
      }
    } catch (e) {
      if (context.mounted) {
        floatingSnackBar(
            message: 'Error signing in with Google: $e', context: context);
      }
    }
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        if (context.mounted) {
          floatingSnackBar(
              message: 'Please fill in all fields', context: context);
        }
        return;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        floatingSnackBar(message: 'Error signing in: $e', context: context);
      }
    }
  }

  void _showUsernameDialog(BuildContext context, User user) {
    if (!context.mounted) return;
    final TextEditingController usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a Username'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(hintText: 'Enter your username'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final userName = usernameController.text.trim();
                if (userName.isNotEmpty) {
                  await _userService.createUserProfile(
                      user: user, userName: userName);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }
}
