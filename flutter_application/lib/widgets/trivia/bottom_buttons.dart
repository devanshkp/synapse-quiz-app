import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/shared.dart';

class BottomButtons extends StatelessWidget {
  final bool answered;
  final VoidCallback onNextQuestion;

  const BottomButtons({
    super.key,
    required this.answered,
    required this.onNextQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return answered
        ? NextButton(onPressed: onNextQuestion)
        : SkipButton(onPressed: onNextQuestion);
  }
}

class SkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: onPressed,
      minimumSize: const Size(200, 0),
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      text: "SKIP QUESTION",
      textColor: Colors.white,
      fontSize: 13,
      gradient: LinearGradient(
        colors: [
          const Color.fromARGB(255, 255, 174, 0).withOpacity(0.9),
          Colors.orange.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool drawerButton;

  const NextButton(
      {super.key, required this.onPressed, this.drawerButton = false});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: onPressed,
      minimumSize: const Size(200, 0),
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      text: "NEXT QUESTION",
      icon: Icons.arrow_forward,
      textColor: Colors.black,
      fullWidth: drawerButton ? true : false,
      fontSize: 13,
      gradient: const LinearGradient(
        colors: [
          Colors.white,
          Colors.white,
        ],
      ),
    );
  }
}
