import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _formValid = false;

  // Validation states
  String? _emailError;

  // Form completion tracking
  bool get _isFormValid =>
      _emailController.text.isNotEmpty &&
      _emailError == null &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text == _passwordController.text &&
      _fullNameController.text.isNotEmpty;

  void _updateFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_formValid != isValid &&
        _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      setState(() {
        _formValid = isValid;
      });
    }
  }

  @override
  void initState() {
    super.initState();
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

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Check minimum length
    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }

    // Check for spaces and special characters
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  void _registerUser() async {
    if (!_isFormValid) return;

    await _authService.register(
      context: context,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      fullName: _fullNameController.text.trim(),
    );
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
                  const Spacer(flex: 1),
                  const Text(
                    "Hello! Register to get started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // FULLNAME
                  CustomTextFormField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    validator: _validateName,
                  ),
                  const SizedBox(height: 12.5),

                  // EMAIL
                  CustomTextFormField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 12.5),

                  // PASSWORD
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                    isPasswordField: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 12.5),

                  // CONFIRM PASSWORD
                  CustomTextFormField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    isPasswordField: true,
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 20),

                  CustomAuthButton(
                    label: 'Register',
                    onPressed: _registerUser,
                    isEnabled: _isFormValid,
                    backgroundColor: Colors.white,
                  ),
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
                  const Spacer(flex: 3),
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
      ),
    );
  }
}
