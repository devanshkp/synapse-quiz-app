import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _formValid = false;
  String _errorMessage = '';

  void _updateFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_formValid != isValid &&
        _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        mounted) {
      setState(() {
        _formValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null;
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

    return _authService.validatePassword(value);
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty || _passwordController.text.isEmpty) {
      return null;
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _setErrorMessage(String errorMessage) {
    if (mounted) {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  Future<void> _registerUser() async {
    final errorMessage = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      fullName: _fullNameController.text.trim(),
    );

    if (errorMessage != null) {
      _setErrorMessage(errorMessage);
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Future<void> _handleSignInWithGoogle() async {
    final errorMessage = await _authService.signInWithGoogle();
    if (errorMessage != null) {
      _setErrorMessage(errorMessage);
    } else {
      if (context.mounted)
        Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Future<void> _handleSignInWithGithub() async {
    final errorMessage = await _authService.signInWithGithub();
    if (errorMessage != null) {
      _setErrorMessage(errorMessage);
    } else {
      if (context.mounted)
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                      const SizedBox(height: 25),
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
                          "Create Account",
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
                        'Join our community and start your learning journey!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (_errorMessage.isNotEmpty) ...[
                        AlertBanner(
                          message: _errorMessage,
                          onDismiss: () => _setErrorMessage(''),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // FULLNAME
                      CustomTextFormField(
                        controller: _fullNameController,
                        labelText: 'Full Name',
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),

                      // EMAIL
                      CustomTextFormField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 16),

                      // PASSWORD
                      CustomTextFormField(
                        controller: _passwordController,
                        labelText: 'Password',
                        validator: _validatePassword,
                        isPasswordField: true,
                      ),
                      const SizedBox(height: 16),

                      // CONFIRM PASSWORD
                      CustomTextFormField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        validator: _validateConfirmPassword,
                        isPasswordField: true,
                      ),
                      const SizedBox(height: 30),

                      // Register button with solid color instead of gradient and glow
                      LoadingStateButton(
                        label: 'Next',
                        onPressed: () async {
                          await _registerUser();
                        },
                        isEnabled: _formValid,
                        backgroundColor: _formValid
                            ? purpleAccent
                            : darkPurpleAccent.withValues(alpha: 0.5),
                        textColor: Colors.white,
                      ),

                      const SizedBox(height: 10),

                      const HorizontalDividerWithText(
                        text: 'OR',
                      ),

                      const SizedBox(height: 10),

                      // Social Sign-In Buttons with improved styling
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 40.0),
            child: AuthRedirectText(
              regularText: 'Already have an account?',
              highlightedText: 'Login',
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ),
        ],
      ),
    );
  }
}
