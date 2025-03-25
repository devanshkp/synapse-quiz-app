import 'package:flutter/material.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/services/observer_service.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
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

  bool _movingToNextQuestion = false;
  // Drawer State
  final double _drawerOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addObserver(this);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Simplified scale animation with a subtle effect
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );

    // Simplified slide animation with minimal movement
    _slideAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );

    _topicAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _topicAnimationController.dispose();

    if (widget.isTemporarySession && _triviaProvider.isTemporarySession) {
      Future.microtask(() {
        debugPrint("ending temporary session");
        _triviaProvider.endTemporarySession(widget.topic);
      });
    }
    ObserverService.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
    ObserverService.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);

    if (widget.isTemporarySession) {
      debugPrint("starting temp session");
      _triviaProvider.startTemporarySession(widget.topic);
    }

    Future.delayed(const Duration(seconds: 30), () {
      _triviaProvider.forceLoadingComplete();
    });
  }

  @override
  void didPush() {
    if (widget.quickPlay) _triviaProvider.setTriviaActive(true);
  }

  @override
  void didPop() {
    if (widget.quickPlay) _triviaProvider.setTriviaActive(false);
  }

  // ============================== QUESTION LOGIC ==============================

  void handleNextQuestion() {
    if (_movingToNextQuestion) {
      return;
    }

    _movingToNextQuestion = true;

    // Use a faster reverse animation for a cleaner transition
    _animationController.reverse(from: 1.0).then((_) {
      // Update the question index
      _triviaProvider.nextQuestion();
      _advancedDrawerController.hideDrawer();

      _movingToNextQuestion = false;

      // Animate in the new question
      _animationController.forward(from: 0.0);
    });
  }

  // ============================== WIDGETS BUILDING ==============================

  @override
  Widget build(BuildContext context) {
    return Consumer<TriviaProvider>(
      builder: (context, triviaProvider, child) {
        if (triviaProvider.isStartingSession) {
          return _buildLoadingScreen(message: "Starting session...");
        }
        // Second check: Are we still loading topics? Show loading screen if true
        if (triviaProvider.isLoadingTopics) {
          return _buildLoadingScreen(message: "Loading topics...");
        }

        // Third check: No topics selected? Show empty state
        if (triviaProvider.selectedTopics.isEmpty) {
          return _buildEmptyState(topicsEmpty: true);
        }

        // Fourth check: Are we loading questions?
        if (triviaProvider.isLoadingQuestions ||
            triviaProvider.isFetchingQuestions) {
          return _buildLoadingScreen(message: "Loading questions...");
        }

        // Fifth check: No questions available for the selected topics
        if (triviaProvider.questions.isEmpty) {
          return _buildEmptyState();
        }

        // All checks passed, show the main trivia page
        return _buildTriviaPage(triviaProvider);
      },
    );
  }

  Widget _buildLoadingScreen({String message = "Loading questions..."}) {
    return PopScope(
      canPop: false,
      child: AbsorbPointer(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: cardGradient),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomCircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
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
                    : "No questions available in selected topics.",
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    double drawerOpenRatio;
    if (screenWidth < 800) {
      drawerOpenRatio = .5;
    } else if (screenWidth < 1000) {
      drawerOpenRatio = .4;
    } else {
      drawerOpenRatio = .35;
    }
    return Scaffold(
      body: SafeArea(
        child: Transform.translate(
          offset: Offset(0, _drawerOffset),
          child: AdvancedDrawer(
            drawer: TriviaDrawer(
              key: _drawerKey,
              question: triviaProvider.currentQuestion,
              isAnswered: triviaProvider.answered,
              onNextQuestion: handleNextQuestion,
            ),
            controller: _advancedDrawerController,
            animationDuration: const Duration(milliseconds: 200),
            openRatio: isTablet ? drawerOpenRatio : .65,
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
      ),
    );
  }

  Widget _buildQuestionPageView(TriviaProvider triviaProvider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildQuestionPage(triviaProvider),
    );
  }

  Widget _buildQuestionPage(TriviaProvider triviaProvider) {
    final question = triviaProvider.currentQuestion;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final needsScrolling = MediaQuery.sizeOf(context).height <= 700;
    final double extraPadding =
        (screenWidth < 1000) ? screenWidth * .1 : screenWidth * .2;

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
                    child: needsScrolling
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: _buildQuestionContent(
                              triviaProvider,
                              question,
                              isTablet,
                              extraPadding,
                              useFixedSpacing: true,
                            ),
                          )
                        : _buildQuestionContent(
                            triviaProvider,
                            question,
                            isTablet,
                            extraPadding,
                            useFixedSpacing: false,
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

  Widget _buildQuestionContent(
    TriviaProvider triviaProvider,
    Map<String, dynamic> question,
    bool isTablet,
    double extraPadding, {
    required bool useFixedSpacing,
  }) {
    return Stack(
      children: [
        if (!widget.isTemporarySession) ...[
          Positioned(
            top: 0,
            right: 0,
            child: buildTopicsCounter(triviaProvider),
          ),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (useFixedSpacing) const SizedBox(height: 20) else const Spacer(),
            _buildQuestionHeader(triviaProvider, question),
            if (useFixedSpacing) const SizedBox(height: 20) else const Spacer(),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isTablet ? extraPadding : 0),
              child: _buildQuestionCard(question),
            ),
            if (useFixedSpacing) const SizedBox(height: 20) else const Spacer(),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isTablet ? extraPadding : 0),
              child: buildOptions(triviaProvider, question),
            ),
            if (useFixedSpacing)
              const SizedBox(height: 20)
            else
              const Spacer(flex: 3),
            buildFooter(triviaProvider),
            const SizedBox(height: 7.5),
          ],
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
          isTimerRunning: triviaProvider.isTimerRunning,
          totalTime: TriviaProvider.totalTime,
        ),
        const SizedBox(height: 17.5),
        Text(
          TextFormatter.formatTitlePreservingCase(question['topic'].toString()),
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
        // Simplified card animation with minimal scaling
        final cardAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutQuint,
        );

        return Transform.scale(
          scale: 0.95 + (0.05 * cardAnimation.value),
          child: Material(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () {
                showFullQuestionDialog(context, question);
              },
              splashColor: Colors.white.withValues(alpha: 0.1),
              highlightColor: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withValues(alpha: 0.08),
                      blurRadius: 8 * cardAnimation.value,
                      spreadRadius: 0.5 * cardAnimation.value,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: TextFormatter.formatText(
                          maxLines: 4,
                          question['question'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Add a subtle indicator to show the card is tappable
                    const Positioned(
                      right: 10,
                      bottom: 10,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white54,
                        size: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to show the full question in a popup dialog
  void showFullQuestionDialog(
      BuildContext context, Map<String, dynamic> question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 40, 40, 40),
                  Color.fromARGB(255, 25, 25, 25),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question text
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: TextFormatter.formatText(
                      maxLines: 100,
                      question['question'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Close button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildOptions(
      TriviaProvider triviaProvider, Map<String, dynamic> question) {
    final options = question['options'];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: List.generate(options.length, (i) {
            // More subtle staggered animations with consistent timing
            final delay = i * 0.05;
            final startInterval = 0.1 + delay;
            final endInterval = min(1.0, startInterval + 0.2);

            final optionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(startInterval, endInterval,
                    curve: Curves.easeOutQuint),
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

            // Reduced horizontal movement for cleaner appearance
            return Transform.translate(
              offset: Offset(15.0 * (1.0 - optionAnimation.value), 0),
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

  Widget buildFooter(TriviaProvider triviaProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            triviaProvider.answered
                ? "Swipe right for explanation"
                : "Swipe right for hint",
            style: const TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
        ),
        BottomButtons(
          answered: triviaProvider.answered,
          onNextQuestion: handleNextQuestion,
        ),
      ],
    );
  }

  // Build topics counter widget
  Widget buildTopicsCounter(TriviaProvider triviaProvider) {
    final int topicsCount = triviaProvider.selectedTopics.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category_rounded,
            color: Colors.white.withValues(alpha: 0.9),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$topicsCount ${topicsCount == 1 ? 'Topic' : 'Topics'}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
