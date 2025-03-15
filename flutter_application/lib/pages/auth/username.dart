import 'package:flutter/material.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';
import 'package:flutter_application/constants.dart';

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

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length > 10) {
      return 'Username must be less than 10 characters';
    }
    return _authService.validateUsername(value);
  }

  void _updateFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPageColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: _updateFormValidity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/images/logos/synapse_no_bg.png',
                      height: 140,
                      width: 140,
                    ),
                  ),
                  const Spacer(flex: 1),
                  const Text(
                    'Set your username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose a unique username for your account. This can\'t be changed later.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextFormField(
                    controller: _usernameController,
                    labelText: 'Username',
                    validator: _validateUsername,
                  ),
                  const SizedBox(height: 30),
                  CustomAuthButton(
                    label: 'Continue',
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        _authService.setUsername(
                          context,
                          _usernameController.text.trim(),
                        );
                      }
                    },
                    isEnabled: _isFormValid,
                    backgroundColor: Colors.white,
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
