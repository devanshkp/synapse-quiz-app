import 'package:flutter/material.dart';

class QuestionTimer extends StatelessWidget {
  final ValueNotifier<double> timeNotifier;
  final double totalTime;

  const QuestionTimer({
    super.key,
    required this.timeNotifier,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: timeNotifier,
      builder: (context, duration, child) {
        double progress = timeNotifier.value / totalTime;

        return SizedBox(
          height: 60,
          width: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: progress, end: progress),
                  duration:
                      const Duration(milliseconds: 300), // Smooth transition
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color?>(
                        progress <= 0.3
                            ? Colors.redAccent
                            : Colors.greenAccent[200],
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: Text(
                  timeNotifier.value.clamp(0, totalTime).toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
