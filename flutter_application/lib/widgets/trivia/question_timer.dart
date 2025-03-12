import 'package:flutter/material.dart';

class QuestionTimer extends StatefulWidget {
  final ValueNotifier<double> timeNotifier;
  final double totalTime;

  const QuestionTimer({
    super.key,
    required this.timeNotifier,
    required this.totalTime,
  });

  @override
  State<QuestionTimer> createState() => _QuestionTimerState();
}

class _QuestionTimerState extends State<QuestionTimer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.timeNotifier,
      builder: (context, duration, child) {
        double progress = widget.timeNotifier.value / widget.totalTime;
        bool isLowTime = progress <= 0.2;
        bool isMediumTime = progress <= 0.5;

        return SizedBox(
          height: 70,
          width: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Timer background
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.3),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              // Progress indicator
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: progress, end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  final Color progressColor = isLowTime
                      ? Colors.redAccent
                      : isMediumTime
                          ? Colors.orangeAccent
                          : Colors.greenAccent;

                  return SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 5,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  );
                },
              ),

              // Timer text with shadow and pulse animation
              Center(
                child: Text(
                  widget.timeNotifier.value
                      .clamp(0, widget.totalTime)
                      .toStringAsFixed(0),
                  style: TextStyle(
                    color: isLowTime
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    shadows: [
                      Shadow(
                        color: isLowTime
                            ? Colors.redAccent.withOpacity(0.7)
                            : Colors.black.withOpacity(0.5),
                        blurRadius: isLowTime ? 5 : 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
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
