import 'package:flutter/material.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/services/observer_service.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:flutter_application/widgets/trivia/question_timer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/utils/text_formatter.dart';
import 'package:flutter_application/widgets/trivia/bottom_buttons.dart';
import 'package:flutter_application/widgets/trivia/trivia_drawer.dart';
import 'package:flutter_application/widgets/trivia/option_button.dart';
import 'dart:math';

class TriviaPage extends StatefulWidget {
  final String topic;
  final bool quickPlay;
  final bool isTemporarySession;
  const TriviaPage({
    super.key,
    this.topic = '',
    this.quickPlay = false,
    this.isTemporarySession = false,
  });

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
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
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
      duration: const Duration(milliseconds: 400),
    );

    // Create a sequence of animations for a snappier feel
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.02).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 100,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 100,
      ),
    ]).animate(_animationController);

    // Add a slide animation for more dynamic entry
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _topicAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _closeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _topicAnimationController.dispose();
    _closeAnimController.dispose();

    // Use a microtask to ensure state updates happen after disposal
    Future.microtask(() {
      _triviaProvider.setTriviaActive(false);

      // End temporary session if active
      if (widget.isTemporarySession && _triviaProvider.isTemporarySession) {
        _triviaProvider.endTemporarySession(widget.topic);
      }
    });

    ObserverService.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _triviaProvider.setTriviaActive(false,
          temporarySession: widget.isTemporarySession);
    } else if (state == AppLifecycleState.resumed) {
      _triviaProvider.setTriviaActive(true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
    ObserverService.routeObserver.subscribe(this, ModalRoute.of(context)!);

    // Initialize temporary topic session if needed
    if (widget.isTemporarySession && widget.topic.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _triviaProvider.startTemporarySession(widget.topic);

        // Add a safety timeout to prevent infinite loading
        Future.delayed(const Duration(seconds: 30), () {
          if (_triviaProvider.isLoadingQuestions && mounted) {
            debugPrint(
                "Safety timeout triggered - forcing loading state to false");
            _triviaProvider.forceLoadingComplete();
          }
        });
      });
    }
  }

  @override
  void didPush() {
    _triviaProvider.setTriviaActive(true);
  }

  @override
  void didPop() {
    // End temporary session when navigating back
    if (widget.isTemporarySession && _triviaProvider.isTemporarySession) {
      // Use a microtask to ensure this runs after the current frame
      Future.microtask(() {
        _triviaProvider.endTemporarySession(widget.topic);
      });
    }
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
          _triviaProvider.excludeTopic(context);
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
    // First, animate out the current question
    _animationController.reverse().then((_) {
      // Update the question index
      _triviaProvider.nextQuestion();
      _advancedDrawerController.hideDrawer();

      // Animate to the next page without animation (since we're handling it ourselves)
      _pageController.jumpToPage(_triviaProvider.currentIndex);

      // Animate in the new question
      _animationController.forward();
    });
  }

  // ============================== WIDGETS BUILDING ==============================

  @override
  Widget build(BuildContext context) {
    return Consumer<TriviaProvider>(
      builder: (context, triviaProvider, child) {
        if (triviaProvider.isLoadingQuestions) {
          return _buildLoadingScreen();
        }

        if (triviaProvider.selectedTopics.isEmpty) {
          return _buildEmptyState(topicsEmpty: true);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomCircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Loading questions...",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool topicsEmpty = false}) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: cardGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                topicsEmpty
                    ? Icons.question_mark_rounded
                    : Icons.warning_rounded,
                size: 60,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 20),
              Text(
                topicsEmpty
                    ? "No topics selected at the moment."
                    : "No questions available in selected categories.",
                style: TextStyle(
                  fontSize: 16,
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
                        child: _buildQuestionPageView(triviaProvider),
                      ),
                      if (widget.quickPlay || widget.isTemporarySession)
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
              if (_drawerOffset > 0 && _iconAnimationValue > 0)
                Positioned.fill(
                  child: Stack(
                    children: [
                      // Animated background
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: _drawerOffset,
                        child: AnimatedBuilder(
                          animation: _topicAnimationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _iconAnimationValue,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.red.shade600,
                                      Colors.red.shade800,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.red.shade900.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Animated pattern overlay
                                    Positioned.fill(
                                      child: Opacity(
                                        opacity: 0.1,
                                        child: Image.asset(
                                          'assets/images/shapes.png',
                                          repeat: ImageRepeat.repeat,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // Center content
                                    Center(
                                      child: Opacity(
                                        opacity:
                                            _topicAnimationController.value,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Icon with immediate scaling based on drag
                                            Transform.scale(
                                              scale: 0.6 +
                                                  (0.4 *
                                                      (_dragExtent /
                                                              _swipeThreshold)
                                                          .clamp(0.0, 1.0)),
                                              child: Icon(
                                                Icons
                                                    .remove_circle_outline_rounded,
                                                color: Colors.white,
                                                size: 32 *
                                                    _topicAnimationController
                                                        .value,
                                              ),
                                            ),
                                            SizedBox(
                                                width: 10 *
                                                    _topicAnimationController
                                                        .value),
                                            // Text with fade animation
                                            Text(
                                              'Exclude Topic',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17 *
                                                    _topicAnimationController
                                                        .value,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 4,
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
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
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _animationController.value,
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
                        const Spacer(flex: 1)
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
        if (question.containsKey('subtopic') &&
            question['subtopic'] != null) ...[
          const SizedBox(height: 7.5),
          Text(
            '${question['subtopic']}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Create a bouncy effect for the card
        final cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.1, 0.5, curve: Curves.easeOutBack),
          ),
        );

        return Transform.scale(
          scale: 0.8 + (0.2 * cardAnimation.value),
          child: Card(
            elevation: 8 * cardAnimation.value,
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
                    Colors.white.withOpacity(0.085 * cardAnimation.value),
                    Colors.white.withOpacity(0.05 * cardAnimation.value),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black12.withOpacity(cardAnimation.value * 0.12),
                    blurRadius: 10 * cardAnimation.value,
                    spreadRadius: 1 * cardAnimation.value,
                  ),
                ],
              ),
              child: TextFormatter.formatText(
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
          ),
        );
      },
    );
  }

  Widget _buildOptions(
      TriviaProvider triviaProvider, Map<String, dynamic> question) {
    final options = question['options'];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: List.generate(options.length, (i) {
            // Stagger the animations for each option
            final delay = i * 0.1;
            final startInterval = 0.2 + delay;
            final endInterval = min(1.0, startInterval + 0.3);

            final optionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(startInterval, endInterval,
                    curve: Curves.easeOutCubic),
              ),
            );

            final option = options[i];
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

            return Transform.translate(
              offset: Offset(30.0 * (1.0 - optionAnimation.value), 0),
              child: Opacity(
                opacity: optionAnimation.value,
                child: Padding(
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
                ),
              ),
            );
          }),
        );
      },
    );
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
