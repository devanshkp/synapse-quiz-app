import 'package:flutter/material.dart';
import 'package:flutter_application/utils/text_formatter.dart';

class OptionButton extends StatelessWidget {
  final String option;
  final bool isCorrectOption;
  final bool isSelected;
  final Color? buttonColor;
  final VoidCallback? onPressed;

  const OptionButton({
    super.key,
    required this.option,
    required this.isCorrectOption,
    required this.isSelected,
    required this.buttonColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          disabledBackgroundColor: buttonColor,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: Color(0xff444444),
              width: 1,
            ),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: TextFormatter.formatText(
                  option,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
