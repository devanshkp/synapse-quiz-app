import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithGoogle() async {
    try {
      await _auth.signOut();

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
        if (!userDoc.exists) {
          _showUsernameDialog(user);
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
            message: 'Error signing in with Google: $e', context: context);
      }
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      await _auth.signOut();

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        if (mounted) {
          floatingSnackBar(
              message: 'Please fill in all fields', context: context);
        }

        return;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (mounted) {
        floatingSnackBar(message: 'Error signing in: $e', context: context);
      }
    }
  }

  void _showUsernameDialog(User user) {
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
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPageColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 140),
              const Text(
                "Let's Sign you in.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome back',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You\'ve been missed!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 50),
              CustomTextField(
                  controller: _emailController,
                  labelText: 'Enter email address'),
              const SizedBox(height: 10),
              CustomTextField(
                  controller: _passwordController,
                  labelText: 'Enter Password',
                  isPasswordField: true),
              const SizedBox(height: 20),
              CustomAuthButton(
                  label: 'Login', onPressed: _signInWithEmailAndPassword),
              const SizedBox(height: 30),
              const HorizontalDividerWithText(text: 'or Login with'),
              const SizedBox(height: 30),
              // Dynamically built buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ThirdPartySignInButton(
                    svgAssetPath: 'assets/icons/auth/facebook_logo.svg',
                    onPressed: () => {},
                    size: 27.5,
                  ),
                  const SizedBox(width: 5),
                  ThirdPartySignInButton(
                    svgAssetPath: 'assets/icons/auth/google_logo.svg',
                    onPressed: _signInWithGoogle,
                    size: 40.0,
                  ),
                  const SizedBox(width: 5),
                  ThirdPartySignInButton(
                    svgAssetPath: 'assets/icons/auth/github_logo.svg',
                    color: Colors.white,
                    onPressed: () => {},
                    size: 27.5,
                  ),
                ],
              ),
              const SizedBox(height: 150),
              AuthRedirectText(
                  regularText: 'Don\'t have an account?',
                  highlightedText: 'Register',
                  onTap: () => {Navigator.pushNamed(context, '/register')}),
              const SizedBox(height: 15),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
