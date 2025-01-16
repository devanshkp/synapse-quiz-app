import 'package:flutter/material.dart';
import 'package:flutter_application/utility/colors.dart';
import 'dart:async';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  _TriviaPageState createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  late Timer _timer;
  int _remainingTime = 20; // Total countdown time in seconds
  final int _totalTime = 20; // Total time for the countdown

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        // Handle the timeout logic here (e.g., move to the next question)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/mesh.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  // Question Card
                  Container(
                    width: screenSize.width * 0.9,
                    height: screenSize.height * 0.66,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 46, 46, 46),
                            Color.fromARGB(255, 26, 26, 26),
                            Color.fromARGB(255, 20, 20, 20),
                          ]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Row (Question Count and Timer)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Question Count (Top Left)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    child: const Icon(
                                        Icons.question_mark_rounded,
                                        size: 12,
                                        color: Color.fromARGB(255, 43, 43, 43)),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    '4/10',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Timer with Countdown
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 1.0, // Start progress
                                  end: _remainingTime /
                                      _totalTime, // Current progress
                                ),
                                duration: const Duration(
                                    seconds: 1), // Smooth transition duration
                                builder: (context, value, child) {
                                  return SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CircularProgressIndicator(
                                      value: value, // Smooth progress value
                                      strokeWidth: 3,
                                      backgroundColor: Colors.grey[800],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.greenAccent),
                                    ),
                                  );
                                },
                              ),
                              Text(
                                '$_remainingTime',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Question Text
                        Text(
                          'Technology',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'What was the first product launched by Apple?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Answer Options
                        ...['iPhone', 'iPad', 'Apple I', 'iPod'].map(
                          (option) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            child: Container(
                              height: screenSize.height *
                                  0.06, // Proportional height (8% of the parent height)
                              width: double
                                  .infinity, // Stretch to fill the parent width
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: .5,
                                    color: Colors.white
                                        .withOpacity(0.85)), // Grey border
                                borderRadius: BorderRadius.circular(
                                    25), // Rounded corners
                                color: Colors
                                    .transparent, // Transparent background
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0, // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Match border radius
                                  ),
                                ),
                                onPressed: () {
                                  // Add button action here
                                },
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Hint Section (Translucent Bubble)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.white, size: 30),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HINT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Steve Wozniak and Steve Jobs sold 50 pieces of this at a price of US\$666.66',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(.85),
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
