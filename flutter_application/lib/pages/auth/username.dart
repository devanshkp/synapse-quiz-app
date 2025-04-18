import 'package:flutter/material.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isFormValid = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length > 15) {
      return 'Username must be less than 15 characters';
    }
    return _authService.validateUsername(value);
  }

  void _updateFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid && mounted) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _setErrorMessage(String errorMessage) {
    if (mounted) {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  Future<void> _handleSetUsername() async {
    final errorMessage = await _authService.setUsername(
      _usernameController.text.trim(),
    );
    if (errorMessage != null) {
      _setErrorMessage(errorMessage);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
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
      body: SafeArea(
        child: Stack(
          children: [
            if (_errorMessage.isNotEmpty) ...[
              Positioned(
                top: 40,
                left: 25,
                right: 25,
                child: AlertBanner(
                  message: _errorMessage,
                  onDismiss: () => _setErrorMessage(''),
                ),
              ),
            ],
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: _updateFormValidity,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? extraPadding : 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

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
                        "Pick a Username",
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
                      'This will be your unique identifier in the community.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Username field
                    CustomTextFormField(
                      controller: _usernameController,
                      labelText: 'Username',
                      validator: _validateUsername,
                    ),

                    const SizedBox(height: 25),

                    // Continue button with solid color
                    LoadingStateButton(
                      label: 'Continue',
                      onPressed: _handleSetUsername,
                      isEnabled: _isFormValid,
                      backgroundColor: _isFormValid
                          ? purpleAccent
                          : darkPurpleAccent.withValues(alpha: 0.5),
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
