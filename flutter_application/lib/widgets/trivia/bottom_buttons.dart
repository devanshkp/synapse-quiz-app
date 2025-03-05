import 'package:flutter/material.dart';

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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 5),
        backgroundColor: Colors.orange.withOpacity(0.8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 9,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
      child: const Text(
        "SKIP QUESTION",
        style: TextStyle(fontSize: 13),
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: const Text(
        'NEXT QUESTION',
        style: TextStyle(fontSize: 13),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize:
            (drawerButton) ? const Size.fromHeight(5) : const Size(200, 5),
        animationDuration: const Duration(milliseconds: 10),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 9,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
    );
  }
}
