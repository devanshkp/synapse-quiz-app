import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user is new or existing
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          // New user: Show username input dialog
          _showUsernameDialog(user);
        } else {
          // Existing user: Navigate to the home screen
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  void _showUsernameDialog(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a Username'),
          content: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(hintText: 'Enter your username'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_usernameController.text.isNotEmpty) {
                  // Create user profile in Firestore
                  await _createUserProfile(user, _usernameController.text);
                  Navigator.pop(context); // Close the dialog
                  Navigator.of(context, rootNavigator: true)
                      .pushReplacementNamed('/home'); // Navigate to home
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createUserProfile(User user, String username) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'username': username,
      'fullName': user.displayName ??
          'No Name', // Use Firebase Auth display name (if available)
      'profilePicture': user.photoURL ??
          '', // Use Firebase Auth profile picture URL (if available)
      'selectedCategories': [
        "neural_networks",
        "foundational_math",
        "sorting_algorithms",
        "machine_learning",
        "data_structures",
        "programming_basics",
        "popular_algorithms",
        "database_systems",
        "swe_fundamentals"
      ],
      'encounteredQuestions': [],
      'questionsSolved': 0,
      'friends': [],
      'friend_requests': [],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPageColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Quiz App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Sign in with Google',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
