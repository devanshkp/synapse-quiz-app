import 'package:flutter/material.dart';
import 'package:flutter_application/services/observer_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import '../providers/trivia_provider.dart';
import '../widgets/trivia/bottom_buttons.dart';
import '../widgets/trivia/trivia_drawer.dart';
import '../widgets/trivia/option_button.dart';
import '../widgets/trivia/question_timer.dart';
import '../colors.dart';

class TriviaPage extends StatefulWidget {
  final bool topicSpecified;
  final bool quickPlay;
  const TriviaPage(
      {super.key, this.topicSpecified = false, this.quickPlay = false});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage>
    with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  // Controllers
  late TriviaProvider _triviaProvider;
  final _pageController = PageController();
  final _advancedDrawerController = AdvancedDrawerController();
  final _drawerKey = GlobalKey<TriviaDrawerState>();

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _topicAnimationController;
  late AnimationController _closeAnimController;

  // Swipe and Drawer State
  double _iconAnimationValue = 1.0;
  double _dragExtent = 0.0;
  final double _swipeThreshold = 100.0;
  double _drawerOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addObserver(this);
  }

  void _initializeAnimations() {
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

    _topicAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _closeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _topicAnimationController.dispose();
    _closeAnimController.dispose();
    _triviaProvider.setTriviaActive(false);
    ObserverService.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _triviaProvider.setTriviaActive(false);
    } else if (state == AppLifecycleState.resumed) {
      _triviaProvider.setTriviaActive(true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
    ObserverService.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPush() {
    debugPrint("pushed");
    _triviaProvider.setTriviaActive(true);
  }

  // ============================== SWIPE GESTURE HANDLERS ==============================

  void _onDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null && details.primaryDelta! > 0) {
      setState(() {
        _dragExtent += details.primaryDelta!;
        _drawerOffset = _dragExtent.clamp(0.0, _swipeThreshold);
        _topicAnimationController.value =
            (_drawerOffset / _swipeThreshold).clamp(0.0, 1.0);
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragExtent.abs() > _swipeThreshold) {
      _handleTopicExclusion();
    } else {
      _resetDragState();
    }
  }

  void _handleTopicExclusion() {
    // First complete the animation to the threshold
    _topicAnimationController.forward().then((_) {
      final startOffset = _drawerOffset;

      _closeAnimController.reset();

      Animation<double> closeAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _closeAnimController,
          curve: Curves.easeOutQuint,
        ),
      );

      // Update the drawer offset and icon animation value during the animation
      _closeAnimController.addListener(() {
        setState(() {
          _drawerOffset = startOffset * closeAnimation.value;
          _iconAnimationValue = closeAnimation.value;
        });
      });

      // Clean up when animation is done
      _closeAnimController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _dragExtent = 0.0;
            _drawerOffset = 0.0;
            _iconAnimationValue = 1.0;
          });
          _topicAnimationController.reset();

          debugPrint("excluded");
        }
      });

      _closeAnimController.forward();
    });
  }

  void _resetDragState() {
    // For smaller drags, animate back to original position
    final startOffset = _drawerOffset;
    _closeAnimController.reset();

    Animation<double> closeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _closeAnimController,
        curve: Curves.easeOut,
      ),
    );

    _closeAnimController.addListener(() {
      setState(() {
        _drawerOffset = startOffset * closeAnimation.value;
        _iconAnimationValue = closeAnimation.value;
      });
    });

    _closeAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dragExtent = 0.0;
          _drawerOffset = 0.0;
          _iconAnimationValue = 1.0;
        });
        _topicAnimationController.reset();
      }
    });

    _closeAnimController.forward();
  }

  // ============================== QUESTION LOGIC ==============================

  void _handleNextQuestion() {
    _triviaProvider.nextQuestion();
    _advancedDrawerController.hideDrawer();

    // Animate to the next page
    _pageController.animateToPage(
      _triviaProvider.currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Reset the fade animation
    _animationController.reset();
    _animationController.forward();
  }

  // ============================== WIDGETS BUILDING ==============================

  @override
  Widget build(BuildContext context) {
    return Consumer<TriviaProvider>(
      builder: (context, triviaProvider, child) {
        if (triviaProvider.isLoadingQuestions) {
          return _buildLoadingScreen();
        }

        if (triviaProvider.questions.isEmpty) {
          return _buildEmptyState();
        }

        return _buildTriviaPage(triviaProvider);
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: cardGradient),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: cardGradient),
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

  Widget _buildTriviaPage(TriviaProvider triviaProvider) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: Stack(
            children: [
              Transform.translate(
                offset: Offset(0, _drawerOffset),
                child: AdvancedDrawer(
                  drawer: TriviaDrawer(
                    key: _drawerKey,
                    question: triviaProvider.currentQuestion,
                    isAnswered: triviaProvider.answered,
                    onNextQuestion: _handleNextQuestion,
                  ),
                  controller: _advancedDrawerController,
                  animationDuration: const Duration(milliseconds: 200),
                  openRatio: .65,
                  initialDrawerScale: .95,
                  backdropColor: drawerColor,
                  openScale: 1,
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: cardGradient,
                          image: DecorationImage(
                            image: AssetImage('assets/images/shapes.png'),
                            opacity: 0.25,
                            repeat: ImageRepeat.repeat,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProgressIndicator(triviaProvider),
                            Expanded(
                              child: _buildQuestionPageView(triviaProvider),
                            ),
                          ],
                        ),
                      ),
                      if (widget.quickPlay)
                        Positioned(
                          top: 20,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Red background that appears during swipe
              if (_drawerOffset > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _drawerOffset,
                  child: AnimatedBuilder(
                    animation: _topicAnimationController,
                    builder: (context, child) {
                      const maxIconSize = 40;
                      final iconSize = maxIconSize *
                          _topicAnimationController.value *
                          _iconAnimationValue;
                      return Container(
                        color: Colors.red,
                        child: Opacity(
                          opacity: _topicAnimationController.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                color: Colors.white,
                                size: iconSize,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(TriviaProvider triviaProvider) {
    if (triviaProvider.questions.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget if no questions
    }

    double progressValue = triviaProvider.questions.length > 1
        ? triviaProvider.currentIndex / (triviaProvider.questions.length - 1)
        : 1.0; // If only one question, progress is always 100%

    return LinearProgressIndicator(
      value: progressValue,
      backgroundColor: Colors.black12,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white30),
      minHeight: 3,
    );
  }

  Widget _buildQuestionPageView(TriviaProvider triviaProvider) {
    return PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      itemCount: triviaProvider.questions.length,
      onPageChanged: (index) {
        _animationController.reset();
        _animationController.forward();
      },
      itemBuilder: (context, index) {
        return _buildQuestionPage(triviaProvider, triviaProvider.currentIndex);
      },
    );
  }

  Widget _buildQuestionPage(TriviaProvider triviaProvider, int index) {
    final question = triviaProvider.questions[index];

    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                _buildQuestionHeader(triviaProvider, question),
                const Spacer(),
                _buildQuestionCard(question),
                const Spacer(),
                _buildOptions(triviaProvider, question),
                const Spacer(),
                _buildFooter(triviaProvider),
                if (widget.quickPlay) const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(
      TriviaProvider triviaProvider, Map<String, dynamic> question) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QuestionTimer(
          timeNotifier: triviaProvider.timeNotifier,
          totalTime: TriviaProvider.totalTime,
        ),
        const SizedBox(height: 17.5),
        Text(
          triviaProvider.formatTopic(question['topic']),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        if (question.containsKey('subtopic') && question['subtopic'] != null)
          Column(
            children: [
              const SizedBox(height: 7.5),
              Text(
                '${question['subtopic']}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
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
              Colors.white.withOpacity(0.085),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOptions(
      TriviaProvider triviaProvider, Map<String, dynamic> question) {
    return Column(
        children: question['options'].map<Widget>((option) {
      bool isCorrectOption = option == triviaProvider.correctAnswer;
      bool isSelected = option == triviaProvider.selectedAnswer;
      Color? buttonColor = const Color(0xff262626);

      if (triviaProvider.answered) {
        if (isCorrectOption) {
          buttonColor = Colors.green[400];
        } else if (isSelected) {
          buttonColor = Colors.red[600];
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: OptionButton(
          option: option,
          isCorrectOption: isCorrectOption,
          isSelected: isSelected,
          buttonColor: buttonColor,
          onPressed: triviaProvider.answered
              ? null
              : () => _triviaProvider.handleAnswer(option),
        ),
      );
    }).toList());
  }

  Widget _buildFooter(TriviaProvider triviaProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            triviaProvider.answered
                ? "Swipe right to see explanation"
                : "Swipe right for hint, left to exclude topic",
            style: const TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
        ),
        BottomButtons(
          answered: triviaProvider.answered,
          onNextQuestion: _handleNextQuestion,
        ),
      ],
    );
  }
}
