import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You\'ve been missed!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                    controller: _emailController,
                    labelText: 'Enter email address'),
                const SizedBox(height: 15),
                CustomTextField(
                    controller: _passwordController,
                    labelText: 'Enter Password',
                    isPasswordField: true),
                const SizedBox(height: 20),
                CustomAuthButton(
                  label: 'Login',
                  onPressed: () {
                    _authService.signInWithEmailAndPassword(
                      context,
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                  },
                ),
                const SizedBox(height: 25),
                const HorizontalDividerWithText(text: 'or Login with'),
                const SizedBox(height: 25),
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
                      onPressed: () => _authService.signInWithGoogle(context),
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
                  regularText: 'Don\'t have an account?',
                  highlightedText: 'Register',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
