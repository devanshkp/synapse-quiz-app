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
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = null;
      });
      return;
    }

    if (!_authService.isValidEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  void _validatePassword() {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = null;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  bool get _isFormValid =>
      _emailController.text.isNotEmpty &&
      _emailError == null &&
      _passwordController.text.isNotEmpty &&
      _passwordError == null;

  void _handleLogin() {
    if (!_isFormValid) return;

    _authService.signInWithEmailAndPassword(
      context,
      _emailController.text.trim(),
      _passwordController.text.trim(),
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

                // Email field with validation
                TextField(
                  controller: _emailController,
                  cursorColor: Colors.white,
                  cursorWidth: 1.0,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 13),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: Colors.white, width: .5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.6), width: .5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colors.red.shade300, width: .5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colors.red.shade300, width: .5),
                    ),
                    errorText: _emailError,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
                const SizedBox(height: 15),

                // Password field with validation
                TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  cursorColor: Colors.white,
                  cursorWidth: 1.0,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 13),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: Colors.white, width: .5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.6), width: .5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colors.red.shade300, width: .5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colors.red.shade300, width: .5),
                    ),
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 19,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ForgotPasswordDialog(
                          validateEmail: (email) =>
                              _authService.isValidEmail(email),
                          onSendResetLink: (email) {
                            _authService.sendPasswordResetEmail(context, email);
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
                  label: 'Login',
                  onPressed: _handleLogin,
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
                    Navigator.pushNamed(context, '/register');
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
