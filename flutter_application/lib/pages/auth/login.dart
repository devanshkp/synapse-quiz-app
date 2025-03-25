import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  String _errorMessage = '';
  String _alertMessage = '';

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
        _emailController.text.isNotEmpty &&
        mounted) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _setErrorMessage(String errorMessage) {
    if (_alertMessage.isNotEmpty) {
      _setAlertMessage('');
    }
    if (mounted) {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  void _setAlertMessage(String alertMessage) {
    if (_errorMessage.isNotEmpty) {
      _setErrorMessage('');
    }
    if (mounted) {
      setState(() {
        _alertMessage = alertMessage;
      });
    }
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final errorMessage = await _authService.signIn(
        email,
        password,
      );

      if (errorMessage != null) {
        _setErrorMessage(errorMessage);
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  Future<void> _handleSignInWithGoogle() async {
    final errorMessage = await _authService.signInWithGoogle();
    if (errorMessage != null) {
      _setErrorMessage(errorMessage);
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Future<void> _handleSignInWithGithub() async {
    final errorMessage = await _authService.signInWithGithub();
    if (errorMessage != null) {
      _setErrorMessage(errorMessage);
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    double extraPadding = 0;
    if (screenWidth < 800) {
      extraPadding = screenWidth * 0.075;
    } else if (screenWidth < 850) {
      extraPadding = screenWidth * 0.125;
    } else if (screenWidth < 1000) {
      extraPadding = screenWidth * .15;
    } else {
      extraPadding = screenWidth * .2;
    }
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
            padding: const EdgeInsets.only(right: 24.0),
            child: Image.asset(
              'assets/icons/logos/app_foreground.png',
              height: 15,
              width: 15,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height -
                (AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? extraPadding : 25.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: _updateFormValidity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),

                  // Header with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      "Let's Sign you in.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back,\nYou\'ve been missed!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (_errorMessage.isNotEmpty) ...[
                    AlertBanner(
                      message: _errorMessage,
                      onDismiss: () => _setErrorMessage(''),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_alertMessage.isNotEmpty) ...[
                    AlertBanner(
                      message: _alertMessage,
                      onDismiss: () => _setAlertMessage(''),
                      isError: false,
                    ),
                  ],
                  // EMAIL
                  CustomTextFormField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                    validator: _validatePassword,
                    isPasswordField: true,
                  ),

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ForgotPasswordDialog(
                            validateEmail: _validateEmail,
                            onSendResetLink: (email) async {
                              final message = await _authService
                                  .sendPasswordResetEmail(email);
                              if (message != null) {
                                _setAlertMessage(message);
                              }
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login button with solid color instead of gradient and glow
                  LoadingStateButton(
                    label: 'Continue',
                    onPressed: () => _handleSignIn(),
                    isEnabled: _isFormValid,
                    backgroundColor: _isFormValid
                        ? purpleAccent
                        : darkPurpleAccent.withValues(alpha: 0.5),
                    textColor: Colors.white,
                  ),

                  const SizedBox(height: 10),

                  const HorizontalDividerWithText(
                    text: 'OR',
                  ),

                  const SizedBox(height: 10),

                  // Social login buttons with improved styling
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ThirdPartySignInButton(
                      title: 'Continue with Google',
                      svgPicture: SvgPicture.asset(
                        'assets/icons/auth/google_logo.svg',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () => _handleSignInWithGoogle(),
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ThirdPartySignInButton(
                      title: 'Continue with GitHub',
                      svgPicture: SvgPicture.asset(
                        'assets/icons/auth/github_logo.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () => _handleSignInWithGithub(),
                      backgroundColor: githubColor,
                      textColor: Colors.white,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Improved redirect text
                  Center(
                    child: AuthRedirectText(
                      regularText: 'Don\'t have an account?',
                      highlightedText: 'Register',
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/register',
                        );
                      },
                    ),
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
