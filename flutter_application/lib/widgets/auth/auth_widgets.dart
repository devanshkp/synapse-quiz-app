import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThirdPartySignInButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final SvgPicture svgPicture;

  const ThirdPartySignInButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
    required this.svgPicture,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(double.infinity, 50),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          svgPicture,
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPasswordField;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final double borderRadius;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPasswordField = false,
    this.validator,
    this.onChanged,
    this.borderRadius = 12,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPasswordField && !_passwordVisible,
      cursorColor: Colors.white,
      cursorWidth: 1.0,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: widget.labelText,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(color: Colors.white, width: .5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.6),
            width: .5,
          ),
        ),
        errorMaxLines: 2,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: Colors.red.shade300, width: .5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: Colors.red.shade300, width: .5),
        ),
        suffixIcon: widget.isPasswordField
            ? IconButton(
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
              )
            : null,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}

class AuthRedirectText extends StatelessWidget {
  final String regularText;
  final String highlightedText;
  final VoidCallback onTap;

  const AuthRedirectText({
    super.key,
    required this.regularText,
    required this.highlightedText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white70,
          ),
          children: [
            TextSpan(
              text: '$regularText ', // Regular text passed to the widget
            ),
            TextSpan(
              text: highlightedText, // Highlighted text passed to the widget
              style: const TextStyle(
                color: Colors.white,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap =
                    onTap, // Function to be called when highlighted text is tapped
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  final Function(String) onSendResetLink;
  final String? Function(String?) validateEmail;

  const ForgotPasswordDialog({
    super.key,
    required this.onSendResetLink,
    required this.validateEmail,
  });

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _updateFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (_isFormValid != isValid && _emailController.text.isNotEmpty) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      title: const Text(
        'Reset Password',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              controller: _emailController,
              labelText: 'Email Address',
              validator: widget.validateEmail,
              onChanged: (_) => _updateFormValidity(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        TextButton(
          onPressed: _isFormValid
              ? () async {
                  await widget.onSendResetLink(_emailController.text.trim());
                  if (mounted) Navigator.pop(context);
                }
              : () {},
          child: Text(
            'Send Reset Link',
            style: TextStyle(
              color: _isFormValid ? Colors.blue : Colors.white38,
            ),
          ),
        ),
      ],
    );
  }
}
