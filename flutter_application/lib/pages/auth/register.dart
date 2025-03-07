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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  // Validation states
  bool _isCheckingUsername = false;
  bool _isUsernameUnique = true;
  String? _usernameError;
  String? _passwordError;
  String? _emailError;
  bool _passwordVisible = false;

  // Form completion tracking
  bool get _isFormValid =>
      _emailController.text.isNotEmpty &&
      _emailError == null &&
      _passwordController.text.isNotEmpty &&
      _passwordError == null &&
      _confirmPasswordController.text == _passwordController.text &&
      _userNameController.text.isNotEmpty &&
      _usernameError == null &&
      _fullNameController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();

    // Add listeners for real-time validation
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
    _userNameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    // Remove listeners
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _userNameController.removeListener(_validateUsername);

    // Dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    _fullNameController.dispose();

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

    setState(() {
      _passwordError = _authService.validatePassword(_passwordController.text);
    });

    // Also validate confirm password when password changes
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) {
      return;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _passwordError = 'Passwords do not match';
      });
    }
  }

  Future<void> _validateUsername() async {
    if (_userNameController.text.isEmpty) {
      setState(() {
        _usernameError = null;
        _isUsernameUnique = true;
      });
      return;
    }

    // Check minimum length
    if (_userNameController.text.length < 4) {
      setState(() {
        _usernameError = 'Username must be at least 4 characters';
        _isUsernameUnique = false;
      });
      return;
    }

    // Check for spaces and special characters
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(_userNameController.text)) {
      setState(() {
        _usernameError =
            'Username can only contain letters, numbers, and underscores';
        _isUsernameUnique = false;
      });
      return;
    }

    // Check uniqueness with debounce
    setState(() {
      _isCheckingUsername = true;
      _usernameError = null; // Clear any previous errors while checking
    });

    // Delay check to avoid too many requests
    await Future.delayed(const Duration(milliseconds: 500));

    if (_userNameController.text.length >= 4) {
      try {
        bool isUnique =
            await _authService.isUsernameUnique(_userNameController.text);

        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameUnique = isUnique;
            _usernameError = isUnique ? null : 'Username is already taken';
          });
        }
      } catch (e) {
        debugPrint('Error in _validateUsername: $e');
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameUnique = true; // Assume unique on error
            _usernameError = null;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
        });
      }
    }
  }

  void _registerUser() {
    if (!_isFormValid) return;

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

                // Full Name field
                CustomTextField(
                  controller: _fullNameController,
                  labelText: 'Full Name',
                ),
                const SizedBox(height: 12.5),

                // Username field with validation
                TextField(
                  controller: _userNameController,
                  cursorColor: Colors.white,
                  cursorWidth: 1.0,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Username',
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
                    errorText: _usernameError,
                    suffixIcon: _isCheckingUsername
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CustomCircularProgressIndicator(),
                            ),
                          )
                        : _userNameController.text.isNotEmpty &&
                                _isUsernameUnique &&
                                _usernameError == null
                            ? const Icon(Icons.check_circle,
                                color: Colors.green, size: 20)
                            : null,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
                const SizedBox(height: 12.5),

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
                    suffixIcon:
                        _emailController.text.isNotEmpty && _emailError == null
                            ? const Icon(Icons.check_circle,
                                color: Colors.green, size: 20)
                            : null,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
                const SizedBox(height: 12.5),

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
                        color: Colors.white.withOpacity(0.6),
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
                const SizedBox(height: 12.5),

                // Confirm Password field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_passwordVisible,
                  cursorColor: Colors.white,
                  cursorWidth: 1.0,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                    suffixIcon: _confirmPasswordController.text.isNotEmpty &&
                            _confirmPasswordController.text ==
                                _passwordController.text
                        ? const Icon(Icons.check_circle,
                            color: Colors.green, size: 20)
                        : null,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
                const SizedBox(height: 20),

                // Password strength indicator
                if (_passwordController.text.isNotEmpty &&
                    _passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _passwordError!,
                      style: TextStyle(
                          color: Colors.orange.shade300, fontSize: 12),
                    ),
                  ),

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
