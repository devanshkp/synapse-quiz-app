import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/services/user_service.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/widgets/shared.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  Future<void> _registerUser() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();
      final userName = _userNameController.text.trim();
      final fullName = _fullNameController.text.trim();

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
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/email-verification');
        }
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      if (mounted) {
        floatingSnackBar(message: 'Error: ${e.toString()}', context: context);
      }
    }
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
              const SizedBox(height: 100),
              const Text(
                "Hello! Register to get started",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                  controller: _fullNameController, labelText: 'Full Name'),
              const SizedBox(height: 10),
              CustomTextField(
                  controller: _userNameController, labelText: 'Username'),
              const SizedBox(height: 10),
              CustomTextField(
                  controller: _emailController, labelText: 'Email Address'),
              const SizedBox(height: 10),
              CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  isPasswordField: true),
              const SizedBox(height: 10),
              CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  isPasswordField: true),
              const SizedBox(height: 20),
              CustomAuthButton(label: 'Register', onPressed: _registerUser),
              const SizedBox(height: 30),
              const HorizontalDividerWithText(text: 'or Sign up with'),
              const SizedBox(height: 30),
              // Social Sign-In Buttons
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
                    onPressed: () {}, // Google Sign-In (Optional)
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
              const SizedBox(height: 80),
              AuthRedirectText(
                  regularText: 'Already have an account?',
                  highlightedText: 'Login',
                  onTap: () => {
                        Navigator.pushNamed(context, '/login')
                      }), // Redirects to Login Page
            ],
          ),
        ),
      ),
    );
  }
}
