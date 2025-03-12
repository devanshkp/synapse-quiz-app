import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThirdPartySignInButton extends StatelessWidget {
  final String svgAssetPath;
  final VoidCallback onPressed;
  final double size;
  final Color? color;

  const ThirdPartySignInButton({
    super.key,
    required this.svgAssetPath,
    required this.onPressed,
    this.size = 32.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Border Container
          Container(
            width: 100,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 0.5,
              ),
            ),
          ),
          // SVG Icon
          SvgPicture.asset(
            svgAssetPath,
            width: size,
            height: size,
            color: color,
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

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPasswordField = false,
    this.validator,
    this.onChanged,
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
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: .5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.6),
            width: .5,
          ),
        ),
        errorMaxLines: 2,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300, width: .5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}

class CustomAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isEnabled;

  const CustomAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : () {},
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isEnabled ? backgroundColor : backgroundColor.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                color: isEnabled ? textColor : textColor.withOpacity(0.5)),
          ),
        ),
      ),
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
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
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
                  Navigator.pop(context);
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
