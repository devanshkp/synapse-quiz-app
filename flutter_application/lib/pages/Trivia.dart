import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'dart:async';
import 'package:string_extensions/string_extensions.dart';
import 'package:flutter_application/colors.dart';
import 'package:rxdart/rxdart.dart';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});
  @override
  _TriviaPageState createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _totalTime = 1000;
  Timer? _timer;
  bool _answered = false;
  String _selectedAnswer = '';
  Map<String, dynamic>? _currentUserData;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _panelController = PublishSubject<DragEndDetails>();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    setDrawerAnimationSpeed(const Duration(milliseconds: 150));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    _panelController
        .throttleTime(const Duration(milliseconds: 200))
        .listen((details) {
      if (details.primaryVelocity! > 0) {
        setState(() {
          if (!_sliderDrawerKey.currentState!.isDrawerOpen) {
            _sliderDrawerKey.currentState?.openSlider();
          }
        });
      } else if (details.primaryVelocity! < 0) {
        if (_sliderDrawerKey.currentState!.isDrawerOpen) {
          _sliderDrawerKey.currentState?.closeSlider();
        } else {
          _excludeTopic(); // Call exclude topic, no need for the extra setState
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _panelController.close();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Helper function to set animation speed
  void setDrawerAnimationSpeed(Duration duration) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _sliderDrawerKey
          .currentState?.animationController.duration = duration);

  Future<void> _loadQuestions() async {
    User? user = _auth.currentUser;
    _isLoading = true;
    setState(() {});

    // Add pre-loaded questions for testing
    _questions = [
      {
        'question': 'What is the capital of France?',
        'options': ['Berlin', 'Paris', 'Madrid', 'Rome'],
        'answer': 'b',
        'explanation': 'Paris is the capital and most populous city of France.',
        'topic': 'probability_&_statistics',
        'subtopic': 'European Capitals',
        'hint': ''
      },
      {
        'question': 'What is the highest mountain in the world?',
        'options': ['K2', 'Kangchenjunga', 'Mount Everest', 'Lhotse'],
        'answer': 'c',
        'explanation':
            'Mount Everest is the Earth\'s highest mountain above sea level.',
        'topic': 'data_structures',
        'subtopic': 'Mountains',
        'hint': ''
      },
      // Add more test questions as needed...
      {
        'question': 'What is the capital of Germany?',
        'options': ['Berlin', 'Munich', 'Hamburg', 'Cologne'],
        'answer': 'a',
        'explanation': 'Berlin is the capital and largest city of Germany.',
        'topic': 'swe_fundamentals',
        'subtopic': 'European Capitals',
        'hint': ''
      },
      {
        'question': 'What is the largest planet in our solar system?',
        'options': ['Mars', 'Venus', 'Jupiter', 'Saturn'],
        'answer': 'c',
        'explanation': 'Jupiter is the largest planet in our solar system.',
        'topic': 'probability_&_statistics',
        'subtopic': 'Planets',
        'hint': ''
      },
    ];

    _questions.shuffle(); // Shuffle the test questions

    if (_questions.length > 50) {
      _questions = _questions.sublist(0, 50);
    }

    _startQuestionTimer(); // Start the timer immediately with test data
    _isLoading = false;
    setState(() {});

    return; // Exit the function early after adding test questions

    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      _currentUserData = userDoc.data() as Map<String, dynamic>?;
      if (_currentUserData != null &&
          _currentUserData!.containsKey('selectedCategories')) {
        List<String> selectedCategories =
            List<String>.from(_currentUserData!['selectedCategories'] as List);
        QuerySnapshot querySnapshot = await _firestore
            .collection('questions')
            .where('topic', whereIn: selectedCategories)
            .get();
        _questions = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _questions.shuffle();
        if (_questions.length > 50) {
          _questions = _questions.sublist(0, 50);
        }
        if (_questions.isNotEmpty) {
          _startQuestionTimer();
        }
      }
    }
    _isLoading = false;
    setState(() {});
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTime > 0) {
        setState(() {
          _totalTime--;
        });
      } else {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      if (_sliderDrawerKey.currentState!.isDrawerOpen) {
        _sliderDrawerKey.currentState?.closeSlider();
      }
      _answered = true;
      _selectedAnswer = '';
    });
    _updateQuestionData(false);
  }

  void _handleAnswer(String selectedOption) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedAnswer = selectedOption;
    });
    String correctAnswerKey = _questions[_currentIndex]['answer'];
    String correctAnswer = _questions[_currentIndex]['options']
        [correctAnswerKey.toLowerCase().codeUnitAt(0) - 97];
    bool isCorrect = selectedOption == correctAnswer;
    _updateQuestionData(isCorrect);
  }

  Future<void> _updateQuestionData(bool isCorrect) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      WriteBatch batch = _firestore.batch();
      if (isCorrect) {
        batch.update(userRef, {'questionsSolved': FieldValue.increment(1)});
      }
      batch.update(userRef, {
        'encounteredQuestions':
            FieldValue.arrayUnion([_questions[_currentIndex]['question']])
      });
      await batch.commit();
    }
  }

  void _nextQuestion() {
    if (_sliderDrawerKey.currentState!.isDrawerOpen) {
      _sliderDrawerKey.currentState?.closeSlider();
    }
    _timer?.cancel();
    _answered = false;
    _selectedAnswer = '';

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _startQuestionTimer();
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _excludeTopic() async {
    if (_currentUserData != null &&
        _currentUserData!.containsKey('selectedCategories')) {
      List<String> updatedCategories =
          List<String>.from(_currentUserData!['selectedCategories'] as List);
      String currentTopic = _questions[_currentIndex]['topic'];
      updatedCategories.remove(currentTopic);
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'selectedCategories': updatedCategories,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Topic "$currentTopic" has been excluded')),
      );
      _loadQuestions();
    }
  }

  String formatTopic(String topic) {
    return topic.replaceAll('_', ' ').toTitleCase;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: cardGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
        ),
      );
    } else if (_questions.isEmpty && _currentUserData != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: cardGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.question_mark, size: 60, color: Colors.grey[600]),
                const SizedBox(height: 20),
                Text(
                  "No questions available in selected categories.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SliderDrawer(
          appBar: const SizedBox(),
          slider: _buildDrawer(_questions[_currentIndex]),
          key: _sliderDrawerKey,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              _panelController.add(details);
            },
            child: Container(
              decoration: const BoxDecoration(
                gradient: cardGradient,
                // image: DecorationImage(
                //   image: AssetImage(
                //       'assets/subtle_pattern.png'), // Add this pattern asset
                //   opacity: 0.05,
                //   repeat: ImageRepeat.repeat,
                // ),
              ),
              child: Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: _currentIndex / (_questions.length - 1),
                    backgroundColor: Colors.black12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white30),
                    minHeight: 3,
                  ),

                  Expanded(
                    child: PageView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      itemCount: _questions.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _answered = false;
                          _selectedAnswer = '';
                          _startQuestionTimer();
                        });
                        _animationController.reset();
                        _animationController.forward();
                      },
                      itemBuilder: (context, index) {
                        final question = _questions[index];
                        String correctAnswerKey = question['answer'];
                        String correctAnswer = question['options']
                            [correctAnswerKey.toLowerCase().codeUnitAt(0) - 97];

                        return Stack(
                          children: [
                            // Main question area
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 40),

                                    // Topic, subtopic and timer
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (question.containsKey('subtopic') &&
                                            question['subtopic'] != null)
                                          _buildQuestionTimer(_totalTime),
                                        const SizedBox(height: 20),
                                        Column(
                                          children: [
                                            Text(
                                              '${question['subtopic']}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                          ],
                                        ),
                                        Text(
                                          formatTopic(question['topic'])
                                                  .isNotEmpty
                                              ? formatTopic(question['topic'])
                                              : 'Unknown',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[400],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 30),

                                    // Question text with card styling
                                    Card(
                                      elevation: 8,
                                      shadowColor: Colors.black45,
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.1),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          question['question'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 30),

                                    // Options
                                    ...question['options']
                                        .map<Widget>((option) {
                                      bool isCorrectOption =
                                          option == correctAnswer;
                                      bool isSelected =
                                          option == _selectedAnswer;
                                      Color buttonColor =
                                          Colors.white.withOpacity(0.1);

                                      if (_answered) {
                                        if (isCorrectOption) {
                                          buttonColor =
                                              Colors.green.withOpacity(0.7);
                                        } else if (isSelected) {
                                          buttonColor =
                                              Colors.red.withOpacity(0.7);
                                        }
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: _buildOptionButton(
                                          option,
                                          isCorrectOption,
                                          isSelected,
                                          buttonColor,
                                        ),
                                      );
                                    }).toList(),

                                    const Spacer(),

                                    // Hint text

                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Text(
                                        _answered
                                            ? "Swipe right to see explanation"
                                            : "Swipe right for hint, left to exclude topic",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),

                                    // Next button when question is answered
                                    _buildBottomButton(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    String option,
    bool isCorrectOption,
    bool isSelected,
    Color buttonColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _handleAnswer(option),
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
            side: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            option,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return _answered ? _buildNextButton() : _buildSkipButton();
  }

  Widget _buildSkipButton() {
    return ElevatedButton(
      onPressed: _nextQuestion,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Colors.orange.withOpacity(0.8), // Different color for skip
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.4),
      ), // Same function for both buttons
      child: const Text("Skip Question"),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton.icon(
      onPressed: _nextQuestion,
      icon: const Icon(Icons.arrow_forward),
      label: const Text('Next Question'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.withOpacity(0.8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
    );
  }

  Widget _buildDrawer(Map<String, dynamic> question) {
    // Modified Drawer Content
    return Container(
      color: Colors.black.withOpacity(0.95),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _answered ? 'Explanation' : 'Hint',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white30),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _answered
                    ? (question['explanation'] ?? 'No explanation available.')
                    : (question['hint'] ?? 'No hint available.'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  SizedBox _buildQuestionTimer(int duration) {
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
              tween: Tween<double>(begin: 1.0, end: 0.0),
              duration: Duration(seconds: duration),
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _totalTime < 5 ? Colors.redAccent : Colors.greenAccent,
                  ),
                );
              },
            ),
          ),
          Center(
            child: TweenAnimationBuilder<int>(
              tween: IntTween(begin: duration, end: 0),
              duration: Duration(seconds: duration),
              builder: (context, value, child) {
                return Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
