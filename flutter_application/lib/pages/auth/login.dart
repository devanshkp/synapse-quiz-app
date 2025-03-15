import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFormValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!_authService.isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    final regex = RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).*$');
    if (!regex.hasMatch(value)) {
      return 'Password must contain at least one number and one special character';
    }

    return null;
  }

  void _updateFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_isFormValid != isValid &&
        _passwordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPageColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/logos/synapse_no_bg.png',
              height: 15,
              width: 15,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height -
                (AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: _updateFormValidity,
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
                    'Welcome back,',
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

                  // EMAIL
                  CustomTextFormField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                    validator: _validatePassword,
                  ),

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ForgotPasswordDialog(
                            validateEmail: _validateEmail,
                            onSendResetLink: (email) {
                              _authService.sendPasswordResetEmail(
                                  context, email);
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  CustomAuthButton(
                    label: 'Continue',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _authService.signIn(
                          context,
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      }
                    },
                    isEnabled: _isFormValid,
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
      ),
    );
  }
}
