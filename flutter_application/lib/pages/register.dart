import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/widgets/shared.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  void _registerUser() {
    _authService.registerUser(
      context: context,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      userName: _userNameController.text.trim(),
      fullName: _fullNameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPageColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Text(
                  "Hello! Register to get started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 25),
                CustomTextField(
                    controller: _fullNameController, labelText: 'Full Name'),
                const SizedBox(height: 12.5),
                CustomTextField(
                    controller: _userNameController, labelText: 'Username'),
                const SizedBox(height: 12.5),
                CustomTextField(
                    controller: _emailController, labelText: 'Email Address'),
                const SizedBox(height: 12.5),
                CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    isPasswordField: true),
                const SizedBox(height: 12.5),
                CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    isPasswordField: true),
                const SizedBox(height: 20),
                CustomAuthButton(label: 'Register', onPressed: _registerUser),
                const SizedBox(height: 25),
                const HorizontalDividerWithText(text: 'or Sign up with'),
                const SizedBox(height: 25),
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
                const Spacer(),
                AuthRedirectText(
                    regularText: 'Already have an account?',
                    highlightedText: 'Login',
                    onTap: () =>
                        {Navigator.pushReplacementNamed(context, '/login')}),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
