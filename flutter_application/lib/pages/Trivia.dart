import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'dart:async';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  _TriviaPageState createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  final List<Map<String, dynamic>> questions = [
    {
      "category": "Technology",
      "title": "What was the first product launched by Apple?",
      "options": ["iPhone", "iPad", "Apple I", "iPod"],
      "answer": "Apple I",
      "hint":
          "Steve Wozniak and Steve Jobs sold 50 pieces of this at a price of US\$666.66.",
      "remainingTime": 20, // Timer for this question
    },
    {
      "category": "Science",
      "title": "What is the chemical symbol for water?",
      "options": ["O2", "H2O", "CO2", "H2"],
      "answer": "H2O",
      "hint": "It consists of two hydrogen atoms and one oxygen atom.",
      "remainingTime": 20, // Timer for this question
    },
    {
      "category": "Mathematics",
      "title": "What is the value of pi (π) up to two decimal points?",
      "options": ["3.12", "3.14", "3.16", "3.18"],
      "answer": "3.14",
      "hint": "It starts with 3 and is a famous irrational number.",
      "remainingTime": 20, // Timer for this question
    },
  ];

  int _currentIndex = 0;
  final int _totalTime = 20; // Total time for the countdown
  final CardSwiperController _controller = CardSwiperController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startQuestionTimer(_currentIndex);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startQuestionTimer(int index) {
    // Cancel any existing timer
    _timer?.cancel();

    // Start a new timer for the current question
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (questions[index]["remainingTime"] > 0) {
          questions[index]["remainingTime"]--;
        } else {
          _timer?.cancel();
          // Handle timeout logic here
        }
      });
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
                image: AssetImage('assets/images/backgrounds/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Card Swiper
                Flexible(
                  child: CardSwiper(
                    controller: _controller,
                    cardsCount: questions.length,
                    numberOfCardsDisplayed: 2,
                    onSwipe: _onSwipe,
                    backCardOffset: const Offset(0, 40),
                    padding: const EdgeInsets.only(top: 25),
                    allowedSwipeDirection:
                        const AllowedSwipeDirection.only(up: true),
                    threshold: 10,
                    maxAngle: 20,
                    scale: 0.9,
                    cardBuilder: (context, index, _, __) =>
                        _buildQuestionCard(context, index, screenSize),
                  ),
                ),
                const SizedBox(height: 10),
                // Hint Section (Translucent Bubble)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                              questions[_currentIndex]["hint"],
                              style: TextStyle(
                                color: Colors.white.withOpacity(.85),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, int index, Size screenSize) {
    final question = questions[index];
    final int remainingTime = question["remainingTime"] ??
        _totalTime; // Default to _totalTime if null
    final double progress = remainingTime / _totalTime;

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.66,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 46, 46, 46),
              Color.fromARGB(255, 26, 26, 26),
              Color.fromARGB(255, 20, 20, 20),
            ],
          ),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Question Count (Top Left)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: const Icon(Icons.question_mark_rounded,
                            size: 12, color: Color.fromARGB(255, 43, 43, 43)),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${index + 1}/${questions.length}',
                        style: const TextStyle(
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
                    key: ValueKey(
                        _currentIndex), // Add a unique key to force rebuild
                    tween: Tween<double>(
                      begin: 1.0, // Start progress as full
                      end: progress, // Current progress
                    ),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.greenAccent,
                          ),
                        ),
                      );
                    },
                  ),
                  Text(
                    '$remainingTime',
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
              question["category"],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              question["title"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            // Answer Options
            ...question["options"].map<Widget>((option) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Container(
                  height: screenSize.height * 0.06,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 0.5,
                        color: Colors.white.withOpacity(0.85)), // Grey border
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                    color: Colors.transparent, // Transparent background
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      elevation: 0, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Match border radius
                      ),
                    ),
                    onPressed: () {
                      // Handle option selection
                    },
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (currentIndex != null) {
      setState(() {
        _startQuestionTimer(currentIndex);
        _currentIndex = currentIndex;
      });
    }
    return true;
  }
}
