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

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPasswordField;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPasswordField = false,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white.withOpacity(0.6);
    double fontSize = 13;

    return TextField(
      controller: widget.controller,
      obscureText: widget.isPasswordField && !isPasswordVisible,
      cursorColor: Colors.white,
      cursorWidth: 1.0,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: color, fontSize: fontSize),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: .5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: .5),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        suffixIcon: widget.isPasswordField
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: color,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      style: TextStyle(color: Colors.white, fontSize: fontSize),
    );
  }
}

class CustomAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CustomAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
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
            style: TextStyle(color: textColor),
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
